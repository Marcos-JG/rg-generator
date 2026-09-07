// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { movementDelta, movementTarget } from '../src/core/freeMovement';
import { editableHtml, cleanPreviewHtml } from '../src/core/editableHtml';
import { useConfigStore } from '../src/stores/configStore';
import { useHistoryStore } from '../src/stores/historyStore';

describe('free movement', () => {
  it('constrains movements to the page and converts scaled coordinates', () => {
    const page = { left: 20, top: 30, right: 420, bottom: 530 };
    const rect = { left: 70, top: 80, right: 170, bottom: 130 };
    expect(movementDelta(rect, page, 30, 40, 0.5)).toEqual({ x: 60, y: 80 });
    expect(movementDelta(rect, page, 1000, -1000)).toEqual({ x: 250, y: -50 });
  });
  it('distinguishes a field from its block and excludes resize handles', () => {
    const doc = new DOMParser().parseFromString('<div data-rg-id="section-emisor" data-drag-section="emisor"><p data-rg-id="name"><span>Nombre</span><i data-resize="e"></i></p></div>', 'text/html');
    expect(movementTarget(doc.querySelector('span')).dataset.rgId).toBe('name');
    expect(movementTarget(doc.querySelector('span'), 'blocks').dataset.rgId).toBe('section-emisor');
    expect(movementTarget(doc.querySelector('i'))).toBeNull();
  });
  it('keeps moved fields visible outside their sections and exports their positions', () => {
    const html = editableHtml('<div style="overflow:hidden"><table><tr data-rg-id="field"><td>Nombre</td></tr></table></div>', {}, { field: { x: 180, y: 240, z: 3 } });
    const doc = new DOMParser().parseFromString(html, 'text/html');
    expect(doc.querySelector('tr').style.transform).toBe('translate(180px, 240px)');
    expect(doc.querySelector('div').style.overflow).toBe('visible');
    expect(cleanPreviewHtml(doc.body)).toContain('translate(180px, 240px)');
  });
  it('persists movement and restores it with undo and redo', async () => {
    const store = useConfigStore.getState();
    store.resetAll();
    store.setPosition('field', { x: 150, y: 220, z: 1 });
    expect(useHistoryStore.getState().past).toHaveLength(1);
    store.undo();
    expect(useConfigStore.getState().positions).toEqual({});
    store.redo();
    expect(useConfigStore.getState().positions.field.x).toBe(150);
    const saved = localStorage.getItem('rg-generator-config');
    store.resetAll();
    localStorage.setItem('rg-generator-config', saved);
    await useConfigStore.persist.rehydrate();
    expect(useConfigStore.getState().positions.field.y).toBe(220);
  });
});
