// @vitest-environment jsdom
import { it, expect } from 'vitest';
import { buildPreviewHtml } from '../src/components/Preview/buildPreviewHtml';
import { extractXmlData } from '../src/core/xmlParser';
import ccf from '../src/configs/sv/ccf.json';

const xml = `<DTE><Identificacion><NumeroDocumento>123</NumeroDocumento></Identificacion>
  <Emisor><Nombre>Empresa</Nombre></Emisor>
  <Receptor><Nombre>Cliente</Nombre></Receptor>
  <Items><Item><Quantity>1</Quantity><Description>Prod</Description><UnitPrice>5.00</UnitPrice></Item></Items>
  <AdditionalDocumentInfo>
    <AdditionalInfo><AditionalData>
      <Data Name="APENDICE"><Info Name="CodigoVendedor" Value="RUTA 7"/><Info Name="CodigoCliente" Value="CL0871"/></Data>
    </AditionalData></AdditionalInfo>
  </AdditionalDocumentInfo>
</DTE>`;

it('applies row textAlign to BOTH label and value cells on appendix rows', () => {
  const currentConfig = { ...ccf };
  const html = buildPreviewHtml({
    currentConfig,
    userStyle: {},
    overrides: { 'apx-0-CodigoVendedor': { textAlign: 'center' } },
    xmlData: extractXmlData(new DOMParser().parseFromString(xml, 'text/xml')),
  });
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const row = doc.querySelector('[data-rg-id="apx-0-CodigoVendedor"]');
  const label = row.querySelector('td:first-child');
  const value = row.querySelector('td:nth-child(2)');
  expect(label.style.textAlign).toBe('center');
  expect(value.style.textAlign).toBe('center');
  expect(value.textContent).toContain('RUTA 7');
});