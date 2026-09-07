// @vitest-environment jsdom
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { act, createElement } from 'react';
import { createRoot } from 'react-dom/client';
import InteractivePreview from '../src/components/Preview/InteractivePreview';
import { useConfigStore } from '../src/stores/configStore';
import config from '../src/configs/sv/fact.json';
import { useHistoryStore } from '../src/stores/historyStore';

globalThis.IS_REACT_ACT_ENVIRONMENT = true;
let host, root;
const text = () => host.querySelector('[data-rg-text="header-title:text:1"]');
describe('direct editing interactions', () => {
  beforeEach(async () => {
    useConfigStore.getState().resetAll();
    useConfigStore.getState().loadDocument('<Root/>', {}, config);
    host = document.createElement('div');
    document.body.append(host);
    root = createRoot(host);
    await act(() => root.render(createElement(InteractivePreview)));
  });
  afterEach(async () => { await act(() => root.unmount()); host.remove(); });
  const pointer = (target, type, x, y) => target.dispatchEvent(new MouseEvent(type, { bubbles: true, cancelable: true, button: 0, clientX: x, clientY: y }));
  const geometry = () => {
    const page = host.querySelector('[data-preview-content]');
    const el = host.querySelector('[data-rg-id="header-title"]');
    page.getBoundingClientRect = () => ({ left: 0, top: 0, right: 816, bottom: 1056, width: 816 });
    el.getBoundingClientRect = () => ({ left: 100, top: 100, right: 300, bottom: 140, width: 200 });
    return { page, el };
  };
  it('keeps a single selection visible when changing between a title and an item cell', async () => {
    const originalNode = text();
    await act(() => originalNode.dispatchEvent(new MouseEvent('mouseover', { bubbles: true })));
    expect(text()).toBe(originalNode);
    await act(() => text().dispatchEvent(new MouseEvent('click', { bubbles: true })));
    expect(text()).toBe(originalNode);
    expect(host.querySelector('.rg-sel').dataset.rgId).toBe('header-title');
    await act(() => host.querySelector('[data-rg-id="item-0-Description"]').dispatchEvent(new MouseEvent('click', { bubbles: true })));
    expect(host.querySelectorAll('.rg-sel')).toHaveLength(1);
    expect(host.querySelector('.rg-sel').dataset.rgId).toBe('item-0-Description');
    await act(() => host.querySelector('[data-preview-content]').dispatchEvent(new MouseEvent('click', { bubbles: true })));
    expect(host.querySelector('.rg-sel')).toBeNull();
  });
  it('highlights and selects the same block in block mode', async () => {
    const select = host.querySelector('[aria-label="Modo de movimiento"]');
    await act(() => { select.value = 'blocks'; select.dispatchEvent(new Event('change', { bubbles: true })); });
    await act(() => host.querySelector('[data-rg-id="item-0-Description"]').dispatchEvent(new MouseEvent('mouseover', { bubbles: true })));
    expect(host.querySelector('.rg-hover').dataset.rgId).toBe('section-items');
    await act(() => host.querySelector('[data-rg-id="item-0-Description"]').dispatchEvent(new MouseEvent('click', { bubbles: true })));
    expect(host.querySelector('.rg-sel').dataset.rgId).toBe('section-items');
    expect(host.querySelector('.rg-hover')).toBeNull();
  });
  it('accepts the next selection after a cancelled drag without a trailing click', async () => {
    const { el } = geometry();
    await act(() => pointer(el, 'pointerdown', 120, 120));
    await act(() => pointer(window, 'pointermove', 240, 300));
    await act(() => window.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true })));
    const cell = host.querySelector('[data-rg-id="item-0-Description"]');
    await act(() => pointer(cell, 'pointerdown', 120, 120));
    await act(() => pointer(window, 'pointerup', 120, 120));
    await act(() => cell.dispatchEvent(new MouseEvent('click', { bubbles: true })));
    expect(host.querySelector('.rg-sel').dataset.rgId).toBe('item-0-Description');
  });
  it('drags independently of rows, commits once and restores with undo', async () => {
    const { el } = geometry();
    await act(() => pointer(el, 'pointerdown', 120, 120));
    await act(() => pointer(window, 'pointermove', 220, 320));
    await act(() => pointer(window, 'pointermove', 270, 360));
    expect(useHistoryStore.getState().past).toHaveLength(0);
    await act(() => pointer(window, 'pointerup', 270, 360));
    expect(useConfigStore.getState().positions['header-title']).toMatchObject({ x: 150, y: 240 });
    expect(useHistoryStore.getState().past).toHaveLength(1);
    expect(host.querySelector('[data-rg-id="header-title"]').style.transform).toBe('translate(150px, 240px)');
    await act(() => useConfigStore.getState().undo());
    expect(host.querySelector('[data-rg-id="header-title"]').style.transform).toBe('');
  });
  it('cancels a drag with Escape without creating history', async () => {
    const { el, page } = geometry();
    await act(() => pointer(el, 'pointerdown', 120, 120));
    await act(() => pointer(window, 'pointermove', 240, 300));
    await act(() => window.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true })));
    expect(el.style.transform).toBe('');
    expect(page.hasAttribute('data-free-moving')).toBe(false);
    expect(useConfigStore.getState().positions).toEqual({});
    expect(useHistoryStore.getState().past).toHaveLength(0);
  });
  it('does not treat a click as movement and preserves double-click editing', async () => {
    const { el } = geometry();
    await act(() => pointer(el, 'pointerdown', 120, 120));
    await act(() => pointer(window, 'pointermove', 121, 120));
    await act(() => pointer(window, 'pointerup', 121, 120));
    expect(useConfigStore.getState().positions).toEqual({});
    await act(() => text().dispatchEvent(new MouseEvent('dblclick', { bubbles: true })));
    expect(text().getAttribute('contenteditable')).toBe('true');
  });
  it('saves double-click editing, survives hover and supports undo/redo', async () => {
    const original = text().textContent;
    await act(() => text().dispatchEvent(new MouseEvent('dblclick', { bubbles: true })));
    expect(text().getAttribute('contenteditable')).toBe('true');
    text().textContent = 'Factura personalizada';
    await act(() => text().dispatchEvent(new MouseEvent('mouseover', { bubbles: true })));
    expect(text().textContent).toBe('Factura personalizada');
    await act(() => text().blur());
    expect(useConfigStore.getState().textOverrides['header-title:text:1']).toBe('Factura personalizada');
    await act(() => useConfigStore.getState().undo());
    expect(text().textContent).toBe(original);
    await act(() => useConfigStore.getState().redo());
    expect(text().textContent).toBe('Factura personalizada');
  });
  it('cancels text with Escape and does not move the design while using an input', async () => {
    const original = text().textContent;
    await act(() => text().dispatchEvent(new MouseEvent('dblclick', { bubbles: true })));
    text().textContent = 'Cancelado';
    await act(() => text().dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true })));
    expect(text().textContent).toBe(original);
    expect(useConfigStore.getState().textOverrides).toEqual({});
    await act(() => text().dispatchEvent(new MouseEvent('click', { bubbles: true })));
    const input = host.querySelector('input');
    await act(() => input.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true })));
    expect(useConfigStore.getState().overrides).toEqual({});
  });
});
