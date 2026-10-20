import { render } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';
import { toleratePageTranslation } from './pageTranslation';

const { insertBefore, removeChild } = Node.prototype;
afterEach(() => { Object.assign(Node.prototype, { insertBefore, removeChild }); });

/** A word that comes before the text the translator gets to. */
function Arriving({ word }: { word: boolean }) {
  return <p>{word && <b>new</b>}left behind</p>;
}

/** Text that goes, before a word that stays. */
function Leaving({ text }: { text: boolean }) {
  return <p>{text && 'left behind'}<b>stays</b></p>;
}

/** What Chrome's translation does: the text is swapped for a node of its own, and leaves the page. */
function swapText(view: { container: HTMLElement }) {
  const text = [...view.container.querySelector('p')!.childNodes].find((node) => node instanceof Text)!;
  const font = document.createElement('font');
  font.textContent = 'zurückgelassen';
  text.replaceWith(font);
}

/** What a translator that keeps the text does: the text moves into a node of its own, where it stood. */
function wrapText(view: { container: HTMLElement }) {
  const text = [...view.container.querySelector('p')!.childNodes].find((node) => node instanceof Text)!;
  const font = document.createElement('font');
  text.replaceWith(font);
  font.append(text);
}

describe('a page a browser translates', () => {
  it('takes React down as it is', () => {
    const view = render(<Arriving word={false} />);
    swapText(view);
    expect(() => view.rerender(<Arriving word />)).toThrow(expect.objectContaining({ name: 'NotFoundError' }));
  });

  it('puts a node due before swapped text at the end', () => {
    toleratePageTranslation();
    const view = render(<Arriving word={false} />);
    swapText(view);
    view.rerender(<Arriving word />);
    expect(view.container.innerHTML).toBe('<p><font>zurückgelassen</font><b>new</b></p>');
  });

  it('puts a node due before moved text before what holds it now', () => {
    toleratePageTranslation();
    const view = render(<Arriving word={false} />);
    wrapText(view);
    view.rerender(<Arriving word />);
    expect(view.container.innerHTML).toBe('<p><b>new</b><font>left behind</font></p>');
  });

  it('removes moved text from where it is now', () => {
    toleratePageTranslation();
    const view = render(<Leaving text />);
    wrapText(view);
    view.rerender(<Leaving text={false} />);
    expect(view.container.innerHTML).toBe('<p><font></font><b>stays</b></p>');
  });

  it('leaves swapped text alone', () => {
    toleratePageTranslation();
    const view = render(<Leaving text />);
    swapText(view);
    view.rerender(<Leaving text={false} />);
    expect(view.container.innerHTML).toBe('<p><font>zurückgelassen</font><b>stays</b></p>');
  });

  it('leaves the DOM as it is where nothing was moved', () => {
    toleratePageTranslation();
    const list = document.createElement('ul');
    const [first, last] = [document.createElement('li'), document.createElement('li')];
    expect(list.insertBefore(last, null)).toBe(last);
    expect(list.insertBefore(first, last)).toBe(first);
    expect([...list.children]).toEqual([first, last]);
    expect(list.removeChild(first)).toBe(first);
    expect([...list.children]).toEqual([last]);
  });
});
