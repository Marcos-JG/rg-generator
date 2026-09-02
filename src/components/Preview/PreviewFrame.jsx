import { useMemo } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { generateXslt } from '../../core/xsltGenerator';
import { transformXmlToHtml } from '../../core/xmlTransformer';
import { extractXmlData } from '../../core/xmlParser';

export default function PreviewFrame() {
  const { xmlString, currentConfig, userStyle } = useConfigStore();

  const htmlContent = useMemo(() => {
    if (!xmlString || !currentConfig) return null;

    try {
      const baseTemplate = `<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes" encoding="UTF-8"/>
  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: {{FONT_FAMILY}}; font-size: {{FONT_SIZE}}; }
          .page { width: 8.5in; margin: 0 auto; padding: 0.25in; box-sizing: border-box; }
          .header { text-align: center; border-bottom: 2px solid {{COLOR_PRIMARY}}; padding-bottom: 10px; margin-bottom: 15px; }
          .doc-type { color: {{COLOR_PRIMARY}}; font-weight: bold; font-size: 14pt; margin: 5px 0; }
          .section { margin-bottom: 15px; }
          .section-title { background-color: {{COLOR_PRIMARY}}; color: white; padding: 5px 10px; font-weight: bold; margin-bottom: 5px; border-radius: {{BORDER_RADIUS}} {{BORDER_RADIUS}} 0 0; }
          .info-table { width: 100%; border-collapse: collapse; }
          .info-table td { padding: 3px 8px; border: 1px solid {{COLOR_BORDER}}; vertical-align: top; font-size: {{FONT_SIZE}}; }
          .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
          .items-table th { border: 1px solid {{COLOR_BORDER}}; padding: 4px; background-color: {{COLOR_PRIMARY}}; color: white; text-align: center; font-size: {{FONT_SIZE}}; }
          .items-table td { border: 1px solid {{COLOR_BORDER}}; padding: 4px; font-size: {{FONT_SIZE}}; }
          .totals-section { margin-top: 10px; }
          .totals-table { width: 50%; margin-left: auto; border-collapse: collapse; }
          .totals-table td { padding: 4px 8px; border: 1px solid {{COLOR_BORDER}}; font-size: {{FONT_SIZE}}; }
          .total-row { background-color: {{COLOR_TOTALES_BG}}; font-weight: bold; }
          .total-pagar { background-color: {{COLOR_TOTAL_PAGAR_BG}}; font-weight: bold; font-size: 110%; }
          .dte-box { border: 1px solid {{COLOR_BORDER}}; padding: 10px; margin-top: 15px; border-radius: {{BORDER_RADIUS}}; background-color: #f9f9f9; }
          .dte-box table { width: 100%; }
          .dte-box td { padding: 2px 5px; font-size: 90%; }
          .footer { text-align: center; margin-top: 20px; padding-top: 10px; border-top: 1px solid {{COLOR_BORDER}}; font-size: 80%; color: #666; }
          @media print { .page { padding: 0; } body { font-size: 7pt; } }
        </style>
      </head>
      <body>
        <div class="page">
          <div class="header">
            <div class="doc-type">{{DOC_TYPE_TITLE}}</div>
            <xsl:if test="Root/Seller/Name"><h1 style="font-size:{{FONT_SIZE_HEADER}};"><xsl:value-of select="Root/Seller/Name"/></h1></xsl:if>
            <xsl:if test="Root/Seller/TaxID"><p>NIT: <xsl:value-of select="Root/Seller/TaxID"/></p></xsl:if>
          </div>
          <div class="section">
            <div class="section-title">EMISOR</div>
            <table class="info-table">{{SELLER_FIELDS}}</table>
          </div>
          <div class="section">
            <div class="section-title">RECEPTOR</div>
            <table class="info-table">{{BUYER_FIELDS}}</table>
          </div>
          <div class="section">
            <table class="items-table">
              <thead><tr>{{ITEM_COLUMNS}}</tr></thead>
              <tbody>
                <xsl:for-each select="Root/Items/Item">
                  <tr>{{ITEM_ROWS}}</tr>
                </xsl:for-each>
              </tbody>
            </table>
          </div>
          <div class="totals-section">
            <table class="totals-table">
              <tr class="total-pagar">
                <td>TOTAL</td>
                <td style="text-align:right;"><xsl:value-of select="format-number(sum(Root/Items/Item/Charges/Charge[Code='VENTA_GRAVADA']/Amount) + sum(Root/Items/Item/Charges/Charge[Code='VENTA_EXENTA']/Amount) + sum(Root/Items/Item/Charges/Charge[Code='VENTA_NO_SUJETA']/Amount) + sum(Root/Items/Item/Charges/Charge[Code='NO_GRAVADO']/Amount), '#,##0.00')"/></td>
              </tr>
            </table>
          </div>
          <div class="dte-box">
            <table>
              <tr><td><strong>GUID:</strong></td><td><xsl:value-of select="Root/Header/GUID"/></td></tr>
              <tr><td><strong>Fecha:</strong></td><td><xsl:value-of select="concat(substring(Root/Header/IssuedDateTime,9,2), '-', substring(Root/Header/IssuedDateTime,6,2), '-', substring(Root/Header/IssuedDateTime,1,4), ' ', substring(Root/Header/IssuedDateTime,12,8))"/></td></tr>
              <tr>
                <td><strong>Condición de la Operación:</strong></td>
                <td>
                  <xsl:choose>
                    <xsl:when test="Root/Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value = '1'">Contado</xsl:when>
                    <xsl:when test="Root/Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value = '2'">A Crédito</xsl:when>
                    <xsl:when test="Root/Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value = '3'">Otro</xsl:when>
                    <xsl:otherwise>[Condición de la Operación]</xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
              <xsl:for-each select="Root/Payments/Payment">
                <tr>
                  <td><strong>Forma de Pago:</strong></td>
                  <td>
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
              </xsl:for-each>
            </table>
          </div>
          <div class="footer">{{FOOTER_TEXT}}</div>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>`;

      let xmlData = null;
      try {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(xmlString, 'text/xml');
        if (!xmlDoc.querySelector('parsererror')) xmlData = extractXmlData(xmlDoc);
      } catch (e) { /* ignore */ }
      const xslt = generateXslt(baseTemplate, currentConfig, userStyle, xmlData);
      return transformXmlToHtml(xmlString, xslt);
    } catch (err) {
      return `<div style="color:red;padding:20px;"><h3>Error generando preview</h3><pre>${err.message}</pre></div>`;
    }
  }, [xmlString, currentConfig, userStyle]);

  if (!htmlContent) {
    return (
      <div className="h-full flex items-center justify-center text-gray-400">
        <p>Sube un XML para ver el preview</p>
      </div>
    );
  }

  return (
    <iframe
      srcDoc={htmlContent}
      sandbox="allow-same-origin"
      className="w-full h-full border-0 bg-white"
      title="Preview del RG"
    />
  );
}
