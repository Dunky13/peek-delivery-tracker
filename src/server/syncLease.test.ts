import { afterEach, expect, it, vi } from 'vitest';
import { SyncJobWorker, type BackgroundState } from './background';
import { SupabaseServiceClient } from './supabase';
import { TrackingSyncService, type SyncSummary } from './trackingSync';
import type { SyncRunContext } from './trackingAudit';

afterEach(() => { vi.restoreAllMocks(); vi.useRealTimers(); });
it.each([false, true])('renews a long-running job and stops writes after renewal loss: %s', async (loseLease) => {
  vi.useFakeTimers();
  const client = new SupabaseServiceClient('https://database.test', 'test');
  const state: BackgroundState = { workerHeartbeat: null, lastScheduledSync: null, nextScheduledSync: null, lastSummary: null, lastError: null, lastAutoArchived: 0 };
  vi.spyOn(client, 'claimSyncJob').mockResolvedValueOnce({ id: 'job', kind: 'package', package_id: 'package' }).mockResolvedValue(null);
  vi.spyOn(client, 'getPackage').mockResolvedValue({ id: 'package' });
  const renew = vi.spyOn(client, 'renewSyncJobLease').mockResolvedValue(!loseLease);
  const finish = vi.spyOn(client, 'finishSyncJob').mockResolvedValue();
  const withdrawn = vi.spyOn(client, 'syncJobWithdrawn').mockResolvedValue(false);
  const service = new TrackingSyncService(client);
  let context!: SyncRunContext;
  let complete!: (summary: SyncSummary) => void;
  vi.spyOn(service, 'syncPackage').mockImplementation((_parcel, incoming) => {
    context = incoming!;
    return new Promise(resolve => { complete = resolve; });
  });
  const worker = new SyncJobWorker(service, state);
  worker.start();
  await vi.advanceTimersByTimeAsync(1);
  const heartbeat = state.workerHeartbeat;
  await vi.advanceTimersByTimeAsync(30_000);
  expect(renew).toHaveBeenCalledWith('job', worker.workerId);
  expect(context.lease).toEqual({ jobId: 'job', workerId: worker.workerId });
  expect(context.signal?.aborted).toBe(loseLease);
  if (!loseLease) expect(state.workerHeartbeat).toBeGreaterThan(heartbeat!);
  complete({ checked: 1, updated: 1, unchanged: 0, waiting: 0, errors: 0, unsupported: 0, superseded: 0, notifications_sent: 0, notification_errors: 0, subscriptions_expired: 0, emails_sent: 0, email_errors: 0 });
  await vi.advanceTimersByTimeAsync(1);
  if (loseLease) expect(finish).not.toHaveBeenCalled();
  else expect(finish).toHaveBeenCalledOnce();
  expect(withdrawn).toHaveBeenCalledTimes(loseLease ? 1 : 0);
  worker.stop();
  const calls = renew.mock.calls.length;
  await vi.advanceTimersByTimeAsync(60_000);
  expect(renew).toHaveBeenCalledTimes(calls);
});

it.each([[10, 'package'], [-20, 'package'], [-30, 'release']])('runs a parcel\'s job of priority %i as a %s check', async (priority, trigger) => {
  vi.useFakeTimers();
  const client = new SupabaseServiceClient('https://database.test', 'test');
  const state: BackgroundState = { workerHeartbeat: null, lastScheduledSync: null, nextScheduledSync: null, lastSummary: null, lastError: null, lastAutoArchived: 0 };
  vi.spyOn(client, 'claimSyncJob').mockResolvedValueOnce({ id: 'job', kind: 'package', package_id: 'package', priority }).mockResolvedValue(null);
  vi.spyOn(client, 'getPackage').mockResolvedValue({ id: 'package' });
  vi.spyOn(client, 'finishSyncJob').mockResolvedValue();
  const service = new TrackingSyncService(client);
  const check = vi.spyOn(service, 'syncPackage').mockResolvedValue({ checked: 1, updated: 0, unchanged: 1, waiting: 0, errors: 0, unsupported: 0,
    superseded: 0, notifications_sent: 0, notification_errors: 0, subscriptions_expired: 0, emails_sent: 0, email_errors: 0 });
  const worker = new SyncJobWorker(service, state);
  worker.start();
  await vi.advanceTimersByTimeAsync(1);
  worker.stop();
  expect(check.mock.calls[0][1]).toMatchObject({ trigger });
});
