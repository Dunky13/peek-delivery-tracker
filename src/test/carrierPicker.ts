import { screen, within } from '@testing-library/react';
import type { UserEvent } from '@testing-library/user-event';

/** The open carrier picker. */
export function carrierPicker(): HTMLElement {
  return screen.getByRole('dialog', { name: 'Carrier' });
}

/** Opens the carrier picker with `opener`, searches for `name` and picks it. */
export async function pickCarrier(user: UserEvent, opener: HTMLElement, name: string): Promise<void> {
  await user.click(opener);
  const picker = await screen.findByRole('dialog', { name: 'Carrier' });
  // Pasted in one go: typing searches and redraws the results once per letter,
  // which held the tests that pick carriers close to their time limit under load.
  await user.click(within(picker).getByRole('combobox', { name: 'Search carriers' }));
  await user.paste(name);
  await user.click(within(picker).getByRole('option', { name }));
}
