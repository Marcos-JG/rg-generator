import { describe, it, expect } from 'vitest';
import { validateConfig } from '../src/core/configSchema.js';

const validConfig = {
  country: 'sv',
  docType: '01',
  title: 'FACTURA',
  version: 'v2-0-0',
  sellerFields: [
    { id: 'Name', label: 'Nombre', required: true },
  ],
  buyerFields: [
    { id: 'Name', label: 'Nombre', required: true },
  ],
  itemColumns: [
    { id: 'Number', label: '#', width: '4%', required: true },
  ],
  totalsFields: [
    { id: 'VENTA_GRAVADA', label: 'Venta Gravada:', required: true },
    { id: 'TOTAL_PAGAR', label: 'TOTAL A PAGAR:', required: true },
  ],
  showSumasRow: true,
  showDteBox: true,
  dteBoxFields: ['GUID'],
  showFooter: true,
  showQR: true,
  style: {
    colorPrimary: '#020873',
    colorBorder: '#808080',
    colorTotalesBg: '#e6e6e6',
    colorTotalPagarBg: '#D1D5DB',
    fontSize: '7pt',
    fontSizeHeader: '12pt',
    fontFamily: 'Arial, Helvetica, sans-serif',
    borderRadius: '6px',
  },
};

describe('configSchema', () => {
  it('accepts a valid config', () => {
    const result = validateConfig(validConfig, 'test');
    expect(result.country).toBe('sv');
  });

  it('rejects invalid country', () => {
    const config = { ...validConfig, country: 'xx' };
    expect(() => validateConfig(config, 'test')).toThrow('Config inválido');
  });

  it('rejects missing sellerFields', () => {
    const config = { ...validConfig, sellerFields: [] };
    expect(() => validateConfig(config, 'test')).toThrow('Config inválido');
  });

  it('rejects invalid color format', () => {
    const config = {
      ...validConfig,
      style: { ...validConfig.style, colorPrimary: 'red' },
    };
    expect(() => validateConfig(config, 'test')).toThrow('Config inválido');
  });

  it('rejects invalid column width', () => {
    const config = {
      ...validConfig,
      itemColumns: [{ id: 'Number', label: '#', width: 'wide', required: true }],
    };
    expect(() => validateConfig(config, 'test')).toThrow('Config inválido');
  });
});
