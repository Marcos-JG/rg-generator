// @vitest-environment jsdom
import { beforeEach, describe, expect, it } from 'vitest';
import { useConfigStore } from '../src/stores/configStore';
import { useHistoryStore } from '../src/stores/historyStore';
import { normalizeSavedDesign } from '../src/core/editorElements';

describe('saved editor design', () => {
  it('migrates old wrapper and content records into one logical block', () => {
    const migrated = normalizeSavedDesign({
      overrides: { 'section-header-qr': { width: '200px', height: '180px' }, 'header-qr': { backgroundColor: '#fff', width: '150px' } },
      positions: { 'section-header-qr': { x: 20, y: 30 }, 'header-qr': { x: 40, y: 50 } },
    });
    expect(migrated.overrides).toEqual({ 'header-qr': { width: '150px', height: '180px', backgroundColor: '#fff' } });
    expect(migrated.positions).toEqual({ 'header-qr': { x: 40, y: 50 } });
  });
  it('moves legacy header text settings onto its visible block and removes the empty header target', () => {
    const migrated = normalizeSavedDesign({
      overrides: { header: { height: '150px' }, 'header-guid': { color: 'red' }, 'header-ids': { width: '320px' } },
      positions: { header: { x: 5, y: 8 }, 'header-guid': { x: 12, y: 20 } },
    });
    expect(migrated.overrides).toEqual({ 'header-ids': { color: 'red', width: '320px' } });
    expect(migrated.positions).toEqual({ 'header-ids': { x: 12, y: 20 } });
  });
  it('removes a saved footer position while preserving its visual overrides', () => {
    const migrated = normalizeSavedDesign({
      overrides: { footer: { color: '#123456' } },
      positions: { footer: { x: 80, y: -120 }, emisor: { x: 10, y: 20 } },
    });
    expect(migrated.overrides.footer.color).toBe('#123456');
    expect(migrated.positions).toEqual({ emisor: { x: 10, y: 20 } });
  });
  beforeEach(() => useConfigStore.getState().resetAll());
  it('undoes and redoes text, dimensions, styles and configuration together', () => {
    const store = useConfigStore.getState();
    store.loadDocument('<Root/>', { docType: '01' }, { title: 'Factura' });
    store.setOverrides({ emisor: { width: '300px' } });
    store.setText('seller-name:text:0', 'Razón social');
    store.updateUserStyle({ colorPrimary: '#ff0000' });
    store.setCurrentConfig({ title: 'Factura', fieldOrders: { seller: ['seller-nit', 'seller-name'] } });
    const final = JSON.stringify(useConfigStore.persist.getOptions().partialize(useConfigStore.getState()));
    for (let i = 0; i < 4; i++) store.undo();
    expect(useConfigStore.getState().overrides).toEqual({});
    expect(useConfigStore.getState().textOverrides).toEqual({});
    expect(useConfigStore.getState().currentConfig).toEqual({ title: 'Factura' });
    for (let i = 0; i < 4; i++) store.redo();
    expect(JSON.stringify(useConfigStore.persist.getOptions().partialize(useConfigStore.getState()))).toBe(final);
  });
  it('restores the document after rehydration', async () => {
    const store = useConfigStore.getState();
    store.loadDocument('<Root/>', { country: 'sv' }, { title: 'Factura' });
    store.setText('header-title:text:1', '<b>Mi factura</b>');
    store.setOverrides({ footer: { color: '#123456' } });
    const saved = localStorage.getItem('rg-generator-config');
    store.resetAll();
    localStorage.setItem('rg-generator-config', saved);
    await useConfigStore.persist.rehydrate();
    expect(useConfigStore.getState().xmlString).toBe('<Root/>');
    expect(useConfigStore.getState().textOverrides['header-title:text:1']).toBe('<b>Mi factura</b>');
    expect(useConfigStore.getState().overrides.footer.color).toBe('#123456');
  });
  it('clears redo after a new change and isolates a new document', () => {
    const store = useConfigStore.getState();
    store.setText('title', 'A');
    store.undo();
    store.setText('title', 'B');
    expect(useHistoryStore.getState().future).toHaveLength(0);
    store.loadDocument('<Other/>', {}, {});
    expect(useConfigStore.getState().textOverrides).toEqual({});
    expect(useHistoryStore.getState().past).toHaveLength(0);
  });
});
