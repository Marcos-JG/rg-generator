// @vitest-environment jsdom
import { beforeEach, describe, expect, it } from 'vitest';
import { useConfigStore } from '../src/stores/configStore';
import { useHistoryStore } from '../src/stores/historyStore';

describe('saved editor design', () => {
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
