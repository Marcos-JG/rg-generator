<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:adenda="https://www.digifact.com.sv/dtecomm" xmlns:b="urn:ean.ucc:pay:2"
  xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:Root="https://admin.factura.gob.sv"
  exclude-result-prefixes="b" xml:space="default">
  <xsl:output encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <!-- VARIABLES -->
  
  <!-- VARIABLES QR -->
  
  <xsl:variable name="URLAPIQR">
    <xsl:value-of select="'https://cert.digifact.com.sv/QRService/api/QR?'"/>
  </xsl:variable>
  
  <xsl:variable name="DATAQR"> </xsl:variable>
  
  <xsl:variable name="URLSITE">
    
    <xsl:variable name="guid">
      <xsl:value-of select="/Root/Header/GUID"/>
    </xsl:variable>
    
    <xsl:variable name="version">
      <xsl:value-of select="/Root/Header/AdditionalIssueType"/>
    </xsl:variable>
    
    <xsl:variable name="fecha">
      <xsl:value-of select="substring(/Root/Header/IssuedDateTime,1,10)"/>
    </xsl:variable>
    
    <xsl:value-of select="concat('https://admin.factura.gob.sv/consultaPublica?ambiente=',$version,'%7C','codGen=',$guid,'%7C','fechaEmi=',$fecha)"/>
    
  </xsl:variable>
  
  <xsl:variable name="NITEFACE"> </xsl:variable>
  <!--  VARIABLES -->
  <xsl:variable name="NITGFACE">
    <xsl:value-of select="'NIT 0614-230822-102-5'"/>
  </xsl:variable>
  <xsl:variable name="NRCFACE">
    <xsl:value-of select="'NRC 318270-1'"/>
  </xsl:variable>


  <xsl:variable name="INFORMACION_GFACE">
    <xsl:value-of select="'DIGIFACT SERVICIOS, SOCIEDAD ANONIMA  https://www.digifact.com.sv'"/>

  </xsl:variable>

  <xsl:variable name="TELEFONO_EFACE">
    <xsl:value-of select="'2319-1921'"/>
  </xsl:variable>

  <xsl:variable name="IdDocument">
    <xsl:value-of select="/DTE/Documento/@Id"/>
  </xsl:variable>

  <xsl:variable name="SerieFel"> </xsl:variable>

  <xsl:variable name="NoFel"> </xsl:variable>

  <xsl:variable name="uniqueCreatorIdentification">
    <xsl:value-of select="concat($SerieFel,' ',$NoFel)"/>
  </xsl:variable>

  <xsl:variable name="uniqueCreatorIdentificationPIPE">
    <xsl:value-of
      select="/DTE/Documento/b:invoice/invoiceIdentification/uniqueCreatorIdentification"/>
  </xsl:variable>

  <xsl:variable name="DocumentID">
    <xsl:choose>
      <xsl:when test="contains($IdDocument,'paraFirmarConEFACE')">
        <xsl:value-of
          select="/DTE/Documento/b:invoice/invoiceIdentification/uniqueCreatorIdentification"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$IdDocument"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="caracter">
    <xsl:choose>
      <xsl:when test="contains($uniqueCreatorIdentification,'-')">
        <xsl:value-of select="'-'"/>
      </xsl:when>
      <xsl:when test="contains($uniqueCreatorIdentification,'_')">
        <xsl:value-of select="'_'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'|'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>



  <xsl:variable name="FechaEmision"> </xsl:variable>
  <xsl:variable name="FechaEmCorta">
    <xsl:value-of select="substring($FechaEmision,1,10)"/>
  </xsl:variable>
  <xsl:variable name="FechaEmisionAnio">
    <xsl:value-of select="substring-before($FechaEmCorta,'-')"/>

  </xsl:variable>
  <xsl:variable name="FechaEmisionMes">
    <xsl:value-of select="substring-before(substring-after($FechaEmCorta,'-'),'-')"/>
  </xsl:variable>
  <xsl:variable name="FechaEmisionDia">
    <xsl:value-of select="substring-after(substring-after($FechaEmCorta,'-'),'-')"/>
  </xsl:variable>
  <xsl:variable name="Simbolo">
    <xsl:value-of select="''"/>

  </xsl:variable>



  <xsl:variable name="TotalInWords"
    select="/DTE/Documento/b:invoice/invoice/contentOwner/additionalPartyIdentification[additionalPartyIdentificationType='FOR_INTERNAL_USE_1']/additionalPartyIdentificationValue"/>

  <xsl:variable name="InternalId"
    select="/DTE/Documento/b:invoice/invoice/contentOwner/additionalPartyIdentification[additionalPartyIdentificationType='FOR_INTERNAL_USE_2']/additionalPartyIdentificationValue"/>

  <xsl:variable name="DocumentType2">
    <xsl:value-of select="substring-before($uniqueCreatorIdentification,$caracter)"/>
  </xsl:variable>

  <xsl:variable name="RFCAmpersandToUnderscore">
    <xsl:value-of select="/Root/Seller/TaxID"/>

    <!--<xsl:value-of
      select="translate(/p:GTDocumento/p:SAT/p:DTE/p:DatosEmision/p:Emisor/@NITEmisor,'&amp;','_')"/>-->
  </xsl:variable>

<!-- MODO TRANSPORTE -->
  <xsl:template name="ModoTrans">
    <xsl:choose>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='1'">Terrestre</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='2'">Aéreo</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='3'">Marítimo</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='4'">Férreo</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='5'">Multimodal</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='6'">Multimodal</xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="ModoTransMayus">
    <xsl:choose>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='1'">TERRESTRE</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='2'">AÉREO</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='3'">MARÍTIMO</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='4'">FÉRREO</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='5'">MULTIMODAL</xsl:when>
      <xsl:when test="//Info[@Name='ModoTransporte']/@Value='6'">MULTIMODAL</xsl:when>
    </xsl:choose>
  </xsl:template>

<xsl:template name="RemitenciaBienes">
  <xsl:choose>
    <xsl:when test="//Buyer/AdditionlInfo/Info[@Name='BienTitulo']/@Value='01'">DEPÓSITO</xsl:when>
    <xsl:when test="//Buyer/AdditionlInfo/Info[@Name='BienTitulo']/@Value='02'">PROPIEDAD</xsl:when>
    <xsl:when test="//Buyer/AdditionlInfo/Info[@Name='BienTitulo']/@Value='03'">CONSIGNACIÓN</xsl:when>
    <xsl:when test="//Buyer/AdditionlInfo/Info[@Name='BienTitulo']/@Value='04'">TRASLADO</xsl:when>
    <xsl:when test="//Buyer/AdditionlInfo/Info[@Name='BienTitulo']/@Value='05'">OTROS</xsl:when>
  </xsl:choose>
</xsl:template>

  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="TipoDOC">
    <xsl:choose>
      <xsl:when test="//DocType='01'">FACTURA</xsl:when>
      <xsl:when test="//DocType='03'">COMPROBANTE DE CRÉDITO FISCAL</xsl:when>
      <xsl:when test="//DocType='04'">NOTA DE REMISIÓN</xsl:when>
      <xsl:when test="//DocType='05'">NOTA DE CRÉDITO</xsl:when>
      <xsl:when test="//DocType='06'">NOTA DE DÉBITO</xsl:when>
      <xsl:when test="//DocType='07'">COMPROBANTE DE RETENCIÓN</xsl:when>
      <xsl:when test="//DocType='08'">COMPROBANTE DE LIQUIDACIÓN</xsl:when>
      <xsl:when test="//DocType='09'">DOCUMENTO CONTABLE DE LIQUIDACIÓN</xsl:when>
      <xsl:when test="//DocType='11'">FACTURA DE EXPORTACIÓN</xsl:when>
      <xsl:when test="//DocType='14'">FACTURA DE SUJETO EXCLUIDO</xsl:when>
      <xsl:when test="//DocType='15'">COMPROBANTE DE DONACIÓN</xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="TipoDocRelMin">
    <xsl:choose>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='01']">Factura</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='03']">Comprobante De Crédito Fiscal</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='04']">Nota De Remisión</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='05']">Nota De Crédito</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='06']">Nota De Débito</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='07']">Comprobante De Retención</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='08']">Comprobante De Liquidación</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='09']">Documento Contable De Liquidación</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='11']">Factura De Exportación</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='14']">Factura De Sujeto Excluido</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='15']">Comprobante De Donación</xsl:when>      
    </xsl:choose>
  </xsl:template>
  <xsl:template name="RipoDocRelMin">
    <xsl:choose>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='01']">Factura</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='03']">Comprobante De Crédito Fiscal</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='04']">Nota De Remisión</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='05']">Nota De Crédito</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='06']">Nota De Débito</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='07']">Comprobante De Retención</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='08']">Comprobante De Liquidación</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='09']">Documento Contable De Liquidación</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='11']">Factura De Exportación</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='14']">Factura De Sujeto Excluido</xsl:when>
      <xsl:when test="//Data/Info[@Name='TipoDocumento' and @Value='15']">Comprobante De Donación</xsl:when>      
    </xsl:choose>
  </xsl:template>

  <!-- TIPO DE RECINTO FISCAL -->
  <xsl:template name="TipoREC">
    <xsl:choose>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='01'">Terrestre
        San Bartolo</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='02'">Marítima
        de Acajutla </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='03'">Aérea De Comalapa</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='04'">Terrestre
        Las Chinamas</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='05'">Terrestre
        La Hachadura</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='06'">Terrestre
        Santa Ana</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='07'">Terrestre
        San Cristóbal</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='08'">Terrestre
        Anguiatú</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='09'">Terrestre
        El Amatillo</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='10'">Marítima La Unión</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='11'">Terrestre
        El Poy</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='12'">Aduana
        Terrestre Metalío</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='15'">Fardos
        Postales</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='16'">Z.F. San
        Marcos</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='17'">Z.F. El
        Pedregal</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='18'">Z.F. San
        Bartolo</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='20'">Z.F.
        Exportsalva</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='21'">Z.F.
        American Park</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='23'">Z.F.
        Internacional</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='24'">Z.F.
        Diez</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='26'">Z.F.
        Miramar</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='27'">Z.F. Santo
        Tomas</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='28'">Z.F. Santa
        Tecla</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='29'">Z.F. Santa
        Ana</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='30'">Z.F. La
        Concordia</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='31'">Aérea
        Ilopango</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='32'">Z.F.
        Pipil</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='33'">Puerto
        Barillas</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='34'">Z.F. Calvo
        Conservas</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='35'">Feria
        Internacional</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='36'">Aduana El Papalón</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='37'">Z.F. Sam-Li</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='38'">Z.F. San
        José</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='39'">Z.F. Las
        Mercedes</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='71'">Aldesa</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='72'">Agdosa Merliot</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='73'">Bodesa</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='76'"
        >Delegacion DHL</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='77'">Transauto</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='80'"
        >Nejapa</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='81'"
        >Almaconsa</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='83'">Agdosa Apopa</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='85'">Gutiérrez Courier Y Cargo</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='RecintoFiscal']/@Value='99'">San Bartolo Envío Hn/Gt</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- TIPO DE REGIMEN FISCAL -->
  <xsl:template name="TipoREG">
    <xsl:choose>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1000.000'"
        >Exportación Definitiva, Exportación Definitiva, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1040.000'"
        >Exportación Definitiva, Exportación Definitiva Sustitución de Mercancías, Régimen
        Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1041.020'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Provisional,
        Franq. Presidenciales exento de DAI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1041.021'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Provisional,
        Franq. Presidenciales exento de DAI e IVA</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.025'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Maquinaria y Equipo LZF. DPA </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.031'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Distribución Internacional </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.032'"
        >Exportación Definitiva, Exportación Definitiva Proveniente. de Franquicia Definitiva,
        Operaciones Internacionales de Logística </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.033'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva, Centro
        Internacional de llamadas (Call Center)</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.034'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Tecnologías de Información LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.035'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Investigación y Desarrollo LSI </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.036'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Reparación y Mantenimiento de Embarcaciones Marítimas LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.037'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Reparación y Mantenimiento de Aeronaves LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.038'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Procesos Empresariales LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.039'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Servicios Medico-Hospitalarios LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.040'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Servicios Financieros Internacionales LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.043'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Reparación y Mantenimiento de Contenedores LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.044'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Reparación de Equipos Tecnológicos LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.054'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Atención Ancianos y Convalecientes LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.055'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Telemedicina LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1048.056'"
        >Exportación Definitiva, Exportación Definitiva Proveniente de Franquicia Definitiva,
        Cinematografía LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1052.000'"
        >Exportación Definitiva, Exportación Definitiva de DPA con origen en Compras Locales,
        Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1054.000'"
        >Exportación Definitiva, Exportación Definitiva de Zona Franca con origen en Compras
        Locales, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1100.000'"
        >Exportación Definitiva, Exportación Definitiva de Envíos de Socorro, Régimen
        Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1200.000'"
        >Exportación Definitiva, Exportación Definitiva de Envíos Postales, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1300.000'"
        >Exportación Definitiva, Exportación Definitiva Envíos que requieren despacho urgente,
        Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1400.000'"
        >Exportación Definitiva, Exportación Definitiva Courier, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1400.011'"
        >Exportación Definitiva, Exportación Definitiva Courier, Muestras Sin Valor
        Comercial</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1400.012'"
        >Exportación Definitiva, Exportación Definitiva Courier, Material Publicitario </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1400.017'"
        >Exportación Definitiva, Exportación Definitiva Courier, Declaración de
        Documentos</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-1.1500.000'"
        >Exportación Definitiva, Exportación Definitiva Menaje de casa, Régimen Común </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-2.2100.000'"
        >Exportación Temporal, Exportación Temporal para Perfeccionamiento Pasivo, Régimen
        Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-2.2200.000'"
        >Exportación Temporal, Exportación Temporal con Reimportación en el mismo estado, Régimen
        Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-2.2400.000'"
        >Traslados Definitivos</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3050.000'"
        >Re-Exportación, Reexportación Proveniente de Importación Temporal, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3051.000'"
        >Re-Exportación, Reexportación Proveniente de Tiendas Libres, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3052.000'"
        >Reexp. Prov. de Adm Temp. para Perfeccionamiento Activo</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3053.000'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3054.000'"
        >Reexp. Prov. de Régimen de Zona Franca</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3055.000'"
        >Reexp. Prov. de Adm. Temporal para Perfeccionamiento Activo con Garantía</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3056.000'"
        >Re-Exp. Prov.de Adm. Temporal de Ley de Servi.Internacionales</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3056.057'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Distribución Internacional
        Parque de Servicios, Remisión entre Usuarios Directos del Mismo Parque de
        Servicios</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3056.058'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Distribución Internacional
        Parque de Servicios, Remisión entre Usuarios Directos de Diferente Parque de
        Servicios</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3056.072'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Distribución Internacional
        Parque de Servicios, Decreto 738 Eléctricos e Híbridos </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3057.000'"
        >Reexportacion Prov. de Centro de Servicio LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3057.057'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Operaciones Internacional de
        Logística Parque de Servicios, Remisión entre Usuarios Directos del Mismo Parque de
        Servicios</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3057.058'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Operaciones Internacional de
        Logística Parque de Servicios, Remisión entre Usuarios Directos de Diferente Parque de
        Servicios</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3058.033'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Centro Servicio LSI, Centro
        Internacional de llamadas (Call Center)</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3058.036'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Centro Servicio LSI,
        Reparación y Mantenimiento de Embarcaciones Marítimas LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3058.037'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Centro Servicio LSI,
        Reparación y Mantenimiento de Aeronaves LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3058.043'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Centro Servicio LSI,
        Reparación y Mantenimiento de Contenedores LSI</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3059.000'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Reparación de Equipo
        Tecnológico Parque de Servicios, Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3059.057'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Reparación de Equipo
        Tecnológico Parque de Servicios, Remisión entre Usuarios Directos del Mismo Parque de
        Servicios</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3059.058'"
        >Re-Exportación, Reexportación Proveniente de Admisión Temporal Reparación de Equipo
        Tecnológico Parque de Servicios, Remisión entre Usuarios Directos de Diferente Parque de
        Servicios</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3070.000'"
        >Re-Exportación, Reexportación Proveniente de Depósito., Régimen Común</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3070.072'"
        >Re-Exportación, Reexportación Proveniente de Depósito., Decreto 738 Eléctricos e
        Híbridos</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='Regimen']/@Value='EX-3.3071.000'">Reexp. Prov. de Deposito.</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ACTIVIDADES ECONOMICAS -->
  <xsl:template name="ActEco">
    <xsl:choose>
      <xsl:when test="/Root/Seller/TaxIDAdditionalInfo/Info[@Name='CodigoActividad']/@Value='01111'"
        >Cultivo de cereales excepto arroz y para forrajes</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- TIPO DE DOCUMENTO RELACIONADO -->

  <xsl:template name="TipoDOCREL">
    <xsl:choose>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='01'"
        >FACTURA</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='03'"
        >COMPROBANTE DE CRÉDITO FISCAL </xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='04'"
        >NOTA DE REMISIÓN</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='05'"
        >NOTA DE CRÉDITO</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='06'"
        >NOTA DE DÉBITO</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='07'"
        >COMPROBANTE DE RETENCIÓN</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='08'"
        >COMPROBANTE DE LIQUIDACIÓN</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='09'"
        >DOCUMENTO CONTABLE DE LIQUIDACIÓN</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='11'"
        >FACTURA DE EXPORTACIÓN</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='14'"
        >FACTRUA DE SUJETO EXCLUIDO</xsl:when>
      <xsl:when
        test="/Root/AdditionalDocumentInfo/AdditionalInfo/AditionalData/Data/Info[@Name='TipoDocumento']/@Value='15'"
        >COMPROBANTE DE DONACIÓN</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Tipo de Documentos Relacionado -->
  <xsl:template name="TipoDTE">
    <xsl:choose>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='01'"
        >FACTURA</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='03'">COMPROBANTE
        DE CRÉDITO FISCAL</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='04'">NOTA DE
        REMISIÓN</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='05'">NOTA DE
        CRÉDITO</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='06'">NOTA DE
        DÉBITO</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='07'">COMPROBANTE
        DE RETENCIÓN</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='08'">COMPROBANTE
        DE LIQUIDACIÓN</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='09'">DOCUMENTO
        CONTABLE DE LIQUIDACIÓN Eltrónico</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='11'">FACTURA DE
        EXPORTACIÓN</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='14'">FACTURA DE
        SUJETO EXCLUIDO</xsl:when>
      <xsl:when test="/Root/Items/Item/AdditionalInfo/Info[@Name='TipoDte']/@Value='15'">COMPROBANTE
        DE DONACIÓN</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Tipo de Documentos Relacionado -->
  <xsl:template name="NomTributo">
    <xsl:choose>
      <xsl:when test="/Root/Items/Item/Taxes/Tax/Code='22'">Retención IVA 1%</xsl:when>
      <xsl:when test="/Root/Items/Item/Taxes/Tax/Code='C4'">Retención IVA 13%</xsl:when>
      <xsl:when test="/Root/Items/Item/Taxes/Tax/Code='C9'">Otras Retenciones IVA casos
        especiales</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Ambiente">
    <xsl:choose>
      <xsl:when test="/Root/Header[AdditionalIssueType = '00']"> TEST </xsl:when>
      <xsl:when test="/Root/Header[AdditionalIssueType = '01']"> PRODUCTIVO </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="TipoModelo">

    <xsl:choose>
      <xsl:when test="/Root/Header/AdditionalIssueDocInfo/Info[@Name='TipoModelo']/@Value='1'"
        >Modelo Facturación Previo</xsl:when>
      <xsl:when test="/Root/Header/AdditionalIssueDocInfo/Info[@Name='TipoModelo']/@Value='2'"
        >Modelo Facturación diferido</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="CondicionOperacion">
    <xsl:choose>
      <xsl:when test="//Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value='1'"
        >Contado</xsl:when>
      <xsl:when test="//Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value='2'">A
        crédito</xsl:when>
      <xsl:when test="//Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value='3'"
        >Otro</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="PlazoOperacion">
    <xsl:choose>
      <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='01'"
        >Días</xsl:when>
      <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='02'"
        >Meses</xsl:when>
      <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='03'"
        >Años</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="PlazoOperacion2">
    <xsl:param name="Plazo"/>
    <xsl:choose>
      <xsl:when test="$Plazo='01'">Días</xsl:when>
      <xsl:when test="$Plazo='02'">Meses</xsl:when>
      <xsl:when test="$Plazo='03'">Años</xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="COperacion">
  <xsl:choose>
    <xsl:when test="//Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value='1'">Contado</xsl:when>
    <xsl:when test="//Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value='2'">A Crédito, 
      <xsl:value-of select="//Payments/Payment/AditionalData/Info[@Name='Periodo']/@Value"/><xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='01'"
          >Días</xsl:when>
        <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='02'"
          >Meses</xsl:when>
        <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='03'"
          >Años</xsl:when>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="//Totals/AdditionalInfo/Info[@Name='CondicionOperacion']/@Value='3'">Otro (Mixto), 
      <xsl:value-of select="//Payments/Payment/AditionalData/Info[@Name='Periodo']/@Value"/><xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='01'"
          >Días</xsl:when>
        <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='02'"
          >Meses</xsl:when>
        <xsl:when test="//Payments/Payment/AditionalData/Info[@Name='Plazo']/@Value='03'"
          >Años</xsl:when>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
  </xsl:template>
  
  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="TipoTransmision">
    <xsl:choose>
      <xsl:when test="//AdditionalIssueDocInfo/Info[@Name='TipoOperacion']/@Value='1'">Transmisión
        normal</xsl:when>
      <xsl:when test="//AdditionalIssueDocInfo/Info[@Name='TipoOperacion']/@Value='2'">Transmisión
        por contingencia</xsl:when>

    </xsl:choose>
  </xsl:template>
  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="Establecimiento">
    <xsl:choose>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='CodEstablecimiento']/@Value='01'">Sucursal</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='CodEstablecimiento']/@Value='02'">Casa Matriz</xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='CodEstablecimiento']/@Value='04'">
        Bodega </xsl:when>
      <xsl:when test="/Root/Seller/AdditionlInfo/Info[@Name='CodEstablecimiento']/@Value='07'">Patio</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="TipoEstablecimiento">
    <xsl:param name="tipo"/>
    <xsl:choose>
      <xsl:when test="$tipo='01'"> Sucursal</xsl:when>
      <xsl:when test="$tipo='02'"> Casa matriz </xsl:when>
      <xsl:when test="$tipo='04'"> Bodega </xsl:when>
      <xsl:when test="$tipo='07'"> Patio </xsl:when>
      </xsl:choose>
  </xsl:template>

  <!-- FORMA DE PAGO -->
  <xsl:template name="FormaPago">
    <xsl:choose>
      <xsl:when test="/Root/Payments/Payment/Code='01'">Billetes y monedas</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='02'">Tarjeta Débito</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='03'">Tarjeta Crédito</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='04'">Cheque</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='05'">Transferencia- Depósito Bancario</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='06'">Vales o Cupones</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='08'">Dinero electrónico</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='09'">Monedero electrónico</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='10'">Certificado o tarjeta de regalo</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='11'">Bitcoin</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='12'">Otras Criptomonedas</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='13'">Cuentas por pagar del receptor</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='14'">Giro bancario</xsl:when>
      <xsl:when test="/Root/Payments/Payment/Code='99'">Otros (se debe indicar el medio de
        pago)</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- FORMA DE PAGO -->
  <xsl:template name="FormaPago2">
    <xsl:param name="code"/>
    <xsl:choose>
      <xsl:when test="$code='01'">Billetes y monedas</xsl:when>
      <xsl:when test="$code='02'">Tarjeta Débito</xsl:when>
      <xsl:when test="$code='03'">Tarjeta Crédito</xsl:when>
      <xsl:when test="$code='04'">Cheque</xsl:when>
      <xsl:when test="$code='05'">Transferencia- Depósito Bancario</xsl:when>
      <xsl:when test="$code='06'">Vales o Cupones</xsl:when>
      <xsl:when test="$code='08'">Dinero electrónico</xsl:when>
      <xsl:when test="$code='09'">Monedero electrónico</xsl:when>
      <xsl:when test="$code='10'">Certificado o tarjeta de regalo</xsl:when>
      <xsl:when test="$code='11'">Bitcoin</xsl:when>
      <xsl:when test="$code='12'">Otras Criptomonedas</xsl:when>
      <xsl:when test="$code='13'">Cuentas por pagar del receptor</xsl:when>
      <xsl:when test="$code='14'">Giro bancario</xsl:when>
      <xsl:when test="$code='99'">Otros (se debe indicar el medio de pago)</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- TIPO DE DOCUMENTO DE IDENTIFICACION DEL RECEPTOR -->
  <xsl:template name="TipoDoctoR">
    <xsl:choose>
      <xsl:when test="/Root/Buyer/TaxIDType='36'">NIT</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='13'">DUI</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='37'">Otro</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='03'">Pasaporte</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='02'">Carnet de Residente</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- TIPO DE PERSONA -->
  <xsl:template name="TipoPersona">
    <xsl:choose>
      <xsl:when test="//Root/Buyer/TaxIDType='01'">Persona Natural</xsl:when>
      <xsl:when test="//Root/Buyer/TaxIDType='02'">Persona Jurídica</xsl:when>
      <xsl:when test="//Root/Buyer/TaxIDAdditionalInfo/Info[@Name='TipoPersona']/@Value='01'"
        >Persona Natural</xsl:when>
      <xsl:when test="//Root/Buyer/TaxIDAdditionalInfo/Info[@Name='TipoPersona']/@Value='02'"
        >Persona Jurídica</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- TIPO DE DOCUMENTO DE DOCUMENTO EN CONTINGENCIA-->
  <xsl:template name="TipoContingencia">
    <xsl:choose>
      <xsl:when test="/Root/Buyer/TaxIDType='36'">NIT</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='13'">DUI</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='37'">Otro</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='03'">Pasaporte</xsl:when>
      <xsl:when test="/Root/Buyer/TaxIDType='02'">Carnet de Residente</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="Unidad">
    <xsl:choose>
      <xsl:when test="./UnitOfMeasure='01'">Metro</xsl:when>
      <xsl:when test="./UnitOfMeasure='1'">metro</xsl:when>
      <xsl:when test="./UnitOfMeasure='02'">Yarda</xsl:when>
      <xsl:when test="./UnitOfMeasure='2'">Yarda</xsl:when>
      <xsl:when test="./UnitOfMeasure='03'">Vara</xsl:when>
      <xsl:when test="./UnitOfMeasure='04'">Pie</xsl:when>
      <xsl:when test="./UnitOfMeasure='05'">Pulgada</xsl:when>
      <xsl:when test="./UnitOfMeasure='06'">Milímetro</xsl:when>
      <xsl:when test="./UnitOfMeasure='6'">Milímetro</xsl:when>
      <xsl:when test="./UnitOfMeasure='08'">Milla cuadrada</xsl:when>
      <xsl:when test="./UnitOfMeasure='09'">Kilómetro cuadrado</xsl:when>
      <xsl:when test="./UnitOfMeasure='9'">kilómetro cuadrado</xsl:when>
      <xsl:when test="./UnitOfMeasure='10'">Hectárea</xsl:when>
      <xsl:when test="./UnitOfMeasure='11'">Manzana</xsl:when>
      <xsl:when test="./UnitOfMeasure='12'">Acre</xsl:when>
      <xsl:when test="./UnitOfMeasure='13'">metro cuadrado</xsl:when>
      <xsl:when test="./UnitOfMeasure='14'">Yarda cuadrada</xsl:when>
      <xsl:when test="./UnitOfMeasure='15'">Vara cuadrada</xsl:when>
      <xsl:when test="./UnitOfMeasure='16'">Pie cuadrado</xsl:when>
      <xsl:when test="./UnitOfMeasure='17'">Pulgada cuadrada</xsl:when>
      <xsl:when test="./UnitOfMeasure='18'">metro cúbico</xsl:when>
      <xsl:when test="./UnitOfMeasure='19'">Yarda cúbica</xsl:when>
      <xsl:when test="./UnitOfMeasure='20'">Barril</xsl:when>
      <xsl:when test="./UnitOfMeasure='21'">Pie cúbico</xsl:when>
      <xsl:when test="./UnitOfMeasure='22'">Galón</xsl:when>
      <xsl:when test="./UnitOfMeasure='23'">Litro</xsl:when>
      <xsl:when test="./UnitOfMeasure='24'">Botella</xsl:when>
      <xsl:when test="./UnitOfMeasure='25'">Pulgada cúbica</xsl:when>
      <xsl:when test="./UnitOfMeasure='26'">Mililitro</xsl:when>
      <xsl:when test="./UnitOfMeasure='27'">Onza fluida</xsl:when>
      <xsl:when test="./UnitOfMeasure='29'">Tonelada métrica</xsl:when>
      <xsl:when test="./UnitOfMeasure='30'">Tonelada</xsl:when>
      <xsl:when test="./UnitOfMeasure='31'">Quintal métrico</xsl:when>
      <xsl:when test="./UnitOfMeasure='32'">Quintal</xsl:when>
      <xsl:when test="./UnitOfMeasure='33'">Arroba</xsl:when>
      <xsl:when test="./UnitOfMeasure='34'">Kilogramo</xsl:when>
      <xsl:when test="./UnitOfMeasure='35'">Libra troy</xsl:when>
      <xsl:when test="./UnitOfMeasure='36'">Libra</xsl:when>
      <xsl:when test="./UnitOfMeasure='37'">Onza troy</xsl:when>
      <xsl:when test="./UnitOfMeasure='38'">Onza</xsl:when>
      <xsl:when test="./UnitOfMeasure='39'">Gramo</xsl:when>
      <xsl:when test="./UnitOfMeasure='40'">Miligramo</xsl:when>
      <xsl:when test="./UnitOfMeasure='42'">Megawatt</xsl:when>
      <xsl:when test="./UnitOfMeasure='43'">Kilowatt</xsl:when>
      <xsl:when test="./UnitOfMeasure='44'">Watt</xsl:when>
      <xsl:when test="./UnitOfMeasure='45'">Megavoltio-amperio</xsl:when>
      <xsl:when test="./UnitOfMeasure='46'">Kilovoltio-amperio</xsl:when>
      <xsl:when test="./UnitOfMeasure='47'">Voltio-amperio</xsl:when>
      <xsl:when test="./UnitOfMeasure='49'">Gigawatt-hora</xsl:when>
      <xsl:when test="./UnitOfMeasure='50'">Megawatt-hora</xsl:when>
      <xsl:when test="./UnitOfMeasure='51'">Kilowatt-hora</xsl:when>
      <xsl:when test="./UnitOfMeasure='52'">Watt-hora</xsl:when>
      <xsl:when test="./UnitOfMeasure='53'">Kilovoltio</xsl:when>
      <xsl:when test="./UnitOfMeasure='54'">Voltio</xsl:when>
      <xsl:when test="./UnitOfMeasure='55'">Millar</xsl:when>
      <xsl:when test="./UnitOfMeasure='56'">Medio millar</xsl:when>
      <xsl:when test="./UnitOfMeasure='57'">Ciento</xsl:when>
      <xsl:when test="./UnitOfMeasure='58'">Docena</xsl:when>
      <xsl:when test="./UnitOfMeasure='59'">Unidad</xsl:when>
      <xsl:when test="./UnitOfMeasure='99'">Otra</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="UnidadLinea">
    <xsl:choose>
      <xsl:when test="//UnitOfMeasure='01'">Metro</xsl:when>
      <xsl:when test="//UnitOfMeasure='1'">metro</xsl:when>
      <xsl:when test="//UnitOfMeasure='02'">Yarda</xsl:when>
      <xsl:when test="//UnitOfMeasure='2'">Yarda</xsl:when>
      <xsl:when test="//UnitOfMeasure='03'">Vara</xsl:when>
      <xsl:when test="//UnitOfMeasure='04'">Pie</xsl:when>
      <xsl:when test="//UnitOfMeasure='05'">Pulgada</xsl:when>
      <xsl:when test="//UnitOfMeasure='06'">Milímetro</xsl:when>
      
      <xsl:when test="//UnitOfMeasure='6'">milímetro</xsl:when>
      <xsl:when test="//UnitOfMeasure='08'">Milla cuadrada</xsl:when>
      <xsl:when test="//UnitOfMeasure='09'">Kilómetro cuadrado</xsl:when>
      <xsl:when test="//UnitOfMeasure='9'">kilómetro cuadrado</xsl:when>
      <xsl:when test="//UnitOfMeasure='10'">Hectárea</xsl:when>
      <xsl:when test="//UnitOfMeasure='11'">Manzana</xsl:when>
      <xsl:when test="//UnitOfMeasure='12'">Acre</xsl:when>
      <xsl:when test="//UnitOfMeasure='13'">metro cuadrado</xsl:when>
      <xsl:when test="//UnitOfMeasure='14'">Yarda cuadrada</xsl:when>
      <xsl:when test="//UnitOfMeasure='15'">Vara cuadrada</xsl:when>
      <xsl:when test="//UnitOfMeasure='16'">Pie cuadrado</xsl:when>
      <xsl:when test="//UnitOfMeasure='17'">Pulgada cuadrada</xsl:when>
      <xsl:when test="//UnitOfMeasure='18'">metro cúbico</xsl:when>
      <xsl:when test="//UnitOfMeasure='19'">Yarda cúbica</xsl:when>
      <xsl:when test="//UnitOfMeasure='20'">Barril</xsl:when>
      <xsl:when test="//UnitOfMeasure='21'">Pie cúbico</xsl:when>
      <xsl:when test="//UnitOfMeasure='22'">Galón</xsl:when>
      <xsl:when test="//UnitOfMeasure='23'">Litro</xsl:when>
      <xsl:when test="//UnitOfMeasure='24'">Botella</xsl:when>
      <xsl:when test="//UnitOfMeasure='25'">Pulgada cúbica</xsl:when>
      <xsl:when test="//UnitOfMeasure='26'">Mililitro</xsl:when>
      <xsl:when test="//UnitOfMeasure='27'">Onza fluida</xsl:when>
      <xsl:when test="//UnitOfMeasure='29'">Tonelada métrica</xsl:when>
      <xsl:when test="//UnitOfMeasure='30'">Tonelada</xsl:when>
      <xsl:when test="//UnitOfMeasure='31'">Quintal métrico</xsl:when>
      <xsl:when test="//UnitOfMeasure='32'">Quintal</xsl:when>
      <xsl:when test="//UnitOfMeasure='33'">Arroba</xsl:when>
      <xsl:when test="//UnitOfMeasure='34'">Kilogramo</xsl:when>
      <xsl:when test="//UnitOfMeasure='35'">Libra troy</xsl:when>
      <xsl:when test="//UnitOfMeasure='36'">Libra</xsl:when>
      <xsl:when test="//UnitOfMeasure='37'">Onza troy</xsl:when>
      <xsl:when test="//UnitOfMeasure='38'">Onza</xsl:when>
      <xsl:when test="//UnitOfMeasure='39'">Gramo</xsl:when>
      <xsl:when test="//UnitOfMeasure='40'">Miligramo</xsl:when>
      <xsl:when test="//UnitOfMeasure='42'">Megawatt</xsl:when>
      <xsl:when test="//UnitOfMeasure='43'">Kilowatt</xsl:when>
      <xsl:when test="//UnitOfMeasure='44'">Watt</xsl:when>
      <xsl:when test="//UnitOfMeasure='45'">Megavoltio-amperio</xsl:when>
      <xsl:when test="//UnitOfMeasure='46'">Kilovoltio-amperio</xsl:when>
      <xsl:when test="//UnitOfMeasure='47'">Voltio-amperio</xsl:when>
      <xsl:when test="//UnitOfMeasure='49'">Gigawatt-hora</xsl:when>
      <xsl:when test="//UnitOfMeasure='50'">Megawatt-hora</xsl:when>
      <xsl:when test="//UnitOfMeasure='51'">Kilowatt-hora</xsl:when>
      <xsl:when test="//UnitOfMeasure='52'">Watt-hora</xsl:when>
      <xsl:when test="//UnitOfMeasure='53'">Kilovoltio</xsl:when>
      <xsl:when test="//UnitOfMeasure='54'">Voltio</xsl:when>
      <xsl:when test="//UnitOfMeasure='55'">Millar</xsl:when>
      <xsl:when test="//UnitOfMeasure='56'">Medio millar</xsl:when>
      <xsl:when test="//UnitOfMeasure='57'">Ciento</xsl:when>
      <xsl:when test="//UnitOfMeasure='58'">Docena</xsl:when>
      <xsl:when test="//UnitOfMeasure='59'">Unidad</xsl:when>
      <xsl:when test="//UnitOfMeasure='99'">Otra</xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="UnidadColumna">
    <xsl:param name="Lineas"/>
    <xsl:choose>
      <xsl:when test="$Lineas='01'">Metro</xsl:when>
      <xsl:when test="$Lineas='1'">metro</xsl:when>
      <xsl:when test="$Lineas='02'">Yarda</xsl:when>
      <xsl:when test="$Lineas='2'">Yarda</xsl:when>
      <xsl:when test="$Lineas='03'">Vara</xsl:when>
      <xsl:when test="$Lineas='04'">Pie</xsl:when>
      <xsl:when test="$Lineas='05'">Pulgada</xsl:when>
      <xsl:when test="$Lineas='06'">Milímetro</xsl:when>
      <xsl:when test="$Lineas='6'">milímetro</xsl:when>
      <xsl:when test="$Lineas='08'">Milla cuadrada</xsl:when>
      <xsl:when test="$Lineas='09'">Kilómetro cuadrado</xsl:when>
      <xsl:when test="$Lineas='9'">kilómetro cuadrado</xsl:when>
      <xsl:when test="$Lineas='10'">Hectárea</xsl:when>
      <xsl:when test="$Lineas='11'">Manzana</xsl:when>
      <xsl:when test="$Lineas='12'">Acre</xsl:when>
      <xsl:when test="$Lineas='13'">metro cuadrado</xsl:when>
      <xsl:when test="$Lineas='14'">Yarda cuadrada</xsl:when>
      <xsl:when test="$Lineas='15'">Vara cuadrada</xsl:when>
      <xsl:when test="$Lineas='16'">Pie cuadrado</xsl:when>
      <xsl:when test="$Lineas='17'">Pulgada cuadrada</xsl:when>
      <xsl:when test="$Lineas='18'">metro cúbico</xsl:when>
      <xsl:when test="$Lineas='19'">Yarda cúbica</xsl:when>
      <xsl:when test="$Lineas='20'">Barril</xsl:when>
      <xsl:when test="$Lineas='21'">Pie cúbico</xsl:when>
      <xsl:when test="$Lineas='22'">Galón</xsl:when>
      <xsl:when test="$Lineas='23'">Litro</xsl:when>
      <xsl:when test="$Lineas='24'">Botella</xsl:when>
      <xsl:when test="$Lineas='25'">Pulgada cúbica</xsl:when>
      <xsl:when test="$Lineas='26'">Mililitro</xsl:when>
      <xsl:when test="$Lineas='27'">Onza fluida</xsl:when>
      <xsl:when test="$Lineas='29'">Tonelada métrica</xsl:when>
      <xsl:when test="$Lineas='30'">Tonelada</xsl:when>
      <xsl:when test="$Lineas='31'">Quintal métrico</xsl:when>
      <xsl:when test="$Lineas='32'">Quintal</xsl:when>
      <xsl:when test="$Lineas='33'">Arroba</xsl:when>
      <xsl:when test="$Lineas='34'">Kilogramo</xsl:when>
      <xsl:when test="$Lineas='35'">Libra troy</xsl:when>
      <xsl:when test="$Lineas='36'">Libra</xsl:when>
      <xsl:when test="$Lineas='37'">Onza troy</xsl:when>
      <xsl:when test="$Lineas='38'">Onza</xsl:when>
      <xsl:when test="$Lineas='39'">Gramo</xsl:when>
      <xsl:when test="$Lineas='40'">Miligramo</xsl:when>
      <xsl:when test="$Lineas='42'">Megawatt</xsl:when>
      <xsl:when test="$Lineas='43'">Kilowatt</xsl:when>
      <xsl:when test="$Lineas='44'">Watt</xsl:when>
      <xsl:when test="$Lineas='45'">Megavoltio-amperio</xsl:when>
      <xsl:when test="$Lineas='46'">Kilovoltio-amperio</xsl:when>
      <xsl:when test="$Lineas='47'">Voltio-amperio</xsl:when>
      <xsl:when test="$Lineas='49'">Gigawatt-hora</xsl:when>
      <xsl:when test="$Lineas='50'">Megawatt-hora</xsl:when>
      <xsl:when test="$Lineas='51'">Kilowatt-hora</xsl:when>
      <xsl:when test="$Lineas='52'">Watt-hora</xsl:when>
      <xsl:when test="$Lineas='53'">Kilovoltio</xsl:when>
      <xsl:when test="$Lineas='54'">Voltio</xsl:when>
      <xsl:when test="$Lineas='55'">Millar</xsl:when>
      <xsl:when test="$Lineas='56'">Medio millar</xsl:when>
      <xsl:when test="$Lineas='57'">Ciento</xsl:when>
      <xsl:when test="$Lineas='58'">Docena</xsl:when>
      <xsl:when test="$Lineas='59'">Unidad</xsl:when>
      <xsl:when test="$Lineas='99'">Otra</xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="DireccionEmisor">
    <xsl:value-of select="//Root/Seller/AddressInfo/Address" disable-output-escaping="yes"/>.
      <xsl:call-template name="DistritosEmisor"/>, <xsl:call-template name="EstadosEmisor"/>
  </xsl:template>

  <!-- INFORMACION DE EL SALVADOR -->
  <xsl:template name="DireccionReceptor">
    <xsl:value-of select="//Root/Buyer/AddressInfo/Address" disable-output-escaping="yes"/>,
      <xsl:call-template name="DistritosReceptor"/>, <xsl:call-template name="EstadosReceptor"/>
  </xsl:template>
  <!-- INFORMACION DE ESTADOS DEL EMISOR DE EL SALVADOR -->
  <xsl:template name="EstadosEmisor">
    <xsl:choose>
      <xsl:when test="/Root/Seller/AddressInfo/State='00'">Otro (Para extranjeros)</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='01'">Ahuachapán</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='02'">Santa Ana</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='03'">Sonsonate</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='04'">Chalatenango</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='05'">La Libertad</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='06'">San Salvador</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='07'">Cuscatlán</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='08'">La Paz</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='09'">Cabañas</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='10'">San Vicente</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='11'">Usulután</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='12'">San Miguel</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='13'">Morazán</xsl:when>
      <xsl:when test="/Root/Seller/AddressInfo/State='14'">La Unión</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- INFORMACION DE ESTADOS DEL RECEPTOR DE EL SALVADOR -->
  <xsl:template name="EstadosReceptor">
    <xsl:choose>
      <xsl:when test="/Root/Buyer/AddressInfo/State='00'">Otros (Para extranjeros)</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='01'">Ahuachapán</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='02'">Santa Ana</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='03'">Sonsonate</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='04'">Chalatenango</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='05'">La Libertad</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='06'">San Salvador</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='07'">Cuscatlán</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='08'">La Paz</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='09'">Cabañas</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='10'">San Vicente</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='11'">Usulután</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='12'">San Miguel</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='13'">Morazán</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='14'">La Unión</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="EstadosReceptorMayus">
    <xsl:choose>
      <xsl:when test="/Root/Buyer/AddressInfo/State='00'">OTROS (PARA EXTRANJEROS)</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='01'">AHUACHAPÁN</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='02'">SANTA ANA</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='03'">SONSONATE</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='04'">CHALATENANGO</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='05'">LA LIBERTAD</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='06'">SAN SALVADOR</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='07'">CUSCATLÁN</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='08'">LA PAZ</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='09'">CABAÑAS</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='10'">SAN VICENTE</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='11'">USULUTÁN</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='12'">SAN MIGUEL</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='13'">MORAZÁN</xsl:when>
      <xsl:when test="/Root/Buyer/AddressInfo/State='14'">LA UNIÓN</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- INFORMACION DE DISTRITOS POR EMISOR DE EL SALVADOR -->

  <xsl:template name="DistritosEmisor">
    <xsl:if test="/Root/Seller/AddressInfo/State='00'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='00'">Otro (Para extranjeros)</xsl:when>  
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='01'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Ahuachapán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Apaneca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Atiquizaya</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Concepción de Ataco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">El Refugio</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Guaymango</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Jujutla</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">San Francisco Menéndez</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">San Lorenzo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">San Pedro Puxtla</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Tacuba</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Turín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Ahuachapan Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Ahuachapan Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Ahuachapan Sur</xsl:when>
        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='02'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Candelaria de la Frontera</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Coatepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Chalchuapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">El Congo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">El Porvenir</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Masahuat</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Metapán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">San Antonio Pajonal</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">San Sebastián Salitrillo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Santa Ana</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Santa Rosa Guachipilín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Santiago de la Frontera</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Texistepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Santa Ana Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Santa Ana Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Santa Ana Este</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">Santa Ana Oeste</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='03'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Acajutla</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Armenia</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Caluco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Cuisnahuat</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Santa Isabel Ishuatán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Izalco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Juayúa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Nahuizalco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Nahulingo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Salcoatitán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">San Antonio del Monte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">San Julián</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Santa Catarina Masahuat</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Santo Domingo Guzmán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Sonsonate</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Sonzacate</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">Sonsonate Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Sonsonate Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">Sonsonate Este</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">Sonsonate Oeste</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='04'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Agua Caliente</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Arcatao</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Azacualpa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Citalá</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Comalapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Concepción Quezaltepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Chalatenango</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Dulce Nombre de María</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">El Carrizal</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">El Paraíso</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">La Laguna</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">La Palma</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">La Reina</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Las Vueltas</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Nombre de Jesús</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Nueva Concepción</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">Nueva Trinidad</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Ojos de Agua</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">Potonico</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">San Antonio de la Cruz</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">San Antonio Los Ranchos</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">San Fernando</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">San Francisco Lempa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='24'">San Francisco Morazán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='25'">San Ignacio</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='26'">San Isidro Labrador</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='27'">San José Cancasque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='28'">San José Las Flores</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='29'">San Luis del Carmen</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='30'">San Miguel de Mercedes</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='31'">San Rafael</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='32'">Santa Rita</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='33'">Tejutla</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='34'">Chalatenango Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='35'">Chalatenango Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='36'">Chalatenango Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='05'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Antiguo Cuscatlán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Ciudad Arce</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Colón</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Comasagua</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Chiltiupán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Huizúcar</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Jayaque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Jicalapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">La Libertad</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Nuevo Cuscatlán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Santa Tecla</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Quezaltepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Sacacoyo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">San José Villanueva</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">San Juan Opico</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">San Matías</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">San Pablo Tacachico</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Tamanique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">Talnique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">Teotepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">Tepecoyo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">Zaragoza</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">La Libertad Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='24'">La Libertad Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='25'">La Libertad Oeste</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='26'">La Libertad Este</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='27'">La Libertad Costa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='28'">La Libertad Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='06'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Aguilares</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Apopa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Ayutuxtepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Cuscatancingo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">El Paisnal</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Guazapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Ilopango</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Mejicanos</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Nejapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Panchimalco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Rosario de Mora</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">San Marcos</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">San Martín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">San Salvador</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Santiago Texacuangos</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Santo Tomás</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">Soyapango</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Tonacatepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">Ciudad Delgado</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">San Salvador Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">San Salvador Oeste</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">San Salvador Este</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">San Salvador Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='24'">San Salvador Sur</xsl:when>

      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='07'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Candelaria</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Cojutepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">El Carmen</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">El Rosario</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Monte San Juan</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Oratorio de Concepción</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">San Bartolomé Perulapía</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">San Cristóbal</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">San José Guayabal</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">San Pedro Perulapán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">San Rafael Cedros</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">San Ramón</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Santa Cruz Analquito</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Santa Cruz Michapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Suchitoto</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Tenancingo</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">Cuscatlan Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Cuscatlan Sur</xsl:when>
        
      </xsl:choose>
    </xsl:if>
    
    <xsl:if test="/Root/Seller/AddressInfo/State='08'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Cuyultitán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">El Rosario</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Jerusalén</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Mercedes La Ceiba</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Olocuilta</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Paraíso de Osorio</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">San Antonio Masahuat</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">San Emigdio</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">San Francisco Chinameca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">San Juan Nonualco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">San Juan Talpa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">San Juan Tepezontes</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">San Luis Talpa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">San Miguel Tepezontes</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">San Pedro Masahuat</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">San Pedro Nonualco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">San Rafael Obrajuelo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Santa María Ostuma</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">Santiago Nonualco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">Tapalhuaca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">Zacatecoluca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">San Luis La Herradura</xsl:when>
        
        
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">La Paz Oeste</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='24'">La Paz Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='25'">La Paz Este</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='09'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Cinquera</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Guacotecti</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Ilobasco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Jutiapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">San Isidro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Sensuntepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Tejutepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Victoria</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Dolores</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Cabañas Oeste</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Cabañas Este</xsl:when>        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='10'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Apastepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Guadalupe</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">San Cayetano Istepeque</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Santa Clara</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Santo Domingo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">San Esteban Catarina</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">San Ildefonso</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">San Lorenzo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">San Sebastián</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">San Vicente</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Tecoluca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Tepetitán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Verapaz</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">San Vicente Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">San Vicente Sur</xsl:when>
        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='11'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Alegría</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Berlín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">California</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Concepción Batres</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">El Triunfo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Ereguayquín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Estanzuelas</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Jiquilisco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Jucuapa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Jucuarán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Mercedes Umaña</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Nueva Granada</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Ozatlán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Puerto El Triunfo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">San Agustín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">San Buenaventura</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">San Dionisio</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Santa Elena</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">San Francisco Javier</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">Santa María</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">Santiago de María</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">Tecapán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">Usulután</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='24'">Usulután Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='25'">Usulután Este</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='26'">Usulután Oeste</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='12'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Carolina</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Ciudad Barrios</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Comacarán</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Chapeltique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Chinameca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">Chirilagua</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">El Tránsito</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Lolotique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Moncagua</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Nueva Guadalupe</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Nuevo Edén de San Juan</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Quelepa</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">San Antonio del Mosco</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">San Gerardo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">San Jorge</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">San Luis de la Reina</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">San Miguel</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">San Rafael Oriente</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">Sesori</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">Uluazapa</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">San Miguel Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">San Miguel Centro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">San Miguel Oeste</xsl:when>

      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='13'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Arambala</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Cacaopera</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Corinto</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Chilanga</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">Delicias de Concepción</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">El Divisadero</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">El Rosario</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">Gualococti</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Guatajiagua</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Joateca</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Jocoaitique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Jocoro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Lolotiquillo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">Meanguera</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">Osicala</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Perquín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">San Carlos</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">San Fernando</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">San Francisco Gotera</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">San Isidro</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='21'">San Simón</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='22'">Sensembra</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='23'">Sociedad</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='24'">Torola</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='25'">Yamabal</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='26'">Yoloaiquín</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='27'">Morazan Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='28'">Morazan Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Seller/AddressInfo/State='14'">
      <xsl:choose>
        <xsl:when test="/Root/Seller/AddressInfo/District='01'">Anamorós</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='02'">Bolívar</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='03'">Concepción de Oriente</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='04'">Conchagua</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='05'">El Carmen</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='06'">El Sauce</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='07'">Intipucá</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='08'">La Unión</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='09'">Lislique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='10'">Meanguera del Golfo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='11'">Nueva Esparta</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='12'">Pasaquina</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='13'">Polorós</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='14'">San Alejo</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='15'">San José</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='16'">Santa Rosa de Lima</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='17'">Yayantique</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='18'">Yucuaiquín</xsl:when>
        
        <xsl:when test="/Root/Seller/AddressInfo/District='19'">La Union Norte</xsl:when>
        <xsl:when test="/Root/Seller/AddressInfo/District='20'">La Union Sur</xsl:when>

      </xsl:choose>
    </xsl:if>
  </xsl:template>


  <!-- INFORMACION DE DISTRITOS POR RECEPTOR DE EL SALVADOR -->
  <xsl:template name="DistritosReceptor">
    <xsl:if test="/Root/Buyer/AddressInfo/State='00'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='00'">Otro (Para extranjeros)</xsl:when>  
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='01'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Ahuachapán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Apaneca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Atiquizaya</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Concepción de Ataco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">El Refugio</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Guaymango</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Jujutla</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">San Francisco Menéndez</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">San Lorenzo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">San Pedro Puxtla</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Tacuba</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Turín</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Ahuachapan Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Ahuachapan Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Ahuachapan Sur</xsl:when>
        
        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='02'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Candelaria de la Frontera</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Coatepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Chalchuapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">El Congo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">El Porvenir</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Masahuat</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Metapán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">San Antonio Pajonal</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">San Sebastián Salitrillo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Santa Ana</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Santa Rosa Guachipilín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Santiago de la Frontera</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Texistepeque</xsl:when>
        
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Santa Ana Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Santa Ana Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Santa Ana Este</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">Santa Ana Oeste</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='03'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Acajutla</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Armenia</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Caluco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Cuisnahuat</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Santa Isabel Ishuatán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Izalco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Juayúa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Nahuizalco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Nahulingo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Salcoatitán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">San Antonio del Monte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">San Julián</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Santa Catarina Masahuat</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Santo Domingo Guzmán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Sonsonate</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Sonzacate</xsl:when>
        
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">Sonsonate Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Sonsonate Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">Sonsonate Este</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">Sonsonate Oeste</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='04'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Agua Caliente</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Arcatao</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Azacualpa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Citalá</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Comalapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Concepción Quezaltepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Chalatenango</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Dulce Nombre de María</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">El Carrizal</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">El Paraíso</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">La Laguna</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">La Palma</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">La Reina</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Las Vueltas</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Nombre de Jesús</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Nueva Concepción</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">Nueva Trinidad</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Ojos de Agua</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">Potonico</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">San Antonio de la Cruz</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">San Antonio Los Ranchos</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">San Fernando</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">San Francisco Lempa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='24'">San Francisco Morazán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='25'">San Ignacio</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='26'">San Isidro Labrador</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='27'">San José Cancasque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='28'">San José Las Flores</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='29'">San Luis del Carmen</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='30'">San Miguel de Mercedes</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='31'">San Rafael</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='32'">Santa Rita</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='33'">Tejutla</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='34'">Chalatenango Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='35'">Chalatenango Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='36'">Chalatenango Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='05'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Antiguo Cuscatlán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Ciudad Arce</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Colón</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Comasagua</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Chiltiupán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Huizúcar</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Jayaque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Jicalapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">La Libertad</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Nuevo Cuscatlán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Santa Tecla</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Quezaltepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Sacacoyo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">San José Villanueva</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">San Juan Opico</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">San Matías</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">San Pablo Tacachico</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Tamanique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">Talnique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">Teotepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">Tepecoyo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">Zaragoza</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">La Libertad Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='24'">La Libertad Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='25'">La Libertad Oeste</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='26'">La Libertad Este</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='27'">La Libertad Costa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='28'">La Libertad Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='06'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Aguilares</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Apopa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Ayutuxtepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Cuscatancingo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">El Paisnal</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Guazapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Ilopango</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Mejicanos</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Nejapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Panchimalco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Rosario de Mora</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">San Marcos</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">San Martín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">San Salvador</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Santiago Texacuangos</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Santo Tomás</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">Soyapango</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Tonacatepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">Ciudad Delgado</xsl:when>


        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">San Salvador Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">San Salvador Oeste</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">San Salvador Este</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">San Salvador Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='24'">San Salvador Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='07'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Candelaria</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Cojutepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">El Carmen</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">El Rosario</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Monte San Juan</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Oratorio de Concepción</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">San Bartolomé Perulapía</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">San Cristóbal</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">San José Guayabal</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">San Pedro Perulapán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">San Rafael Cedros</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">San Ramón</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Santa Cruz Analquito</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Santa Cruz Michapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Suchitoto</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Tenancingo</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">Cuscatlan Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Cuscatlan Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='08'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Cuyultitán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">El Rosario</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Jerusalén</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Mercedes La Ceiba</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Olocuilta</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Paraíso de Osorio</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">San Antonio Masahuat</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">San Emigdio</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">San Francisco Chinameca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">San Juan Nonualco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">San Juan Talpa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">San Juan Tepezontes</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">San Luis Talpa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">San Miguel Tepezontes</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">San Pedro Masahuat</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">San Pedro Nonualco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">San Rafael Obrajuelo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Santa María Ostuma</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">Santiago Nonualco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">Tapalhuaca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">Zacatecoluca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">San Luis La Herradura</xsl:when>
        
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">La Paz Oeste</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='24'">La Paz Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='25'">La Paz Este</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='09'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Cinquera</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Guacotecti</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Ilobasco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Jutiapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">San Isidro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Sensuntepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Tejutepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Victoria</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Dolores</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Cabañas Oeste</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Cabañas Este</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='10'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Apastepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Guadalupe</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">San Cayetano Istepeque</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Santa Clara</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Santo Domingo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">San Esteban Catarina</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">San Ildefonso</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">San Lorenzo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">San Sebastián</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">San Vicente</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Tecoluca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Tepetitán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Verapaz</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">San Vicente Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">San Vicente Sur</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='11'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Alegría</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Berlín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">California</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Concepción Batres</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">El Triunfo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Ereguayquín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Estanzuelas</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Jiquilisco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Jucuapa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Jucuarán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Mercedes Umaña</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Nueva Granada</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Ozatlán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Puerto El Triunfo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">San Agustín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">San Buenaventura</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">San Dionisio</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Santa Elena</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">San Francisco Javier</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">Santa María</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">Santiago de María</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">Tecapán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">Usulután</xsl:when>
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='24'">Usulutan Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='25'">Usulutan Este</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='26'">Usulutan Oeste</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='12'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Carolina</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Ciudad Barrios</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Comacarán</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Chapeltique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Chinameca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">Chirilagua</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">El Tránsito</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Lolotique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Moncagua</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Nueva Guadalupe</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Nuevo Edén de San Juan</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Quelepa</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">San Antonio del Mosco</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">San Gerardo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">San Jorge</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">San Luis de la Reina</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">San Miguel</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">San Rafael Oriente</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">Sesori</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">Uluazapa</xsl:when>
        
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">San Miguel Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">San Miguel Centro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">San Miguel Oeste</xsl:when>

      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='13'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Arambala</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Cacaopera</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Corinto</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Chilanga</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">Delicias de Concepción</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">El Divisadero</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">El Rosario</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">Gualococti</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Guatajiagua</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Joateca</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Jocoaitique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Jocoro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Lolotiquillo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">Meanguera</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">Osicala</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Perquín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">San Carlos</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">San Fernando</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">San Francisco Gotera</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">San Isidro</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='21'">San Simón</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='22'">Sensembra</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='23'">Sociedad</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='24'">Torola</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='25'">Yamabal</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='26'">Yoloaiquín</xsl:when>
        
        
        <xsl:when test="/Root/Buyer/AddressInfo/District='27'">Morazan Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='28'">Morazan Sur</xsl:when>

      </xsl:choose>
    </xsl:if>
    <xsl:if test="/Root/Buyer/AddressInfo/State='14'">
      <xsl:choose>
        <xsl:when test="/Root/Buyer/AddressInfo/District='01'">Anamorós</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='02'">Bolívar</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='03'">Concepción de Oriente</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='04'">Conchagua</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='05'">El Carmen</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='06'">El Sauce</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='07'">Intipucá</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='08'">La Unión</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='09'">Lislique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='10'">Meanguera del Golfo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='11'">Nueva Esparta</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='12'">Pasaquina</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='13'">Polorós</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='14'">San Alejo</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='15'">San José</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='16'">Santa Rosa de Lima</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='17'">Yayantique</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='18'">Yucuaiquín</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='19'">La Union Norte</xsl:when>
        <xsl:when test="/Root/Buyer/AddressInfo/District='20'">La Union Sur</xsl:when>

      </xsl:choose>
    </xsl:if>

  </xsl:template>
  
  <!-- DISTRITOS EN MAYUSCULAS -->
    <xsl:template name="DistritosReceptorMayus">
      <xsl:if test="/Root/Buyer/AddressInfo/State='00'">
        <xsl:choose>
          <xsl:when test="/Root/Buyer/AddressInfo/District='00'">OTRO (PARA EXTRANJEROS)</xsl:when>  
        </xsl:choose>
      </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='01'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">AHUACHAPÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">APANECA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">ATIQUIZAYA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CONCEPCIÓN DE ATACO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">EL REFUGIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">GUAYMANGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">JUJUTLA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">SAN FRANCISCO MENÉNDEZ</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">SAN LORENZO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">SAN PEDRO PUXTLA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">TACUBA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">TURÍN</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='13'">AHUACHAPÁN NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">AHUACHAPÁN CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">AHUACHAPÁN SUR</xsl:when>
        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='02'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">CANDELARIA DE LA FRONTERA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">COATEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">CHALCHUAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">EL CONGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">EL PORVENIR</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">MASAHUAT</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">METAPÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">SAN ANTONIO PAJONAL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">SAN SEBASTIÁN SALITRILLO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">SANTA ANA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">SANTA ROSA GUACHIPILÍN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">SANTIAGO DE LA FRONTERA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">TEXISTEPEQUE</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='14'">SANTA ANA NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SANTA ANA CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SANTA ANA ESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SANTA ANA OESTE</xsl:when>  
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='03'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">ACAJUTLA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">ARMENIA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">CALUCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CUISNAHUAT</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">SANTA ISABEL ISHUATÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">IZALCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">JUAYÚA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">NAHUIZALCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">NAHULINGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">SALCOATITÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">SAN ANTONIO DEL MONTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">SAN JULIÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">SANTA CATARINA MASAHUAT</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SANTO DOMINGO GUZMÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SONSONATE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SONZACATE</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='17'">SONSONATE NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">SONSONATE CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">SONSONATE ESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">SONSONATE OESTE</xsl:when>  
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='04'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">AGUA CALIENTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">ARCATAO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">AZACUALPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CITALÁ</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">COMALAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">CONCEPCIÓN QUEZALTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">CHALATENANGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">DULCE NOMBRE DE MARÍA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">EL CARRIZAL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">EL PARAÍSO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">LA LAGUNA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">LA PALMA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">LA REINA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">LAS VUELTAS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">NOMBRE DE JESÚS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">NUEVA CONCEPCIÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">NUEVA TRINIDAD</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">OJOS DE AGUA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">POTONICO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">SAN ANTONIO DE LA CRUZ</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='21'">SAN ANTONIO LOS RANCHOS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">SAN FERNANDO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='23'">SAN FRANCISCO LEMPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='24'">SAN FRANCISCO MORAZÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='25'">SAN IGNACIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='26'">SAN ISIDRO LABRADOR</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='27'">SAN JOSÉ CANCASQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='28'">SAN JOSÉ LAS FLORES</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='29'">SAN LUIS DEL CARMEN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='30'">SAN MIGUEL DE MERCEDES</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='31'">SAN RAFAEL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='32'">SANTA RITA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='33'">TEJUTLA</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='34'">CHALATENANGO NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='35'">CHALATENANGO CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='36'">CHALATENANGO SUR</xsl:when>   
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='05'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">ANTIGUO CUSCATLÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">CIUDAD ARCE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">COLÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">COMASAGUA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">CHILTIUPÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">HUIZÚCAR</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">JAYAQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">JICALAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">LA LIBERTAD</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">NUEVO CUSCATLÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">SANTA TECLA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">QUEZALTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">SACACOYO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SAN JOSÉ VILLANUEVA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SAN JUAN OPICO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SAN MATÍAS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SAN PABLO TACACHICO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">TAMANIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">TALNIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">TEOTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='21'">TEPECOYO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">ZARAGOZA</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='23'">LA LIBERTAD NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='24'">LA LIBERTAD CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='25'">LA LIBERTAD OESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='26'">LA LIBERTAD ESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='27'">LA LIBERTAD COSTA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='28'">LA LIBERTAD SUR</xsl:when>
        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='06'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">AGUILARES</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">APOPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CUSCATANCINGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">EL PAISNAL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">GUAZAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">ILOPANGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">MEJICANOS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">NEJAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">PANCHIMALCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">ROSARIO DE MORA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">SAN MARCOS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">SAN MARTÍN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SAN SALVADOR</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SANTIAGO TEXACUANGOS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SANTO TOMÁS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SOYAPANGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">TONACATEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">CIUDAD DELGADO</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='20'">SAN SALVADOR NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='21'">SAN SALVADOR OESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">SAN SALVADOR ESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='23'">SAN SALVADOR CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='24'">SAN SALVADOR SUR</xsl:when>

      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='07'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">CANDELARIA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">COJUTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">EL CARMEN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">EL ROSARIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">MONTE SAN JUAN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">ORATORIO DE CONCEPCIÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">SAN BARTOLOMÉ PERULAPÍA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">SAN CRISTÓBAL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">SAN JOSÉ GUAYABAL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">SAN PEDRO PERULAPÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">SAN RAFAEL CEDROS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">SAN RAMÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">SANTA CRUZ ANALQUITO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SANTA CRUZ MICHAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SUCHITOTO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">TENANCINGO</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='17'">CUSCATLÁN NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">CUSCATLÁN SUR</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='08'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">CUYULTITÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">EL ROSARIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">JERUSALÉN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">MERCEDES LA CEIBA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">OLOCUILTA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">PARAÍSO DE OSORIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">SAN ANTONIO MASAHUAT</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">SAN EMIGDIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">SAN FRANCISCO CHINAMECA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">SAN JUAN NONUALCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">SAN JUAN TALPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">SAN JUAN TEPEZONTES</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">SAN LUIS TALPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SAN MIGUEL TEPEZONTES</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SAN PEDRO MASAHUAT</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SAN PEDRO NONUALCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SAN RAFAEL OBRAJUELO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">SANTA MARÍA OSTUMA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">SANTIAGO NONUALCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">TAPALHUACA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='21'">ZACATECOLUCA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">SAN LUIS LA HERRADURA</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='23'">LA PAZ OESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='24'">LA PAZ CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='25'">LA PAZ ESTE</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='09'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">CINQUERA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">GUACOTECTI</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">ILOBASCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">JUTIAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">SAN ISIDRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">SENSUNTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">TEJUTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">VICTORIA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">DOLORES</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='10'">CABAÑAS OESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">CABAÑAS ESTE</xsl:when>   
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='10'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">APASTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">GUADALUPE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">SAN CAYETANO ISTEPEQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">SANTA CLARA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">SANTO DOMINGO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">SAN ESTEBAN CATARINA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">SAN ILDEFONSO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">SAN LORENZO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">SAN SEBASTIÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">SAN VICENTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">TECOLUCA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">TEPETITÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">VERAPAZ</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='14'">SAN VICENTE NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SAN VICENTE SUR</xsl:when>
        
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='11'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">ALEGRÍA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">BERLÍN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">CALIFORNIA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CONCEPCIÓN BATRES</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">EL TRIUNFO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">EREGUAYQUÍN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">ESTANZUELAS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">JIQUILISCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">JUCUAPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">JUCARÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">MERCEDES UMAÑA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">NUEVA GRANADA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">OZATLÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">PUERTO EL TRIUNFO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SAN AGUSTÍN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SAN BUENAVENTURA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SAN DIONISIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">SANTA ELENA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">SAN FRANCISCO JAVIER</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">SANTA MARÍA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='21'">SANTIAGO DE MARÍA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">TECAPÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='23'">USULUTÁN</xsl:when>

        <xsl:when test="//Buyer/AddressInfo/District='24'">USULUTÁN NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='25'">USULUTÁN ESTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='26'">USULUTÁN OESTE</xsl:when>  
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='12'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">CAROLINA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">CIUDAD BARRIOS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">COMACARÁN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CHAPELTIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">CHINAMECA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">CHIRILAGUA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">EL TRÁNSITO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">LOLOTIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">MONCAGUA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">NUEVA GUADALUPE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">NUEVO EDÉN DE SAN JUAN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">QUELEPA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">SAN ANTONIO DEL MOSCO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SAN GERARDO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SAN JORGE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SAN LUIS DE LA REINA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SAN MIGUEL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">SAN RAFAEL ORIENTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">SESORI</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">ULUAZAPA</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='21'">SAN MIGUEL NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">SAN MIGUEL CENTRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='23'">SAN MIGUEL OESTE</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='13'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">ARAMBALA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">CACAOPERA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">CORINTO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CHILANGA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">DELICIAS DE CONCEPCIÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">EL DIVISADERO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">EL ROSARIO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">GUALOCOCTI</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">GUATAJIAGUA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">JOATECA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">JOCOAITIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">JOCORO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">LOLOTIQUILLO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">MEANGUERA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">OSICALA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">PERQUÍN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">SAN CARLOS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">SAN FERNANDO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='19'">SAN FRANCISCO GOTERA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">SAN ISIDRO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='21'">SAN SIMÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='22'">SENSEMBRA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='23'">SOCIEDAD</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='24'">TOROLA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='25'">YAMABAL</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='26'">YOLOAIQUÍN</xsl:when>

        <xsl:when test="//Buyer/AddressInfo/District='27'">MORAZÁN NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='28'">MORAZAN SUR</xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="//Buyer/AddressInfo/State='14'">
      <xsl:choose>
        <xsl:when test="//Buyer/AddressInfo/District='01'">ANAMORÓS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='02'">BOLÍVAR</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='03'">CONCEPCIÓN DE ORIENTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='04'">CONCHAGUA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='05'">EL CARMEN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='06'">EL SAUCE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='07'">INTIPUCÁ</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='08'">LA UNIÓN</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='09'">LISLIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='10'">MEANGUERA DEL GOLFO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='11'">NUEVA ESPARTA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='12'">PASAQUINA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='13'">OLORÓS</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='14'">SAN ALEJO</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='15'">SAN JOSÉ</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='16'">SANTA ROSA DE LIMA</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='17'">YAYANTIQUE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='18'">YUCUAIQUÍN</xsl:when>
        
        <xsl:when test="//Buyer/AddressInfo/District='19'">LA UNIÓN NORTE</xsl:when>
        <xsl:when test="//Buyer/AddressInfo/District='20'">LA UNIÓN SUR</xsl:when>
      </xsl:choose>
    </xsl:if>

  </xsl:template>
  
  <!-- INICIAN VARIABLES PARA CALCULOS -->
  <xsl:variable name="TotalCompras">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_COMPRA']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_COMPRA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="TotalNoSujeta">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalExenta">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_EXENTA']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_EXENTA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalGravada">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_GRAVADA']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_GRAVADA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalNoGravado">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalExportaciones">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_EXPORTACIONES']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_EXPORTACIONES']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalSujetoExcluido">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_COMPRA']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_COMPRA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(0.00)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="DescuentoNoSujeta">
    <xsl:choose>
      <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
        <xsl:value-of select="//Discount[Code='NO_SUJETA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="DescuentoExenta">
    <xsl:choose>
      <xsl:when test="//Discount[Code='EXENTA']/Amount">
        <xsl:value-of select="//Discount[Code='EXENTA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="DescuentoGravada">
    <xsl:choose>
      <xsl:when test="//Discount[Code='GRAVADA']/Amount">
        <xsl:value-of select="//Discount[Code='GRAVADA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="Descuento">
    <xsl:choose>
      <xsl:when test="//TotalDiscounts/Discount[Code='DESCUENTO']/Amount">
        <xsl:value-of select="//TotalDiscounts/Discount[Code='DESCUENTO']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(0.00)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalCompra">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_COMPRA']/Amount">
        <xsl:value-of select="//TotalCharge[Code='TOTAL_COMPRA']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="IvaRetenido">
    <xsl:choose>
      <xsl:when test="//Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value">
        <xsl:value-of select="//Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="IvaPercibido">
    <xsl:choose>
      <xsl:when test="//Totals/AdditionalInfo/Info[@Name='IvaPercibido']/@Value">
        <xsl:value-of select="//Totals/AdditionalInfo/Info[@Name='IvaPercibido']/@Value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="IvaTotal">
    <xsl:choose>
      <xsl:when test="//Totals/TotalTaxes/TotalTax[Code='20']/Amount">
        <xsl:value-of select="//Totals/TotalTaxes/TotalTax[Code='20']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="IvaRetenidoDoc7">
    <xsl:choose>
      <xsl:when test="//Totals/TotalTaxes/TotalTax[Code='TOTAL_IVA_RETENIDO']/Amount">
        <xsl:value-of select="//Totals/TotalTaxes/TotalTax[Code='TOTAL_IVA_RETENIDO']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="RetencionRenta">
    <xsl:choose>
      <xsl:when test="//Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value">
        <xsl:value-of select="//Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TotalSujetoRetencion">
    <xsl:choose>
      <xsl:when test="//Totals/TotalTaxes/TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount">
        <xsl:value-of select="//Totals/TotalTaxes/TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0.00"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- TERMINAN VARIABLES PARA CALCULOS -->

  <!-- CALCULOS SUBTOTAL, TRIBUTOS, TOTALES ALTERNOS -->
  <xsl:variable name="SubtotalFAC">
    <xsl:value-of
      select="($TotalNoSujeta + $TotalExenta + $TotalGravada )-($DescuentoNoSujeta + $DescuentoExenta + $DescuentoGravada)"
    />
  </xsl:variable>

  <xsl:variable name="SubtotalCCF">
    <xsl:value-of
      select="($TotalNoSujeta + $TotalExenta + $TotalGravada )-($DescuentoNoSujeta + $DescuentoExenta + $DescuentoGravada)"
    />
  </xsl:variable>

  <xsl:variable name="SubtotalDocs">
    <xsl:value-of
      select="($TotalNoSujeta + $TotalExenta + $TotalGravada + $TotalCompras )-($DescuentoNoSujeta + $DescuentoExenta + $DescuentoGravada +$Descuento)"
    />
  </xsl:variable>
  <!-- FIN DE CALCULOS -->

  <xsl:template name="SubtotalV">
    <xsl:choose>
      <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
        <xsl:value-of
          select="format-number(($TotalNoSujeta + $TotalExenta + $TotalGravada)
          -($DescuentoNoSujeta+$DescuentoExenta+$DescuentoGravada),'#,###,##0.00##')"
        />
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
        <xsl:value-of
          select="format-number($TotalNoSujeta + $TotalExenta + $TotalGravada,'#,###,##0.00##')"/>
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_COMPRA']/Amount">
        <xsl:value-of
          select="format-number($TotalCompra - $Descuento - $IvaRetenido - $RetencionRenta,'#,###,##0.00##')"
        />
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_GRAVADA']/Amount">
        <xsl:value-of
          select="format-number($TotalNoGravado + $TotalGravada - $Descuento,'#,###,##0.00##')"/>
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Template de prueba-->

  <xsl:template name="SumatoriaVentas">
    <xsl:value-of
      select="format-number(($TotalGravada + $TotalExenta + $TotalNoSujeta + $TotalExportaciones + $TotalCompras),'#,###,##0.00##')"
    />
  </xsl:template>
  <xsl:template name="Subtotal">
    <xsl:choose>
      <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
        <xsl:value-of
          select="format-number((//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount + //TotalCharge[Code='TOTAL_EXENTA']/Amount + //TotalCharge[Code='TOTAL_GRAVADA']/Amount)
          -(//Discount[Code='NO_SUJETA']/Amount+//Discount[Code='EXENTA']/Amount+//Discount[Code='GRAVADA']/Amount),'#,###,##0.00##')"
        />
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
        <xsl:value-of
          select="format-number(//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount + //TotalCharge[Code='TOTAL_EXENTA']/Amount + //TotalCharge[Code='TOTAL_GRAVADA']/Amount,'#,###,##0.00##')"
        />
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_COMPRA']/Amount">
        <xsl:value-of
          select="format-number(//TotalCharge[Code='TOTAL_COMPRA']/Amount - //TotalDiscounts/Discount[Code='DESCUENTO']/Amount - //Totals/AdditionalInfo/Info[@Name='IvaRetenido']/@Value - //Totals/AdditionalInfo/Info[@Name='RetencionRenta']/@Value,'#,###,##0.00##')"
        />
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_GRAVADA']/Amount">
        <xsl:value-of
          select="format-number(//TotalCharge[Code='TOTAL_NO_GRAVADO']/Amount + //TotalCharge[Code='TOTAL_GRAVADA']/Amount - //TotalDiscounts/Discount[Code='DESCUENTO']/Amount,'#,###,##0.00##')"
        />
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="Subtotal4">
    <xsl:variable name="sumatoria">
      <xsl:value-of
        select="$TotalGravada + $TotalExenta + $TotalNoSujeta + $TotalSujetoExcluido + $TotalExportaciones"
      />
    </xsl:variable>
    <xsl:value-of
      select="$sumatoria - $Descuento - $DescuentoExenta - $DescuentoGravada - $DescuentoNoSujeta + $IvaTotal"
    />
  </xsl:variable>

  <xsl:variable name="MontoTotalOperacion">
    <xsl:value-of select="$Subtotal4 + $IvaPercibido - $IvaRetenido - $RetencionRenta"/>
  </xsl:variable>

  <xsl:template name="TotalPagar">
    <xsl:value-of select="format-number($MontoTotalOperacion + $TotalNoSujeta,'#,###,##0.00##')"/>
  </xsl:template>

  <xsl:template name="SumatoriaVentas2">
    <xsl:value-of
      select="format-number(//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount + //TotalCharge[Code='TOTAL_EXENTA']/Amount + //TotalCharge[Code='TOTAL_GRAVADA']/Amount + /Root/Totals/TotalTaxes/TotalTax/Amount,'#,###,##0.00#######')"
    />
  </xsl:template>
  <xsl:template name="SumatoriaVentas3">
    <xsl:value-of
      select="format-number($TotalNoSujeta + $TotalExenta + $TotalGravada,'#,###,##0.00#######')"/>
  </xsl:template>
  <xsl:template name="SumatoriaVentas4">
    <xsl:value-of
      select="format-number(//GrandTotal/InvoiceTotal - $IvaRetenido - $IvaPercibido,'#,###,##0.00#######')"
    />
  </xsl:template>
  <xsl:template name="SumatoriaVentasFEX">
    <xsl:value-of
      select="format-number($TotalGravada + $TotalNoGravado - $IvaRetenido - $RetencionRenta,'#,###,##0.00#######')"
    />
  </xsl:template>

  <xsl:template name="Subtotal2">
    <xsl:choose>
      <xsl:when test="//Discount[Code='NO_SUJETA']/Amount">
        <xsl:value-of
          select="format-number((//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount + //TotalCharge[Code='TOTAL_EXENTA']/Amount + //TotalCharge[Code='TOTAL_GRAVADA']/Amount + /Root/Totals/TotalTaxes/TotalTax/Amount)
          -(//Discount[Code='NO_SUJETA']/Amount+//Discount[Code='EXENTA']/Amount+//Discount[Code='GRAVADA']/Amount),'#,###,##0.00#######')"
        />
      </xsl:when>
      <xsl:when test="//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount">
        <xsl:value-of
          select="format-number(//TotalCharge[Code='TOTAL_NO_SUJETA']/Amount + //TotalCharge[Code='TOTAL_EXENTA']/Amount + //TotalCharge[Code='TOTAL_GRAVADA']/Amount + /Root/Totals/TotalTaxes/TotalTax/Amount,'#,###,##0.00#######')"
        />
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Subtotal3">
    <xsl:variable name="IVA">
      <xsl:call-template name="IVADOC7"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="//TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount">
        <xsl:value-of select="$TotalSujetoRetencion + $IVA"/>
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="SubtotalFEX">
    <xsl:choose>
      <xsl:when test="//TotalCharge[Code='TOTAL_GRAVADA']/Amount">
        <xsl:value-of select="format-number($TotalGravada + $TotalNoGravado, '#,###,##0.00#######')"
        />
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="IVADOC7">
    <xsl:choose>
      <xsl:when test="//TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount">
        <xsl:value-of select="$TotalSujetoRetencion * 0.13"/>
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="TOTALDOC7">
    <xsl:variable name="SUBTOTAL">
      <xsl:call-template name="Subtotal3"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="//TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount">
        <xsl:value-of select="format-number($SUBTOTAL - $IvaRetenidoDoc7,'#,###,##0.00#######')"/>
      </xsl:when>
      <xsl:otherwise> 0.00 </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="TotalDoc7">
    <xsl:value-of
      select="format-number(//TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount * 0.13 + //TotalTax[Code='TOTAL_SUJETO_RETENCION']/Amount - //TotalTax[Code='TOTAL_IVA_RETENIDO']/Amount ,'#,###,##0.00#######')"
    />
  </xsl:variable>

  <xsl:template name="FechaHora">
    <xsl:param name="Fecha"/>
    <xsl:value-of select="substring($Fecha,9,2)"/>
    <xsl:value-of select="'-'"/>
    <xsl:value-of select="substring($Fecha,6,2)"/>
    <xsl:value-of select="'-'"/>
    <xsl:value-of select="substring($Fecha,1,4)"/>
    <xsl:value-of select="' '"/>
    <xsl:value-of select="substring($Fecha,12,5)"/>
  </xsl:template>

  <xsl:template name="TasaITBMS">
    <xsl:param name="CodTasa"/>

    <xsl:choose>
      <xsl:when test="$CodTasa = '00'">
        <xsl:value-of select="'0%'"/>
      </xsl:when>
      <xsl:when test="$CodTasa = '01'">
        <xsl:value-of select="'7%'"/>
      </xsl:when>
      <xsl:when test="$CodTasa = '02'">
        <xsl:value-of select="'10%'"/>
      </xsl:when>
      <xsl:when test="$CodTasa = '03'">
        <xsl:value-of select="'15%'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$CodTasa"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="TasasImpuestosTranslate">
    <xsl:param name="Codigo"/>
    <xsl:choose>
      <xsl:when test="$Codigo = '01'">
        <xsl:value-of select="'SUME 911'"/>
      </xsl:when>
      <xsl:when test="$Codigo = '02'">
        <xsl:value-of select="'Tasa Portabilidad Numérica'"/>
      </xsl:when>
      <xsl:when test="$Codigo = '03'">
        <xsl:value-of select="'Impuesto sobre seguro'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$Codigo"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="NitToTaxID">
    <xsl:param name="Nit"/>
    <xsl:choose>
      <xsl:when test="string-length($Nit)&lt; 12">
        <xsl:call-template name="NitToTaxID">
          <xsl:with-param name="Nit" select="concat('0',$Nit)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$Nit"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:variable name="ClientLogosBanner">
    <!--<xsl:value-of select="'http://10.0.1.44/mx.com.fact.res/logo/'"/>-->
    <xsl:value-of select="'https://digifact-logo.s3.amazonaws.com/SV/logo/'"/>
    <xsl:value-of select="$RFCAmpersandToUnderscore"/>
    <xsl:value-of select="'\'"/>
  </xsl:variable>

  <xsl:variable name="ClientLogoBannerTop">
    <!--<xsl:value-of select="concat($RFCAmpersandToUnderscore,'bannertop.jpg?opt=',$UNI)"/>-->
    <xsl:value-of select="'bannertop.jpg'"/>
  </xsl:variable>

  <xsl:variable name="ClientLogoBannerFooter">
    <!--<xsl:value-of select="concat($RFCAmpersandToUnderscore,'bannerfooter.jpg?opt=',$UNI)"/>-->
    <xsl:value-of select="'bannerfooter.jpg'"/>
  </xsl:variable>

  <xsl:variable name="LogoBannerURLTop">
    <xsl:value-of select="concat($ClientLogosBanner,$ClientLogoBannerTop)"/>
  </xsl:variable>

  <xsl:variable name="LogoBannerURLFooter">
    <xsl:value-of select="concat($ClientLogosBanner,$ClientLogoBannerFooter)"/>
  </xsl:variable>

  <xsl:variable name="ClientLogos">
    <xsl:if test="//Header/AdditionalIssueType = '00'">
      <xsl:value-of select="'https://digifact-logo.s3.amazonaws.com/SV/logo/TEST/'"/>
    </xsl:if>
    <xsl:if test="//Header/AdditionalIssueType = '01'">
      <xsl:value-of select="'https://digifact-logo.s3.amazonaws.com/SV/logo/'"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="LogoURL">
    <xsl:value-of select="concat($ClientLogos,$ClientLogo)"/>
  </xsl:variable>
  
  <xsl:variable name="LogoURLEST">
    <xsl:value-of select="concat($ClientLogos,$ClientLogoEst)"/>
  </xsl:variable>
  
  <xsl:variable name="LogoURL2">
    <xsl:value-of select="concat('http://10.2.10.95/LogosSV/',$ClientLogo)"/>
  </xsl:variable>
  <xsl:variable name="LogoURL3">
    <xsl:value-of select="concat('http://localhost:8012/logos/',$ClientLogo)"/>
  </xsl:variable>
  <xsl:variable name="WaterMarkURL">
    <xsl:value-of select="concat($ClientLogos,$ClienteMarca)"/>
  </xsl:variable>
  <xsl:variable name="ClientLogo">
    <xsl:value-of select="concat($RFCAmpersandToUnderscore,'.jpg')"/>
  </xsl:variable>
  <xsl:variable name="ClientLogoEst">
    <xsl:variable name="Est">
      <xsl:value-of select="//Seller/AdditionlInfo/Info[@Name='CodEstablecimientoMH']/@Value"/>
    </xsl:variable>
    <xsl:value-of select="concat($RFCAmpersandToUnderscore,'_',$Est,'.jpg')"/>
  </xsl:variable>
  
  
  <xsl:variable name="ClienteMarca">
    <!-- <xsl:value-of select="concat($RFCAmpersandToUnderscore,'.jpg?opt=',$UNI)"/>-->
    <xsl:value-of select="concat($RFCAmpersandToUnderscore,'_watermark.jpg')"/>
  </xsl:variable>


  <xsl:variable name="DocumentResto">
    <xsl:value-of select="substring-after($uniqueCreatorIdentification,$caracter)"/>
  </xsl:variable>

  <xsl:variable name="UNI">
    <xsl:value-of select="translate($uniqueCreatorIdentification,'|','-')"/>
  </xsl:variable>
  <!-- TERMINO VARIABLES                -->

  <!--  TEMPLATES GLOBALES      -->
  <xsl:template name="DocTitle">
    <xsl:text>DTE </xsl:text>
    <xsl:value-of select="/DTE/Documento/b:invoice/invoiceType"/>

    <xsl:text> </xsl:text>
    <xsl:value-of select="/DTE/Documento/b:invoice/seller/companyRegistrationNumber"/>
    <xsl:text> </xsl:text>

    <xsl:if test="/DTE/Documento/CAE/DCAE/Serie">
      <xsl:value-of select="/DTE/Documento/CAE/DCAE/Serie"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="/DTE/Documento/CAE/DCAE/NumeroDocumento"/>
  </xsl:template>

  <xsl:template name="repeatable05052015">
    <xsl:param name="index"/>
    <xsl:param name="total"/>

    <xsl:value-of select="concat('','0')"/>

    <xsl:if test="not($index = $total)">
      <xsl:call-template name="repeatable05052015">
        <xsl:with-param name="index" select="$index + 1"/>
        <xsl:with-param name="total" select="$total"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="StaxIDFixed05052015">
    <xsl:param name="CompanyRegistrationNameToComplete"/>
    <xsl:variable name="CantCaracteres">
      <xsl:value-of select="string-length($CompanyRegistrationNameToComplete)"/>
    </xsl:variable>
    <xsl:if test="string-length(artist) &lt; number(12)">
      <xsl:call-template name="repeatable05052015">
        <xsl:with-param name="index" select="'1'"/>
        <xsl:with-param name="total" select="number(12)-number($CantCaracteres)"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="$CompanyRegistrationNameToComplete"/>

  </xsl:template>

  <xsl:template name="DireccionDTE">
    <!-- <xsl:value-of select="./p:Direccion"/>-->
    <!--
    <xsl:if test="./p:CodigoPostal">
      <xsl:value-of select="', C.P. '"/>
      <xsl:value-of select="./p:CodigoPostal"/>
    </xsl:if>-->
  </xsl:template>

  <xsl:template name="TranslateTipo">
    <xsl:param name="Tipo"/>

    <xsl:choose>
      <xsl:when test="$Tipo = 'B'">
        <xsl:value-of select="'BIEN'"/>
      </xsl:when>
      <xsl:when test="$Tipo = 'S'">
        <xsl:value-of select="'SERVICIO'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$Tipo"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="TranslateDocumentNumero">

    <xsl:variable name="DocumentTipo">
      <xsl:value-of select="substring-before($DocumentID,'_')"/>
    </xsl:variable>

    <xsl:variable name="DocumentResIden">
      <xsl:value-of select="substring-after($uniqueCreatorIdentificationPIPE,'|')"/>
    </xsl:variable>

    <xsl:variable name="DocumentResIdenRes">
      <xsl:value-of select="substring-after($DocumentResIden,'|')"/>
    </xsl:variable>

    <xsl:variable name="DocumentNumero">
      <xsl:value-of select="substring-after($DocumentResIdenRes,'|')"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$DocumentTipo='CFACE1'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNDE4'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE5'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE6'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE8'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE30'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE32'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE37'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE38'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNDE39'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE40'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE53'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNDE55'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE56'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE57'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED59'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE60'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE61'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE62'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE63'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='NCE64'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='NDE65'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE66'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE67'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE68'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE69'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED70'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='NCE71'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE72'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='RED73'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE74'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE75'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE76'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE77'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE78'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE79'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE80'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE81'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE82'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE83'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED84'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED85'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED86'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE87'">
        <xsl:value-of select="$DocumentNumero"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/DTE/Documento/CAE/DCAE/NumeroDocumento/text()"/>

      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  <xsl:template name="RegimenISR">
    <xsl:param name="regimen"/>
    <xsl:choose>
      <xsl:when test="$regimen='RET_DEFINITIVA'">
        <xsl:value-of select="'SUJETO A RETENCION DEFINITIVA'"/>
      </xsl:when>
      <xsl:when test="$regimen='PAGO_CAJAS'">
        <xsl:value-of select="'PAGO DIRECTO EN CAJAS'"/>
      </xsl:when>
      <xsl:when test="$regimen='PAGO_TRIMESTRAL'">
        <xsl:value-of select="'SUJETO A PAGOS TRIMESTRALES'"/>
      </xsl:when>
      <xsl:when test="$regimen='NO_APLICA_ISR'">
        <xsl:value-of select="'NO GENERA DERECHO A CREDITO FISCAL'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$regimen"/>

      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="TransalteRegimen">

    <xsl:param name="CodEscenario"/>
    <xsl:choose>
      <xsl:when test="$CodEscenario = '1'">
        <xsl:value-of select="'SUJETO A PAGOS TRIMESTRALES'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '2'">
        <xsl:value-of select="'SUJETO A RETENCION DEFINITIVA'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '3'">
        <xsl:value-of select="'PAGO DIRECTO EN CAJAS'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('Escenario: ',$CodEscenario)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="TransalteExentoIVA">

    <xsl:param name="CodEscenario"/>
    <xsl:choose>
      <xsl:when test="$CodEscenario = '1'">
        <xsl:value-of select="'Exportaciones'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '2'">
        <xsl:value-of select="'Servicios'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '3'">
        <xsl:value-of select="'Ventas de Cooperativas'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '4'">
        <xsl:value-of select="'Aportes y donaciones'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '5'">
        <xsl:value-of select="'Pagos por el derecho de ser miembro y las cuotas periodicas s'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '6'">
        <xsl:value-of select="'Servicios exentos'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '7'">
        <xsl:value-of select="'Venta de activos de Bancos o Sociedades Financieras'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '8'">
        <xsl:value-of select="'Servicios exentos centros educativos privados'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '9'">
        <xsl:value-of select="'Medicamentos'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '10'">
        <xsl:value-of select="'Vehiculos'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '11'">
        <xsl:value-of select="'Ventas a maquilas'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '12'">
        <xsl:value-of select="'Ventas a zonas francas'"/>
      </xsl:when>
      <xsl:when test="$CodEscenario = '18'">
        <xsl:value-of select="'Ventas a exentos con resolución específica.'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('Escenario: ',$CodEscenario)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="INCOTERMS">
    <xsl:param name="TERM"/>
    <xsl:choose>
      <xsl:when test="$TERM='EXW'">
        <xsl:value-of select="'En fabrica (EXW)'"/>
      </xsl:when>
      <xsl:when test="$TERM='FCA'">
        <xsl:value-of select="'Libre Transportista (FCA)'"/>
      </xsl:when>
      <xsl:when test="$TERM='FAS'">
        <xsl:value-of select="'Libre al costado del buque (FAS)'"/>
      </xsl:when>
      <xsl:when test="$TERM='FOB'">
        <xsl:value-of select="'Libre a bordo (FOB)'"/>
      </xsl:when>
      <xsl:when test="$TERM='CFR'">
        <xsl:value-of select="'Costo y Flete (CFR)'"/>
      </xsl:when>
      <xsl:when test="$TERM='CIF'">
        <xsl:value-of select="'Costo, seguro y flete (CIF)'"/>
      </xsl:when>
      <xsl:when test="$TERM='CPT'">
        <xsl:value-of select="'Flete pagado hasta (CPT)'"/>
      </xsl:when>
      <xsl:when test="$TERM='CIP'">
        <xsl:value-of select="'Flete y seguro pagado hasta (CIP)'"/>
      </xsl:when>
      <xsl:when test="$TERM='DDP'">
        <xsl:value-of select="'Entregado en destino con derechos pagados (DDP)'"/>
      </xsl:when>
      <xsl:when test="$TERM='DAP'">
        <xsl:value-of select="'Entregada en lugar (DAP)'"/>
      </xsl:when>
      <xsl:when test="$TERM='DAT'">
        <xsl:value-of select="'Entregada en terminal (DAT)'"/>
      </xsl:when>
      <xsl:when test="$TERM='ZZZ'">
        <xsl:value-of select="'Otros (ZZZ)'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$TERM"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="TranslateDocumentSerie">

    <xsl:variable name="DocumentTipo">
      <xsl:value-of select="substring-before($DocumentID,'_')"/>
    </xsl:variable>

    <xsl:variable name="DocumentResIden">
      <xsl:value-of select="substring-after($DocumentID,'_')"/>
    </xsl:variable>

    <xsl:variable name="DocumentSerie">
      <xsl:value-of select="substring-before($DocumentResIden,'_')"/>
    </xsl:variable>

    <xsl:variable name="DocumentResIdenRes">
      <xsl:value-of select="substring-after($DocumentResIden,'_')"/>
    </xsl:variable>



    <xsl:variable name="DocumentDispositivo">
      <xsl:value-of select="substring-before($DocumentResIdenRes,'_')"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$DocumentTipo='CFACE1'">
        <xsl:value-of select="'CFACE-1'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNDE4'">
        <xsl:value-of select="'CNDE-4'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE5'">
        <xsl:value-of select="'CNCE-5'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE6'">
        <xsl:value-of select="'CFACE-6'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE8'">
        <xsl:value-of select="'CFACE-8'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE30'">
        <xsl:value-of select="'CFACE-30'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE32'">
        <xsl:value-of select="'CFACE-32'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE37'">
        <xsl:value-of select="'CFACE-37'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE38'">
        <xsl:value-of select="'CFACE-38'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNDE39'">
        <xsl:value-of select="'CNDE-39'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE40'">
        <xsl:value-of select="'CNCE-40'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE53'">
        <xsl:value-of select="'CFACE-53'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNDE55'">
        <xsl:value-of select="'CNDE-55'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE56'">
        <xsl:value-of select="'CNCE-56'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE57'">
        <xsl:value-of select="'CFACE-57'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED59'">
        <xsl:value-of select="'CRED-59'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE60'">
        <xsl:value-of select="'CFACE-60'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CNCE61'">
        <xsl:value-of select="'CNCE-61'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE62'">
        <xsl:value-of select="'CFACE-62'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE63'">
        <xsl:value-of select="'FACE-63'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='NCE64'">
        <xsl:value-of select="'NCE-64'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='NDE65'">
        <xsl:value-of select="'NDE-65'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE66'">
        <xsl:value-of select="'FACE-66'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE67'">
        <xsl:value-of select="'FACE-67'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE68'">
        <xsl:value-of select="'CFACE-68'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE69'">
        <xsl:value-of select="'CFACE-69'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED70'">
        <xsl:value-of select="'CRED-70'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='NCE71'">
        <xsl:value-of select="'NCE-71'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE72'">
        <xsl:value-of select="'FACE-72'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='RED73'">
        <xsl:value-of select="'RED-73'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE74'">
        <xsl:value-of select="'FACE-74'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE75'">
        <xsl:value-of select="'CFACE-75'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE76'">
        <xsl:value-of select="'CFACE-76'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE77'">
        <xsl:value-of select="'CFACE-77'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE78'">
        <xsl:value-of select="'CFACE-78'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE79'">
        <xsl:value-of select="'CFACE-79'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE80'">
        <xsl:value-of select="'CFACE-80'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CFACE81'">
        <xsl:value-of select="'CFACE-81'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE82'">
        <xsl:value-of select="'FACE-82'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE83'">
        <xsl:value-of select="'FACE-83'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED84'">
        <xsl:value-of select="'CRED-84'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED85'">
        <xsl:value-of select="'CRED-85'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='CRED86'">
        <xsl:value-of select="'CRED-86'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:when test="$DocumentTipo='FACE87'">
        <xsl:value-of select="'FACE-87'"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentDispositivo"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentSerie"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/DTE/Documento/CAE/DCAE/Serie/text()"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>




  <xsl:template name="TranslateDocumentTypeB">
    <xsl:param name="Document"/>
    <xsl:choose>
      <xsl:when test="$Document='FACT'">
        <xsl:value-of select="'FACTURA'"/>
      </xsl:when>
      <xsl:when test="$Document='FCAM'">
        <xsl:value-of select="'FACTURA CAMBIARIA'"/>
      </xsl:when>
      <xsl:when test="$Document='FPEQ'">
        <xsl:value-of select="'FACTURA PEQUE�O CONTRIBUYENTE'"/>
      </xsl:when>
      <xsl:when test="$Document='FCAP'">
        <xsl:value-of select="'FACTURA CAMBIARIA PEQUE�O CONTRIBUYENTE'"/>
      </xsl:when>
      <xsl:when test="$Document='FESP'">
        <xsl:value-of select="'FACTURA ESPECIAL'"/>
      </xsl:when>
      <xsl:when test="$Document='NABN'">
        <xsl:value-of select="'NOTA DE ABONO'"/>
      </xsl:when>
      <xsl:when test="$Document='RDON'">
        <xsl:value-of select="'RECIBO POR DONACION'"/>
      </xsl:when>
      <xsl:when test="$Document='RECI'">
        <xsl:value-of select="'RECIBO'"/>
      </xsl:when>
      <xsl:when test="$Document='NDEB'">
        <xsl:value-of select="'NOTA DE DEBITO'"/>
      </xsl:when>
      <xsl:when test="$Document='NCRE'">
        <xsl:value-of select="'NOTA DE CREDITO'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'DTE:'"/>
        <xsl:value-of select="$Document"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="ShowTipoCambio">
    <xsl:variable name="tipomon" select="/DTE/Documento/b:invoice/invoiceCurrency/currencyISOCode"/>
    <xsl:variable name="exchangerate"
      select="/DTE/Documento/b:invoice/taxCurrencyInformation/exchangeRate"/>
    <xsl:choose>
      <xsl:when test="$tipomon ='GTQ'">
        <b> </b>
      </xsl:when>
      <xsl:otherwise>
        <b> Tipo Cambio : <xsl:value-of select="$exchangerate"/>
        </b>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="UCI">
    <!-- <xsl:value-of select="substring-before(substring-after($numero1,$pipe1),$pipe1)"/>-->
    <xsl:value-of select="substring-before($uniqueCreatorIdentification,$caracter)"/>
  </xsl:template>
  <!--  TERMINA TEMPLATES GLOBALES      -->

  <!-- AUX templates -->
  <xsl:variable name="SplitLengthMonospaceCTEAM" select="70"/>

  <xsl:variable name="SplitLengthMonospaceCNOT" select="120"/>

  <xsl:variable name="SplitLengthMonospace" select="56"/>

  <xsl:variable name="SplitLengthMonospaceTICKET" select="47"/>
  <xsl:variable name="SplitLengthMonospaceFIRMA_CARTA" select="100"/>

  <xsl:template name="hr">
    <tr>
      <td colspan="4">
        <hr/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="SplitString">
    <xsl:param name="startIndex"/>
    <xsl:param name="splitLength"/>
    <xsl:param name="totalLength"/>
    <xsl:if test="$startIndex &lt;= $totalLength">
      <xsl:value-of select="substring(.,$startIndex,$splitLength)"/>
      <!--<xsl:value-of select="translate(substring(.,$startIndex,$splitLength),' ','*')"/>-->
      <br/>
      <xsl:call-template name="SplitString">
        <xsl:with-param name="startIndex">
          <xsl:value-of select="$startIndex + $splitLength"/>
        </xsl:with-param>
        <xsl:with-param name="splitLength">
          <xsl:value-of select="$splitLength"/>
        </xsl:with-param>
        <xsl:with-param name="totalLength">
          <xsl:value-of select="$totalLength"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="string-replace-all">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="by"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$by"/>
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="by" select="$by"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>




  <xsl:template name="GETNITWithoutZEROS">
    <xsl:param name="text" select="/DTE/Documento/b:invoice/seller/companyRegistrationNumber"/>
    <xsl:if test="$text != ''">
      <xsl:variable name="letter" select="substring($text, 1, 1)"/>
      <xsl:if test="$letter != '0'">
        <xsl:variable name="PrimerNumeroDifCero">
          <xsl:value-of select="substring-after($text, $letter)"/>
        </xsl:variable>
        <b>
          <xsl:value-of select="$text"/>
        </b>
      </xsl:if>

      <xsl:if test="$letter = '0'">
        <xsl:call-template name="GETNITWithoutZEROS">
          <xsl:with-param name="text" select="substring-after($text, $letter)"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>



  <xsl:template name="TranslateDocumentIdentificador">

    <xsl:choose>
      <xsl:when test="$DocumentType2='FACE66'">
        <xsl:value-of select="'FACE-66-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='FACE63'">
        <xsl:value-of select="'FACE-63-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='NCE64'">
        <xsl:value-of select="'NCE-64-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='NDE65'">
        <xsl:value-of select="'NDE-65-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='FACE67'">
        <xsl:value-of select="'FACE-67-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='NCE71'">
        <xsl:value-of select="'NCE-71-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='RED73'">
        <xsl:value-of select="'RED-73-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='FACE74'">
        <xsl:value-of select="'FACE-74-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='FACE72'">
        <xsl:value-of select="'FACE-72-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CRED59'">
        <xsl:value-of select="'CRED-59-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE60'">
        <xsl:value-of select="'CFACE-60-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE68'">
        <xsl:value-of select="'CFACE-68-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE69'">
        <xsl:value-of select="'CFACE-69-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CRED70'">
        <xsl:value-of select="'CRED-70-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE1'">
        <xsl:value-of select="'CFACE-1-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNDE4'">
        <xsl:value-of select="'CNDE-4-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNCE5'">
        <xsl:value-of select="'CNCE-5-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE6'">
        <xsl:value-of select="'CFACE-6-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE8'">
        <xsl:value-of select="'CFACE-8-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE30'">
        <xsl:value-of select="'CFACE-30-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE32'">
        <xsl:value-of select="'CFACE-32-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE37'">
        <xsl:value-of select="'CFACE-37-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE38'">
        <xsl:value-of select="'CFACE-38-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNDE39'">
        <xsl:value-of select="'CNDE-39-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNCE40'">
        <xsl:value-of select="'CNCE-40-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE53'">
        <xsl:value-of select="'CFACE-53-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNDE55'">
        <xsl:value-of select="'CNDE-55-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNCE56'">
        <xsl:value-of select="'CNCE-56-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE57'">
        <xsl:value-of select="'CFACE-57- '"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CNCE61'">
        <xsl:value-of select="'CFACE-61-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:when test="$DocumentType2='CFACE62'">
        <xsl:value-of select="'CFACE-62-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:when>
      <xsl:otherwise>
        <!--<xsl:value-of select="'DTE: '"/>-->
        <xsl:value-of select="$DocumentType2"/>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$DocumentResto"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Inicia Variable para sacar el IVA en Facturas que no contienen el Nodo de IVA-->
  <xsl:variable name="IvaTributo">
    <xsl:value-of select="format-number(sum(//Info[@Name = 'IvaItem']/@Value),'#,##0.00')"/>
  </xsl:variable>
  <!-- Finaliza Variable para sacar el IVA en Facturas que no contienen el Nodo de IVA-->

  <xsl:template name="SplitStringCTEAM">
    <xsl:param name="startIndexTEAM"/>
    <xsl:param name="splitLengthTEAM"/>
    <xsl:param name="totalLengthTEAM"/>
    <xsl:if test="$startIndexTEAM &lt;= $totalLengthTEAM">
      <xsl:value-of select="substring(.,$startIndexTEAM,$splitLengthTEAM)"/>
      <!--<xsl:value-of select="translate(substring(.,$startIndex,$splitLength),' ','*')"/>-->
      <br/>
      <xsl:call-template name="SplitStringCTEAM">
        <xsl:with-param name="startIndexTEAM">
          <xsl:value-of select="$startIndexTEAM + $splitLengthTEAM"/>
        </xsl:with-param>
        <xsl:with-param name="splitLengthTEAM">
          <xsl:value-of select="$splitLengthTEAM"/>
        </xsl:with-param>
        <xsl:with-param name="totalLengthTEAM">
          <xsl:value-of select="$totalLengthTEAM"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="SplitStringCNOT">
    <xsl:param name="startIndexNOT"/>
    <xsl:param name="splitLengthNOT"/>
    <xsl:param name="totalLengthNOT"/>
    <xsl:if test="$startIndexNOT &lt;= $totalLengthNOT">
      <xsl:value-of select="substring(.,$startIndexNOT,$splitLengthNOT)"/>
      <!--<xsl:value-of select="translate(substring(.,$startIndex,$splitLength),' ','*')"/>-->
      <br/>
      <xsl:call-template name="SplitStringCNOT">
        <xsl:with-param name="startIndexNOT">
          <xsl:value-of select="$startIndexNOT + $splitLengthNOT"/>
        </xsl:with-param>
        <xsl:with-param name="splitLengthNOT">
          <xsl:value-of select="$splitLengthNOT"/>
        </xsl:with-param>
        <xsl:with-param name="totalLengthNOT">
          <xsl:value-of select="$totalLengthNOT"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- Termina AUX templates -->
</xsl:stylesheet>
