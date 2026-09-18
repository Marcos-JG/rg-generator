// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { mkdtempSync, writeFileSync, rmSync, copyFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { execFileSync } from 'node:child_process';
import { xmlDataFields, xmlPaletteFields, appendXmlFieldsHtml } from '../src/core/xmlFields';
import { editImportedXslt } from '../src/core/importedXslt';
import { generateEditorXslt } from '../src/core/editorXslt';
import { applyMovementPosition } from '../src/core/freeMovement';
import { editableHtml, cleanPreviewHtml, applySelection } from '../src/core/editableHtml';
import { useConfigStore } from '../src/stores/configStore';
import ccf from '../src/configs/sv/ccf.json';

const xml = `<Root xmlns="urn:test"><Extra><Info Name="Order" Value="OC-01"/><Info Name="Salesperson" Value="Ana"/></Extra><Item><Code>A</Code></Item><Item><Code>B</Code></Item></Root>`;
const datum = () => xmlDataFields(xml).find(field => field.label === 'Salesperson');
const field = () => ({ id: 'xml-field-test', xpath: datum().xpath, label: 'Vendedor', x: 120, y: 350 });
const source = `<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:output method="html"/><xsl:template match="/"><html><body><p>Original</p></body></html></xsl:template></xsl:stylesheet>`;
const logoXml = xml.replace('<Extra>', '<Seller><TaxID>123</TaxID></Seller><Extra>');
const logo = () => ({ ...xmlPaletteFields(logoXml)[0], id: 'xml-logo-test', x: 200, y: 60 });

it('removes all dragged additions together and restores them with undo without altering the original design', () => {
  const store = useConfigStore.getState(); store.resetAll();
  store.addXmlField(field()); store.addXmlField(logo());
  store.setOverrides({ emisor: { color: 'blue' }, [field().id]: { color: 'red' } });
  store.setPosition(field().id, { x: 10, y: 20 }); store.setText(field().id + ':text:0', 'Cliente: ');
  store.clearXmlFields();
  expect(useConfigStore.getState().xmlFields).toEqual([]);
  expect(useConfigStore.getState().overrides).toEqual({ emisor: { color: 'blue' } });
  expect(useConfigStore.getState().positions).toEqual({}); expect(useConfigStore.getState().textOverrides).toEqual({});
  store.undo(); expect(useConfigStore.getState().xmlFields).toHaveLength(2);
  expect(useConfigStore.getState().positions[field().id]).toEqual({ x: 10, y: 20 });
  store.redo(); expect(useConfigStore.getState().xmlFields).toEqual([]); store.resetAll();
});

it('adds the issuer logo as an image with an XML binding', () => {
  expect(logo().kind).toBe('logo');
  const doc = new DOMParser().parseFromString(appendXmlFieldsHtml('', [logo()], () => logo().value, {}), 'text/html');
  expect(doc.querySelector('img').getAttribute('src')).toBe('https://digifact-logo.s3.amazonaws.com/SV/logo/123.jpg');
  expect(doc.querySelector('div').style.position).toBe('absolute');
  expect(doc.querySelector('button').getAttribute('aria-label')).toBe('Eliminar Logo del emisor');
  expect(cleanPreviewHtml(doc.body)).not.toContain('button');
});
it('shows the remove button only on the selected added field, never on hover', () => {
  const doc = new DOMParser().parseFromString(appendXmlFieldsHtml('', [field(), logo()], () => 'Ana', {}), 'text/html');
  expect(doc.querySelectorAll('[data-rg-remove]:not([hidden])')).toHaveLength(0);
  applySelection(doc.body, { hovered: field().id });
  expect(doc.querySelectorAll('[data-rg-remove]:not([hidden])')).toHaveLength(0);
  applySelection(doc.body, { selected: field().id });
  expect(doc.querySelectorAll('[data-rg-remove]:not([hidden])')).toHaveLength(1);
  expect(doc.querySelector('[data-rg-remove]:not([hidden])').getAttribute('data-rg-remove')).toBe(field().id);
  applySelection(doc.body, { selected: logo().id });
  expect(doc.querySelector('[data-rg-remove]:not([hidden])').getAttribute('data-rg-remove')).toBe(logo().id);
  applySelection(doc.body, {});
  expect(doc.querySelectorAll('[data-rg-remove]:not([hidden])')).toHaveLength(0);
});
it('makes added data resizable and preserves its dimensions without exporting editor handles', () => {
  const doc = new DOMParser().parseFromString(appendXmlFieldsHtml('', [field()], () => 'Ana', {
    overrides: { [field().id]: { width: '320px', height: '80px', fontSize: '24px' } },
  }), 'text/html');
  const node = doc.querySelector<HTMLElement>('[data-rg-id]');
  expect(node.getAttribute('data-drag-section')).toBe(field().id);
  expect(node.querySelector('[data-resize="he"]')).not.toBeNull();
  expect(node.style.width).toBe('320px'); expect(node.style.height).toBe('80px');
  expect(node.style.fontSize).toBe('24px');
  const exported = new DOMParser().parseFromString(cleanPreviewHtml(doc.body), 'text/html');
  expect(exported.querySelector('[data-resize]')).toBeNull();
  expect(exported.querySelector('div').style.width).toBe('320px');
  expect(exported.body.textContent).toContain('Ana');
});

it('keeps an added field out of document flow during its first and subsequent moves and after saving', () => {
  const html = appendXmlFieldsHtml('<p>Existing document content</p>', [field()], () => 'Ana', {});
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const node = doc.querySelector<HTMLElement>('[data-rg-id]');
  for (const position of [{ x: 15, y: 20 }, { x: 25, y: 30 }]) {
    applyMovementPosition(node, position);
    expect(node.style.position).toBe('absolute');
    expect(node.style.left).toBe('120px'); expect(node.style.top).toBe('350px');
    const saved = new DOMParser().parseFromString(editableHtml(html, {}, { [field().id]: position }), 'text/html');
    const restored = saved.querySelector<HTMLElement>('[data-rg-id]');
    expect(restored.style.position).toBe('absolute');
    expect(restored.style.transform).toBe(`translate(${position.x}px, ${position.y}px)`);
  }
});

it('lists attributes and separate repeated elements without confusing their values', () => {
  const fields = xmlDataFields(xml);
  expect(fields.filter(field => field.label === 'Code')).toHaveLength(2);
  expect(fields.filter(field => field.label === 'Code').map(field => field.value)).toEqual(['A', 'B']);
  expect(new Set(fields.map(field => field.xpath)).size).toBe(fields.length);
  expect(datum().value).toBe('Ana');
  expect(xmlDataFields('<broken>')).toEqual([]);
});

it('escapes XML values and labels while keeping their selection and placement', () => {
  const doc = new DOMParser().parseFromString(appendXmlFieldsHtml('<p>Original</p>', [{ ...field(), label: '<Cliente>' }], () => '<script>valor</script>', { overrides: { 'xml-field-test': { color: 'red' } } }), 'text/html');
  expect(doc.querySelector('script')).toBeNull();
  expect(doc.querySelector('[data-rg-value]').textContent).toBe('<script>valor</script>');
  expect(doc.querySelector('[data-rg-id]').style.left).toBe('120px');
  expect(doc.querySelector('[data-rg-id]').style.color).toBe('red');
});

it('persists additions and includes removal and insertion in undo/redo', async () => {
  const store = useConfigStore.getState(); store.resetAll(); store.addXmlField(field());
  const saved = localStorage.getItem('rg-generator-config');
  store.undo(); expect(useConfigStore.getState().xmlFields).toEqual([]);
  store.redo(); expect(useConfigStore.getState().xmlFields).toEqual([field()]);
  store.removeXmlField(field().id); expect(useConfigStore.getState().xmlFields).toEqual([]);
  store.undo(); expect(useConfigStore.getState().xmlFields).toEqual([field()]);
  store.resetAll(); localStorage.setItem('rg-generator-config', saved);
  await useConfigStore.persist.rehydrate(); expect(useConfigStore.getState().xmlFields).toEqual([field()]);
  store.resetAll();
});

it.skipIf(process.platform !== 'win32')('transforms imported and generated XSLT with .NET using future XML values', () => {
  const folder = mkdtempSync(join(tmpdir(), 'rg-xml-fields-'));
  try {
    for (const name of ['RG-SharedSV_fel_2.xslt', 'Shared_ENLETRAS_fel_2.xslt']) copyFileSync(resolve('public/templates', name), join(folder, name));
    const editor = { xmlFields: [field(), logo()], positions: { 'xml-field-test': { x: 20, y: 15 } }, overrides: { 'xml-field-test': { color: 'red', width: '300px' } } };
    for (const stylesheet of [editImportedXslt(source, editor), generateEditorXslt(ccf, {}, editor)]) {
      expect(stylesheet).not.toContain('Ana');
      writeFileSync(join(folder, 'design.xsl'), stylesheet);
      writeFileSync(join(folder, 'source.xml'), logoXml.replace('<TaxID>123</TaxID>', '<TaxID>456</TaxID>').replace('<Info Name="Order" Value="OC-01"/><Info Name="Salesperson" Value="Ana"/>', '<Info Name="Salesperson" Value="Luis"/><Info Name="Order" Value="OC-02"/>'));
      const result = execFileSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', resolve('tests/transformXslt.ps1'), '-Stylesheet', join(folder, 'design.xsl'), '-Xml', join(folder, 'source.xml')], { encoding: 'utf8' });
      const output = new DOMParser().parseFromString(result, 'text/html');
      expect(output.body.textContent).toContain('Vendedor: Luis');
      expect(output.querySelector('img[alt="Logo del emisor"]').getAttribute('src')).toBe('https://digifact-logo.s3.amazonaws.com/SV/logo/456.jpg');
      const node = [...output.querySelectorAll('div')].find(node => node.style.left === '120px');
      expect(node.style.transform.replace(/\s/g, '')).toBe('translate(20px,15px)');
      expect(node.style.color).toBe('red');
      expect(node.style.position).toBe('absolute');
      expect(output.querySelector('[data-rg-id], [data-rg-text]')).toBeNull();
    }
  } finally { rmSync(folder, { recursive: true, force: true }); }
}, 15000);
