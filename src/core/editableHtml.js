// Text fragments get identities within their nearest element. Wrapping only the
// text preserves labels, data cells, line breaks and resize handles during editing.
import { applyPositions } from './freeMovement';

export function editableHtml(html, textOverrides = {}, positions = {}, selection = {}) {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const walker = doc.createTreeWalker(doc.body, 4);
  const nodes = [];
  while (walker.nextNode()) nodes.push(walker.currentNode);
  const counts = new Map();
  for (const node of nodes) {
    if (!node.textContent.trim() || node.parentElement.closest('script, style, [data-resize], .col-resize-handle')) continue;
    const owner = node.parentElement.closest('[data-rg-id]');
    if (!owner) continue;
    const id = owner.getAttribute('data-rg-id');
    const index = counts.get(id) || 0;
    counts.set(id, index + 1);
    const key = `${id}:text:${index}`;
    const span = doc.createElement('span');
    span.setAttribute('data-rg-text', key);
    span.style.whiteSpace = 'pre-wrap';
    span.textContent = Object.hasOwn(textOverrides, key) ? textOverrides[key] : node.textContent;
    node.replaceWith(span);
  }
  applyPositions(doc, positions);
  applySelection(doc, selection);
  return doc.body.innerHTML;
}

// Update highlights in place so hovering/selecting never replaces document nodes
// or disrupts the browser's scroll anchor, focus and pointer target.
export function applySelection(root, selection = {}) {
  root.querySelectorAll('.rg-sel, .rg-hover').forEach(el => el.classList.remove('rg-sel', 'rg-hover'));
  for (const el of root.querySelectorAll('[data-rg-id]')) {
    const id = el.getAttribute('data-rg-id');
    if (id === selection.selected) el.classList.add('rg-sel');
    else if (id === selection.hovered) el.classList.add('rg-hover');
  }
}

export function cleanPreviewHtml(previewEl) {
  const clone = previewEl.cloneNode(true);
  clone.querySelectorAll('[data-resize], .col-resize-handle').forEach(el => el.remove());
  for (const el of [clone, ...clone.querySelectorAll('*')]) {
    el.classList.remove('rg-sel', 'rg-hover', 'field-draggable');
    for (const attr of [...el.attributes]) {
      if (attr.name.startsWith('data-') || ['draggable', 'contenteditable'].includes(attr.name)) el.removeAttribute(attr.name);
    }
  }
  return clone.innerHTML;
}
