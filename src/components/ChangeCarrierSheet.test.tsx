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

  it('goes back to automatic detection, filed as adding the number would file it', async () => {
    vi.stubGlobal('fetch', vi.fn(async () => Response.json({ refused: false })));
    const user = userEvent.setup();
    const chooseAutomatic = async (opener: HTMLElement) => {
      await user.click(opener);
      await user.click(within(await screen.findByRole('dialog', { name: 'Carrier' })).getByRole('option', { name: /^Detect automatically/ }));
    };
    // A number no shape settles is filed under no carrier, and Peek looks for it.
    const onChange = vi.fn().mockResolvedValue(undefined);
    const { unmount } = render(<ChangeCarrierSheet parcel={parcel} onChange={onChange} onClose={vi.fn()} />);
    let sheet = screen.getByRole('dialog', { name: 'Change carrier' });
    await chooseAutomatic(within(sheet).getByRole('button', { name: /^Carrier / }));
    expect(within(sheet).getByRole('button', { name: 'Carrier Detect automatically' })).toHaveAccessibleDescription('Peek finds the carrier for you.');
    await user.click(within(sheet).getByRole('button', { name: 'Save carrier' }));
    expect(onChange).toHaveBeenCalledWith(expect.objectContaining({ carrier: 'unknown' }));
    unmount();

    // A number whose shape names its carrier goes back to that carrier.
    const ups = vi.fn().mockResolvedValue(undefined);
    const { unmount: close } = render(<ChangeCarrierSheet parcel={{ ...parcel, carrier: 'dpd', trackingNumber: '1Z999AA10123456784' }}
      onChange={ups} onClose={vi.fn()} />);
    sheet = screen.getByRole('dialog', { name: 'Change carrier' });
    await chooseAutomatic(within(sheet).getByRole('button', { name: /^Carrier / }));
    expect(within(sheet).getByRole('button', { name: 'Carrier Detect automatically' })).toHaveAccessibleDescription('UPS, from the number');
    await user.click(within(sheet).getByRole('button', { name: 'Save carrier' }));
    expect(ups).toHaveBeenCalledWith(expect.objectContaining({ carrier: 'ups' }));
    close();

    // An Amazon number is tracked through Amazon Shipping alone.
    render(<ChangeCarrierSheet parcel={{ ...parcel, carrier: 'amazon-shipping', trackingNumber: 'TBA123456789012' }} onChange={vi.fn()} onClose={vi.fn()} />);
    await user.click(within(screen.getByRole('dialog', { name: 'Change carrier' })).getByRole('button', { name: /^Carrier / }));
    expect(within(await screen.findByRole('dialog', { name: 'Carrier' })).queryByRole('option', { name: /^Detect automatically/ })).not.toBeInTheDocument();
  });

  it('opens on automatic detection for a parcel filed under no carrier', async () => {
    vi.stubGlobal('fetch', vi.fn(async () => Response.json({ refused: false })));
    const user = userEvent.setup();
    render(<ChangeCarrierSheet parcel={{ ...parcel, carrier: 'unknown' }} onChange={vi.fn()} onClose={vi.fn()} />);
    const sheet = screen.getByRole('dialog', { name: 'Change carrier' });
    const carrier = within(sheet).getByRole('button', { name: 'Carrier Detect automatically' });
    const save = within(sheet).getByRole('button', { name: 'Save carrier' });
    expect(save).toBeDisabled();
    // Automatic detection stands for the parcel's own entry.
    await user.click(carrier);
    const picker = await screen.findByRole('dialog', { name: 'Carrier' });
    expect(within(picker).getByRole('option', { name: /^Detect automatically/ })).toHaveAttribute('aria-selected', 'true');
    expect(within(picker).queryByText('Current')).not.toBeInTheDocument();
    await user.click(within(picker).getByRole('button', { name: 'Cancel' }));

    await pickCarrier(user, carrier, 'DPD Switzerland');
    expect(save).toBeEnabled();
    await user.click(carrier);
    await user.click(within(await screen.findByRole('dialog', { name: 'Carrier' })).getByRole('option', { name: /^Detect automatically/ }));
    expect(save).toBeDisabled();
  });
});
