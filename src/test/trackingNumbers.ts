/** Eight serial digits and their UPU S10 check digit, for synthetic numbers. */
export function s10(serial: string): string {
  const sum = [...serial].reduce((total, digit, index) => total + Number(digit) * [8, 6, 4, 2, 3, 5, 9, 7][index], 0);
  const check = 11 - (sum % 11);
  return `${serial}${check === 10 ? 0 : check === 11 ? 5 : check}`;
}

/** The number with its character at `index` typed twice. */
export const doubled = (number: string, index: number) => number.slice(0, index + 1) + number.slice(index);
