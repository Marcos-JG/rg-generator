// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { generateEditorXslt } from '../src/core/editorXslt';
import { editImportedXslt } from '../src/core/importedXslt';
import { documentCss } from '../src/core/documentCss';
import ccf from '../src/configs/sv/ccf.json';

it('keeps Carta as the default and exports Oficio with matching paper and content heights', () => {
  expect(documentCss()).toContain('min-height:11in');
  const doc = new DOMParser().parseFromString(generateEditorXslt(ccf, { pageSize: 'oficio' }, {}), 'application/xml');
  expect(doc.querySelector('parsererror')).toBeNull();
  expect(doc.querySelector('head style').textContent).toContain('size:8.5in 13in');
  expect(doc.querySelector('.rg-design').getAttribute('style')).toContain('min-height:12.5in');
});

it('exports the selected paper size in an external XSLT while preserving XML bindings', () => {
  const source = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/"><html><head/><body><xsl:value-of select="Root/Name"/></body></html></xsl:template></xsl:stylesheet>';
  const doc = new DOMParser().parseFromString(editImportedXslt(source, { visualStyle: { pageSize: 'oficio' } }), 'application/xml');
  expect(doc.querySelector('head style').textContent).toContain('size:8.5in 13in');
  expect(doc.getElementsByTagNameNS('http://www.w3.org/1999/XSL/Transform', 'value-of')[0].getAttribute('select')).toBe('Root/Name');
});
