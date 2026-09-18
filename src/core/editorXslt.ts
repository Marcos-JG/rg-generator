import { buildPreviewHtml } from '../components/Preview/buildPreviewHtml';
import { editableHtml } from './editableHtml';
import { escapeXml as esc } from './escapeXml';
import { documentCss } from './documentCss';
import { bundleXslt, isReferenceDocument } from './referenceXslt';

const XSL = 'http://www.w3.org/1999/XSL/Transform';
const value = select => `<xsl:value-of select="${esc(select)}"/>`;
const literal = text => `<xsl:text>${esc(text)}</xsl:text>`;
const choose = (test, yes, no = '') => `<xsl:choose><xsl:when test="${esc(test)}">${yes}</xsl:when><xsl:otherwise>${no}</xsl:otherwise></xsl:choose>`;
const fallback = (paths, last = '') => paths.reduceRight((next, path) => choose(`string(${path}) != ''`, value(path), next), literal(last));
const money = expr => choose(`number(${expr}) = number(${expr})`, value(`format-number(${expr},'#,##0.00')`), literal('0.00'));
const info = (root, name) => `${root}/Info[@Name=${xpathLiteral(name)}]/@Value`;
function xpathLiteral(text) {
  if (!text.includes("'")) return `'${text}'`;
  if (!text.includes('"')) return `"${text}"`;
  return `concat(${text.split("'").map(part => `'${part}'`).join(`,"'",`)})`;
}
const additional = '/Root/AdditionalDocumentInfo';
const dataPath = name => `${additional}/AdditionalInfo/AditionalData/Data[@Name='${name}']`;
const charge = code => `/Root/Totals/*[self::TotalCharges or self::Charges]/*[self::TotalCharge or self::Charge][Code='${code}']/Amount`;
const totalInfo = name => info('/Root/Totals/AdditionalInfo', name);

// Compile the canvas markup with symbolic values. The layout is built once by
// buildPreviewHtml; only data bindings and repeated/conditional rows become XSL.
// No values from the uploaded invoice are embedded in the reusable stylesheet.
export function generateEditorXslt(config, userStyle: Partial<import('../types/editor').UserStyle> = {}, editor: import('../types/editor').EditorState = {}) {
  const tokens = new Map();
  const bind = instruction => {
    const key = `RGXVALUE${tokens.size}END`;
    tokens.set(key, instruction);
    return key;
  };
  const select = path => bind(value(path));
  const conditions = new Map();
  const parties: Record<string, Record<string, string>> = {};
  const fieldIds = { Name:'name', TaxID:'nit', NRC:'nrc', TaxIDType:'taxidtype', Address:'address',
    Phone:'phone', Email:'email', NombreComercial:'nombre-comercial', TipoEstablecimiento:'tipo-establecimiento' };
  for (const party of ['seller', 'buyer']) {
    const root = `/Root/${party === 'seller' ? 'Seller' : 'Buyer'}`;
    const paths = { Name:`${root}/Name`, TaxID:`${root}/TaxID`, TaxIDType:`${root}/TaxIDType`,
      NRC:info(`${root}/TaxIDAdditionalInfo`, 'NRC'),
      CodigoActividad:info(`${root}/TaxIDAdditionalInfo`, 'CodigoActividad'),
      DescActividad:info(`${root}/TaxIDAdditionalInfo`, 'DescActividad'),
      Address:`${root}/AddressInfo/Address`, Phone:`${root}/Contact/PhoneList/Phone`, Email:`${root}/Contact/EmailList/Email`,
      NombreComercial:info(`${root}/AdditionlInfo`, 'NombreComercial'), TipoEstablecimiento:info(`${root}/AdditionlInfo`, 'TipoEstablecimiento') };
    parties[party] = Object.fromEntries(Object.entries(paths).map(([key, path]) => [key, select(path)]));
    for (const [key, id] of Object.entries(fieldIds)) conditions.set(`${party}-${id}`, `string(${paths[key]}) != ''`);
    conditions.set(`${party}-actividad`, `string(${paths.DescActividad}) != ''${party === 'seller' ? ` and string(${paths.CodigoActividad}) != ''` : ''}`);
  }
  const hdr = '/Root/Header';
  const header = Object.fromEntries(['GUID', 'DocType', 'AdditionalIssueType'].map(key => [key, select(`${hdr}/${key}`)]));
  Object.assign(header, { Version:bind(fallback(['/Root/Version'], '1.0')), IssuedDateTime:'2000-01-01T00:00:00',
    ReceptionSeal:bind(fallback([`//Info[@Name='selloRecibido']/@Value`], '[Sello de Recepción]')),
    Secuencial:select(info(`${hdr}/AdditionalIssueDocInfo`, 'Secuencial')),
    CodEstPuntoV:select(info(`${hdr}/AdditionalIssueDocInfo`, 'CodEstPuntoV')) });
  const totalPaths = { TOTAL_GRAVADA:charge('TOTAL_GRAVADA'), TOTAL_EXENTA:charge('TOTAL_EXENTA'),
    TOTAL_NO_SUJETA:charge('TOTAL_NO_SUJETA'), TOTAL_NO_GRAVADO:charge('TOTAL_NO_GRAVADO'), TOTAL_DESCUENTO:charge('TOTAL_DESCUENTO'),
    IVA_PERCIBIDO:totalInfo('IvaPercibido'), IVA_RETENIDO:totalInfo('IvaRetenido'), RETENCION_RENTA:totalInfo('RetencionRenta') };
  const rawTotals = Object.fromEntries(Object.entries(totalPaths).map(([key, path]) => [key, fallback([path], '0.00')]));
  rawTotals.SUBTOTAL = choose(`string(${charge('SUBTOTAL')}) != ''`, value(charge('SUBTOTAL')),
    value(`sum(${charge('TOTAL_GRAVADA')} | ${charge('TOTAL_EXENTA')} | ${charge('TOTAL_NO_SUJETA')})`));
  rawTotals.IVA = fallback([charge('IVA'), "/Root/Totals/TotalTaxes/TotalTax[Code='20']/Amount"], '0.00');
  rawTotals.TOTAL_PAGAR = fallback([charge('TOTAL_PAGAR'), '/Root/Totals/GrandTotal/InvoiceTotal'], '0.00');
  rawTotals.MONTO_TOTAL_OPERACION = fallback([totalInfo('MontoTotalOperacion'), '/Root/Totals/GrandTotal/InvoiceTotal'], '0.00');
  const variables = Object.entries(rawTotals).map(([key, expr]) => `<xsl:variable name="t_${key}">${expr}</xsl:variable>`).join('');
  const totals = Object.fromEntries(Object.keys(rawTotals).map(key => [key, bind(money(`$t_${key}`))]));
  const totalIds = { VENTA_GRAVADA:'TOTAL_GRAVADA', VENTA_EXENTA:'TOTAL_EXENTA', VENTA_NO_SUJETA:'TOTAL_NO_SUJETA', DESCUENTO:'TOTAL_DESCUENTO' };
  for (const field of config.totalsFields || []) if (!field.required) conditions.set(`total-${field.id}`, `number($t_${totalIds[field.id] || field.id}) != 0`);
  const item = {};
  for (const col of config.itemColumns) {
    const paths = col.id === 'Qty' ? ['Qty', 'Quantity'] : col.id === 'Price' ? ['Price', 'UnitPrice']
      : ['Discount','NO_GRAVADO','VENTA_NO_SUJETA','VENTA_EXENTA','VENTA_GRAVADA'].includes(col.id)
        ? [`Charges/Charge[Code='${col.id === 'Discount' ? 'DESCUENTO' : col.id}']/Amount`] : [col.id];
    item[col.id] = bind(fallback(paths, paths[0].startsWith('Charges/') ? '0.00' : '-'));
  }
  const responsible = Object.fromEntries(['NombreEntrega','DocuEntrega','NombreRecibe','DocuRecibe'].map(key => [key, select(`//Info[@Name='${key}']/@Value`)]));
  const general = `(${info(`${additional}/AdditionalInfo/AditionalInfo`, 'Observaciones')} | ${totalInfo('Observaciones')})[1]`;
  const appendixPath = `${additional}/AdditionalInfo/AditionalData/Data[@Name='INFORMACION_ADICIONAL' or @Name='APENDICE']/Info[normalize-space(@Value) != '' and not(@Name='NombreEntrega' or @Name='DocuEntrega' or @Name='NombreRecibe' or @Name='DocuRecibe')]`;
  const labels = { REFERENCIA_INTERNA:'Referencia interna', ReferenciaInterna:'Referencia interna', CodigoVendedor:'Vendedor', Vendedor:'Vendedor',
    CodigoCliente:'Código de cliente', CondicionPago:'Condición de pago', FechaVencimiento:'Fecha de vencimiento', OBSERVACIONES:'Observaciones',
    Num_OrdenCompra:'Orden de compra', OrdenCompra:'Orden de compra', ORDEN_COMPRA:'Orden de compra', NotaEntrega:'Nota de entrega', NOTA_ENTREGA:'Nota de entrega' };
  const labelExpr = Object.entries(labels).reduceRight((next, [key,label]) => choose(`translate(@Name,' ','')='${key}'`, literal(label), next), value("translate(@Name,'_',' ')"));
  const paymentLabels = { '01':'Billetes y monedas', '02':'Tarjeta Débito', '03':'Tarjeta Crédito', '04':'Cheque', '05':'Transferencia-Depósito Bancario', '08':'Dinero electrónico', '09':'Monedero electrónico', '11':'Bitcoin', '12':'Otras Criptomonedas', '13':'Cuentas por pagar del receptor', '14':'Giro bancario', '99':'Otros' };
  const payment = Object.entries(paymentLabels).reduceRight((next,[key,label]) => choose(`Code='${key}'`, literal(label), next), value('Code'));
  const payments = choose('/Root/Payments/Payment[Code]', `<xsl:for-each select="/Root/Payments/Payment[Code]"><xsl:if test="position() &gt; 1">${literal(', ')}</xsl:if>${payment}<xsl:if test="Amount != '' and Amount != '0.00'">${literal(' (')}${value('Amount')}${literal(')')}</xsl:if></xsl:for-each>`, literal('[Forma de Pago]'));
  const editedItemIndices = [...Object.keys(editor.overrides || {}), ...Object.keys(editor.textOverrides || {})]
    .map(key => /^item-(\d+)-/.exec(key)).filter(Boolean).map(match => Number(match[1]));
  // Keep edits to a specific detail row tied to its position, and use an
  // unedited fallback row for any additional items in future XML documents.
  const templateCount = editedItemIndices.length ? Math.max(...editedItemIndices) + 2 : 1;
  const data = { ...parties, header, totals, items:Array.from({length:templateCount}, () => item),
    taxes:[{ code:'RGXTAX', description:bind(fallback(['Description'], 'Impuesto')), amount:bind(money('Amount')) }],
    inWords:bind(fallback(['/Root/Totals/InWords'], '[Valor en Letras]')),
    condicionOperacion:bind(choose(`${totalInfo('CondicionOperacion')}='1'`, literal('Contado'), choose(`${totalInfo('CondicionOperacion')}='2'`, literal('A Crédito'), choose(`${totalInfo('CondicionOperacion')}='3'`, literal('Otro'), fallback([totalInfo('CondicionOperacion')], '[Condición de la Operación]'))))),
    payments:[{ label:bind(payments), amount:'' }], responsible, generalObservations:select(general),
    appendix:[{ name:bind(labelExpr), value:select('@Value') }],
    relatedDocuments:[Object.fromEntries(['TipoDocumento','NumDocumento','FechaEmision'].map(key => [key, select(info('.', key))]))],
    otherDocuments:[Object.fromEntries(['CodigoDocAsociado','DescDoc'].map(key => [key, select(info('.', key))]))],
    adenda:Object.fromEntries((config.adendaFields || []).map(field => { const name = field.name || field.id; return [name, bind(fallback([`${additional}/AdditionalInfo/AditionalData/Data/Info[@Name=${xpathLiteral(name)}]/@Value`], `[${field.label || name}]`))]; })) };
  const date = `${hdr}/IssuedDateTime`;
  const nit = '/Root/Seller/TaxID';
  const nrc = info('/Root/Seller/TaxIDAdditionalInfo','NRC');
  const formattedNit = choose(`string-length(${nit})=14`, value(`concat(substring(${nit},1,4),'-',substring(${nit},5,6),'-',substring(${nit},11,3),'-',substring(${nit},14))`), choose(`string-length(${nit})=9`, value(`concat(substring(${nit},1,4),'-',substring(${nit},5,4),'-',substring(${nit},9))`), value(nit)));
  const footer = `${value('/Root/Seller/Name')}${literal(', https://www.digifact.com.sv')}<xsl:if test="${esc(nit)}">${literal(', NIT ')}${formattedNit}</xsl:if><xsl:if test="${esc(nrc)}">${literal(', NRC ')}${choose(`string-length(${nrc})=7`, value(`concat(substring(${nrc},1,6),'-',substring(${nrc},7))`), value(nrc))}</xsl:if>`;
  const bindings = { money:v => v || null, itemNumber:select('position()'),
    date:select(`concat(substring(${date},9,2),'-',substring(${date},6,2),'-',substring(${date},1,4))`), time:select(`substring(${date},12,8)`),
    model:bind(choose(`${info(`${hdr}/AdditionalIssueDocInfo`,'TipoModelo')}='2'`, literal('Diferido'), literal('Previo'))),
    transmission:bind(choose(`(${info(`${hdr}/AdditionalIssueDocInfo`,'TipoOperacion')} | ${info(`${hdr}/AdditionalIssueDocInfo`,'TipoTransmision')})[1]='2'`, literal('Contingencia'), literal('Normal'))),
    logo:select(`concat('https://digifact-logo.s3.amazonaws.com/SV/logo/',${nit},'.jpg')`),
    qr:select(`concat('https://cert.digifact.com.sv/QRService/api/QR?data=https%3A%2F%2Fadmin.factura.gob.sv%2FconsultaPublica%3Fambiente%3D',${hdr}/AdditionalIssueType,'%257CcodGen%3D',${hdr}/GUID,'%257CfechaEmi%3D',substring(${date},1,10),'&size=100x100')`), footer:bind(footer) };
  let html = buildPreviewHtml({ currentConfig:config, userStyle, xmlData:data, overrides:editor.overrides || {}, docTitle:userStyle.docTitle, bindings });
  const buyerCode = info('/Root/Buyer/TaxIDAdditionalInfo','CodigoActividad');
  const buyerDescription = info('/Root/Buyer/TaxIDAdditionalInfo','DescActividad');
  html = html.replace(`${parties.buyer.CodigoActividad} – ${parties.buyer.DescActividad}`, bind(choose(`string(${buyerCode}) != '' and string(${buyerDescription}) != ''`, `${value(buyerCode)}${literal(' – ')}${value(buyerDescription)}`, value(buyerDescription))));
  const doc = new DOMParser().parseFromString(editableHtml(html, editor.textOverrides, editor.positions), 'text/html');
  const wraps = new Map();
  const wrap = (el, kind, expression) => { if (el) wraps.set(el, { kind, expression }); };
  const byId = id => doc.querySelector(`[data-rg-id="${id}"]`);
  for (const [id, expression] of conditions) wrap(byId(id), 'if', expression);
  const repeatBlock = (id, path) => { const el=byId(id); wrap(el, 'if', path); wrap(el?.querySelector('tbody > tr'), 'for-each', path); };
  repeatBlock('documentos-relacionados', dataPath('DOC_RELACIONADO'));
  repeatBlock('otros-documentos', dataPath('OTROS_DOC_RELACIONADOS'));
  repeatBlock('apendice', appendixPath);
  wrap(byId('total-tax-RGXTAX'), 'for-each', "/Root/Totals/TotalTaxes/TotalTax[Code!='20']");
  const itemBody = doc.querySelector('.items-table tbody');
  const responsibleRows = byId('responsables')?.querySelectorAll('tr') || [];
  const respConditions = ["//Info[@Name='NombreEntrega' or @Name='DocuEntrega']/@Value != ''", "//Info[@Name='NombreRecibe' or @Name='DocuRecibe']/@Value != ''", `string(${general}) != ''`];
  responsibleRows.forEach((row,i) => wrap(row,'if',respConditions[i]));
  wrap(byId('responsables'), 'if', respConditions.map(test => `(${test})`).join(' or '));
  doc.querySelectorAll('[data-resize], .col-resize-handle').forEach(el => el.remove());
  const emitText = text => text.split(/(RGXVALUE\d+END)/).map(part => tokens.get(part) || literal(part)).join('');
  function emit(node) {
    if (node.nodeType === 3) return emitText(node.textContent);
    if (node.nodeType !== 1) return '';
    const attributes = []; const dynamicAttributes = [];
    for (const attr of node.attributes) {
      if (attr.name.startsWith('data-') || ['draggable','contenteditable'].includes(attr.name)) continue;
      if (/RGXVALUE\d+END/.test(attr.value)) dynamicAttributes.push(`<xsl:attribute name="${attr.name}">${emitText(attr.value)}</xsl:attribute>`);
      else attributes.push(`${attr.name}="${esc(attr.value.replaceAll('{','{{').replaceAll('}','}}'))}"`);
    }
    let children = [...node.childNodes].map(emit).join('');
    if (node === itemBody) {
      const rows = [...node.children];
      const content = rows.length === 1 ? emit(rows[0]) : `<xsl:choose>${rows.slice(0,-1).map((row,index) => `<xsl:when test="position()=${index+1}">${emit(row)}</xsl:when>`).join('')}<xsl:otherwise>${emit(rows.at(-1))}</xsl:otherwise></xsl:choose>`;
      children = `<xsl:for-each select="/Root/Items/Item">${content}</xsl:for-each>`;
    }
    let result = `<${node.localName}${attributes.length ? ' '+attributes.join(' ') : ''}>${dynamicAttributes.join('')}${children}</${node.localName}>`;
    const w=wraps.get(node);
    if (w) result = `<xsl:${w.kind} ${w.kind === 'if' ? 'test' : 'select'}="${esc(w.expression)}">${result}</xsl:${w.kind}>`;
    return result;
  }
  const stylesheet = `<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" xmlns:xsl="${XSL}">
    <xsl:include href="RG-SharedSV_fel_2.xslt"/><xsl:include href="Shared_ENLETRAS_fel_2.xslt"/>
    <xsl:output method="html" encoding="UTF-8" indent="no" doctype-system="about:legacy-compat"/>
    <xsl:template match="/">${variables}<html><head><meta charset="UTF-8"/><title>${esc(userStyle.docTitle || config.title)}</title>
    <style>${esc('html,body{margin:0;padding:0;}'+documentCss())}</style></head><body><div class="dte-page-wrap">${[...doc.body.childNodes].map(emit).join('')}</div></body></html></xsl:template>
  </xsl:stylesheet>`;
  return isReferenceDocument(config) ? stylesheet : bundleXslt(stylesheet);
}
