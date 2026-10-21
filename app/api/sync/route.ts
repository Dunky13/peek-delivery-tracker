import {
  apiRoute,
  json,
  requireService,
  requireUser,
  requireUserClient,
} from '../../../src/server/api';
import { wakeSyncWorker } from '../../../src/server/background';
import { checkAccountRequest } from '../../../src/server/nativeVerification';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export const POST = apiRoute(async (context) => {
  const service = requireService(context);
  const userId = requireUser(context).id;
  // The route takes no body, so a signed request signs none.
  await checkAccountRequest(context.request, service, new Uint8Array(), 'account_refresh');
  const jobIds: string[] = [];
  let queued = false;
  for (const parcel of await requireUserClient(context).listActivePackages()) {
    if (typeof parcel.id !== 'string') continue;
    const job = await service.enqueueSyncJob({ userId, packageId: parcel.id, reason: 'refresh' });
    queued ||= job.queued;
    if (typeof job.row.id === 'string' && !jobIds.includes(job.row.id)) jobIds.push(job.row.id);
  }
  if (jobIds.length > 0) wakeSyncWorker();
  return json({
    queued,
    pending: await service.pendingSyncJobCount(userId),
    jobIds,
  }, 202);
}, { serviceRequired: true });
