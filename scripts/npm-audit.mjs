// `npm audit` for CI: `node scripts/npm-audit.mjs --omit=dev` takes npm audit's own arguments.
// A report whose vulnerabilities reach the configured level fails the step, as npm audit does.
// When the registry's audit endpoint fails instead (a 5xx, 408 or 429 answer, or none in time),
// the audit is tried again after a pause; if the endpoint never answers, the step passes with
// a warning, and the next run audits again.
import { spawn } from 'node:child_process';
import path from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';

/** The pauses before each new attempt. */
export const RETRY_DELAYS_MS = [10_000, 20_000, 40_000];
/** How long one attempt waits for the endpoint. npm's own retries are off: the attempts above replace them. */
const FETCH_TIMEOUT_MS = 30_000;

function parse(stdout) {
  try {
    const value = JSON.parse(stdout);
    return value && typeof value === 'object' && !Array.isArray(value) ? value : null;
  } catch {
    return null;
  }
}

/**
 * What one `npm audit --json` run found: `passed`; `vulnerable`, a report whose vulnerabilities
 * reach the configured level; `unavailable`, the endpoint did not answer; or `failed`, anything
 * else, such as a missing lockfile or a request the endpoint refused.
 * Only a run without a report can be `unavailable`: npm reports an endpoint that failed with
 * the request's `message` and an `error`, and the answer's `statusCode` when there was one.
 */
export function classify(status, stdout) {
  if (status === 0) return 'passed';
  const output = parse(stdout);
  if (!output) return 'failed';
  if ('vulnerabilities' in output || 'auditReportVersion' in output) return 'vulnerable';
  if (!output.error || typeof output.message !== 'string') return 'failed';
  const answer = output.statusCode;
  if (answer === undefined) return 'unavailable';
  return Number.isInteger(answer) && (answer >= 500 || answer === 408 || answer === 429) ? 'unavailable' : 'failed';
}

/** One line per vulnerable package, after the count by severity. */
export function describe(report) {
  const packages = Object.values(report?.vulnerabilities ?? {});
  if (packages.length === 0) return 'npm audit: no known vulnerabilities.';
  const counts = Object.entries(report.metadata?.vulnerabilities ?? {})
    .filter(([severity, count]) => severity !== 'total' && count > 0)
    .map(([severity, count]) => `${count} ${severity}`).join(', ');
  return [`npm audit: ${packages.length} vulnerable package${packages.length === 1 ? '' : 's'} (${counts})`,
    ...packages.map(({ name, severity, via = [] }) => `  ${name} (${severity}): ${via.map(cause => (typeof cause === 'string'
      ? `through ${cause}` : `${cause.title} ${cause.url}`)).join('; ')}`)].join('\n');
}

/** A workflow command's text: GitHub reads `%`, CR and LF as escapes. */
const command = text => text.replace(/%/g, '%25').replace(/\r/g, '%0D').replace(/\n/g, '%0A');

function runNpm(args, { cwd, stderr }) {
  return new Promise((resolve, reject) => {
    const child = spawn('npm', args, { cwd, stdio: ['ignore', 'pipe', stderr] });
    let stdout = '';
    child.stdout.setEncoding('utf8').on('data', (chunk) => { stdout += chunk; });
    child.on('error', reject);
    child.on('close', status => resolve({ status, stdout }));
  });
}

/** Audits and returns the exit code. */
export async function audit(args, {
  cwd = process.cwd(), stderr = 'inherit', delays = RETRY_DELAYS_MS, wait = delay, log = console.log,
} = {}) {
  // The arguments given come last, so they can set the timeout too.
  const npmArgs = ['audit', '--json', '--fetch-retries=0', `--fetch-timeout=${FETCH_TIMEOUT_MS}`, ...args];
  for (let attempt = 1; ; attempt += 1) {
    const { status, stdout } = await runNpm(npmArgs, { cwd, stderr });
    const outcome = classify(status, stdout);
    if (outcome === 'unavailable') {
      const reason = parse(stdout).message;
      if (attempt <= delays.length) {
        log(`The npm audit endpoint failed (${reason}). Trying again in ${delays[attempt - 1] / 1000} s.`);
        await wait(delays[attempt - 1]);
        continue;
      }
      log(`::warning title=npm audit skipped::${command(`The npm audit endpoint failed ${attempt} times, last with "${reason}". The audit was skipped; the next run audits again.`)}`);
      return 0;
    }
    if (outcome === 'failed') {
      log(stdout);
      return status || 1;
    }
    log(describe(parse(stdout)));
    return outcome === 'passed' ? 0 : status;
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  process.exitCode = await audit(process.argv.slice(2));
}
