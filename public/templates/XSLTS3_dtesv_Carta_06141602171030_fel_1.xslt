<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:adenda="https://www.digifact.com.sv/dtecomm" xmlns:b="urn:ean.ucc:pay:2"
  xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:Root="https://admin.factura.gob.sv"
  xmlns:CAFE="http://dgi-fep.mef.gob.pa" exclude-result-prefixes="b" xml:space="default">

  <xsl:output method="html" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http: //www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" indent="no"/>
  <!-- S3 shared PROD (pubresources) -->
  <xsl:include href="RG-SharedSV_fel_2.xslt"/>
  <xsl:include href="Shared_ENLETRAS_fel_2.xslt"/>
  <!--<xsl:include href="RG-SharedSV_fel_2.xslt"/><xsl:include href="Shared_ENLETRAS_fel_2.xslt"/>-->
  
  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:call-template name="TipoDOC"/>
        </title>
        <style type="text/css">
          body{
              padding:0in;
              margin:0;
              font-family:Arial;
              font-size:7pt;
              text-align:left;
          }
          .page{
              margin:0;
              padding:0.25in;
              width:8in;
              font-family:Arial;
              font-size:7pt;
              text-align:left;
              background:white;
          }
          .page_ANULADO{
              margin:0;
              padding:0.25in;
              width:8in;
              font-family:Arial;
              font-size:7pt;
              text-align:left;
              backgroun:transparent;
              background-image:url('http://10.1.10.3:8097/mx.com.fact.res/logo/watermark_anulada.png');
              background-repeat:repeat;
          }
          table{
              font-family:Arial;
              font-size:7pt;
              text-align:left;
              background:white;
          }
          td{
              vertical-align:top;
              border-color:#808080;
              padding-left:0.02in;
              padding-right:0.02in;
              padding-top:0.02in;
              padding-bottom:0.02in;
          }
          td .free{
              vertical-align:top;
              width:100%;
              border-color:#808080;
              padding-right:0.0in;
              padding-top:0.02in;
              padding-bottom:0.02in;
          }
          .vcenter{
              vertical-align:middle;
          }
          .hright{
              text-align:right;
          }
          .hcenter{
              text-align:center;
          }
          .hleft{
              text-align:left;
          }
          .nowidth{
              width:10%;
          }
          hr{
              height:1px;
              background-color:#808080;
              border:0;
              width:100%;
              color:#808080;
          }
          hr .low{
              height:1px;
              background-color:#808080;
              border:0;
              /* for ie */
              width:50%;
              color:#808080;
              padding:0;
              margin:0;
          }
          pre{
              font-family:"Courier New";
              font-size:7pt;
              padding:0;
              margin:0;
              text-align:left;
          }
          h3{
              font-family:Arial;
              font-size:12pt;
          }</style>
      </head>
      <body>
        <div class="page">
          <header>
            <xsl:call-template name="LeyendaSuperior"/>
            <xsl:call-template name="EmisoryReceptor"/>
            <xsl:call-template name="Terceros"/>
          </header>
          <xsl:call-template name="Detalle"/>
          <footer>
            <xsl:call-template name="Observaciones"/>
            <xsl:call-template name="MostrarApendice"/>
            <xsl:call-template name="Responsable"/>
            <xsl:call-template name="Certificador"/>
          </footer>
        </div>
      </body>
    </html>
  </xsl:template>


  <!-- MAIN LAYOUT TEMPLATES -->
  <xsl:variable name="bgColor" select="'#000'"/>

  <xsl:template name="LeyendaSuperior">
    <xsl:variable name="LogoWidth">
      <xsl:choose>
        <xsl:when test="//Seller/TaxID='06141006021012'">
          <xsl:value-of select="'200px'"/>
        </xsl:when>
        <xsl:when test="//Seller/TaxID='06140212051010'">
          <xsl:value-of select="'200px'"/>
        </xsl:when>
        <xsl:when test="//Seller/TaxID='06141012221015'">
          <xsl:value-of select="'200px'"/>
        </xsl:when>
        <xsl:when test="//Seller/TaxID='06141211041042'">
          <xsl:value-of select="'150px'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'150px'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div style="height: 200px;">
      
      <div style="position:absolute; ">
        <img width="{$LogoWidth}" src="{$LogoURL}" alt="[logo]" align="left"></img>
      </div>
      
      <div style="text-align: right; position:relative; font-weight: 700">Ver.<xsl:value-of
          select="//Root/Version"/></div>
      
      <div style="text-align: center; position:relative; font-weight: 700">DOCUMENTO TRIBUTARIO
        ELECTRÓNICO <br/><xsl:call-template name="TipoDOC"/></div>
      
      <div style="width:100px; height:100px; position:relative; left:320px; ">
        <xsl:call-template name="QR"/>
      </div>
      
      <div style="width:350px; position:relative; bottom: 5px; text-align: left; font-weight: 700">
        <b>Código de Generación: </b>
        <xsl:value-of select="/Root/Header/GUID"/>
        <br/>
        <b>Número de control: </b>
        <xsl:value-of
          select="concat('DTE-',/Root/Header/DocType,'-',/Root/Header/AdditionalIssueDocInfo/Info[@Name='CodEstPuntoV']/@Value,'-',/Root/Header/AdditionalIssueDocInfo/Info[@Name='Secuencial']/@Value)"/>
        <br/>
        <b>Sello de Recepción: </b>
        <xsl:value-of select="/Root/TaxEntityResponse/Info[@Name='selloRecibido']/@Value"/>
      </div>
      
      <div
        style="width:350px; position:relative; bottom: 35px; left:450px; text-align: left; font-weight: 700">
        <b>Módelo de Facturación: </b>
        <xsl:call-template name="TipoModelo"/>
        <br/>
        <b>Tipo de Transmisión: </b>
        <xsl:call-template name="TipoTransmision"/>
        <br/>
        <b>Fecha y hora de Generación: </b>
        <xsl:value-of select="substring(/Root/Header/IssuedDateTime,9,2)"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="substring(/Root/Header/IssuedDateTime,6,2)"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="substring(/Root/Header/IssuedDateTime,1,4)"/>
        <b>
          <xsl:value-of select="' Hora: '"/>
        </b>
        <xsl:value-of select="substring(/Root/Header/IssuedDateTime,12,5)"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="EmisoryReceptor">
    <!-- Comprador y Vendedor -->
    <xsl:variable name="CondPagoApendice"
      select="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='APENDICE']/Info[@Name='CondicionPago']/@Value"/>
    <xsl:variable name="RutaReceptor"
      select="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='APENDICE']/Info[@Name='CodigoVendedor']/@Value"/>
    <xsl:variable name="CodigoClienteReceptor"
      select="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='APENDICE']/Info[@Name='CodigoCliente']/@Value"/>
    <table width="100%" cellpadding="0" cellspacing="5" border="0">
      <tbody>
        <!-- ENCABEZADOS -->
        <tr>
          <td width="49%" align="center">
            <b>EMISOR</b>
          </td>
          <td width="2%"/>
          <td width="49%" align="center">
            <b>RECEPTOR</b>
          </td>
        </tr>
        <!-- LLENADO DE TABLA -->
        <tr>
          <!-- Datos del EMISOR -->
          <td width="49%"
            style="vertical-align: top;border: 1px solid {$bgColor}; border-radius: 5px ;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tbody>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Nombre o Razón Social: </b>
                  </td>
                  <td aling="right">
                    <xsl:value-of select="//Root/Seller/Name"/>
                  </td>
                </tr>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>NIT: </b>
                  </td>
                  <td aling="right">
                    <xsl:value-of select="//Root/Seller/TaxID"/>
                  </td>
                </tr>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>NRC: </b>
                  </td>
                  <td aling="right">
                    <xsl:value-of
                      select="//Root/Seller/TaxIDAdditionalInfo/Info[@Name='NRC']/@Value"/>
                  </td>
                </tr>
                <xsl:if
                  test="//Root/Seller/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value or //Root/Seller/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Actividad Economica: </b>
                    </td>
                    <td aling="right">
                      <xsl:value-of
                        select="concat(//Root/Seller/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value,' &#8211; ',//Root/Seller/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value)"
                      />
                    </td>
                  </tr>
                </xsl:if>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Direccion: </b>
                  </td>
                  <td aling="right">
                    <xsl:call-template name="DireccionEmisor"/>
                  </td>
                </tr>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Telefono: </b>
                  </td>
                  <td aling="right">
                    <xsl:value-of select="//Root/Seller/Contact/PhoneList/Phone"/>
                  </td>
                </tr>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Correo electronico: </b>
                  </td>
                  <td aling="right">
                    <xsl:value-of select="//Root/Seller/Contact/EmailList/Email"/>
                  </td>
                </tr>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Nombre Comercial: </b>
                  </td>
                  <td aling="right">
                    <xsl:value-of
                      select="//Root/Seller/AdditionlInfo/Info[@Name='NombreComercial']/@Value"/>
                  </td>
                </tr>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Tipo de Establecimiento: </b>
                  </td>
                  <td aling="right">
                    <xsl:call-template name="TipoEstablecimiento">
                      <xsl:with-param name="tipo"
                        select="//Seller/AdditionlInfo/Info[@Name='TipoEstablecimiento']/@Value"/>
                    </xsl:call-template>
                  </td>
                </tr>
                <xsl:if test="//DocType='11'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Recinto Fiscal: </b>
                    </td>
                    <td aling="right">
                      <xsl:call-template name="TipoREC"/>
                    </td>
                  </tr>
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Regimen de exportacion: </b>
                    </td>
                    <td aling="right">
                      <xsl:value-of
                        select="//Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value"/>
                    </td>
                  </tr>
                </xsl:if>
              </tbody>
            </table>
          </td>
          <td width="2%" style="border: none;"/>
          <!-- Datos del RECEPTOR -->
          <td width="49%"
            style="vertical-align: top;border: 1px solid {$bgColor}; border-radius: 5px ;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tbody>

                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Nombre o Razón social: </b>
                  </td>
                  <td>
                    <xsl:value-of select="//Root/Buyer/Name" disable-output-escaping="yes"/>
                  </td>
                </tr>

                <xsl:if
                  test="//DocType='03' or //DocType='05' or //DocType='06' or //DocType='08' or //DocType='09'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>NIT: </b>
                    </td>
                    <td>
                      <xsl:value-of select="//Root/Buyer/TaxID"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if test="//DocType='01' or //DocType='04' or //DocType='07' or //DocType='14'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Tipo de Documento: </b>
                    </td>
                    <td>
                      <xsl:call-template name="TipoDoctoR"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if
                  test="//DocType='01' or //DocType='04' or //DocType='07' or //DocType='11' or //DocType='14'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>No. de doc. de Identificacion: </b>
                    </td>
                    <td>
                      <xsl:value-of select="//Root/Buyer/TaxID"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if
                  test="//DocType='03' or //DocType='04' or //DocType='05' or //DocType='06' or //DocType='07' or //DocType='08' or //DocType='09'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>NRC: </b>
                    </td>
                    <td>
                      <xsl:value-of
                        select="//Root/Buyer/TaxIDAdditionalInfo/Info[@Name='NRC']/@Value"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if
                  test="//DocType='03' or //DocType='05' or //DocType='06' or //DocType='08' or //DocType='09'">
                  <xsl:if
                    test="//Root/Buyer/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value or //Root/Buyer/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value">
                    <tr>
                      <td width="35%" style="white-space: nowrap;">
                        <b>Actividad Economica: </b>
                      </td>
                      <td>
                        <xsl:value-of
                          select="concat(//Root/Buyer/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value,' &#8211; ',//Root/Buyer/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value)"
                        />
                      </td>
                    </tr>
                  </xsl:if>
                </xsl:if>

                <xsl:if test="//DocType='11'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Pais Destino: </b>
                    </td>
                    <td>
                      <xsl:value-of
                        select="//Root/Buyer/AdditionlInfo/Info[@Name='NombrePais']/@Value"/>
                    </td>
                  </tr>
                </xsl:if>
                <xsl:if test="//DocType='11'">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Direccion: </b>
                    </td>
                    <td>
                      <xsl:value-of
                        select="//Root/Buyer/AdditionlInfo/Info[@Name='Complemento']/@Value"/>
                    </td>
                  </tr>
                </xsl:if>
                <xsl:if test="/Root/Buyer/AddressInfo">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Direccion: </b>
                    </td>
                    <td>
                      <xsl:call-template name="DireccionReceptor"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if test="/Root/Buyer/Contact/EmailList/Email">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Correo: </b>
                    </td>
                    <td>
                      <xsl:value-of select="/Root/Buyer/Contact/EmailList/Email"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if test="/Root/Buyer/Contact/PhoneList/Phone">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Telefono: </b>
                    </td>
                    <td>
                      <xsl:value-of select="/Root/Buyer/Contact/PhoneList/Phone"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if test="/Root/Buyer/AdditionlInfo/Info[@Name='NombreComercial']">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Nombre Comercial: </b>
                    </td>
                    <td>
                      <xsl:value-of
                        select="/Root/Buyer/AdditionlInfo/Info[@Name='NombreComercial']/@Value"
                        disable-output-escaping="yes"/>
                    </td>
                  </tr>
                </xsl:if>

                <xsl:if test="/Root/Buyer/AdditionlInfo/Info[@Name='TipoEstablecimiento']">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Tipo Establecimiento: </b>
                    </td>
                    <td>
                      <xsl:call-template name="TipoEstablecimiento">
                        <xsl:with-param name="tipo"
                          select="//Buyer/AdditionlInfo/Info[@Name='TipoEstablecimiento']/@Value"/>
                      </xsl:call-template>
                    </td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Totals/AdditionalInfo/Info[@Name='DescIncoterms']">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Incoterms: </b>
                    </td>
                    <td>
                      <xsl:value-of
                        select="//Totals/AdditionalInfo/Info[@Name='DescIncoterms']/@Value"/>
                    </td>
                  </tr>
                </xsl:if>
                <xsl:if test="$RutaReceptor">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Ruta: </b>
                    </td>
                    <td>
                      <xsl:value-of select="$RutaReceptor"/>
                    </td>
                  </tr>
                </xsl:if>
                <xsl:if test="//DocType='03' and $CodigoClienteReceptor">
                  <tr>
                    <td width="35%" style="white-space: nowrap;">
                      <b>Código de Cliente: </b>
                    </td>
                    <td>
                      <xsl:value-of select="$CodigoClienteReceptor"/>
                    </td>
                  </tr>
                </xsl:if>
                <tr>
                  <td width="35%" style="white-space: nowrap;">
                    <b>Condicion de Pago: </b>
                  </td>
                  <td>
                    <xsl:call-template name="CondicionOperacion"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="//Payments/Payment/AditionalData/Info[@Name='Periodo']/@Value"/><xsl:text> </xsl:text><xsl:call-template name="PlazoOperacion"/>
                    <xsl:if
                      test="string-length($CondPagoApendice) &gt; string-length(translate($CondPagoApendice,'0123456789',''))">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="$CondPagoApendice"/>
                    </xsl:if>
                  </td>
                </tr>
              </tbody>
            </table>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="Terceros">

   <!-- <table width="100%" cellspacing="0" cellpadding="10">
      <tr>
        <td align="center" colspan="2">
          <b>VENTA A CUENTA DE TERCEROS</b>
        </td>
      </tr>
      <tr>
        <td
          style="vertical-align: middle;border: solid; border-width: 1px 0 1px 1px ;border-radius:5px 0 0px 5px;padding:10px">
          <b>NIT: </b>
          <xsl:value-of select="//Info[@Name='NitTercero']/@Value"/>
        </td>
        <td
          style="vertical-align: middle;border: solid; border-width: 1px 1px 1px 0px ;border-radius: 0 5px 5px 0;">
          <b>Nombre, denominación o razón social: </b>
          <xsl:value-of select="//Info[@Name='NombreTercero']/@Value"/>
        </td>
      </tr>
    </table>-->
    <xsl:if test="//DocType='05' or //DocType='06'">
    <br/>
    <table width="100%" cellspacing="0" cellpadding="5">
      <tr>
        <td align="center" colspan="3">
          <b>DOCUMENTOS RELACIONADOS</b>
        </td>
      </tr>
      <tr>
        <td align="center"
          style="vertical-align: middle;border: solid; border-width: 1px 1px 1px 1px ;">
          <b>Tipo de Documento </b>
        </td>
        <td align="center"
          style="vertical-align: middle;border: solid; border-width: 1px 1px 1px 0px ;">
          <b>No. de Documento</b>
        </td>
        <td align="center"
          style="vertical-align: middle;border: solid; border-width: 1px 1px 1px 0px ;">
          <b>Fecha de Documento</b>
        </td>
      </tr>
      <xsl:for-each
        select="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='DOC_RELACIONADO']">
        <tr>
          <td align="center"
            style="vertical-align: middle;border: solid; border-width: 0px 1px 1px 1px ;">
            <xsl:value-of select="./Info[@Name='TipoDocumento']/@Value"/>
          </td>
          <td align="center"
            style="vertical-align: middle;border: solid; border-width: 0px 1px 1px 0px ;">
            <xsl:value-of select="./Info[@Name='NumDocumento']/@Value"/>
          </td>
          <td align="center"
            style="vertical-align: middle;border: solid; border-width: 0px 1px 1px 0px ;">
            <xsl:value-of select="./Info[@Name='FechaEmision']/@Value"/>
          </td>
        </tr>
      </xsl:for-each>

    </table>
    <br/>
    <xsl:if test="//AdditionalInfo/AditionalData/Data[@Name='OTROS_DOC_RELACIONADOS']">
      <table width="100%" cellspacing="0" cellpadding="5">
        <tr>
          <td align="center" colspan="3">
            <b>OTROS DOCUMENTOS ASOCIADOS</b>
          </td>
        </tr>
        <tr>
          <td align="center"
            style="vertical-align: middle;border: solid; border-width: 1px 1px 1px 1px ;">
            <b>Identificación del Documento </b>
          </td>
          <td align="center"
            style="vertical-align: middle;border: solid; border-width: 1px 1px 1px 0px ;">
            <b>Descripcion</b>
          </td>
        </tr>
        <xsl:for-each select="//AdditionalInfo/AditionalData/Data[@Name='OTROS_DOC_RELACIONADOS']">

          <tr>
            <td width="25%" align="center" height="20px"
              style="vertical-align: middle;border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
              <xsl:value-of select="./Info[@Name='CodigoDocAsociado']/@Value"/>
            </td>
            <td height="20px"
              style="vertical-align: middle;border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
              <xsl:value-of select="./Info[@Name='DescDoc']/@Value"/>
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="Detalle">
    <br/>
    <xsl:choose>
      <xsl:when test="//DocType='01'">
       <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>No.</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Codigo</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="35%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Otros montos no afectos</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas No Sujetas</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas Exentas</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Ventas Gravadas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="/Root/Items/Item">
              <tr>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                  <xsl:value-of select="./@Number"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                  <xsl:value-of select="./Codes/Code[@Name='Codigo']/@Value"/>
                </td><td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0">
                  <xsl:value-of select="format-number(./Qty,'#,##0.##')"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:call-template name="Unidad"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Description"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value">
                      <xsl:value-of select="format-number(./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:when test="./Price">
                      <xsl:value-of select="format-number(./Price,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:otherwise>0.00</xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='TOTAL_NO_GRAVADO']">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='TOTAL_NO_GRAVADO']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_NO_SUJETA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_NO_SUJETA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_EXENTA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_EXENTA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_GRAVADA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_GRAVADA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>

            </xsl:for-each>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Suma de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                />
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                />
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                />
              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sumatoria de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number(($TotalGravada + $TotalExenta + $TotalNoSujeta + $TotalExportaciones),'#,###,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas no sujetas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='NO_SUJETA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas exentas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='EXENTA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas gravadas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='GRAVADA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='GRAVADA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sub-Total:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($Subtotal4,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>IVA Retenido:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Retención Renta:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto Total de la Operación:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($MontoTotalOperacion,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total otros Montos no Afectos:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total a pagar:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:when test="//DocType='05' or //DocType='06'">
        <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>No.</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Codigo</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="35%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descuento por Item</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas No Sujetas</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas Exentas</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Ventas Gravadas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="/Root/Items/Item">
              <tr>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                  <xsl:value-of select="./@Number"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                  <xsl:value-of select="./Codes/Code[@Name='Codigo']/@Value"/>
                </td><td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0">
                  <xsl:value-of select="format-number(./Qty,'#,##0.##')"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:call-template name="Unidad"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Description"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value">
                      <xsl:value-of select="format-number(./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:when test="./Price">
                      <xsl:value-of select="format-number(./Price,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:otherwise>0.00</xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="format-number(./Discounts/Discount/Amount,'#,##0.00')"/>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_NO_SUJETA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_NO_SUJETA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_EXENTA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_EXENTA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="/Root/Items/Item/Charges/Charge[Code='VENTA_GRAVADA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_GRAVADA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
              </tr>

            </xsl:for-each>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="2"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Suma de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                />
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                />
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                />
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sumatoria de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(($TotalGravada + $TotalExenta + $TotalNoSujeta + $TotalExportaciones),'#,###,##0.00')"
                />
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas no sujetas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='NO_SUJETA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas exentas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='EXENTA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas gravadas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='GRAVADA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='GRAVADA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <xsl:choose>
              <xsl:when test="//Totals/TotalTaxes/TotalTax[Code='20']/Description">
                <tr>
                  <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
                  <td colspan="4"
                    style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                    <b>
                      <xsl:value-of select="//Totals/TotalTaxes/TotalTax[Code='20']/Description"
                      />
                    </b>
                  </td>
                  <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                    <xsl:value-of
                      select="format-number(//Totals/TotalTaxes/TotalTax[Code='20']/Amount,'#,##0.00')"
                    />
                  </td>
                </tr>
              </xsl:when>
            </xsl:choose>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sub-Total:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($Subtotal4,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>IVA Percibido:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='IvaPercibido']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='IvaPercibido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>IVA Retenido:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="4"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto Total de la Operación:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($MontoTotalOperacion,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:when test="//DocType='07'">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <thead>
            <tr>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>No.</b>
              </td>
              <td width="20%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Tipo De Doc. Relacionado</b>
              </td>
              <td width="20%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>No. del Documento Relacionado</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Fecha del Doc.</b>
              </td>
              <td width="20%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Monto Sujeto a Retención</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>IVA Retenido</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="/Root/Items/Item">
              <tr>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                  <xsl:value-of select="./@Number"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0px 1px 1px 0">
                  <xsl:call-template name="TipoDTE"/>
                </td>
                <td style=" border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Codes/Code[@Name='NumeroDocumento']/@Value"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./AdditionalInfo/Info[@Name='FechaEmision']/@Value"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Description"/>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="format-number(./Taxes/Tax/TaxableAmount,'#,##0.00')"/>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="format-number(./Taxes/Tax/Amount,'#,##0.00')"/>
                </td>
              </tr>

            </xsl:for-each>
            <tr>
              <td colspan="3"/>
              <td style="text-align: center;"/>
              <td colspan="2"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 0px 0px">
                <b>Total Monto Sujeto a Retención:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(//Totals/TotalTaxes/TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount,'#,##0.00')"
                />
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: center; border: solid {$bgColor}; border-width: 1px;">
                <b>Valor en Letras IVA Retenido</b>
                <div>
                  <xsl:value-of select="/Root/Totals/InWords"/>
                </div>
              </td>
              <td style="text-align: center;"/>
              <td colspan="2"
                style="vertical-align: middle;text-align: right; border: solid {$bgColor}; border-width: 0 1px 0px 0px">
                <b>Total IVA Retenido:</b>
              </td>
              <td
                style="vertical-align: middle;text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(//Totals/TotalTaxes/TotalTax[Code='TOTAL_IVA_RETENIDO']/Amount,'#,##0.00')"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      
      <xsl:when test="//DocType='11'">
        <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>No.</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Codigo</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="35%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descuento por Item</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Otros montos no afectos</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Ventas Afectas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="/Root/Items/Item">
              <tr>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                  <xsl:value-of select="./@Number"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                  <xsl:value-of select="./Codes/Code[@Name='Codigo']/@Value"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0">
                  <xsl:value-of select="format-number(./Qty,'#,##0.##')"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:call-template name="Unidad"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Description"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value">
                      <xsl:value-of select="format-number(./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:when test="./Price">
                      <xsl:value-of select="format-number(./Price,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:otherwise>0.00</xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="format-number(./Discounts/Discount/Amount,'#,##0.00')"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="/Root/Items/Item/Charges/Charge[Code='NO_GRAVADO']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='NO_GRAVADO']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="/Root/Items/Item/Charges/Charge[Code='VENTA_GRAVADA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_GRAVADA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>

            </xsl:for-each>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total de Operaciones Afectas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                />
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas afectas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='DESCUENTO']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='DESCUENTO']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Seguro:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='Seguro']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='Seguro']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Flete:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='Flete']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='Flete']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto Total de la Operación:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($MontoTotalOperacion,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total otros Montos no Afectos:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total a General:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:when test="//DocType='14'">
        <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>No.</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Codigo</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="35%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descuento por Item</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Ventas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="/Root/Items/Item">
              <tr>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                  <xsl:value-of select="./@Number"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                  <xsl:value-of select="./Codes/Code[@Name='Codigo']/@Value"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0">
                  <xsl:value-of select="format-number(./Qty,'#,##0.##')"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:call-template name="Unidad"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Description"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value">
                      <xsl:value-of select="format-number(./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:when test="./Price">
                      <xsl:value-of select="format-number(./Price,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:otherwise>0.00</xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="format-number(./Discounts/Discount/Amount,'#,##0.00')"/>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="/Root/Items/Item/Totals/TotalItem">
                      <xsl:value-of select="format-number(./Totals/TotalItem,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>

            </xsl:for-each>
            <tr style="page-break-inside: avoid;">
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="2"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sumatoria Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_COMPRA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_COMPRA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr style="page-break-inside: avoid;">
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="2"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sub-Total:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($TotalCompra - $Descuento,'#,##0.00')"/>
              </td>
            </tr>
            <tr style="page-break-inside: avoid;">
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="2"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Retencion Renta:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="5" style="border: solid {$bgColor}; border-width: 0 1px 0 0"/>
              <td colspan="2"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total a Pagar:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>No.</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Codigo</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="35%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Otros montos no afectos</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descuento por Item</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas No Sujetas</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas Exentas</b>
              </td>
              <td width="8%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Ventas Gravadas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="/Root/Items/Item">
              <tr>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                  <xsl:value-of select="./@Number"/>
                </td>
                <td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                  <xsl:value-of select="./Codes/Code[@Name='Codigo']/@Value"/>
                </td><td
                  style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 0">
                  <xsl:value-of select="format-number(./Qty,'#,##0.##')"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:call-template name="Unidad"/>
                </td>
                <td style="border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="./Description"/>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value">
                      <xsl:value-of select="format-number(./AdditionalInfo/Info[@Name='PrecioSugeridoVenta']/@Value,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:when test="./Price">
                      <xsl:value-of select="format-number(./Price,'#,##0.00')"/>
                    </xsl:when>
                    <xsl:otherwise>0.00</xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='TOTAL_NO_GRAVADO']">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='TOTAL_NO_GRAVADO']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:value-of select="format-number(./Discounts/Discount/Amount,'#,##0.00')"/>
                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_NO_SUJETA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_NO_SUJETA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_EXENTA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_EXENTA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>

                </td>
                <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                  <xsl:choose>
                    <xsl:when test="./Charges/Charge[Code='VENTA_GRAVADA']/Amount">
                      <xsl:value-of
                        select="format-number(./Charges/Charge[Code='VENTA_GRAVADA']/Amount,'#,##0.00')"
                      />
                    </xsl:when>
                    <xsl:otherwise> 0.00 </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>

            </xsl:for-each>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="3"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Suma de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                />
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                />
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                />
              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sumatoria de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number(($TotalGravada + $TotalExenta + $TotalNoSujeta + $TotalExportaciones),'#,###,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas no sujetas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='NO_SUJETA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas exentas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='EXENTA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto global Desc., Rebajas y otros a ventas gravadas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="//Discount[Code='GRAVADA']/Amount">
                    <xsl:value-of
                      select="format-number(//Discount[Code='GRAVADA']/Amount,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <xsl:choose>
              <xsl:when test="//Totals/TotalTaxes/TotalTax[Code='20']/Description">
                <tr>
                  <td colspan="4"/>
                  <td
                    style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
                  <td colspan="5"
                    style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                    <b>
                      <xsl:value-of select="//Totals/TotalTaxes/TotalTax[Code='20']/Description"
                      />
                    </b>
                  </td>
                  <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                    <xsl:value-of
                      select="format-number(//Totals/TotalTaxes/TotalTax[Code='20']/Amount,'#,##0.00')"
                    />
                  </td>
                </tr>
              </xsl:when>
            </xsl:choose>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Sub-Total:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($Subtotal4,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>IVA Retenido:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Retención Renta:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Monto Total de la Operación:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of select="format-number($MontoTotalOperacion,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total otros Montos no Afectos:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="4"/>
              <td style="text-align: center; border: solid {$bgColor}; border-width: 0 1px 0px 0px"/>
              <td colspan="5"
                style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0px">
                <b>Total a pagar:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0 1px 1px 0">
                <xsl:value-of
                  select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- MOSTRAR APENDICE -->
  <xsl:template name="MostrarApendice">
    <xsl:if test="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='APENDICE']">
      <br/>
      <!-- Se agregó el borde y se ajustó al tamaño carta -->
      <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td
            style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px;border-radius:5px 5px 5px 5px;">
            <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
              <xsl:for-each
                select="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='APENDICE']/Info[@Name!='CodigoVendedor']">
                <tr>
                  <td>
                    <b>
                      <xsl:choose>
                        <xsl:when test="@Data"><xsl:value-of select="@Data"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="@Name"/></xsl:otherwise>
                      </xsl:choose>
                    </b>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="@Value"/>
                  </td>
                </tr>
              </xsl:for-each>
            </table>
          </td>
        </tr>
      </table>
    </xsl:if>
  </xsl:template>
  <!-- __________________________________________________________ -->
  <xsl:template match="Info">
    <tr>
      <td>
        <xsl:value-of select="@Name"/>
      </td>
      <td>
        <xsl:value-of select="@Data"/>
      </td>
      <td>
        <xsl:value-of select="@Value"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="Observaciones">
    <br/>
    <xsl:choose>
      <xsl:when test="//DocType='08'"> </xsl:when>
      <xsl:otherwise>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td
              style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px;border-radius:5px 5px 5px 5px;">
              <table width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td width="20%" align="right">
                    <b>
                      <xsl:value-of select="'Valor en Letras: '"/>
                    </b>
                  </td>
                  <td>
                    <xsl:value-of select="/Root/Totals/InWords"/>
                  </td>
                </tr>
                <xsl:choose>
                  <xsl:when test="//DocType='03'">
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Condición de la Operación: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:call-template name="CondicionOperacion"/>
                      </td>
                    </tr>
                  </xsl:when>
                  <xsl:when test="//DocType='04'">
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Condición de la Operación: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:call-template name="CondicionOperacion"/>
                      </td>
                    </tr>
                  </xsl:when>
                  <!-- SE AGREGO LA CONDICION DE DOCTYPE11 -->
                  <xsl:when test="//DocType='11'">
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Condición de la Operación: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:call-template name="CondicionOperacion"/>
                      </td>
                    </tr>
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Peso Neto: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:value-of select="//Totals/AdditionalInfo/Info[@Name='PesoNeto']/@Value"
                        />
                      </td>
                    </tr>
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Peso Bruto: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:value-of
                          select="//Totals/AdditionalInfo/Info[@Name='PesoBruto']/@Value"/>
                      </td>
                    </tr>
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Observaciones: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:value-of
                          select="//Totals/AdditionalInfo/Info[@Name='Observaciones']/@Value"/>
                      </td>
                    </tr>
                  </xsl:when>
                  <xsl:otherwise>
                    <tr>
                      <td align="right">
                        <b>
                          <xsl:value-of select="'Condición de la Operación: '"/>
                        </b>
                      </td>
                      <td>
                        <xsl:call-template name="CondicionOperacion"/>
                      </td>
                    </tr>
                  </xsl:otherwise>
                </xsl:choose>


              </table>
            </td>
          </tr>
        </table>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="Responsable">
    <xsl:choose>
      <xsl:when test="//DocType='08'">
        <br/>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td height="30px"
              style="vertical-align: middle;border: solid {$bgColor}; border-width: 1px 1px 1px 1px;border-radius:5px;">
              <table width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td width="30%" align="right" style="font-size:10px;">
                    <b>Nombre del Responsable de la liquidación:</b>
                  </td>
                  <td width="25%"> </td>
                  <td align="right" width="25%" style="font-size:10px;">
                    <b>Doc. de Identificación</b>
                  </td>
                  <td width="20%"> </td>
                </tr>

              </table>
            </td>
          </tr>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <br/>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px;border-radius:5px;">
              <table width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td width="25%" align="right">
                    <b>Responsable por parte del emisor:</b>
                  </td>
                  <td width="50%">
                    <xsl:value-of select="//Info[@Name='NombreEntrega']/@Value"/>
                  </td>
                  <td align="right" width="15%">
                    <b>No. de Documento</b>
                  </td>
                  <td width="15%">
                    <xsl:value-of select="//Info[@Name='DocuEntrega']/@Value"/>
                  </td>
                </tr>
                <tr>
                  <td width="25%" align="right">
                    <b>Responsable por parte del Receptor:</b>
                  </td>
                  <td width="50%">
                    <xsl:value-of select="//Info[@Name='NombreRecibe']/@Value"/>
                  </td>
                  <td align="right" width="15%">
                    <b>No. de Documento</b>
                  </td>
                  <td width="15%">
                    <xsl:value-of select="//Info[@Name='DocuRecibe']/@Value"/>
                  </td>
                </tr>
                <xsl:choose>
                  <xsl:when test="//DocType='030'"> </xsl:when>
                  <xsl:when test="//DocType='070'"> </xsl:when>
                  <xsl:otherwise>
                    <tr>
                      <td align="right">
                        <b>Observación General:</b>
                      </td>
                      <td>
                        <xsl:if
                          test="//AdditionalDocumentInfo/AdditionalInfo/AditionalInfo/Info[@Name='Observaciones']/@Value">
                          <xsl:value-of
                            select="//AdditionalDocumentInfo/AdditionalInfo/AditionalInfo/Info[@Name='Observaciones']/@Value"
                          />
                        </xsl:if>
                        <xsl:if test="//Totals/AdditionalInfo/Info[@Name='Comentario']/@Value">
                          <xsl:value-of
                            select="//Totals/AdditionalInfo/Info[@Name='Comentario']/@Value"/>
                        </xsl:if>
                      </td>
                    </tr>
                  </xsl:otherwise>
                </xsl:choose>
              </table>
            </td>
          </tr>
        </table>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- AUX TEMPLATES -->
  <xsl:template name="TranslateReceiver">
    <xsl:choose>
      <xsl:when test="//CAFE:gDatRec/CAFE:iTipoRec='01'">Contribuyente</xsl:when>
      <xsl:when test="//CAFE:gDatRec/CAFE:iTipoRec='02'">Consumidor Final</xsl:when>
      <xsl:when test="//CAFE:gDatRec/CAFE:iTipoRec='03'">Gobierno</xsl:when>
      <xsl:when test="//CAFE:gDatRec/CAFE:iTipoRec='04'">Extranjero</xsl:when>
    </xsl:choose>
  </xsl:template>





  <xsl:template name="AutDGI">
    <xsl:value-of select="substring(substring-before(//CAFE:dId,'-'),5,200)"/>
  </xsl:template>

  <xsl:template name="FechaEmisionCarta">
    <xsl:value-of select="substring(//CAFE:dFechaEm,9,2)"/> de <xsl:choose>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='01'">enero</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='02'">febrero</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='03'">marzo</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='04'">abril</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='05'">mayo</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='06'">junio</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='07'">julio</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='08'">agosto</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='09'">septiembre</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='10'">octubre</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='11'">noviembre</xsl:when>
      <xsl:when test="substring(/Root/Header/IssuedDateTime,6,2)='12'">diciembre</xsl:when>
    </xsl:choose> de <xsl:value-of select="substring(/Root/Header/IssuedDateTime,1,4)"/>
  </xsl:template>

  <xsl:template name="HoraEmisionCarta">
    <xsl:value-of select="substring(/Root/Header/IssuedDateTime,12,8)"/>
  </xsl:template>

  <xsl:template name="QR">
    <img width="125" height="125">
      <xsl:attribute name="src">
        <xsl:value-of select="concat($URLAPIQR,'data=',$URLSITE,'&amp;size=100x100')"/>
        <!--<xsl:value-of select="concat($URLAPIQR,'data=',$URLSITE,'DATA=',$DATAQR,'&amp;size=100x100')"/>-->
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="'DTE'"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="'Su DTE FEL'"/>
      </xsl:attribute>
    </img>
  </xsl:template>
  <xsl:template name="Certificador">
    <br/>
    <table width="100%" cellpadding="0" cellspacing="0">
      <tr>
        <td align="left" colspan="4"
          style="border-radius: 5px 5px 5px 5px; border:solid {$bgColor};border-width: 1px;">
          <table width="100%">
            <tr>
              <td style="vertical-align:bottom;font-size:9px;">

                <xsl:value-of select="$INFORMACION_GFACE"/>
                <xsl:value-of select="', '"/>
                <xsl:value-of select="$NITGFACE"/>
                <xsl:value-of select="', '"/>
                <xsl:value-of select="$NRCFACE"/>
              </td>


            </tr>
          </table>
        </td>
      </tr>
    </table>
  </xsl:template>
</xsl:stylesheet>
