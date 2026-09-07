import { escapeXml } from './escapeXml.js';
import { replaceAllPlaceholders } from './templateEngine.js';
import { buildFooterText } from './svFormat.js';

function generateFieldXslt(field, section) {
  const xpath = `${section}/${field.id}`;
  return `<xsl:if test="${xpath}">
        <tr>
          <td style="font-weight:bold;width:35%;white-space:nowrap;padding:2px 4px;"><xsl:value-of select="'${escapeXml(field.label)}'"/></td>
          <td style="padding:2px 4px;"><xsl:value-of select="${xpath}"/></td>
        </tr>
      </xsl:if>`;
}

function generateSellerFieldXslt(field) {
  let xpath;
  switch (field.id) {
    case 'NRC':
      xpath = "Seller/TaxIDAdditionalInfo/Info[@Name='NRC']/@Value";
      break;
    case 'CodigoActividad':
      xpath = "Seller/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value";
      break;
    case 'DescActividad':
      xpath = "Seller/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value";
      break;
    case 'NombreComercial':
      xpath = "Seller/AdditionlInfo/Info[@Name='NombreComercial']/@Value";
      break;
    case 'TipoEstablecimiento':
      xpath = "Seller/AdditionlInfo/Info[@Name='TipoEstablecimiento']/@Value";
      break;
    default:
      xpath = `Seller/${field.id}`;
  }
  return `<xsl:if test="${xpath}">
        <tr>
          <td style="font-weight:bold;width:35%;white-space:nowrap;padding:2px 4px;"><xsl:value-of select="'${escapeXml(field.label)}'"/></td>
          <td style="padding:2px 4px;"><xsl:value-of select="${xpath}"/></td>
        </tr>
      </xsl:if>`;
}

function generateBuyerFieldXslt(field) {
  let xpath;
  switch (field.id) {
    case 'NRC':
      xpath = "Buyer/TaxIDAdditionalInfo/Info[@Name='NRC']/@Value";
      break;
    default:
      xpath = `Buyer/${field.id}`;
  }
  return `<xsl:if test="${xpath}">
        <tr>
          <td style="font-weight:bold;width:35%;white-space:nowrap;padding:2px 4px;"><xsl:value-of select="'${escapeXml(field.label)}'"/></td>
          <td style="padding:2px 4px;"><xsl:value-of select="${xpath}"/></td>
        </tr>
      </xsl:if>`;
}

function generateColumnsXslt(columns) {
  return columns
    .map(
      (col) =>
        `<th style="width:${col.width};border:1px solid ${'{{COLOR_BORDER}}'};padding:4px;background-color:${'{{COLOR_PRIMARY}}'};color:white;text-align:center;font-size:${'{{FONT_SIZE}}'};">
          <xsl:value-of select="'${escapeXml(col.label)}'"/>
        </th>`
    )
    .join('\n            ');
}

function generateItemRowXslt(columns) {
  const cells = columns
    .map((col) => {
      let xpath;
      switch (col.id) {
        case 'Number':
          xpath = 'position()';
          break;
        case 'Qty':
          xpath = 'Quantity';
          break;
        case 'UnitOfMeasure':
          xpath = 'UnitOfMeasure';
          break;
        case 'Description':
          xpath = 'Description';
          break;
        case 'Price':
          xpath = 'UnitPrice';
          break;
        case 'Discount':
          xpath = 'Charges/Charge[Code=&apos;DESCUENTO&apos;]/Amount';
          break;
        case 'NO_GRAVADO':
          xpath = "Charges/Charge[Code='NO_GRAVADO']/Amount";
          break;
        case 'VENTA_NO_SUJETA':
          xpath = "Charges/Charge[Code='VENTA_NO_SUJETA']/Amount";
          break;
        case 'VENTA_EXENTA':
          xpath = "Charges/Charge[Code='VENTA_EXENTA']/Amount";
          break;
        case 'VENTA_GRAVADA':
          xpath = "Charges/Charge[Code='VENTA_GRAVADA']/Amount";
          break;
        default:
          xpath = col.id;
      }
      const align = ['Number', 'Qty', 'Price', 'Discount', 'NO_GRAVADO', 'VENTA_NO_SUJETA', 'VENTA_EXENTA', 'VENTA_GRAVADA'].includes(col.id)
        ? 'text-align:right;'
        : '';
      return `<td style="border:1px solid {{COLOR_BORDER}};padding:4px;${align}font-size:${'{FONT_SIZE}'};">
              <xsl:choose>
                <xsl:when test="number(${xpath})">
                  <xsl:value-of select="format-number(${xpath}, '#,##0.00')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="${xpath}"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>`;
    })
    .join('\n            ');

  return `<tr>
            ${cells}
          </tr>`;
}

function generateTotalsXslt(config) {
  const totalsFields = config.totalsFields || [];
  
  const xpathMap = {
    'VENTA_GRAVADA': "/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount",
    'VENTA_EXENTA': "/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount",
    'VENTA_NO_SUJETA': "/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount",
    'TOTAL_NO_GRAVADO': "/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount",
    'SUBTOTAL': "/Root/Totals/TotalCharges/TotalCharge[Code='SUBTOTAL']/Amount",
    'DESCUENTO': "/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_DESCUENTO']/Amount",
    'IVA': "/Root/Totals/TotalCharges/TotalCharge[Code='IVA']/Amount",
    'IVA_PERCIBIDO': "/Root/Totals/AdditionalInfo/Info[@Name='IvaPercibido']/@Value",
    'IVA_RETENIDO': "/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value",
    'RETENCION_RENTA': "/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value",
    'MONTO_TOTAL_OPERACION': "/Root/Totals/AdditionalInfo/Info[@Name='MontoTotalOperacion']/@Value",
    'TOTAL_PAGAR': "/Root/Totals/GrandTotal/InvoiceTotal",
  };

  const htmlRows = totalsFields
    .filter(f => f.id !== 'TOTAL_PAGAR')
    .map(({ id, label }) => {
      const xpath = xpathMap[id] || `/Root/Totals/${id}`;
      const isFormat = xpath.includes('AdditionalInfo') || xpath.includes('format-number');
      return `<tr>
        <td style="padding:4px 8px;border:1px solid {{COLOR_BORDER}};background-color:{{COLOR_TOTALES_BG}};font-weight:bold"><xsl:value-of select="'${escapeXml(label)}'"/></td>
        <td style="padding:4px 8px;border:1px solid {{COLOR_BORDER}};text-align:right;background-color:{{COLOR_TOTALES_BG}};font-weight:bold">
          <xsl:choose>
            <xsl:when test="${xpath}">
              <xsl:value-of select="${isFormat ? xpath : `format-number(${xpath},'#,##0.00')`}"/>
            </xsl:when>
            <xsl:otherwise> 0.00 </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>`;
    }).join('\n');

  const totalPagarField = totalsFields.find(f => f.id === 'TOTAL_PAGAR');
  const pagarRow = totalPagarField ? `<tr>
        <td style="padding:4px 8px;border:1px solid {{COLOR_BORDER}};background-color:{{COLOR_TOTAL_PAGAR_BG}};font-weight:bold;font-size:110%"><xsl:value-of select="'${escapeXml(totalPagarField.label)}'"/></td>
        <td style="padding:4px 8px;border:1px solid {{COLOR_BORDER}};text-align:right;background-color:{{COLOR_TOTAL_PAGAR_BG}};font-weight:bold;font-size:110%">
          <xsl:value-of select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
        </td>
      </tr>` : '';

  return htmlRows + '\n' + pagarRow;
}

function generateAdendaXslt(config) {
  const fields = config.adendaFields || [];
  if (!fields.length) return '';

  const order = (config.fieldOrders?.['datos-adicionales'] || fields.map((f) => `da-${f.id || f.name}`)).map(
    (id) => id.replace(/^da-/, '')
  );
  const byName = {};
  fields.forEach((f) => {
    const name = f.id || f.name;
    if (name) byName[name] = f;
  });

  return order
    .map((name) => {
      const f = byName[name];
      if (!f) return '';
      const label = f.label || f.name || name;
      const xpath = `Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='${name}']/@Value`;
      return `                    <tr>
                      <td width="20%" style="text-align:right;font-weight:bold;padding:4px">${escapeXml(label)}:</td>
                      <td style="padding:4px"><xsl:value-of select="${xpath}"/></td>
                    </tr>`;
    })
    .filter(Boolean)
    .join('\n');
}

function generateObservacionesXslt(config) {
  const order = (config.fieldOrders?.observaciones || ['obs-VALOR_EN_LETRAS', 'obs-CONDICION_OPERACION', 'obs-FORMA_DE_PAGO'])
    .map((id) => id.replace(/^obs-/, ''));

  const PAYMENT_XSLT = `<xsl:for-each select="Root/Payments/Payment">
                    <tr>
                      <td style="font-weight:bold;width:35%;white-space:nowrap;padding:2px 4px;">Forma de Pago:</td>
                      <td style="padding:2px 4px;">
                        <xsl:choose>
                          <xsl:when test="Code = '01'">Billetes y monedas</xsl:when>
                          <xsl:when test="Code = '02'">Tarjeta Débito</xsl:when>
                          <xsl:when test="Code = '03'">Tarjeta Crédito</xsl:when>
                          <xsl:when test="Code = '04'">Cheque</xsl:when>
                          <xsl:when test="Code = '05'">Transferencia-Depósito Bancario</xsl:when>
                          <xsl:when test="Code = '08'">Dinero electrónico</xsl:when>
                          <xsl:when test="Code = '09'">Monedero electrónico</xsl:when>
                          <xsl:when test="Code = '11'">Bitcoin</xsl:when>
                          <xsl:when test="Code = '12'">Otras Criptomonedas</xsl:when>
                          <xsl:when test="Code = '13'">Cuentas por pagar del receptor</xsl:when>
                          <xsl:when test="Code = '14'">Giro bancario</xsl:when>
                          <xsl:otherwise>Otros</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text><xsl:value-of select="Amount"/>
                      </td>
                    </tr>
                  </xsl:for-each>`;

  return order.map((id) => {
    if (id === 'VALOR_EN_LETRAS') {
      return `                    <tr>
                      <td style="font-weight:bold;width:35%;white-space:nowrap;padding:2px 4px;">Valor en Letras:</td>
                      <td style="padding:2px 4px"><xsl:value-of select="InWords"/></td>
                    </tr>`;
    }
    if (id === 'CONDICION_OPERACION') {
      return `                    <tr>
                      <td style="font-weight:bold;width:35%;white-space:nowrap;padding:2px 4px;">Condición de la Operación:</td>
                      <td style="padding:2px 4px">
                        <xsl:choose>
                          <xsl:when test="Root/Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value = '1'">Contado</xsl:when>
                          <xsl:when test="Root/Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value = '2'">A Crédito</xsl:when>
                          <xsl:when test="Root/Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value = '3'">Otro</xsl:when>
                          <xsl:otherwise>[Condición de la Operación]</xsl:otherwise>
                        </xsl:choose>
                      </td>
                    </tr>`;
    }
    if (id === 'FORMA_DE_PAGO') {
      return PAYMENT_XSLT;
    }
    return '';
  }).join('\n');
}

export function generateXslt(baseTemplate, config, userStyle = {}, xmlData = null) {
  let xslt = baseTemplate;
  const style = { ...config.style, ...userStyle };

  xslt = replaceAllPlaceholders(xslt, 'COLOR_PRIMARY', escapeXml(style.colorPrimary));
  xslt = replaceAllPlaceholders(xslt, 'COLOR_FONT', escapeXml(style.colorFont || '#333333'));
  xslt = replaceAllPlaceholders(xslt, 'COLOR_BORDER', escapeXml(style.colorBorder || '#808080'));
  xslt = replaceAllPlaceholders(xslt, 'FONT_SIZE', escapeXml(style.fontSize));
  xslt = replaceAllPlaceholders(xslt, 'FONT_SIZE_HEADER', escapeXml(style.fontSizeHeader || '12pt'));
  xslt = replaceAllPlaceholders(xslt, 'FONT_FAMILY', escapeXml(style.fontFamily || 'Arial, Helvetica, sans-serif'));
  xslt = replaceAllPlaceholders(xslt, 'DOC_TYPE_TITLE', escapeXml(userStyle.docTitle || config.title));

  const logoUrl = userStyle.logoUrl || '';
  xslt = replaceAllPlaceholders(xslt, 'LOGO_URL', escapeXml(logoUrl));

  const sellerXslt = config.sellerFields
    .filter((f) => f.required || userStyle.enabledFields?.includes(f.id))
    .map((f) => generateSellerFieldXslt(f))
    .join('\n        ');

  const buyerXslt = config.buyerFields
    .filter((f) => f.required || userStyle.enabledFields?.includes(f.id))
    .map((f) => generateBuyerFieldXslt(f))
    .join('\n        ');

  const layoutOrder = config.layoutOrder || ['emisor', 'receptor'];
  const col1Type = layoutOrder[0] || 'emisor';
  const col2Type = layoutOrder[1] || 'receptor';

  const col1Title = col1Type === 'emisor' ? 'EMISOR' : 'RECEPTOR';
  const col1Fields = col1Type === 'emisor' ? sellerXslt : buyerXslt;
  const col2Title = col2Type === 'emisor' ? 'EMISOR' : 'RECEPTOR';
  const col2Fields = col2Type === 'emisor' ? sellerXslt : buyerXslt;

  xslt = replaceAllPlaceholders(xslt, 'COL1_TITLE', escapeXml(col1Title));
  xslt = replaceAllPlaceholders(xslt, 'COL1_FIELDS', col1Fields);
  xslt = replaceAllPlaceholders(xslt, 'COL2_TITLE', escapeXml(col2Title));
  xslt = replaceAllPlaceholders(xslt, 'COL2_FIELDS', col2Fields);

  xslt = replaceAllPlaceholders(xslt, 'SELLER_FIELDS', sellerXslt);
  xslt = replaceAllPlaceholders(xslt, 'BUYER_FIELDS', buyerXslt);

  const columnsXslt = generateColumnsXslt(config.itemColumns);
  xslt = replaceAllPlaceholders(xslt, 'ITEM_COLUMNS', columnsXslt);

  const itemRowXslt = generateItemRowXslt(config.itemColumns);
  xslt = replaceAllPlaceholders(xslt, 'ITEM_ROWS', itemRowXslt);

  const adendaXslt = generateAdendaXslt(config);
  xslt = replaceAllPlaceholders(xslt, 'ADENDA_FIELDS', adendaXslt);

  const observacionesXslt = generateObservacionesXslt(config);
  xslt = replaceAllPlaceholders(xslt, 'OBSERVACIONES_FIELDS', observacionesXslt);

  const totalsXslt = generateTotalsXslt(config);
  xslt = replaceAllPlaceholders(xslt, 'TOTALS_ROWS', totalsXslt);

  const footerText = buildFooterText(xmlData, userStyle.footerText || 'DIGIFACT SERVICIOS, SOCIEDAD ANONIMA https://www.digifact.com.sv, NIT 0614-230822-102-5, NRC 318270-1');
  xslt = replaceAllPlaceholders(xslt, 'FOOTER_TEXT', escapeXml(footerText));

  const borderRadius = style.borderRadius || '6px';
  xslt = replaceAllPlaceholders(xslt, 'BORDER_RADIUS', escapeXml(borderRadius));

  const colorTotalesBg = style.colorTotalesBg || '#e6e6e6';
  xslt = replaceAllPlaceholders(xslt, 'COLOR_TOTALES_BG', escapeXml(colorTotalesBg));

  const colorTotalPagarBg = style.colorTotalPagarBg || '#D1D5DB';
  xslt = replaceAllPlaceholders(xslt, 'COLOR_TOTAL_PAGAR_BG', escapeXml(colorTotalPagarBg));

  return xslt;
}
