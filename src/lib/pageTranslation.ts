/**
 * A browser translating the page (Safari, Chrome, Edge), or an extension,
 * swaps the text React wrote for nodes of its own. React still holds the old
 * nodes, and its next change that removes one, or puts a node before one,
 * throws a NotFoundError that takes the page down to its error screen. Such a
 * change lands as near as the page now allows instead: a node that has left
 * its parent is removed from where it is now, or is gone already, and a node
 * to go before it goes before whatever holds it now, or at the end.
 */
export function toleratePageTranslation(prototype: Node = Node.prototype): void {
  const { insertBefore, removeChild } = prototype;
  prototype.insertBefore = function <T extends Node>(this: Node, node: T, child: Node | null): T {
    let place = child;
    while (place && place.parentNode !== this) place = place.parentNode;
    return insertBefore.call(this, node, place) as T;
  };
  prototype.removeChild = function <T extends Node>(this: Node, child: T): T {
    const parent = child.parentNode;
    if (parent !== this && !(parent && this.contains(parent))) return child;
    return removeChild.call(parent, child) as T;
  };
}
