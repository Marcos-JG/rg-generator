<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:adenda="https://www.digifact.com.sv/dtecomm" xmlns:b="urn:ean.ucc:pay:2"
  xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:Root="https://admin.factura.gob.sv"
  xmlns:CAFE="http://dgi-fep.mef.gob.pa" exclude-result-prefixes="b" xml:space="default">

  <xsl:output method="html" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http: //www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" indent="no"/>
  <xsl:include href="RG-SharedSV_fel_2.xslt"/>
  <!--<xsl:include href="https://digifact-shared.s3.amazonaws.com/RG-Shared_fel_2.xslt"/>-->
  <xsl:include href="Shared_ENLETRAS_fel_2.xslt"/>
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
          <table width="100%">
            <thead> 
              <tr>
                <th>
                  <xsl:call-template name="LeyendaSuperior"/>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  <xsl:call-template name="EmisoryReceptor"/>
                </td>
                <!--<xsl:call-template name="Terceros"/>-->
              </tr>
              <tr>
                <td>
                  <xsl:call-template name="Detalle"/>
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td>
                  <xsl:call-template name="PiePagina"/>
                </td>
              </tr>
              <tr>
                <td>
                  <xsl:call-template name="Certificador"/>
                </td>
              </tr>
            </tfoot>
            <xsl:call-template name="Observaciones"/>
            <tr>
              <td>
                <xsl:call-template name="MostrarApendice"/>
              </td>
            </tr>
            <xsl:call-template name="Responsable"/>
          </table>        
        </div>
      </body>
    </html>
  </xsl:template>


  <!-- MAIN LAYOUT TEMPLATES -->
  <xsl:variable name="bgColor" select="'#000'"/>

  <xsl:template name="LeyendaSuperior">
    <xsl:variable name="LogoWidth">
      <xsl:value-of select="'140px'"/>
    </xsl:variable>
    
    <table style="width: 100%;">
      <tr>
        
        <td>
          
          <table>
            <tr>
              <td>
                <img width="{$LogoWidth}" src="{$LogoURL}" alt="[logo]" align="left"></img>
              </td>
            </tr>
          </table>
        </td>
       
        <td width="50%">
          
        </td>
        
        <td width="30%">
          <table style="width: 260px; height: 100px; border: 1px solid black; border-radius: 10px; text-align: center; table-layout: fixed; min-height: 0; transform: translateX(8px);">
            <tr>
              <td style="font-size: 10px; line-height: 1.5; overflow: hidden; padding: 5px; font-weight: normal;">
                <b>Código de Generación: </b><br/>
                <xsl:value-of select="/Root/Header/GUID"/>
                <br/>
                <b>Número de control: </b><br/>
                <xsl:value-of
                  select="concat('DTE-',/Root/Header/DocType,'-',/Root/Header/AdditionalIssueDocInfo/Info[@Name='CodEstPuntoV']/@Value,'-',/Root/Header/AdditionalIssueDocInfo/Info[@Name='Secuencial']/@Value)"/>
                <br/>
                <b>Sello de Recepción: </b><br/>
                <xsl:value-of select="/Root/TaxEntityResponse/Info[@Name='selloRecibido']/@Value"/>
                <br/>
                <!-- BEGIN-REQ::[DRTI-6162]::2026-09-01::DB::Añadir campos a RG | FASSINO -->
                <b style="font-size:12px">Modelo de facturación: </b>
                <div style="font-weight: normal;">
                  <xsl:choose>
                    <xsl:when test="//AdditionalIssueDocInfo/Info[@Name='TipoModelo']/@Value='1'">Modelo Facturación Previo</xsl:when>
                    <xsl:when test="//AdditionalIssueDocInfo/Info[@Name='TipoModelo']/@Value='2'">Modelo Facturación diferido</xsl:when>
                  </xsl:choose>
                </div>
                <b style="font-size:12px">Modelo de transmisión: </b>
                <div style="font-weight: normal;">
                  <xsl:choose>
                    <xsl:when test="//AdditionalIssueDocInfo/Info[@Name='TipoOperacion']/@Value='1'">Transmisión normal</xsl:when>
                    <xsl:when test="//AdditionalIssueDocInfo/Info[@Name='TipoOperacion']/@Value='2'">Transmisión por contingencia</xsl:when>
                  </xsl:choose>
                </div>
                <!-- END-REQ::[DRTI-6162]::2026-09-01::DB::Añadir campos a RG | FASSINO -->
              </td>
            </tr>
          </table>
        </td>
        
     
      </tr> 
      
    </table>
    <table width="100%">
      <tr>
        <td width="40%">
          <table style="width: 450px; height: 112px; border: 1px solid black; border-radius: 10px; margin-top: 15px; table-layout: fixed;">
            <tr>
              <td style="text-align: center; font-weight: 700; font-size: 13px; overflow: hidden;">
                <xsl:choose>
                  <xsl:when test="//Seller/TaxID='03152605211017'">
                    IMPORTADORA DE RODAMIENTOS, S.A. DE C.V.
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="//Seller/AdditionlInfo/Info[@Name = 'NombreComercial']/@Value"/>
                  </xsl:otherwise>
                </xsl:choose>
                </td>
            </tr>
            
            <tr>
              <td style="text-align: center; font-weight: 500; font-size: 10px;">
                <table style="table-layout: fixed; width: 100%;">
                  <xsl:if test="//Seller/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value != ''">
                    <tr>
                      <td width="15%">
                        <b>Actividad economica:</b>
                      </td>
                      <td style="overflow: hidden;">
                        <xsl:if test="//Seller/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value != ''">
                          <xsl:value-of select="concat(//Seller/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value,' &#8211; ')"/>
                        </xsl:if>
                        <xsl:value-of select="//Seller/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value"/>
                      </td>
                    </tr>
                  </xsl:if>
                  <tr>
                    <td>
                      <b>Direccion: </b>
                    </td>
                    <td style="overflow: hidden;">
                      <xsl:call-template name="DireccionEmisor"/>
                    </td>
                  </tr>
                  <xsl:if test="not(//DocType='01' or //DocType='03')">
                    <tr>
                      <td>
                        <b>Telefono: </b>
                      </td>
                      <td> 
                        <xsl:value-of select="//Contact/PhoneList/Phone"/> 
                      </td>
                    </tr>
                  </xsl:if>
                </table>
              </td>
            </tr>
            <!--<tr>
              <td style="text-align: center; font-weight: 600; font-size: 8.5px; overflow: hidden;">
                <xsl:if test="//DocType='01' or //DocType='03'">
                  Para pagos y consultas de saldo llamar a Depto. de Creditos y Cobros: Tel.: +(503)2118-2222 / 7682-2222
                </xsl:if>
              </td>
            </tr>-->
          </table>
        </td>
        
        <td width="15%" align="right">
          <table>
            <tr>
              <td>
                <xsl:call-template name="QR"/>
              </td>
            </tr>
          </table>
        </td>
        
        <xsl:choose>
      
          <xsl:when test="//DocType = '11'">
            <td width="40%" align="right">
              <table style="border: 1px solid black; border-radius: 10px; height: 20px; margin-top: 15px;">
                <tr>
                  <td style="text-align: center; font-weight: 700; padding-bottom: 13px;">
                    <span style="font-size: 11px;">
                      <xsl:call-template name="TipoDOC"/>
                      <br></br>
                      <xsl:value-of select="//Info[@Name='NumDocumento']/@Value"/>
                    </span>
                  </td>
                </tr>
                
                <tr>              
                  <td style="text-align: center; font-weight: 100; padding-top: 30px;">
                    <br/>
                    <b style="font-size: 11px;"> N.R.C.: <xsl:value-of select="//TaxIDAdditionalInfo/Info[@Name = 'NRC']/@Value"/> </b>
                    <br/>
                    <b style="font-size: 11px;">N.I.T.: <xsl:value-of select="//TaxID"/></b>
                  </td>
                </tr>
              </table>
            </td>
          </xsl:when>
          
          <xsl:when test="//DocType = '01' or //DocType = '04'">
            <td width="40%" align="right">
              <table style="border: 1px solid black; border-radius: 10px; width: 163px; height: 10px; margin-top: 13px; table-layout: fixed;">
                <tr>
                  <td style="text-align: center; font-weight: 700; padding-bottom: 40px; height: 26px;"> 
                    <span style="font-size: 11px;">
                      <xsl:call-template name="TipoDOC"/>
                      <br/>
                      <xsl:value-of select="//Info[@Name='NumDocumento']/@Value"/>
                    </span>
                  </td>
                </tr>
                
                <tr>              
                  <td style="text-align: center; font-weight: 100; height: 30px;"> 
                    <br/>
                    <b style="font-size: 11px;"> N.R.C.: 
                      <xsl:value-of select="//TaxIDAdditionalInfo/Info[@Name = 'NRC']/@Value"/> 
                    </b>
                    <br/>
                    <b style="font-size: 11px;">N.I.T.: 
                      <xsl:value-of select="//TaxID"/>
                    </b>
                  </td>
                </tr>
              </table>
            </td>
            
            
          </xsl:when>
          
          <xsl:when test="//DocType = '05' or //DocType = '06'">
            <td width="40%" align="right">
              <table style="border: 1px solid black; border-radius: 10px; margin-top: 15px;">
                <tr>
                  <td style="text-align: center; font-weight: 700;">
                    <span style="font-size: 11px;">
                      <xsl:call-template name="TipoDOC"/>
                      <br></br>
                      <xsl:value-of select="//Info[@Name='NumDocumento']/@Value"/>
                    </span>
                  </td>
                </tr>
                
                <tr>              
                  <td style="text-align: center; font-weight: 100; padding-top: 20px;">
                    <br/>
                    <b style="font-size: 11px;"> N.R.C.: <xsl:value-of select="//TaxIDAdditionalInfo/Info[@Name = 'NRC']/@Value"/> </b>
                    <br/>
                    <b style="font-size: 11px;">N.I.T.: <xsl:value-of select="//TaxID"/></b>
                  </td>
                </tr>
              </table>
            </td>
          </xsl:when>
          
          <xsl:otherwise>
            <td width="30%" align="right">
              <table style="width: 163px; height: 110px; border: 1px solid black; border-radius: 10px; margin-top: 15px; table-layout: fixed; min-height: 0;">
                <tr>
                  <td style="text-align: center; font-weight: 700; overflow: hidden;">
                    <span style="font-size: 11px; line-height: 0.5;">
                      <xsl:call-template name="TipoDOC"/>
                      <br></br>
                      <xsl:value-of select="//Info[@Name='NumDocumento']/@Value"/>
                    </span>
                  </td>
                </tr>
                
                <tr>              
                  <td style="text-align: center; font-weight: 100; padding-top: 30px; overflow: hidden;">
                    <br/>
                    <b style="font-size: 11px;">N.R.C.: <xsl:value-of select="//TaxIDAdditionalInfo/Info[@Name = 'NRC']/@Value"/></b>
                    <br/>
                    <b style="font-size: 11px;">N.I.T.: <xsl:value-of select="//TaxID"/></b>
                  </td>
                </tr>
              </table>
            </td>
            
          </xsl:otherwise>
        
        </xsl:choose>
         
        
      </tr> 
    </table>
  </xsl:template>
  
  
  <xsl:template name="EmisoryReceptor">
    <!-- Comprador y Vendedor -->
    <table width="100%" cellpadding="0" cellspacing="0"
      style="border: 1px solid {$bgColor}; border-radius: 10px;">
      <tr>
        <xsl:choose>
          
          <xsl:when test="//DocType='04' or //DocType = '14' or //DocType = '07'">
        
        <td width="40%" height="15px" style="border: solid  black; border-width: 0px 1px 0px 0px">
          <b>NOMBRE CLIENTE: </b>
          <xsl:value-of select="//Buyer/Name" disable-output-escaping="yes"/>
        </td>
        <td width="30%" height="15px" style="border: solid  black; border-width: 0px 1px 0px 0px">
          <b>FECHA CREACION: </b>
          <xsl:value-of select="substring(//Header/IssuedDateTime,9,2)"/>
          <xsl:value-of select="'-'"/>
          <xsl:value-of select="substring(//Header/IssuedDateTime,6,2)"/>
          <xsl:value-of select="'-'"/>
          <xsl:value-of select="substring(//Header/IssuedDateTime,1,4)"/>
          <b>
            <xsl:value-of select="' Hora: '"/>
          </b>
          <xsl:value-of select="substring(//Header/IssuedDateTime,12,5)"/>
        </td>
        <td width="30%" height="15px" style="border: solid  black; border-width: 0px 0px 0px 0px">
          <b>FECHA VENCIMIENTO: </b>
          <xsl:call-template name="FechaVencimientoCarta"/>
        </td>
      
          </xsl:when>
        
        <xsl:otherwise>
                   
          <td width="40%" height="15px" style="border: solid  black; border-width: 0px 1px 1px 0px">
            <b>NOMBRE CLIENTE: </b>
            <xsl:value-of select="//Buyer/Name" disable-output-escaping="yes"/>
          </td>
          <td width="30%" height="15px" style="border: solid  black; border-width: 0px 1px 1px 0px">
            <b>FECHA CREACION: </b>
            <xsl:value-of select="substring(//Header/IssuedDateTime,9,2)"/>
            <xsl:value-of select="'-'"/>
            <xsl:value-of select="substring(//Header/IssuedDateTime,6,2)"/>
            <xsl:value-of select="'-'"/>
            <xsl:value-of select="substring(//Header/IssuedDateTime,1,4)"/>
            <b>
              <xsl:value-of select="' Hora: '"/>
            </b>
            <xsl:value-of select="substring(//Header/IssuedDateTime,12,5)"/>
          </td>
          <td width="30%" height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>FECHA VENCIMIENTO: </b>
            <xsl:call-template name="FechaVencimientoCarta"/>
          </td>
                  
        </xsl:otherwise>        
        </xsl:choose>
        
        
      </tr>

      <tr>
        <xsl:if test="//DocType='01'">
          <td colspan="3" height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>NIT O DUI DEL CLIENTE: </b>
            <xsl:value-of select="//Buyer/TaxID"/>
          </td>
        </xsl:if>
        <xsl:if test="//DocType='03' or //DocType='05' or //DocType='06'">
          <td colspan="2" height="15px" style="border: solid  black; border-width: 0px 1px 1px 0px">
            <b>DIRECCIÓN: </b>
            <xsl:value-of select="//Buyer/AddressInfo/Address" disable-output-escaping="yes"/>,
              <xsl:call-template name="DistritosReceptor"/>
          </td>
          <td height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>DEPARTAMENTO: </b>
            <xsl:call-template name="EstadosReceptor"/>
          </td>
        </xsl:if>
        <xsl:if test="//DocType='11'">
          <td colspan="3" height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>DIRECCIÓN: </b>
            <xsl:value-of select="//Buyer/AdditionlInfo/Info[@Name='Complemento']/@Value"/>
          </td>
        </xsl:if>
      </tr>

      <tr>
        <xsl:if test="//DocType='01'">
          <td colspan="3" height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>DIRECCIÓN: </b>
            <xsl:call-template name="DireccionReceptor"/>
          </td>
        </xsl:if>
        <xsl:if test="//DocType='03' or //DocType='05' or //DocType='06'">
          <td height="15px" style="border: solid  black; border-width: 0px 1px 1px 0px">
            <b>N.I.T.: </b>
            <xsl:value-of select="//Buyer/TaxID"/>
          </td>
          <td height="15px" style="border: solid  black; border-width: 0px 1px 1px 0px">
            <b>N.R.C.: </b>
            <xsl:value-of select="//Buyer/TaxIDAdditionalInfo/Info[@Name='NRC']/@Value"/>
          </td>
          <td height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>GIRO: </b>
            <xsl:value-of select="//Buyer/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value"/>
          </td>
        </xsl:if>
        <xsl:if test="//DocType='11'">
          <td colspan="3" height="15px">
            <b>EXPORTACION A CUENTA DE: </b>
            <xsl:value-of select="//Info[@Name='NombreTercero']/@Value"/>
          </td>
        </xsl:if>
      </tr>

      <!-- Actividad económica del receptor (condicionada por presencia, no por DocType) - REQ DRTI-6162 #8 -->
      <xsl:if test="//Buyer/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value != ''">
        <tr>
          <td colspan="3" height="15px" style="border: solid  black; border-width: 0px 0px 1px 0px">
            <b>Actividad economica: </b>
            <xsl:if test="//Buyer/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value != ''">
              <xsl:value-of select="concat(//Buyer/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value,' &#8211; ')"/>
            </xsl:if>
            <xsl:value-of select="//Buyer/TaxIDAdditionalInfo/Info[@Name='DescActividad']/@Value"/>
          </td>
        </tr>
      </xsl:if>

      <tr>
        <xsl:if test="//DocType='01'">
          <td colspan="3" height="15px">
            <b>VENTA A CUENTA DE: </b>
            <xsl:value-of select="//Info[@Name='NombreTercero']/@Value"/>
          </td>
        </xsl:if>
        <xsl:if test="//DocType='03'">
          <td height="15px" colspan="3">
            <table width="100%">
              <tr>
                <td width="33%" style="border: solid  black; border-width: 0px 1px 0px 0px">
                  <b>VENTA A CUENTA DE: </b>
                  <xsl:value-of select="//Info[@Name='NombreTercero']/@Value"/>
                </td>

                <td width="33%" style="border: solid  black; border-width: 0px 1px 0px 0px">
                  <b># NOTA DE REMISIÓN ANT.: </b>
                  <xsl:value-of select="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='NumDocumento']/@Value"/>
                </td>

                <td width="33%">
                  <b>FECHA DE NOTA DE REMISIÓN ANT.: </b>
                  <xsl:value-of select="//Info[@Name='FechaEmision']/@Value"/>
                </td>

              </tr>
            </table>

          </td>
        </xsl:if>
        <xsl:if test="//DocType='05' or //DocType='06'">
          <td height="15px" style="border: solid black; border-width: 0px 1px 0px 0px">
            <b>Tipo de documento relacionado: </b>
            <xsl:call-template name="TipoDOCREL"/>
          </td>
          <td height="15px" style="border: solid black; border-width: 0px 1px 0px 0px">
            <b>Número de documento relacionado: </b>
            <xsl:value-of select="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='DOC_RELACIONADO'][1]/Info[@Name='NumDocumento']/@Value"/>
          </td>
          <td height="15px">
            <b>Fecha de emisión del documento relacionado: </b>
            <xsl:value-of select="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='DOC_RELACIONADO'][1]/Info[@Name='FechaEmision']/@Value"/>
          </td>
        </xsl:if>
      </tr>

      <xsl:if test="//DocType='05' or //DocType='06'">
        <tr>
          <td colspan="3" height="15px">
            <b>VENTA A CUENTA DE: </b>
            <xsl:value-of select="//Info[@Name='NombreTercero']/@Value"/>
          </td>
        </tr>
      </xsl:if>

    </table>
  </xsl:template>

  <xsl:template name="FechaVencimientoCarta">
    <xsl:choose>
      <xsl:when test="//Info[@Name='FechaVencimiento'][normalize-space(@Value) != '']">
        <xsl:value-of select="(//Info[@Name='FechaVencimiento'][normalize-space(@Value) != ''])[1]/@Value"/>
      </xsl:when>
      <xsl:when test="//Info[@Name='Fecha'][normalize-space(@Value) != '']">
        <xsl:value-of select="(//Info[@Name='Fecha'][normalize-space(@Value) != ''])[1]/@Value"/>
      </xsl:when>
      <xsl:otherwise>No proporcionada</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Terceros">

    <table width="100%" cellspacing="0" cellpadding="10">
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

        </td>
      </tr>
    </table>
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
  </xsl:template>

  <xsl:template name="Detalle">
    <br/>
    <xsl:choose>
      <xsl:when test="//DocType='01'">
        <table width="768px" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="30px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px; border-top-left-radius: 10px;">
                <b>#</b>
              </td>
              <td width="100px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="03152605211017">
                    <b>CODIGO</b>
                  </xsl:when>
                  <xsl:otherwise>
                    <b>CODIGO DE BARRA</b>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td width="48px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>CANTIDAD</b>
              </td>
              <td width="300px"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>D E S C R I P C I O N</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>PRECIO UNITARIO</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>VENTAS NO SUJETAS</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>VENTAS EXENTAS</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px; border-top-right-radius: 10px;">
                <b>VENTAS GRAVADAS</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="numNodes" select="count(//Items/Item)"/>
            <xsl:choose>
              <xsl:when test="$numNodes&lt;=15">
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="16"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="$numNodes+1"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <tr>
              <td colspan="4" style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>Son: </b>
                <xsl:value-of select="//Totals/InWords"/>
              </td>
              <td style="border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>SUMAS: </b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <!-- TD IZQUIERDO -->
              <td colspan="4"
                style=" text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px"
                > <!--LLENAR SI LA OPERACION ES MAYOR A $200--> </td>
              <!-- TD DERECHO -->
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>1% IVA Retenido:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value">
                    <xsl:value-of
                      select="format-number(//Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <!-- TD IZQUIERDO -->
              <td colspan="4" rowspan="12"
                style="border: solid {$bgColor}; border-width: 0px 1px 1px 1px; border-bottom-left-radius: 10px;">
                <table width="100%">
                  <tr>
                    <td> NOMBRE, DENOMINACION O RAZON SOCIAL: </td>
                  </tr>
                  <tr>
                    <td> NIT/DUI: </td>
                  </tr>
                  <tr>
                    <td> EXTRANJEROS: PASAPORTE/CARNET DE RESIDENCIA: </td>
                  </tr>
                </table>
                <b/>
              </td>
              <!-- TD DERECHO -->
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Sub-Total:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of select="format-number($Subtotal4,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Ventas No Sujetas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Ventas Exentas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 1px 0px">
                <b>Total a pagar:</b>
              </td>
              <td
                style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px; border-bottom-right-radius: 10px;">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of
                  select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:when test="//DocType='03'">
        <!-- CCF Por si es necesario separarlo -->
        <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="30px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px; border-top-left-radius: 10px;">
                <b>#</b>
              </td>
              <td width="100px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <xsl:choose>
                  <xsl:when test="03152605211017">
                    <b>CODIGO</b>
                  </xsl:when>
                  <xsl:otherwise>
                    <b>CODIGO DE BARRA</b>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td width="48px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>CANTIDAD</b>
              </td>
              <td width="300px"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>D E S C R I P C I O N</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>PRECIO UNITARIO</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>VENTAS NO SUJETAS</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>VENTAS EXENTAS</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px; border-top-right-radius: 10px;">
                <b>VENTAS GRAVADAS</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="numNodes" select="count(//Items/Item)"/>
            <xsl:choose>
              <xsl:when test="$numNodes&lt;=15">
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="16"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="$numNodes+1"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <tr>
              <td colspan="4" rowspan="2"
                style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>SON: </b>
                <xsl:value-of select="//Totals/InWords"/>
              </td>
              <td style="border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>SUMAS: </b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>13% DE IVA</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of select="format-number(//TotalTaxes/TotalTax/Amount,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="4"
                style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
               <!-- LLENAR SI LA OPERACION ES SUPERIOR A LOS $11,428.58 --></td>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>SUB-TOTAL:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of select="format-number($Subtotal4,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="4" rowspan="12"
                style="border: solid {$bgColor}; border-width: 0px 1px 1px 1px; border-bottom-left-radius: 10px;">
                <table width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td width="50%" style="border: solid {$bgColor}; border-width: 0px 1px 0px 0px;"
                      ><strong> ENTREGADO POR: </strong><br/>
                      
                      <br/><strong>NOMBRE: </strong>
                      <xsl:value-of select="//AditionalInfo/Info[@Name = 'NombreEntrega']/@Value"/>
                      <br/><strong> DUI: </strong>
                      <xsl:value-of select="//AditionalInfo/Info[@Name = 'DocuEntrega']/@Value"/>
                      <br/><strong> FIRMA: </strong></td>
                    <td width="50%"><strong> RECIBIDO POR: </strong><br/>
                      <br/><strong> NOMBRE: </strong>
                      <xsl:value-of select="//AditionalInfo/Info[@Name = 'NombreRecibe']/@Value"/>
                      <br/><strong> DUI: </strong>
                      <xsl:value-of select="//AditionalInfo/Info[@Name = 'DocuRecibe']/@Value"/>
                      <br/><strong> FIRMA: </strong></td>
                  </tr>
                </table>
              </td>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>(+) IVA PERCIBIDO:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//AdditionalInfo/Info[@Name='IvaPercibido']/@Value">
                    <xsl:value-of
                      select="format-number(//AdditionalInfo/Info[@Name='IvaPercibido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>(-) 1% IVA RETENIDO:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Info[@Name='IvaRetenido']/@Value">
                    <xsl:value-of
                      select="format-number(//Info[@Name='IvaRetenido']/@Value,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>VENTAS NO SUJETAS:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>VENTAS EXENTAS:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>TOTAL:</b>
              </td>
              <td
                style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px; border-bottom-right-radius: 10px;">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
              <td width="30px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px; border-top-left-radius: 10px;">
                <b>#</b>
              </td>
              <td width="48px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>CANTIDAD</b>
              </td>
              <td width="400px"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>D E S C R I P C I O N</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>PRECIO UNITARIO</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>VENTAS NO SUJETAS</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>VENTAS EXENTAS</b>
              </td>
              <td width="72.5px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px; border-top-right-radius: 10px;">
                <b>VENTAS GRAVADAS</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="numNodes" select="count(//Items/Item)"/>
            <xsl:choose>
              <xsl:when test="$numNodes&lt;=15">
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="16"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="$numNodes+1"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <tr>
              <td colspan="3" rowspan="2"
                style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>SON: </b>
                <xsl:value-of select="//Totals/InWords"/>
              </td>
              <td style="border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>SUMAS: </b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount">
                    <xsl:value-of
                      select="format-number(//Totals/TotalCharges/TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>IVA</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of select="format-number(//TotalTaxes/TotalTax/Amount,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: center; border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                LLENAR SI LA OPERACION ES SUPERIOR A LOS $11,428.58 </td>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>SUBTOTAL:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of select="format-number($Subtotal4,'#,##0.00')"/>
              </td>
            </tr>
            <tr>
              <td colspan="3" rowspan="12"
                style="border: solid {$bgColor}; border-width: 0px 1px 1px 1px; border-bottom-left-radius: 10px;">
                <table width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td width="50%" style="border: solid {$bgColor}; border-width: 0px 1px 0px 0px;"
                      > ENTREGADO POR: <br/>
                      <br/> NOMBRE: <br/>
                      <br/> D.U.I: <br/>
                      <br/> FIRMA: </td>
                    <td width="50%"> RECIBIDO POR: <br/>
                      <br/> NOMBRE: <br/>
                      <br/> D.U.I: <br/>
                      <br/> FIRMA: </td>
                  </tr>
                </table>
              </td>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>(+) IVA PERCIBIDO:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//AdditionalInfo/Info[@Name='IvaPercibido']/@Value">
                    <xsl:value-of
                      select="format-number(//AdditionalInfo/Info[@Name='IvaPercibido']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>(-) 1% IVA RETENIDO:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="//Info[@Name='IvaRetenido']/@Value">
                    <xsl:value-of
                      select="format-number(//Info[@Name='IvaRetenido']/@Value,'#,##0.00')"/>
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>VENTA NO SUJETA:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when
                    test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>VENTA EXENTA:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>TOTAL:</b>
              </td>
              <td
                style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px; border-bottom-right-radius: 10px;">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of
                  select="format-number(/Root/Totals/GrandTotal/InvoiceTotal,'#,##0.00')"/>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:when test="//DocType='11'">
        <table width="100%" cellspacing="0" cellpadding="0" style="border: 0px solid {$bgColor};">
          <thead>
            <tr>
              <td width="50px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 1px; border-top-left-radius: 10px;">
                <b>#</b>
              </td>
              <td width="68px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>CANTIDAD</b>
              </td>
              <td width="400px"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>D E S C R I P C I O N</b>
              </td>
              <td width="125px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>PRECIO UNITARIO</b>
              </td>
              <td width="125px"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px; border-top-right-radius: 10px;">
                <b>VENTAS AFECTAS</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="numNodes" select="count(//Items/Item)"/>
            <xsl:choose>
              <xsl:when test="$numNodes&lt;=15">
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="16"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="$numNodes+1"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <tr>
              <td colspan="3" style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>SON: </b>
                <xsl:value-of select="//Totals/InWords"/>
              </td>
              <td style="border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b/>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b/>
              </td>
            </tr>
            <tr>
              <td colspan="3" style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <b/>
              </td>
              <td style="text-align: left; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <b>VALOR TOTAL:</b>
              </td>
              <td
                style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px; border-bottom-right-radius: 10px;">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="50%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="15%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="15%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="numNodes" select="count(/Root/Items/Item)"/>
            <xsl:choose>
              <xsl:when test="$numNodes&lt;=15">
                <xsl:call-template name="LineasFSE">
                  <xsl:with-param name="CantLineas" select="16"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="LineasFSE">
                  <xsl:with-param name="CantLineas" select="$numNodes+1"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <tr>
              <td colspan="4" style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>Valor en letras: </b>
                <xsl:value-of select="//Root/Totals/InWords"/>
              </td>
              <td style="text-align: left; border: solid {$bgColor}; border-width: 1px 0px 0px 0px">
                <b>Sumatoria de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 1px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
            <tr>
              <!-- TD IZQUIERDO -->
              <td colspan="4"
                style=" text-align: center; border: solid {$bgColor}; border-width: 0px 1px 0px 1px"> </td>
              <!-- TD DERECHO -->
              <td style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Retencion Renta:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
              <!-- TD IZQUIERDO -->
              <td colspan="4" rowspan="12"
                style="border: solid {$bgColor}; border-width: 0px 1px 1px 1px"> </td>
              <!-- TD DERECHO -->
              <td style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 1px 0px">
                <b>Total a Pagar:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
                <b>#</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Cantidad</b>
              </td>
              <td width="5%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Unidad</b>
              </td>
              <td width="45%"
                style="vertical-align: middle;text-align: center;border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Descripción</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Precio Unitario</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas No Sujetas</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0">
                <b>Ventas Exentas</b>
              </td>
              <td width="10%"
                style="vertical-align: middle;text-align: center; border: 1px solid {$bgColor}; border-width: 1px 1px 1px 0px">
                <b>Ventas Gravadas</b>
              </td>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="numNodes" select="count(/Root/Items/Item)"/>
            <xsl:choose>
              <xsl:when test="$numNodes&lt;=15">
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="16"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="LineasFact">
                  <xsl:with-param name="CantLineas" select="$numNodes+1"/>
                  <xsl:with-param name="Linea" select="1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <tr>
              <td colspan="8" style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px">
                <b>Son: </b>
                <xsl:value-of select="//Root/Totals/InWords"/>
              </td>
            </tr>
            <tr>
              <!-- TD IZQUIERDO -->
              <td colspan="4"
                style=" text-align: center; border: solid {$bgColor}; border-width: 0px 1px 0px 1px"> </td>
              <!-- TD DERECHO -->
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Sumatoria de Ventas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:value-of
                  select="format-number($TotalGravada + $TotalExenta + $TotalNoSujeta + $TotalExportaciones,'#,###.##')"
                />
              </td>
            </tr>
            <tr>
              <!-- TD IZQUIERDO -->
              <td colspan="4" rowspan="12"
                style="border: solid {$bgColor}; border-width: 0px 1px 1px 1px">
                <b/>
              </td>
              <!-- TD DERECHO -->
            </tr>
            <xsl:if test="not(//DocType ='03')">
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='20']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='20']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='20']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='C3']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='C3']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='C3']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='59']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='59']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='59']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='71']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='71']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='71']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='D1']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='D1']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='D1']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='C8']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="Root/Totals/TotalTaxes/TotalTax[Code='C8']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="Root/Totals/TotalTaxes/TotalTax[Code='C8']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='D5']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='D5']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='D5']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="/Root/Totals/TotalTaxes/TotalTax[Code='D4']/Description">
                  <tr>
                    <td colspan="3"
                      style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                      <b>
                        <xsl:value-of
                          select="/Root/Totals/TotalTaxes/TotalTax[Code='D4']/Description"/>
                      </b>
                    </td>
                    <td
                      style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                      <span style="float: left;">
                        <b>$</b>
                      </span>
                      <xsl:value-of select="/Root/Totals/TotalTaxes/TotalTax[Code='D4']/Amount"/>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
            </xsl:if>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>1% IVA Retenido:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
            <!--<tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Retención Renta:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value">
                    <xsl:value-of
                      select="format-number(/Root/Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>-->
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Ventas Exentas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_EXENTA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 0px 0px">
                <b>Ventas No Sujetas:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 0px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
                <xsl:choose>
                  <xsl:when
                    test="/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
                    <xsl:value-of
                      select="format-number(/Root/Totals/TotalCharges/TotalCharge[Code='TOTAL_NO_SUJETA']/Amount,'#,##0.00')"
                    />
                  </xsl:when>
                  <xsl:otherwise> 0.00 </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td colspan="3"
                style="text-align: left; border: solid {$bgColor}; border-width: 0px 0px 1px 0px">
                <b>Total a pagar:</b>
              </td>
              <td style="text-align: right; border: solid {$bgColor}; border-width: 0px 1px 1px 0px">
                <span style="float: left;">
                  <b>$</b>
                </span>
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
    <xsl:if test="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='INFORMACION_ADICIONAL' or @Name='APENDICE']">
      <br/>
      <!-- Se agregó el borde y se ajustó al tamaño carta -->
      <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td
            style="border: solid {$bgColor}; border-width: 1px 1px 1px 1px;border-radius:5px 5px 5px 5px;">
            <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
              <xsl:for-each
                select="//AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data[@Name='INFORMACION_ADICIONAL' or @Name='APENDICE']/Info">
                <tr>
                  <td>
                    <b>
                      <xsl:value-of select="@Name"/>
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
                  <xsl:when test="//DocType='03'"> </xsl:when>
                  <xsl:when test="//DocType='07'"> </xsl:when>
                  <xsl:otherwise>
                    <tr>
                      <td align="right">
                        <b>Observación General:</b>
                      </td>
                      <td>
                        <xsl:value-of
                          select="//AdditionalDocumentInfo/AdditionalInfo/AditionalInfo/Info[@Name='Observaciones']/@Value"
                        />
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

  <xsl:template name="LineasFSE">
    <xsl:param name="CantLineas"/>
    <xsl:param name="Linea"/>
    <tr>
      <td width="5%" align="center" height="10px;"
        style="border-width:1px;border-color:{$bgColor};border-bottom-style:none;border-top-style:none;border-left-style:solid;border-right-style:solid;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:value-of select="$Linea"/>
        </xsl:if>
      </td>
      <td width="5%" align="center" height="10px;"
        style="border-width:1px;border-color:{$bgColor};border-bottom-style:none;border-top-style:none;border-left-style:none;border-right-style:solid;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:value-of select="format-number(//Items/Item[@Number = $Linea]/Qty,'#,##0.00')"/>
        </xsl:if>
      </td>
      <td width="10%" align="center" height="10px;"
        style="border-width:1px;border-color:{$bgColor};border-bottom-style:none;border-top-style:none;border-left-style:none;border-right-style:solid;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:call-template name="UnidadColumna"/>
        </xsl:if>
      </td>
      <td width="50%" align="left" height="10px;"
        style="border-width:1px;border-color:{$bgColor};border-bottom-style:none;border-top-style:none;border-left-style:none;border-right-style:solid;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:call-template name="SaltoTG">
            <xsl:with-param name="texto" select="//Items/Item[@Number = $Linea]/Description"/>
          </xsl:call-template> 
        </xsl:if>
      </td>
      <td width="15%" align="right" height="10px;"
        style="border-width:1px;border-color:{$bgColor};border-bottom-style:none;border-top-style:none;border-left-style:none;border-right-style:solid;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <span style="float: left;">
            <b>$</b>
          </span>
          <xsl:choose>
            <xsl:when test="//Items/Item[@Number = $Linea]/Price">
              <xsl:value-of select="format-number(//Items/Item[@Number = $Linea]/Price,'#,##0.00')"
              />
            </xsl:when>
            <xsl:otherwise>0.00</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
      <td width="15%" align="right" height="10px;"
        style="border-width:1px;border-color:{$bgColor};border-bottom-style:none;border-top-style:none;border-left-style:none;border-right-style:solid;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <span style="float: left;">
            <b>$</b>
          </span>
          <xsl:choose>
            <xsl:when test="//Items/Item[@Number = $Linea]/Totals/TotalItem">
              <xsl:value-of
                select="format-number(//Items/Item[@Number = $Linea]/Totals/TotalItem,'#,##0.00')"/>
            </xsl:when>
            <xsl:otherwise>0.00</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
    </tr>
    <xsl:variable name="Cant" select="$Linea+1"/>


    <xsl:if test="$Cant &lt; $CantLineas">
      <xsl:call-template name="LineasFSE">
        <xsl:with-param name="CantLineas" select="$CantLineas"/>
        <xsl:with-param name="Linea" select="$Cant"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="LineasFact">
    <xsl:param name="CantLineas"/>
    <xsl:param name="Linea"/>
    <tr>
      <td align="center" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 1px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:value-of select="$Linea"/>
        </xsl:if>
      </td>
      <xsl:if test="not(//DocType='05' or //DocType='06' or //DocType='11')">
        <td align="center" height="10px;"
          style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
          <xsl:choose>
            <xsl:when test="03152605211017">
              <xsl:if test="//Items/Item[@Number = $Linea]/Description">
                <xsl:value-of select="//Items/Item[@Number = $Linea]/Codes/Code[@Name='Codigo']/@Value"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="//Items/Item[@Number = $Linea]/Description">
                <xsl:value-of select="//Items/Item[@Number = $Linea]/AdditionalInfo/Info[@Name='CodigoBarra']/@Value"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          
        </td>
      </xsl:if>
      <td align="center" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:value-of select="format-number(//Items/Item[@Number = $Linea]/Qty,'#,##0.00')"/>
        </xsl:if>
      </td>
      <td align="left" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <xsl:call-template name="SaltoTG">
            <xsl:with-param name="texto" select="//Items/Item[@Number = $Linea]/Description"/>
          </xsl:call-template> 
        </xsl:if>
      </td>
      <td align="right" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <span style="float: left;">
            <b>$</b>
          </span>
          <xsl:choose>
            <xsl:when test="//Items/Item[@Number = $Linea]/Price">
              <xsl:value-of select="format-number(//Items/Item[@Number = $Linea]/Price,'#,##0.00')"
              />
            </xsl:when>
            <xsl:otherwise>0.00</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
      <xsl:if test="not(//DocType='11')">
      <td align="right" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <span style="float: left;">
            <b>$</b>
          </span>
          <xsl:choose>
            <xsl:when
              test="//Items/Item[@Number = $Linea]/Charges/Charge[Code='VENTA_NO_SUJETA']/Amount">
              <xsl:value-of
                select="format-number(//Items/Item[@Number = $Linea]/Charges/Charge[Code='VENTA_NO_SUJETA']/Amount,'#,##0.00')"
              />
            </xsl:when>
            <xsl:otherwise>0.00</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
      </xsl:if>
      <xsl:if test="not(//DocType='11')">
      <td align="right" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <span style="float: left;">
            <b>$</b>
          </span>
          <xsl:choose>
            <xsl:when
              test="//Items/Item[@Number = $Linea]/Charges/Charge[Code='VENTA_EXENTA']/Amount">
              <xsl:value-of
                select="format-number(//Items/Item[@Number = $Linea]/Charges/Charge[Code='VENTA_EXENTA']/Amount,'#,##0.00')"
              />
            </xsl:when>
            <xsl:otherwise>0.00</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
      </xsl:if>
      <td align="right" height="10px;"
        style="border: 1px solid {$bgColor}; border-width: 0px 1px 0px 0px;">
        <xsl:if test="//Items/Item[@Number = $Linea]/Description">
          <span style="float: left;">
            <b>$</b>
          </span>
          <xsl:choose>
            <xsl:when
              test="//Items/Item[@Number = $Linea]/Charges/Charge[Code='VENTA_GRAVADA']/Amount">
              <xsl:value-of
                select="format-number(//Items/Item[@Number = $Linea]/Charges/Charge[Code='VENTA_GRAVADA']/Amount,'#,##0.00')"
              />
            </xsl:when>
            <xsl:otherwise>0.00</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
    </tr>
    <xsl:variable name="Cant" select="$Linea+1"/>


    <xsl:if test="$Cant &lt; $CantLineas">
      <xsl:call-template name="LineasFact">
        <xsl:with-param name="CantLineas" select="$CantLineas"/>
        <xsl:with-param name="Linea" select="$Cant"/>
      </xsl:call-template>
    </xsl:if> 
  </xsl:template>

  <xsl:template name="PiePagina">
    <xsl:if test="not(//DocType='05' or //DocType='06')">
      <!--<br/>-->
      <!--<table width="100%" cellpadding="0" cellspacing="0">
        <tr>
          <td align="left" colspan="4"
            style="border-radius: 5px 5px 5px 5px; border:solid {$bgColor};border-width: 1px;">
            <table width="100%">
              <tr>
                <td style="vertical-align:bottom;font-size:9px;"> PAGARE SIN PROTESTO,El
                  dia_____de_____del año_____Obligo(amos), reconocere(mos), intereses del 4% mensual
                  para los efectos de esta obligación mercantil. Fijo(amos) como domicilio especial
                  la Ciudad de San Salvador, y en caso de acción judicial, renuncio(amos) al derecho
                  de la sentencia de remate y toda otra procedencia apelable que se declare en el
                  juicio ejecutivo o en sus incidencias, siendo a mi(nuestro) cargo cualquier gasto
                  que se hiciere en el cobro de este pagaré, inclusive los llamados personales, y
                  aun cuando por la regla general no hubiera condenación en costos y facultos(amos)
                  para que se designe a la persona depositaria de los bienes que se embarguen, a
                  quien revelo la obligación de rendir fianza San Salvador. <br/>
                  <br/>
                  <span style="float: right;">____________________________________________<br/>FIRMA
                    Y SELLO DEL CLIENTE SUSCRIPTOR</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>-->
    </xsl:if>
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

  <xsl:template name="SaltoTG">
    <xsl:param name="texto"/>
    
    <xsl:if test="contains($texto, 'ë')">
      <xsl:value-of select="substring-before($texto, 'ë')"/>
      <br/>
      <xsl:call-template name="SaltoTG">
        <xsl:with-param name="texto" select="substring-after($texto, 'ë')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(contains($texto, 'ë'))">
      <xsl:value-of select="$texto"/>
    </xsl:if>
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
    <img width="110" height="110">
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
