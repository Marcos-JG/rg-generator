// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { readFileSync, writeFileSync, copyFileSync, mkdtempSync, rmSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { execFileSync } from 'node:child_process';
import { editImportedXslt, parseImportedXslt } from '../src/core/importedXslt';
import { bundleXslt, bundleXsltDocument } from '../src/core/referenceXslt';

const source = `<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/"><html><body><div><span style="color:blue">Nombre:</span><p><xsl:attribute name="style">font-size:7pt</xsl:attribute><xsl:value-of select="Root/Name"/></p><xsl:for-each select="Root/Item"><p><xsl:value-of select="."/></p></xsl:for-each></div></body></html></xsl:template></xsl:stylesheet>`;
it('accepts a saved Shared with the misdecoded BOM reported by the browser', () => {
  const shared = readFileSync('public/templates/RG-SharedSV_fel_2.xslt', 'utf8');
  const reference = readFileSync('public/templates/XSLTS3_dtesv_Carta_06141602171030_fel_1.xslt', 'utf8');
  expect(() => parseImportedXslt('ï»¿' + source)).not.toThrow();
  expect(() => parseImportedXslt(bundleXslt(reference, { 'RG-SharedSV_fel_2.xslt': 'ï»¿' + shared }))).not.toThrow();
});
it('keeps the uploaded Carta reference valid through instrumentation and includes', () => {
  const reference = readFileSync('public/templates/XSLTS3_dtesv_Carta_06141602171030_fel_1.xslt', 'utf8');
  const instrumented = editImportedXslt(reference, {}, true);
  expect(() => parseImportedXslt(instrumented)).not.toThrow();
  expect(() => parseImportedXslt(bundleXslt(instrumented))).not.toThrow();
});
it('resolves the Digifact Shared URLs and retains an existing XML document', () => {
  const reference = readFileSync('public/templates/XSLTS3_dtesv_Carta_06141602171030_fel_1.xslt', 'utf8');
  const doc = parseImportedXslt(reference.replace('href="RG-SharedSV_fel_2.xslt"', 'href="https://sv-test-pubresources.s3.us-east-1.amazonaws.com/corexslt/RG-SharedSV_fel_2.xslt"'));
  expect(bundleXsltDocument(doc)).toBe(doc);
  expect(doc.getElementsByTagNameNS('http://www.w3.org/1999/XSL/Transform', 'include')).toHaveLength(0);
});
it('resolves external nested includes, reports missing files and rejects cycles', () => {
  const sheet = content => `<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">${content}</xsl:stylesheet>`;
  const main = sheet('<xsl:include href="lib/a.xsl"/>');
  const files = { 'a.xsl': sheet('<xsl:include href="b.xsl"/>'), 'b.xsl': sheet('<xsl:template name="external">Externo</xsl:template>') };
  const bundled = bundleXslt(main, files);
  expect(bundled).toContain('name="external"');
  expect(bundled).not.toContain('xsl:include');
  expect(() => bundleXslt(main)).toThrow('lib/a.xsl');
  expect(() => bundleXslt(main, { ...files, 'b.xsl': sheet('<xsl:include href="a.xsl"/>') })).toThrow('ciclo');
});
it('rejects non-XSLT and unsupported versions before import', () => {
  expect(() => parseImportedXslt('<html/>')).toThrow('válida');
  expect(() => parseImportedXslt(source.replace('version="1.0"', 'version="2.0"'))).toThrow('1.0');
});
it('patches original literal and dynamic styles without losing XML bindings', () => {
  const doc = parseImportedXslt(editImportedXslt(source, {
    overrides: { 'import-1': { color: 'red', width: '200px' }, 'import-2': { fontSize: '12px' } },
    positions: { 'import-2': { x: 25, y: 10, z: 2 } },
    textOverrides: { 'import-label-0:text:0': 'Cliente {nombre} & dato:' },
  }));
  expect(doc.querySelector('span').textContent).toBe('Cliente {nombre} & dato:');
  expect(doc.querySelector('span').getAttribute('style')).toContain('color: red');
  const dynamic = doc.getElementsByTagNameNS('http://www.w3.org/1999/XSL/Transform', 'attribute')[0];
  expect(dynamic.textContent).toContain('font-size:7pt;font-size: 12px');
  expect(dynamic.textContent).toContain('translate(25px, 10px)');
  expect(doc.getElementsByTagNameNS('http://www.w3.org/1999/XSL/Transform', 'value-of')[0].getAttribute('select')).toBe('Root/Name');
  expect(doc.querySelector('[data-rg-id], [data-rg-text]')).toBeNull();
});
it('gives source elements stable identities and wraps only literal labels', () => {
  const doc = parseImportedXslt(editImportedXslt(source, {}, true));
  expect(doc.querySelector('[data-rg-id="import-1"] [data-rg-text]').getAttribute('data-rg-text')).toBe('import-label-0:text:0');
  expect(doc.querySelector('[data-rg-id="import-2"] [data-rg-text]')).toBeNull();
});
it('exports opt-in document design without changing bindings or adding styles to untouched templates', () => {
  const unchanged = parseImportedXslt(editImportedXslt(source));
  expect(unchanged.querySelector('style')).toBeNull();
  const doc = parseImportedXslt(editImportedXslt(source.replace('<body>', '<head></head><body>'), {
    visualStyle: { designLineHeight: '1.8', designFontFamily: 'Georgia, serif', designCellPadding: '8px', designBorderWidth: '2px' },
  }));
  expect(doc.querySelector('head style').textContent).toContain('line-height:1.8');
  expect(doc.querySelector('head style').textContent).toContain('font-family:Georgia, serif');
  expect(doc.querySelector('head style').textContent).toContain('padding:8px');
  expect(doc.getElementsByTagNameNS('http://www.w3.org/1999/XSL/Transform', 'value-of')[0].getAttribute('select')).toBe('Root/Name');
});
it.skipIf(process.platform !== 'win32')('transforms the supplied standard and edited stylesheet with .NET while keeping future XML data live', () => {
  const folder = mkdtempSync(join(tmpdir(), 'rg-import-'));
  try {
    for (const name of ['RG-SharedSV_fel_2.xslt', 'Shared_ENLETRAS_fel_2.xslt']) copyFileSync(resolve('public/templates', name), join(folder, name));
    const standard = readFileSync('public/templates/XSLTS3_dtesv_Carta_Predeterminada6_fel_1.xslt', 'utf8');
    const editor = { overrides: { 'import-0': { backgroundColor: 'red' } }, positions: { 'import-1': { x: 15, y: 20 } } };
    const xml = readFileSync('XML-preuba/02-ccf-doctype03.xml', 'utf8');
    const transform = (xslt, input) => {
      writeFileSync(join(folder, 'design.xsl'), xslt);
      writeFileSync(join(folder, 'source.xml'), input);
      return execFileSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', resolve('tests/transformXslt.ps1'), '-Stylesheet', join(folder, 'design.xsl'), '-Xml', join(folder, 'source.xml')], { encoding: 'utf8', maxBuffer: 4 * 1024 * 1024 });
    };
    const original = new DOMParser().parseFromString(transform(standard, xml), 'text/html');
    const edited = new DOMParser().parseFromString(transform(editImportedXslt(standard, editor), xml), 'text/html');
    expect(edited.body.textContent).toBe(original.body.textContent);
    expect(edited.querySelector('.page').style.backgroundColor).toBe('red');
    expect(edited.querySelector('[data-rg-id]')).toBeNull();
    const preview = new DOMParser().parseFromString(transform(bundleXslt(editImportedXslt(standard, editor, true)), xml), 'text/html');
    expect(preview.querySelector('[data-rg-id="import-0"]').style.backgroundColor).toBe('red');
    expect(preview.querySelector('.items-table[data-drag-section="items"]')).not.toBeNull();
    expect(preview.body.textContent).toBe(original.body.textContent);
    const alternate = transform(editImportedXslt(standard, editor), xml.replace('Value="DISCHAVA"', 'Value="Empresa nueva importada"'));
    expect(alternate).toContain('Empresa nueva importada');
  } finally { rmSync(folder, { recursive: true, force: true }); }
}, 30000);
