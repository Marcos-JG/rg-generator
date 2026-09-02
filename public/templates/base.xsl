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
          .page { width: 8.5in; height: 11in; margin: 0 auto; padding: 0.25in; background: white; position: relative; overflow: hidden; box-sizing: border-box; }
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

          .footer { text-align: center; margin-top: 20px; padding-top: 10px; border-top: 1px solid {{COLOR_BORDER}}; font-size: 80%; color: #666; }

          .qr-section { text-align: center; margin-top: 15px; }

          @media print {
            .page { padding: 0; }
            body { font-size: 7pt; }
          }
        </style>
      </head>
      <body>
        <div class="page">
          <div class="header" style="display:grid;grid-template-columns:1fr auto;align-items:start;margin-bottom:15px">
            <div class="header-title" style="text-align:center;font-weight:700;color:{{COLOR_PRIMARY}}">
              DOCUMENTO TRIBUTARIO ELECTRÓNICO<br/>
              <xsl:call-template name="TipoDOC"/>
            </div>
            <div style="font-weight:700;white-space:nowrap">Ver. <xsl:value-of select="Root/Version"/></div>
            <div style="display:grid;grid-template-columns:1fr auto 1fr;gap:10px;margin-top:10px;align-items:end">
              <div>
                <xsl:if test="{{LOGO_URL}}">
                  <img width="150" src="{{LOGO_URL}}" alt="[logo]" style="display:block;margin-bottom:10px"/>
                </xsl:if>
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
              </div>
              <div>
                <xsl:call-template name="QR"/>
              </div>
              <div style="display:flex;flex-direction:column;justify-content:flex-end;font-weight:700;font-size:9pt;line-height:1.6">
                <div><b>Modelo de Facturación: </b><xsl:call-template name="TipoModelo"/></div>
                <div><b>Tipo de Transmisión: </b><xsl:call-template name="TipoTransmision"/></div>
                <div><b>Fecha y Hora de Generación: </b>
                  <xsl:value-of select="substring(Root/Header/IssuedDateTime,9,2)"/>-<xsl:value-of select="substring(Root/Header/IssuedDateTime,6,2)"/>-<xsl:value-of select="substring(Root/Header/IssuedDateTime,1,4)"/>
                  <b> Hora: </b><xsl:value-of select="substring(Root/Header/IssuedDateTime,12,5)"/>
                </div>
              </div>
            </div>
          </div>

          <div class="emisor-receptor">
            <table width="100%" cellpadding="0" cellspacing="5" border="0">
              <tbody>
                <tr>
                  <td width="49%" style="text-align:center;font-weight:bold">{{COL1_TITLE}}</td>
                  <td width="2%"></td>
                  <td width="49%" style="text-align:center;font-weight:bold">{{COL2_TITLE}}</td>
                </tr>
                <tr>
                  <td class="section-box">
                    <table width="100%" cellpadding="0" cellspacing="0" border="0">
                      <tbody>
                        {{COL1_FIELDS}}
                      </tbody>
                    </table>
                  </td>
                  <td style="border:none"></td>
                  <td class="section-box">
                    <table width="100%" cellpadding="0" cellspacing="0" border="0">
                      <tbody>
                        {{COL2_FIELDS}}
                      </tbody>
                    </table>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="section">
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

          <div class="totals-section">
            <table class="totals-table">
              {{TOTALS_ROWS}}
            </table>
          </div>

          <div class="observaciones">
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

          <div class="observaciones" style="margin-top:10px">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="border:1px solid {{COLOR_BORDER}};border-radius:5px;padding:4px">
                  <table width="100%" cellpadding="0" cellspacing="0" border="0">
                    <tr><td width="20%" style="text-align:right;font-weight:bold;padding:4px">REFERENCIA_INTERNA:</td><td style="padding:4px"><xsl:value-of select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='REFERENCIA_INTERNA']/@Value"/></td></tr>
                    <tr><td width="20%" style="text-align:right;font-weight:bold;padding:4px">CodigoCliente:</td><td style="padding:4px"><xsl:value-of select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='CodigoCliente']/@Value"/></td></tr>
                    <tr><td width="20%" style="text-align:right;font-weight:bold;padding:4px">Num_OrdenCompra:</td><td style="padding:4px"><xsl:value-of select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='Num_OrdenCompra']/@Value"/></td></tr>
                    <tr><td width="20%" style="text-align:right;font-weight:bold;padding:4px">CondicionPago:</td><td style="padding:4px"><xsl:value-of select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='CondicionPago']/@Value"/></td></tr>
                    <tr><td width="20%" style="text-align:right;font-weight:bold;padding:4px">NRC_COF:</td><td style="padding:4px"><xsl:value-of select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='NRC_COF']/@Value"/></td></tr>
                    <tr><td width="20%" style="text-align:right;font-weight:bold;padding:4px">FechaVencimiento:</td><td style="padding:4px"><xsl:value-of select="Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='FechaVencimiento']/@Value"/></td></tr>
                  </table>
                </td>
              </tr>
            </table>
          </div>

          <div class="footer">
            {{FOOTER_TEXT}}
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
