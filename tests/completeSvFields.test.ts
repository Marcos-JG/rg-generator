// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { extractXmlData, parseXmlFile } from '../src/core/xmlParser';
import { getConfig } from '../src/configs';
import { generateXslt } from '../src/core/xsltGenerator';
import { buildPreviewHtml } from '../src/components/Preview/buildPreviewHtml';
import base from '../public/templates/base.xsl?raw';
import { readFileSync } from 'node:fs';

const xml = `<?xml version="1.0"?><Root>
  <CountryCode>SV</CountryCode><Version>3</Version>
  <Header><DocType>05</DocType><GUID>ABC-123</GUID><AdditionalIssueType>00</AdditionalIssueType><IssuedDateTime>2026-04-15T15:54:30</IssuedDateTime>
    <AdditionalIssueDocInfo><Info Name="TipoModelo" Value="1"/><Info Name="TipoOperacion" Value="2"/><Info Name="CodEstPuntoV" Value="M001P001"/><Info Name="Secuencial" Value="137"/></AdditionalIssueDocInfo>
  </Header>
  <Seller><Name>Emisor</Name><TaxID>01061211540019</TaxID><TaxIDAdditionalInfo><Info Name="NRC" Value="2309467"/><Info Name="CodigoActividad" Value="27900"/><Info Name="DescActividad" Value="Fabricación"/></TaxIDAdditionalInfo></Seller>
  <Buyer><Name>Cliente</Name><TaxID>037609047</TaxID><TaxIDAdditionalInfo><Info Name="NRC" Value="3253751"/><Info Name="CodigoActividad" Value="43210"/><Info Name="DescActividad" Value="Instalaciones eléctricas"/></TaxIDAdditionalInfo><Contact><PhoneList><Phone>2222-2222</Phone></PhoneList></Contact></Buyer>
  <Items><Item><Quantity>2</Quantity><UnitOfMeasure>59</UnitOfMeasure><Description>Producto</Description><UnitPrice>10.50</UnitPrice></Item></Items>
  <Totals><TotalTaxes><TotalTax><Code>20</Code><Description>IVA</Description><Amount>2.73</Amount></TotalTax></TotalTaxes><InWords>VEINTITRÉS DÓLARES</InWords></Totals>
  <AdditionalDocumentInfo><AdditionalInfo><AditionalData>
    <Data Name="DOC_RELACIONADO"><Info Name="TipoDocumento" Value="03"/><Info Name="NumDocumento" Value="DTE-03-X"/><Info Name="FechaEmision" Value="2026-04-01"/></Data>
    <Data Name="OTROS_DOC_RELACIONADOS"><Info Name="CodigoDocAsociado" Value="4"/><Info Name="DescDoc" Value="Contrato"/></Data>
    <Data Name="APENDICE"><Info Name="OrdenCompra" Value="OC-55"/><Info Name="NombreEntrega" Value="Ana"/><Info Name="DocuEntrega" Value="123"/></Data>
  </AditionalData></AdditionalInfo></AdditionalDocumentInfo>
</Root>`;

describe('complete Salvadoran document fields', () => {
  it('selects the correct credit-note configuration', () => {
    const { metadata } = parseXmlFile(xml);
    expect(metadata.docType).toBe('05');
    expect(getConfig('sv', metadata.docType).title).toBe('NOTA DE CRÉDITO');
    expect(getConfig('sv', '06').title).toBe('NOTA DE DÉBITO');
  });

  it('extracts the additional fields used by the Digifact stylesheet', () => {
    const data = extractXmlData(new DOMParser().parseFromString(xml, 'text/xml'));
    expect(data.buyer).toMatchObject({ NRC: '3253751', CodigoActividad: '43210', DescActividad: 'Instalaciones eléctricas', Phone: '2222-2222' });
    expect(data.header).toMatchObject({ AdditionalIssueType: '00', TipoModelo: '1', TipoTransmision: '2' });
    expect(data.items[0]).toMatchObject({ Qty: '2', Price: '10.50' });
    expect(data.taxes[0]).toEqual({ code: '20', description: 'IVA', amount: '2.73' });
    expect(data.relatedDocuments[0].NumDocumento).toBe('DTE-03-X');
    expect(data.otherDocuments[0].DescDoc).toBe('Contrato');
    expect(data.appendix).toContainEqual({ name: 'OrdenCompra', value: 'OC-55' });
    expect(data.responsible).toMatchObject({ NombreEntrega: 'Ana', DocuEntrega: '123' });
  });

  it('reads quantities, prices and totals from the existing Digifact XML shape', () => {
    const existing = readFileSync('XML-preuba/02-ccf-doctype03.xml', 'utf8');
    const data = extractXmlData(new DOMParser().parseFromString(existing, 'text/xml'));
    expect(data.items[0]).toMatchObject({ Qty: '25.0000', Price: '20.000000' });
    expect(data.totals).toMatchObject({ TOTAL_GRAVADA: '387.5000', SUBTOTAL: '387.5', TOTAL_PAGAR: '387.5000', MONTO_TOTAL_OPERACION: '387.5000' });
  });

  it('generates safe conditional calls for all additional groups', () => {
    const xslt = generateXslt(base, getConfig('sv', '05'));
    expect(new DOMParser().parseFromString(xslt, 'application/xml').querySelector('parsererror')).toBeNull();
    expect(xslt).toContain("Data[@Name='DOC_RELACIONADO']");
    expect(xslt).toContain("Data[@Name='OTROS_DOC_RELACIONADOS']");
    expect(xslt).toContain("Info[@Name='NombreEntrega'");
    expect(xslt).toContain('Root/Totals/TotalTaxes/TotalTax');
    expect(xslt).toContain('Qty');
    expect(xslt).toContain('Price');
  });

  it('shows additional data only after the user adds the field', () => {
    const data = extractXmlData(new DOMParser().parseFromString(xml, 'text/xml'));
    const config = getConfig('sv', '05');
    const withoutFields = buildPreviewHtml({ currentConfig: { ...config, adendaFields: [] }, userStyle: {}, xmlData: data, overrides: {} });
    expect(withoutFields).not.toContain('data-rg-id="datos-adicionales"');
    expect(withoutFields).toContain('data-rg-id="apendice"');
    expect(withoutFields).toContain('data-rg-id="responsables"');
    expect(withoutFields).toContain('INFORMACIÓN ADICIONAL');

    const withFieldsConfig = { ...config, adendaFields: [{ id: 'OrdenCompra', label: 'Orden de compra', required: false, addedByUser: true }] };
    const withFields = buildPreviewHtml({ currentConfig: withFieldsConfig, userStyle: {}, xmlData: data, overrides: {} });
    expect(withFields).toContain('data-rg-id="datos-adicionales"');
    expect(withFields).toContain('OC-55');
    const xslt = generateXslt(base, withFieldsConfig);
    expect(xslt).toContain('Orden de compra:');
    expect(new DOMParser().parseFromString(xslt, 'application/xml').documentElement.textContent).toContain('Orden de compra:');
  });

  it('always renders the footer once and after the final information sections', () => {
    const data = extractXmlData(new DOMParser().parseFromString(xml, 'text/xml'));
    const config = { ...getConfig('sv', '05'), layoutGrid: [['footer'], ['emisor', 'receptor'], ['items']] };
    const html = buildPreviewHtml({ currentConfig: config, userStyle: {}, xmlData: data, overrides: {} });
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const footer = doc.querySelector('[data-rg-id="footer"]');
    expect(doc.querySelectorAll('[data-rg-id="footer"]')).toHaveLength(1);
    expect(footer.compareDocumentPosition(doc.querySelector('[data-rg-id="apendice"]')) & Node.DOCUMENT_POSITION_PRECEDING).toBeTruthy();
    expect(footer.compareDocumentPosition(doc.querySelector('[data-rg-id="responsables"]')) & Node.DOCUMENT_POSITION_PRECEDING).toBeTruthy();
    expect(footer.getAttribute('data-drag-section')).toBeNull();
  });
});
