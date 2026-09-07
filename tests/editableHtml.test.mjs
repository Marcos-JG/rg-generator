// @vitest-environment jsdom
import { describe, it, expect } from 'vitest';
import { editableHtml, cleanPreviewHtml } from '../src/core/editableHtml';
import { buildPreviewHtml } from '../src/components/Preview/buildPreviewHtml';
import config from '../src/configs/sv/fact.json';

const parse = html => new DOMParser().parseFromString(html, 'text/html');
describe('editable document rendering', () => {
  it.each(['seller-name', 'buyer-name', 'item-0-Description', 'header-title', 'section-emisor'])('marks selection consistently for %s', selected => {
    const html = buildPreviewHtml({ currentConfig: config, userStyle: {}, overrides: {},
      xmlData: { seller: { Name: 'ACME' }, buyer: { Name: 'Cliente' }, items: [{ Description: 'Producto' }] },
      selected: 'header', hovered: 'header-logo' });
    const doc = parse(editableHtml(html, {}, {}, { selected, hovered: selected }));
    expect(doc.querySelectorAll('.rg-sel')).toHaveLength(1);
    expect(doc.querySelector('.rg-sel').dataset.rgId).toBe(selected);
    expect(doc.querySelector('.rg-hover')).toBeNull();
    expect(cleanPreviewHtml(doc.body)).not.toContain('rg-sel');
  });
  it('edits a text fragment without deleting data or markup and escapes inserted text', () => {
    const html = '<table><tr data-rg-id="seller-name"><td>Nombre:<div class="col-resize-handle"></div></td><td>ACME</td></tr></table>';
    const doc = parse(editableHtml(html, { 'seller-name:text:0': '<img src=x onerror=alert(1)>' }));
    expect(doc.querySelector('td').textContent).toBe('<img src=x onerror=alert(1)>');
    expect(doc.querySelectorAll('td')[1].textContent).toBe('ACME');
    expect(doc.querySelector('img')).toBeNull();
    expect(doc.querySelector('.col-resize-handle')).not.toBeNull();
    expect(parse(editableHtml(html, { 'seller-name:text:0': '' })).querySelector('td').textContent).toBe('');
  });
  it('keeps edited headers and column widths attached to their columns after reordering', () => {
    const first = config.itemColumns[0].id;
    const args = { currentConfig: { ...config, fieldOrders: { items: config.itemColumns.map(c => c.id).reverse() } },
      userStyle: {}, xmlData: null, overrides: { ['col-' + first]: { width: '150px' } } };
    const doc = parse(editableHtml(buildPreviewHtml(args), { ['col-' + first + ':text:0']: 'Mi columna' }));
    const header = doc.querySelector(`[data-rg-id="col-${first}"]`);
    expect(header.textContent).toBe('Mi columna');
    expect(header.style.width).toBe('150px');
  });
  it('exports visible changes without selection or editing controls', () => {
    const doc = parse('<div id="page"><p class="rg-sel field-draggable" data-rg-id="a" draggable="true" style="color:red">Editado<span data-resize="e"></span><span class="col-resize-handle"></span></p></div>');
    const output = parse(cleanPreviewHtml(doc.querySelector('#page')));
    expect(output.querySelector('p').textContent).toBe('Editado');
    expect(output.querySelector('p').style.color).toBe('red');
    expect(output.querySelector('[data-resize], .rg-sel, [draggable], .col-resize-handle')).toBeNull();
  });
});
