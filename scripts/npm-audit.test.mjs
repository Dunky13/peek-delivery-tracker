import assert from 'node:assert/strict';
import { once } from 'node:events';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { describe, it } from 'node:test';
import { audit, classify } from './npm-audit.mjs';

// What npm audit --json prints, cut down.
const report = (vulnerabilities = {}) => JSON.stringify({ auditReportVersion: 2, vulnerabilities,
  metadata: { vulnerabilities: { info: 0, low: 0, moderate: 0, high: Object.keys(vulnerabilities).length, critical: 0 } } });
const vulnerable = report({ 'left-pad': { name: 'left-pad', severity: 'high', via: [{ title: 'Advisory', url: 'https://github.com/advisories/GHSA-test' }] } });
const endpointFailure = fields => JSON.stringify({ message: 'POST https://registry.example/-/npm/v1/security/advisories/bulk', ...fields,
  error: { summary: '', detail: '' } });

describe('classify', () => {
  it('passes what npm passes, vulnerabilities below the configured level included', () => {
    assert.equal(classify(0, report()), 'passed');
    assert.equal(classify(0, vulnerable), 'passed');
  });

  it('takes a report for vulnerabilities, whatever else the output holds', () => {
    assert.equal(classify(1, vulnerable), 'vulnerable');
    assert.equal(classify(1, JSON.stringify({ ...JSON.parse(vulnerable), statusCode: 503, message: 'x', error: {} })), 'vulnerable');
  });

  it('takes a 5xx, 408 or 429 answer, or none, for an endpoint that failed', () => {
    for (const statusCode of [500, 502, 503, 504, 408, 429]) assert.equal(classify(1, endpointFailure({ statusCode })), 'unavailable');
    assert.equal(classify(1, endpointFailure({ message: 'network timeout at: https://registry.example/-/npm/v1/security/advisories/bulk' })), 'unavailable');
  });

  it('fails on anything else', () => {
    for (const statusCode of [400, 401, 403, 404]) assert.equal(classify(1, endpointFailure({ statusCode })), 'failed');
    assert.equal(classify(1, JSON.stringify({ error: { code: 'ENOLOCK', summary: 'This command requires an existing lockfile.' } })), 'failed');
    assert.equal(classify(1, ''), 'failed');
    assert.equal(classify(1, 'npm error audit endpoint returned an error'), 'failed');
  });
});

/** A project of one dependency, audited by npm against a registry that answers `answers` in turn, then the last one. */
async function auditAgainst(t, answers, args = []) {
  const project = mkdtempSync(path.join(tmpdir(), 'npm-audit-'));
  t.after(() => rmSync(project, { recursive: true, force: true }));
  writeFileSync(path.join(project, 'package.json'), JSON.stringify({ name: 'fixture', version: '1.0.0', dependencies: { 'left-pad': '1.3.0' } }));
  writeFileSync(path.join(project, 'package-lock.json'), JSON.stringify({ name: 'fixture', version: '1.0.0', lockfileVersion: 3, packages: {
    '': { name: 'fixture', version: '1.0.0', dependencies: { 'left-pad': '1.3.0' } },
    'node_modules/left-pad': { version: '1.3.0', resolved: 'https://registry.npmjs.org/left-pad/-/left-pad-1.3.0.tgz' },
  } }));
  let audits = 0;
  const server = createServer((request, response) => {
    if (!request.url.endsWith('/advisories/bulk')) {
      response.statusCode = 404;
      return response.end('{}');
    }
    const answer = answers[Math.min(audits, answers.length - 1)];
    audits += 1;
    if (answer === 'silent') return;
    if (typeof answer === 'number') {
      response.statusCode = answer;
      return response.end('<html>unavailable</html>');
    }
    response.setHeader('Content-Type', 'application/json');
    response.end(JSON.stringify(answer));
  });
  server.listen(0, '127.0.0.1');
  t.after(() => { server.closeAllConnections(); server.close(); });
  await once(server, 'listening');
  const lines = [];
  const pauses = [];
  const code = await audit([`--registry=http://127.0.0.1:${server.address().port}/`, ...args], {
    cwd: project, stderr: 'ignore', delays: [1_000, 2_000], wait: async ms => { pauses.push(ms); }, log: line => lines.push(line),
  });
  return { code, audits, pauses, output: lines.join('\n') };
}

const advisory = { 'left-pad': [{ id: 1, url: 'https://github.com/advisories/GHSA-test', title: 'Test advisory', severity: 'high',
  vulnerable_versions: '<9.0.0', cwe: [], cvss: { score: 7.5, vectorString: null } }] };

describe('audit with npm', () => {
  it('fails on an advisory at once', async (t) => {
    const { code, audits, output } = await auditAgainst(t, [advisory]);
    assert.equal(code, 1);
    assert.equal(audits, 1);
    assert.match(output, /left-pad \(high\): Test advisory https:\/\/github\.com\/advisories\/GHSA-test/);
    assert.doesNotMatch(output, /::warning/);
  });

  it('passes a clean report', async (t) => {
    const { code, output } = await auditAgainst(t, [{}]);
    assert.equal(code, 0);
    assert.match(output, /no known vulnerabilities/);
  });

  it('tries an endpoint that failed again, and audits once it answers', async (t) => {
    const { code, audits, pauses, output } = await auditAgainst(t, [503, advisory]);
    assert.deepEqual([code, audits, pauses], [1, 2, [1_000]]);
    assert.match(output, /Test advisory/);
  });

  it('skips the audit with a warning when the endpoint keeps failing', async (t) => {
    const { code, audits, pauses, output } = await auditAgainst(t, [502]);
    assert.deepEqual([code, audits, pauses], [0, 3, [1_000, 2_000]]);
    assert.match(output, /^::warning title=npm audit skipped::The npm audit endpoint failed 3 times, last with "502 Bad Gateway/m);
  });

  it('takes an endpoint that does not answer in time for one that failed', async (t) => {
    const { code, audits, output } = await auditAgainst(t, ['silent'], ['--fetch-timeout=300']);
    assert.deepEqual([code, audits], [0, 3]);
    assert.match(output, /::warning title=npm audit skipped::.*network timeout/);
  });

  it('fails on a request the endpoint refuses', async (t) => {
    const { code, audits, output } = await auditAgainst(t, [404]);
    assert.deepEqual([code, audits], [1, 1]);
    assert.match(output, /"statusCode": 404/);
  });
});
