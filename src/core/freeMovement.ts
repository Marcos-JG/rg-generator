export function movementTarget(target, mode = 'elements') {
  if (target.closest?.('[contenteditable="true"], [data-resize], .col-resize-handle')) return null;
  // A table column and all of its detail cells are one structure. In free
  // movement the table moves as a unit; column changes belong to reorder mode.
  const itemsTable = target.closest?.('.items-table');
  if (itemsTable) return itemsTable.closest('[data-drag-section="items"]');
  if (mode === 'blocks') {
    const block = target.closest?.('[data-drag-section]');
    if (block) return block;
  }
  const element = target.closest?.('[data-rg-id]');
  if (!element || /^(grid-row|header-row)-/.test(element.dataset.rgId)) return null;
  return element;
}

// Bounds are measured in viewport pixels; saved offsets use unscaled page pixels.
export function movementDelta(rect, page, dx, dy, scale = 1) {
  const clamp = (v, min, max) => Math.max(min, Math.min(v, Math.max(min, max)));
  return {
    x: clamp(dx, page.left - rect.left, page.right - rect.right) / scale,
    y: clamp(dy, page.top - rect.top, page.bottom - rect.bottom) / scale,
  };
}

// Compare rendered edges and centers in viewport pixels, including at zoom.
export function alignmentGuides(rect, targets, tolerance = 3) {
  const guides = [];
  for (const axis of ['x', 'y']) {
    const [start, end, crossStart, crossEnd] = axis === 'x'
      ? ['left', 'right', 'top', 'bottom'] : ['top', 'bottom', 'left', 'right'];
    const anchors = box => [box[start], (box[start] + box[end]) / 2, box[end]];
    let best = null;
    for (const target of targets) {
      for (const position of anchors(target)) {
        for (const anchor of anchors(rect)) {
          const distance = Math.abs(position - anchor);
          if (distance <= tolerance && (!best || distance < best.distance)) {
            best = { axis, position, distance,
              start: Math.min(rect[crossStart], target[crossStart]),
              end: Math.max(rect[crossEnd], target[crossEnd]) };
          }
        }
      }
    }
    if (best) guides.push(best);
  }
  return guides;
}

export function applyMovementPosition(el: HTMLElement, position: { x: number; y: number; z?: number }) {
  el.style.transform = `translate(${position.x}px, ${position.y}px)`;
  // Added XML fields already have left/top coordinates outside document flow.
  // Changing them to relative puts their origin at the end of the document.
  if (!['absolute', 'fixed'].includes(el.style.position)) el.style.position = 'relative';
  el.style.zIndex = String(Math.min(position.z || 1, 40));
}

export function applyPositions(doc, positions = {}) {
  for (const el of doc.querySelectorAll('[data-rg-id]')) {
    if (el.dataset.rgId === 'footer') continue;
    const position = positions[el.dataset.rgId];
    if (!position) continue;
    applyMovementPosition(el, position);
    // A moved field may cross its original table or section boundary.
    let parent = el.parentElement;
    while (parent && parent !== doc.body) {
      parent.style.overflow = 'visible';
      parent = parent.parentElement;
    }
  }
}
