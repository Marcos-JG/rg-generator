export const BLOCK_LABELS = {
  emisor: 'Emisor',
  receptor: 'Receptor',
  items: 'Detalle de ítems',
  totals: 'Totales',
  observaciones: 'Observaciones',
  'datos-adicionales': 'Datos adicionales',
  footer: 'Pie de página',
  'header-logo': 'Logo',
  'header-ids': 'Identificación del documento',
  'header-qr': 'Código QR',
  'header-info': 'Información del documento',
  'documentos-relacionados': 'Documentos relacionados',
  'otros-documentos': 'Otros documentos asociados',
  apendice: 'Información adicional',
  responsables: 'Responsables',
};

const LEGACY_ALIASES = {
  'section-emisor': 'emisor',
  'section-seller': 'emisor',
  'section-receptor': 'receptor',
  'section-buyer': 'receptor',
  'section-items': 'items',
  'table-items': 'items',
  'section-totals': 'totals',
  'section-observaciones': 'observaciones',
  'section-datos-adicionales': 'datos-adicionales',
  'section-footer': 'footer',
  'section-header-logo': 'header-logo',
  'section-header-ids': 'header-ids',
  'section-header-qr': 'header-qr',
  'section-header-info': 'header-info',
  'header-guid': 'header-ids',
};

const OBSOLETE_IDS = new Set(['header']);

export const canonicalElementId = id => LEGACY_ALIASES[id] || id;

export function normalizeElementRecord(record = {}) {
  const normalized = {};
  // Legacy wrapper values supply dimensions first; values stored under the
  // canonical content ID take precedence when both existed.
  for (const [id, value] of Object.entries(record)) {
    if (OBSOLETE_IDS.has(id)) continue;
    if (canonicalElementId(id) !== id) {
      const key = canonicalElementId(id);
      normalized[key] = { ...(normalized[key] || {}), ...value };
    }
  }
  for (const [id, value] of Object.entries(record)) {
    if (OBSOLETE_IDS.has(id)) continue;
    if (canonicalElementId(id) === id) normalized[id] = { ...(normalized[id] || {}), ...value };
  }
  return normalized;
}

export function normalizeSavedDesign(state = {}) {
  const positions = normalizeElementRecord(state.positions);
  delete positions.footer;
  return {
    ...state,
    overrides: normalizeElementRecord(state.overrides),
    positions,
  };
}

export function elementLabel(id = '') {
  if (BLOCK_LABELS[id]) return BLOCK_LABELS[id];
  const prefixes = [
    ['seller-', 'Emisor · '], ['buyer-', 'Receptor · '],
    ['total-', 'Totales · '], ['item-col-', 'Columna · '],
    ['item-', 'Ítem · '], ['obs-', 'Observaciones · '], ['da-', 'Dato adicional · '],
  ];
  const match = prefixes.find(([prefix]) => id.startsWith(prefix));
  const raw = match ? id.slice(match[0].length) : id;
  const name = raw.replace(/[-_]+/g, ' ').replace(/\b\w/g, letter => letter.toUpperCase());
  return (match?.[1] || '') + name;
}
