import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { ChangeCarrierSheet } from './ChangeCarrierSheet';
import { pickCarrier } from '../test/carrierPicker';
import type { ParcelWithEvents } from '../types';

afterEach(() => vi.unstubAllGlobals());
const parcel: ParcelWithEvents = { id: 'parcel', carrier: 'seur', trackingNumber: '12345678901235', label: 'Books', createdAt: '2026-09-10T12:00:00Z', syncStatus: 'ok', events: [] };

describe('ChangeCarrierSheet', () => {
  it('says before saving that the chosen carrier issues no number like this one', async () => {
    const refusal = vi.fn(async (_path: string, init?: RequestInit) => Response.json({ refused: JSON.parse(String(init?.body)).carrier === 'nz-couriers' }));
    vi.stubGlobal('fetch', refusal);
    const onChange = vi.fn().mockResolvedValue(undefined);
    const user = userEvent.setup();
    render(<ChangeCarrierSheet parcel={parcel} onChange={onChange} onClose={vi.fn()} />);
    const sheet = screen.getByRole('dialog', { name: 'Change carrier' });
    const carrier = within(sheet).getByRole('button', { name: /^Carrier / });

    await pickCarrier(user, carrier, 'New Zealand Couriers');
    expect(await within(sheet).findByText('New Zealand Couriers doesn’t issue numbers like this one')).toHaveClass('is-attention');
    expect(carrier).toHaveAccessibleDescription('New Zealand Couriers doesn’t issue numbers like this one');
    expect(refusal).toHaveBeenCalledWith('/api/public/refusal', expect.objectContaining({
      method: 'POST', body: JSON.stringify({ carrier: 'nz-couriers', trackingNumber: '12345678901235' }) }));

    await pickCarrier(user, carrier, 'DPD Switzerland');
    expect(within(sheet).queryByText(/doesn’t issue numbers/)).not.toBeInTheDocument();
    // A warning, not a refusal: the change can still be saved.
    await pickCarrier(user, carrier, 'New Zealand Couriers');
    await within(sheet).findByText(/doesn’t issue numbers/);
    await user.click(within(sheet).getByRole('button', { name: 'Save carrier' }));
    expect(onChange).toHaveBeenCalledWith(expect.objectContaining({ carrier: 'nz-couriers' }));
  });
});
