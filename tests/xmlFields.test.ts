// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { mkdtempSync, writeFileSync, rmSync, copyFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { execFileSync } from 'node:child_process';
import { xmlDataFields, appendXmlFieldsHtml } from '../src/core/xmlFields';
import { editImportedXslt } from '../src/core/importedXslt';
import { generateEditorXslt } from '../src/core/editorXslt';
import { applyMovementPosition } from '../src/core/freeMovement';
import { editableHtml } from '../src/core/editableHtml';
import { useConfigStore } from '../src/stores/configStore';
import ccf from '../src/configs/sv/ccf.json';

const xml = `<Root xmlns="urn:test"><Extra><Info Name="Order" Value="OC-01"/><Info Name="Salesperson" Value="Ana"/></Extra><Item><Code>A</Code></Item><Item><Code>B</Code></Item></Root>`;
const datum = () => xmlDataFields(xml).find(field => field.label === 'Salesperson');
const field = () => ({ id: 'xml-field-test', xpath: datum().xpath, label: 'Vendedor', x: 120, y: 350 });
const source = `<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:output method="html"/><xsl:template match="/"><html><body><p>Original</p></body></html></xsl:template></xsl:stylesheet>`;

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
    const editor = { xmlFields: [field()], positions: { 'xml-field-test': { x: 20, y: 15 } }, overrides: { 'xml-field-test': { color: 'red', width: '300px' } } };
    for (const stylesheet of [editImportedXslt(source, editor), generateEditorXslt(ccf, {}, editor)]) {
      expect(stylesheet).not.toContain('Ana');
      writeFileSync(join(folder, 'design.xsl'), stylesheet);
      writeFileSync(join(folder, 'source.xml'), xml.replace('<Info Name="Order" Value="OC-01"/><Info Name="Salesperson" Value="Ana"/>', '<Info Name="Salesperson" Value="Luis"/><Info Name="Order" Value="OC-02"/>'));
      const result = execFileSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', resolve('tests/transformXslt.ps1'), '-Stylesheet', join(folder, 'design.xsl'), '-Xml', join(folder, 'source.xml')], { encoding: 'utf8' });
      const output = new DOMParser().parseFromString(result, 'text/html');
      expect(output.body.textContent).toContain('Vendedor: Luis');
      const node = [...output.querySelectorAll('div')].find(node => node.style.left === '120px');
      expect(node.style.transform.replace(/\s/g, '')).toBe('translate(20px,15px)');
      expect(node.style.color).toBe('red');
      expect(node.style.position).toBe('absolute');
      expect(output.querySelector('[data-rg-id], [data-rg-text]')).toBeNull();
    }
  } finally { rmSync(folder, { recursive: true, force: true }); }
}, 15000);
