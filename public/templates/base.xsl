<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:adenda="https://www.digifact.com.sv/dtecomm" xmlns:b="urn:ean.ucc:pay:2"
  xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:Root="https://admin.factura.gob.sv"
  exclude-result-prefixes="b" xml:space="default">
  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <xsl:include href="RG-SharedSV_fel_2.xslt"/>
  <xsl:include href="Shared_ENLETRAS_fel_2.xslt"/>

  <xsl:template name="QR">
    <img width="125" height="125">
      <xsl:attribute name="src">
        <xsl:value-of select="concat($URLAPIQR,'data=',$URLSITE,'&amp;size=100x100')"/>
      </xsl:attribute>
      <xsl:attribute name="alt"><xsl:value-of select="'DTE'"/></xsl:attribute>
      <xsl:attribute name="title"><xsl:value-of select="'Su DTE FEL'"/></xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: {{FONT_FAMILY}}; font-size: {{FONT_SIZE}}; color: {{COLOR_FONT}}; padding: 0; margin: 0; text-align: left; }
          .page { width: 8.5in; min-height: 11in; height: auto; margin: 0 auto; padding: 0.25in; background: white; position: relative; overflow: visible; box-sizing: border-box; display: flex; flex-direction: column; }
          td { vertical-align: top; padding: 2px 4px; border-color: #808080; }

          .header { margin-bottom: 15px; }
          .header-logo { position: absolute; }
          .header-version { text-align: right; font-weight: 700; }
          .header-title { text-align: center; font-weight: 700; font-size: 14pt; margin-top: 40px; color: {{COLOR_PRIMARY}}; }
          .header-guid { position: absolute; bottom: 15px; left: 0; font-weight: 700; font-size: 9pt; line-height: 1.5; }
          .header-meta { position: absolute; bottom: 15px; right: 0; font-weight: 700; font-size: 9pt; text-align: left; line-height: 1.5; }

          .emisor-receptor { margin-bottom: 15px; }
          .section-box { border: 1px solid {{COLOR_BORDER}}; border-radius: 5px; vertical-align: top; }
          .section-title { text-align: center; font-weight: bold; padding: 5px; }

          .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
          .items-table th {
            border: 1px solid {{COLOR_BORDER}}; padding: 4px;
            background-color: {{COLOR_PRIMARY}}; color: white;
            text-align: center; font-size: {{FONT_SIZE}};
          }
          .items-table td { border: 1px solid {{COLOR_BORDER}}; padding: 4px; }

          .totals-section { margin-top: 10px; }
          .totals-table { width: 50%; margin-left: auto; border-collapse: collapse; }
          .total-row { background-color: {{COLOR_TOTALES_BG}}; font-weight: bold; }
          .total-row td { padding: 4px 8px; border: 1px solid {{COLOR_BORDER}}; }
          .total-pagar { background-color: {{COLOR_TOTAL_PAGAR_BG}}; font-weight: bold; font-size: 110%; }
          .total-pagar td { padding: 4px 8px; border: 1px solid {{COLOR_BORDER}}; }

          .observaciones { margin-top: 15px; }
          .observaciones td { padding: 4px; border: 1px solid {{COLOR_BORDER}}; }

          .footer { text-align: center; margin-top: auto; padding-top: 10px; border-top: 1px solid {{COLOR_BORDER}}; font-size: 80%; color: #666; }

          .qr-section { text-align: center; margin-top: 15px; }

          @media print {
            .page { padding: 0; }
            body { font-size: 7pt; }
          }
        </style>
      </head>
      <body>
        <div class="page">
          <div class="header" style="margin-bottom:15px">
            <div style="display:grid;grid-template-columns:1fr 1.4fr 125px;gap:10px;align-items:start">
              <div><xsl:if test="{{HAS_LOGO}}"><img width="150" src="{{LOGO_URL}}" alt="[logo]" style="display:block"/></xsl:if></div>
              <div class="header-title" style="margin-top:0;text-align:center;font-weight:700;color:{{COLOR_PRIMARY}}">
                DOCUMENTO TRIBUTARIO ELECTRÓNICO<br/>
                {{DOC_TYPE_TITLE}}
              </div>
              <div><xsl:call-template name="QR"/></div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr auto;gap:10px;margin-top:8px;align-items:start">
              <div style="font-weight:700;font-size:9pt;line-height:1.6">
                  <b>Código de Generación: </b><xsl:value-of select="Root/Header/GUID"/><br/>
                  <b>Número de Control: </b>
                  <xsl:value-of select="concat('DTE-',Root/Header/DocType,'-',Root/Header/AdditionalIssueDocInfo/Info[@Name='CodEstPuntoV']/@Value,'-',Root/Header/AdditionalIssueDocInfo/Info[@Name='Secuencial']/@Value)"/><br/>
                  <b>Sello de Recepción: </b>
                  <xsl:choose>
                    <xsl:when test="Root/TaxEntityResponse/Info[@Name='selloRecibido']/@Value"><xsl:value-of select="Root/TaxEntityResponse/Info[@Name='selloRecibido']/@Value"/></xsl:when>
                    <xsl:otherwise>[Sello de Recepción]</xsl:otherwise>
                  </xsl:choose>
              </div>
              <div style="font-weight:700;font-size:9pt;line-height:1.6">
                <div><b>Modelo de Facturación: </b><xsl:call-template name="TipoModelo"/></div>
                <div><b>Tipo de Transmisión: </b><xsl:call-template name="TipoTransmision"/></div>
                <div><b>Fecha y Hora de Generación: </b>
                  <xsl:value-of select="substring(Root/Header/IssuedDateTime,9,2)"/>-<xsl:value-of select="substring(Root/Header/IssuedDateTime,6,2)"/>-<xsl:value-of select="substring(Root/Header/IssuedDateTime,1,4)"/>
                  <b> Hora: </b><xsl:value-of select="substring(Root/Header/IssuedDateTime,12,5)"/>
                </div>
              </div>
              <div style="font-weight:700;white-space:nowrap">Ver. <xsl:value-of select="Root/Version"/></div>
            </div>
          </div>

          <xsl:if test="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='DOC_RELACIONADO']">
            <div class="observaciones">
              <table width="100%" style="border-collapse:collapse">
                <thead><tr><th colspan="3" style="padding:4px">DOCUMENTOS RELACIONADOS</th></tr><tr>
                  <th style="border:1px solid {{COLOR_BORDER}};padding:4px">Tipo de Documento</th>
                  <th style="border:1px solid {{COLOR_BORDER}};padding:4px">No. de Documento</th>
                  <th style="border:1px solid {{COLOR_BORDER}};padding:4px">Fecha de Documento</th>
                </tr></thead>
                <tbody><xsl:for-each select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='DOC_RELACIONADO']"><tr>
                  <td><xsl:value-of select="Info[@Name='TipoDocumento']/@Value"/></td>
                  <td><xsl:value-of select="Info[@Name='NumDocumento']/@Value"/></td>
                  <td><xsl:value-of select="Info[@Name='FechaEmision']/@Value"/></td>
                </tr></xsl:for-each></tbody>
              </table>
            </div>
          </xsl:if>

          <xsl:if test="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='OTROS_DOC_RELACIONADOS']">
            <div class="observaciones">
              <table width="100%" style="border-collapse:collapse">
                <thead><tr><th colspan="2" style="padding:4px">OTROS DOCUMENTOS ASOCIADOS</th></tr><tr>
                  <th style="border:1px solid {{COLOR_BORDER}};padding:4px">Identificación del Documento</th>
                  <th style="border:1px solid {{COLOR_BORDER}};padding:4px">Descripción</th>
                </tr></thead>
                <tbody><xsl:for-each select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='OTROS_DOC_RELACIONADOS']"><tr>
                  <td><xsl:value-of select="Info[@Name='CodigoDocAsociado']/@Value"/></td>
                  <td><xsl:value-of select="Info[@Name='DescDoc']/@Value"/></td>
                </tr></xsl:for-each></tbody>
              </table>
            </div>
          </xsl:if>

          <xsl:if test="false()">
          <div class="section" style="{{ITEMS_STYLE}}">
            <table class="items-table">
              <thead>
                <tr>
                  {{ITEM_COLUMNS}}
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="Root/Items/Item">
                  {{ITEM_ROWS}}
                </xsl:for-each>
              </tbody>
            </table>
          </div>

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:10px;align-items:start">
          <div class="totals-section" style="margin-top:0;{{TOTALS_STYLE}}">
            <table class="totals-table" style="width:100%;margin-left:0">
              <xsl:for-each select="Root/Totals/TotalTaxes/TotalTax[Code!='20']">
                <tr class="total-row">
                  <td><xsl:choose><xsl:when test="Description"><xsl:value-of select="Description"/></xsl:when><xsl:otherwise>Impuesto <xsl:value-of select="Code"/></xsl:otherwise></xsl:choose>:</td>
                  <td style="text-align:right"><xsl:value-of select="format-number(Amount,'#,##0.00')"/></td>
                </tr>
              </xsl:for-each>
              {{TOTALS_ROWS}}
            </table>
          </div>

          <div class="observaciones" style="margin-top:0;{{OBSERVACIONES_STYLE}}">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td>
                  <table width="100%" cellpadding="0" cellspacing="0" border="0">
                    <tr>
                      <td width="20%" style="text-align:right;font-weight:bold;padding:4px">Valor en Letras:</td>
                      <td style="padding:4px"><xsl:value-of select="Root/Totals/InWords"/></td>
                    </tr>
                    <tr>
                      <td width="20%" style="text-align:right;font-weight:bold;padding:4px">Condición de la Operación:</td>
                      <td style="padding:4px">
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
                        <td width="20%" style="text-align:right;font-weight:bold;padding:4px">Forma de Pago:</td>
                        <td style="padding:4px">
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
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="Amount"/>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </table>
                </td>
              </tr>
            </table>
          </div>
          </div>
          </xsl:if>

          {{BODY_LAYOUT}}

          <xsl:if test="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='INFORMACION_ADICIONAL' or @Name='APENDICE']/Info[@Value != '']">
            <div class="observaciones" style="margin-top:10px">
              <div style="text-align:center;font-weight:bold;margin-bottom:4px">INFORMACIÓN ADICIONAL</div>
              <table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
                <td style="border:1px solid {{COLOR_BORDER}};border-radius:5px;padding:4px">
                  <table width="100%" cellpadding="0" cellspacing="0" border="0">
                    <xsl:for-each select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='INFORMACION_ADICIONAL' or @Name='APENDICE']/Info[@Value != '' and not(@Name='NombreEntrega') and not(@Name='DocuEntrega') and not(@Name='NombreRecibe') and not(@Name='DocuRecibe')]">
                      <tr><td width="25%" style="font-weight:bold;padding:2px 4px">
                        <xsl:choose>
                          <xsl:when test="@Name='REFERENCIA_INTERNA' or @Name='ReferenciaInterna'">Referencia interna</xsl:when>
                          <xsl:when test="@Name='CodigoVendedor' or @Name='Vendedor'">Vendedor</xsl:when>
                          <xsl:when test="@Name='Num_OrdenCompra' or @Name='OrdenCompra' or @Name='ORDEN_COMPRA'">Orden de compra</xsl:when>
                          <xsl:when test="@Name='NotaEntrega' or @Name='NOTA_ENTREGA'">Nota de entrega</xsl:when>
                          <xsl:otherwise><xsl:value-of select="translate(@Name,'_',' ')"/></xsl:otherwise>
                        </xsl:choose>:
                      </td><td style="padding:2px 4px"><xsl:value-of select="@Value"/></td></tr>
                    </xsl:for-each>
                  </table>
                </td>
              </tr></table>
            </div>
          </xsl:if>

          {{ADENDA_FIELDS}}

          <xsl:if test="Root/AdditionalDocumentInfo//Info[@Name='NombreEntrega' or @Name='DocuEntrega' or @Name='NombreRecibe' or @Name='DocuRecibe' or @Name='Observaciones']">
            <div class="observaciones"><table width="100%" cellpadding="0" cellspacing="0"><tr><td>
              <table width="100%">
                <tr><td style="font-weight:bold">Responsable por parte del emisor:</td><td><xsl:value-of select="Root/AdditionalDocumentInfo//Info[@Name='NombreEntrega']/@Value"/></td><td style="font-weight:bold">No. de Documento:</td><td><xsl:value-of select="Root/AdditionalDocumentInfo//Info[@Name='DocuEntrega']/@Value"/></td></tr>
                <tr><td style="font-weight:bold">Responsable por parte del receptor:</td><td><xsl:value-of select="Root/AdditionalDocumentInfo//Info[@Name='NombreRecibe']/@Value"/></td><td style="font-weight:bold">No. de Documento:</td><td><xsl:value-of select="Root/AdditionalDocumentInfo//Info[@Name='DocuRecibe']/@Value"/></td></tr>
                <xsl:if test="Root/AdditionalDocumentInfo//Info[@Name='Observaciones']/@Value"><tr><td style="font-weight:bold">Observación General:</td><td colspan="3"><xsl:value-of select="Root/AdditionalDocumentInfo//Info[@Name='Observaciones']/@Value"/></td></tr></xsl:if>
              </table>
            </td></tr></table></div>
          </xsl:if>

          <div class="footer">
            {{FOOTER_TEXT}}
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
