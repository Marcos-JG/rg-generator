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
  root.querySelectorAll('[data-resize-active]').forEach(el => el.removeAttribute('data-resize-active'));
  root.querySelectorAll('.rg-sel, .rg-hover').forEach(el => el.classList.remove('rg-sel', 'rg-hover'));
  for (const el of root.querySelectorAll('[data-rg-id]')) {
    const id = el.getAttribute('data-rg-id');
    if (id === selection.selected) el.classList.add('rg-sel');
    else if (id === selection.hovered) el.classList.add('rg-hover');
    if (id === selection.selected || id === selection.hovered) {
      el.closest('[data-drag-section]')?.setAttribute('data-resize-active', 'true');
    }
  }
}

export function cleanPreviewHtml(previewEl) {
  const clone = previewEl.cloneNode(true);

  // Grid and flex layouts can give a section a visible height that is not
  // present in its inline style. Freeze that final size in the standalone
  // document so the exported HTML is a true snapshot of the preview.
  const previewWidth = previewEl.getBoundingClientRect?.().width || previewEl.offsetWidth || 0;
  const scale = previewWidth && previewEl.offsetWidth ? previewWidth / previewEl.offsetWidth : 1;
  const sourceSections = [...previewEl.querySelectorAll('[data-drag-section]')];
  const clonedSections = [...clone.querySelectorAll('[data-drag-section]')];
  sourceSections.forEach((source, index) => {
    const target = clonedSections[index];
    const rect = source.getBoundingClientRect?.();
    if (!target || !rect || rect.height <= 0) return;
    target.style.height = `${rect.height / scale}px`;
    target.style.flex = 'none';
  });

  clone.querySelectorAll('[data-resize], .col-resize-handle').forEach(el => el.remove());
  for (const el of [clone, ...clone.querySelectorAll('*')]) {
    el.classList.remove('rg-sel', 'rg-hover', 'field-draggable');
    for (const attr of [...el.attributes]) {
      if (attr.name.startsWith('data-') || ['draggable', 'contenteditable'].includes(attr.name)) el.removeAttribute(attr.name);
    }
  }
  return clone.innerHTML;
}
