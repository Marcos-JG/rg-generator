// @vitest-environment jsdom
import { describe, it, expect } from 'vitest';
import { mkdtempSync, writeFileSync, rmSync, copyFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { execFileSync } from 'node:child_process';
import { generateXslt } from '../src/core/xsltGenerator';
import base from '../public/templates/base.xsl?raw';
import ccf from '../src/configs/sv/ccf.json';
import fact from '../src/configs/sv/fact.json';
import { bundleXslt } from '../src/core/referenceXslt';

const parse = (text, type = 'application/xml') => new DOMParser().parseFromString(text, type);
const transform = path => execFileSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', resolve('tests/transformXslt.ps1'),
  '-Stylesheet', path, '-Xml', resolve('XML-preuba/02-ccf-doctype03.xml')], { encoding: 'utf8', maxBuffer: 4 * 1024 * 1024 });

describe('XSLT export', () => {
  it.each([ccf, fact])('creates a valid stylesheet for $docType', config => {
    const xslt = generateXslt(base, config);
    const doc = parse(xslt);
    expect(doc.querySelector('parsererror')).toBeNull();
    const includes = [...doc.getElementsByTagNameNS('http://www.w3.org/1999/XSL/Transform', 'include')];
    expect(includes.map(el => el.getAttribute('href'))).toEqual(config === ccf
      ? ['RG-SharedSV_fel_2.xslt', 'Shared_ENLETRAS_fel_2.xslt'] : []);
    expect(xslt).not.toMatch(/\{\{[A-Z_]+\}\}/);
  });

  it('applies the current editor design to credit-fiscal exports', () => {
    const configured = { ...ccf, fieldOrders: { items: ['Description', 'Number', ...ccf.itemColumns.slice(1).filter(column => column.id !== 'Description').map(column => column.id)] } };
    const xslt = generateXslt(base, configured, { fontSize: '16pt', colorFont: 'red', docTitle: 'Otro' }, null, {
      overrides: { emisor: { height: '240px' }, 'col-Description': { width: '38%' } },
      positions: {},
    });
    expect(xslt).toContain('font-size:16pt');
    expect(xslt).toContain('color:red');
    expect(xslt).toContain('Otro');
    expect(xslt).toContain('height:240px');
    expect(xslt).toContain('width:38%');
    const headings = [...parse(xslt).querySelectorAll('th')].map(el => el.textContent.trim());
    expect(headings).toContain('Descripción');
    expect(headings.indexOf('Descripción')).toBeLessThan(headings.indexOf('#'));
    expect(xslt).not.toContain('No.</td><td>Codigo');
  });

  it.skipIf(process.platform !== 'win32')('compiles the configured credit-fiscal and general exports', () => {
    const folder = mkdtempSync(join(tmpdir(), 'rg-xslt-'));
    try {
      const generated = join(folder, 'generated.xsl');
      for (const name of ['RG-SharedSV_fel_2.xslt', 'Shared_ENLETRAS_fel_2.xslt']) {
        copyFileSync(resolve('public/templates', name), join(folder, name));
      }
      writeFileSync(generated, generateXslt(base, ccf));
      const actual = parse(transform(generated), 'text/html');
      const normalize = doc => doc.body.textContent.replace(/\s+/g, ' ').trim();
      expect(normalize(actual)).toContain('COMPROBANTES DE CRÉDITO FISCAL');
      expect(normalize(actual)).toContain('PANADERIA Y REPOSTERIA EL TRIGAL');
      expect([...actual.querySelectorAll('.items-table th')].map(th => th.textContent.trim())).toEqual(ccf.itemColumns.map(column => column.label));
      writeFileSync(generated, bundleXslt(generateXslt(base, ccf)));
      expect(normalize(parse(transform(generated), 'text/html'))).toContain('COMPROBANTES DE CRÉDITO FISCAL');
      writeFileSync(generated, generateXslt(base, fact));
      const general = parse(transform(generated), 'text/html');
      expect(general.body.textContent).toContain('PANADERIA Y REPOSTERIA EL TRIGAL');
      expect(general.querySelector('.totals-table').textContent).toContain('387.50');
      expect(general.body.textContent).toContain('TRESCIENTOS OCHENTA Y SIETE');
      expect(general.querySelector('tr > tr')).toBeNull();
    } finally {
      rmSync(folder, { recursive: true, force: true });
    }
  }, 30000);
});
