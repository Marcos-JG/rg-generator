const SELECTORS = [
  '.header', '.doc-type', '.section', '.section-title', '.info-table',
  '.items-table', '.totals-section', '.dte-box', '.footer', 'h1',
  '.total-pagar', '.total-row', '.totals-table',
];

const NON_SELECTABLE_IDS = new Set([
  'grid-row-0', 'grid-row-1', 'grid-row-2', 'grid-row-3', 'grid-row-4', 'grid-row-5',
  'header-row-0', 'header-row-1', 'header-row-2',
  'section-emisor', 'section-receptor', 'section-items', 'section-totals', 'section-observaciones', 'section-footer',
  'section-header-logo', 'section-header-ids', 'section-header-qr', 'section-header-info',
]);

export function findSelectable(el) {
  let cur = el;
  while (cur && cur.tagName !== 'BODY') {
    if (cur.matches?.('[data-rg-id]')) {
      const rgId = cur.getAttribute('data-rg-id');
      if (rgId && !NON_SELECTABLE_IDS.has(rgId) && !rgId.startsWith('grid-row') && !rgId.startsWith('header-row')) {
        return { el: cur, sel: '[data-rg-id]' };
      }
      cur = cur.parentElement;
      continue;
    }
    let matched = false;
    for (const s of SELECTORS) {
      if (cur.matches?.(s)) { matched = true; break; }
    }
    if (matched) {
      const rgId = cur.getAttribute?.('data-rg-id');
      if (!rgId || (!NON_SELECTABLE_IDS.has(rgId) && !rgId.startsWith('grid-row') && !rgId.startsWith('header-row'))) {
        return { el: cur, sel: '[class]' };
      }
    }
    cur = cur.parentElement;
  }
  return null;
}

export function findTextContent(el) {
  if (!el) return null;
  for (const c of el.childNodes) {
    if (c.nodeType === 3 && c.textContent.trim()) return c;
  }
  for (const c of el.childNodes) {
    if (c.nodeType === 1) {
      const found = findTextContent(c);
      if (found) return found;
    }
  }
  return null;
}

export function rgbToHex(rgb) {
  if (!rgb || rgb === 'rgba(0, 0, 0, 0)' || rgb === 'transparent') return '#ffffff';
  const m = rgb.match(/\d+/g);
  if (!m || m.length < 3) return '#000000';
  return '#' + m.slice(0, 3).map((n) => parseInt(n).toString(16).padStart(2, '0')).join('');
}

export function cssStr(obj) {
  return Object.entries(obj).map(([k, v]) => `${camelToKebab(k)}:${v}`).join(';');
}

function camelToKebab(s) {
  return s.replace(/[A-Z]/g, (m) => '-' + m.toLowerCase());
}
