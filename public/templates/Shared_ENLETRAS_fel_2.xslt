<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xml:space="default" xmlns:cfd2="http://www.sat.gob.mx/cfd/2"
    xmlns:cfd3="http://www.sat.gob.mx/cfd/3" xmlns:dtegt="http://se.sat.gob.gt/aplicaciones/DTE"
    xmlns:fx="http://www.fact.com.mx/schema/fx" xmlns:gt="http://www.fact.com.mx/schema/gt"
    xmlns:gs1="urn:ean.ucc:pay:2" xmlns:p="http://www.sat.gob.gt/dte/fel/0.2.0"
    xmlns:ucc="urn:ean.ucc:pay:2" xmlns:a="http://se.sat.gob.gt/aplicaciones/DTE"
    xmlns:b="urn:ean.ucc:pay:2" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xsl cfd2 cfd3 dtegt ucc fx gt a b ">
    <xsl:output encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:template name="EnLetras">
        <xsl:param name="amount"/>
        <xsl:choose>
            <!-- AMOUNT CON DECIMALES -->
            <xsl:when test="contains($amount, '.')">
                <!-- VARIABLES -->
                <xsl:variable name="entero" select="substring-before($amount, '.')"/>
                
                <xsl:variable name="decimal">
                    <xsl:value-of select="substring-after($amount,'.')"/>
                </xsl:variable>

                <!-- Solo dos digitos para el decimal -->
                <xsl:variable name="DecimalDosDigitos">
                    <xsl:choose>
                        <xsl:when test="string-length($decimal) &gt;= 2">
                            <xsl:value-of select="substring($decimal, 1, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($decimal, '00')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- INICIO ESCENARIOS -->
                <xsl:choose>
                    <xsl:when test="$entero = 0">
                        <xsl:value-of select="'CERO'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 1">
                        <xsl:value-of select="'UN'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 2">
                        <xsl:value-of select="'DOS'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 3">
                        <xsl:value-of select="'TRES'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 4">
                        <xsl:value-of select="'CUATRO'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 5">
                        <xsl:value-of select="'CINCO'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 6">
                        <xsl:value-of select="'SEIS'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 7">
                        <xsl:value-of select="'SIETE'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 8">
                        <xsl:value-of select="'OCHO'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 9">
                        <xsl:value-of select="'NUEVE'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 10">
                        <xsl:value-of select="'DIEZ'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 11">
                        <xsl:value-of select="'ONCE'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 12">
                        <xsl:value-of select="'DOCE'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 13">
                        <xsl:value-of select="'TRECE'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 14">
                        <xsl:value-of select="'CATORCE'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 15">
                        <xsl:value-of select="'QUINCE'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 20">
                        <xsl:variable name="decenas">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$amount - 10"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('DIECI',$decenas)"/>
                    </xsl:when>
                    <xsl:when test="$entero = 20">
                        <xsl:value-of select="'VEINTE'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 30">
                        <xsl:variable name="decenas">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$amount - 20"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('VEINTI',$decenas)"/>
                    </xsl:when>
                    <xsl:when test="$entero = 30">
                        <xsl:value-of select="'TREINTA'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 40">
                        <xsl:value-of select="'CUARENTA'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 50">
                        <xsl:value-of select="'CINCUENTA'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 60">
                        <xsl:value-of select="'SESENTA'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 70">
                        <xsl:value-of select="'SETENTA'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 80">
                        <xsl:value-of select="'OCHENTA'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 90">
                        <xsl:value-of select="'NOVENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 100">
                        <xsl:variable name="decenas">
                            <xsl:variable name="dec">
                                <xsl:value-of select="floor($amount div 10)"/>
                            </xsl:variable>

                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$dec * 10"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:variable name="unidades">
                            <xsl:variable name="un">
                                <xsl:value-of select="$amount mod 10"/>
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$un"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:value-of select="concat($decenas,' Y ',$unidades)"/>
                    </xsl:when>
                    <xsl:when test="$entero = 100">
                        <xsl:value-of select="'CIEN'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 200">
                        <xsl:variable name="centenas">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$amount - 100"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('CIENTO ',$centenas)"/>
                    </xsl:when>
                    <xsl:when
                        test="$amount =200 or $amount =300 or $amount =400 or $amount =600 or $amount =800">
                        <xsl:variable name="centenas">
                            <xsl:variable name="dec">
                                <xsl:value-of
                                    select="floor($amount div 100)"
                                />
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$dec"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat($centenas,'CIENTOS')"/>
                    </xsl:when>
                    <xsl:when test="$entero = 500">
                        <xsl:value-of select="'QUINIENTOS'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 700">
                        <xsl:value-of select="'SETECIENTOS'"/>
                    </xsl:when>
                    <xsl:when test="$entero = 900">
                        <xsl:value-of select="'NOVECIENTOS'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 1000">
                        <xsl:variable name="centenas">
                            <xsl:variable name="cent">
                                <xsl:value-of
                                    select="floor($amount div 100)"
                                />
                            </xsl:variable>

                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$cent * 100"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:variable name="unidades">
                            <xsl:variable name="un">
                                <xsl:value-of select="$amount mod 100"/>
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$un"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat($centenas,' ',$unidades)"/>
                    </xsl:when>
                    <xsl:when test="$entero = 1000">
                        <xsl:value-of select="'MIL'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 2000">
                        <xsl:variable name="centenas">
                            <xsl:variable name="un">
                                <xsl:value-of select="$amount mod 1000"/>
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$un"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('MIL ',$centenas)"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 1000000">
                        <xsl:variable name="miles">
                            <xsl:value-of
                                select="floor($amount div 1000)"
                            />
                        </xsl:variable>

                        <xsl:variable name="milesLetra">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount" select="$miles"/>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:variable name="centenas">
                            <xsl:value-of select="$amount mod 1000"/>
                        </xsl:variable>

                        <xsl:choose>
                            <xsl:when test="$centenas &gt; 0 ">
                                <xsl:variable name="decenas">
                                    <xsl:call-template name="EnLetras">
                                        <xsl:with-param name="amount">
                                            <xsl:value-of select="$centenas"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:value-of select="concat($milesLetra,' MIL ',$decenas)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($milesLetra,' MIL')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$entero &gt;= 1000000">
                        <xsl:variable name="millones" select="floor($entero div 1000000)"/>
                        <xsl:variable name="resto" select="$entero mod 1000000"/>
                        <xsl:call-template name="EnLetras">
                            <xsl:with-param name="amount" select="$millones"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="$millones = 1"><xsl:text> MILLON</xsl:text></xsl:when>
                            <xsl:otherwise><xsl:text> MILLONES</xsl:text></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$resto &gt; 0">
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount" select="$resto"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <!-- FIN ESCENARIOS -->
                </xsl:choose>
            </xsl:when>
            
            <!-- AMOUNT SIN DECIMALES -->
            <xsl:otherwise>
                <!-- INICIO ESCENARIOS-->
                <xsl:choose>
                    <xsl:when test="$amount = 0">
                        <xsl:value-of select="'CERO'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 1">
                        <xsl:value-of select="'UN'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 2">
                        <xsl:value-of select="'DOS'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 3">
                        <xsl:value-of select="'TRES'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 4">
                        <xsl:value-of select="'CUATRO'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 5">
                        <xsl:value-of select="'CINCO'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 6">
                        <xsl:value-of select="'SEIS'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 7">
                        <xsl:value-of select="'SIETE'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 8">
                        <xsl:value-of select="'OCHO'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 9">
                        <xsl:value-of select="'NUEVE'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 10">
                        <xsl:value-of select="'DIEZ'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 11">
                        <xsl:value-of select="'ONCE'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 12">
                        <xsl:value-of select="'DOCE'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 13">
                        <xsl:value-of select="'TRECE'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 14">
                        <xsl:value-of select="'CATORCE'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 15">
                        <xsl:value-of select="'QUINCE'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 20">
                        <xsl:variable name="decenas">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($amount - 10)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('DIECI',$decenas)"/>
                    </xsl:when>
                    <xsl:when test="$amount = 20">
                        <xsl:value-of select="'VEINTE'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 30">
                        <xsl:variable name="decenas">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($amount - 20)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('VEINTI',$decenas)"/>
                    </xsl:when>
                    <xsl:when test="$amount = 30">
                        <xsl:value-of select="'TREINTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 40">
                        <xsl:value-of select="'CUARENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 50">
                        <xsl:value-of select="'CINCUENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 60">
                        <xsl:value-of select="'SESENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 70">
                        <xsl:value-of select="'SETENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 80">
                        <xsl:value-of select="'OCHENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 90">
                        <xsl:value-of select="'NOVENTA'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 100">
                        <xsl:variable name="decenas">
                            <xsl:variable name="dec">
                                <xsl:value-of
                                    select="substring-before(format-number(number($amount div 10),'#.00'),'.')"
                                />
                            </xsl:variable>

                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($dec * 10)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:variable name="unidades">
                            <xsl:variable name="un">
                                <xsl:value-of select="number($amount mod 10)"/>
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($un)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:value-of select="concat($decenas,' Y ',$unidades)"/>
                    </xsl:when>
                    <xsl:when test="$amount = 100">
                        <xsl:value-of select="'CIEN'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 200">
                        <xsl:variable name="centenas">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($amount - 100)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('CIENTO ',$centenas)"/>
                    </xsl:when>
                    <xsl:when
                        test="$amount =200 or $amount =300 or $amount =400 or $amount =600 or $amount =800">
                        <xsl:variable name="centenas">
                            <xsl:variable name="dec">
                                <xsl:value-of
                                    select="substring-before(format-number(number($amount div 100),'#.00'),'.')"
                                />
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="$dec"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat($centenas,'CIENTOS')"/>
                    </xsl:when>
                    <xsl:when test="$amount = 500">
                        <xsl:value-of select="'QUINIENTOS'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 700">
                        <xsl:value-of select="'SETECIENTOS'"/>
                    </xsl:when>
                    <xsl:when test="$amount = 900">
                        <xsl:value-of select="'NOVECIENTOS'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 1000">
                        <xsl:variable name="centenas">
                            <xsl:variable name="cent">
                                <xsl:value-of
                                    select="substring-before(format-number(number($amount div 100),'#.00'),'.')"
                                />
                            </xsl:variable>

                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($cent * 100)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:variable name="unidades">
                            <xsl:variable name="un">
                                <xsl:value-of select="number($amount mod 100)"/>
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($un)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat($centenas,' ',$unidades)"/>
                    </xsl:when>
                    <xsl:when test="$amount = 1000">
                        <xsl:value-of select="'MIL'"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 2000">
                        <xsl:variable name="centenas">
                            <xsl:variable name="un">
                                <xsl:value-of select="number($amount mod 1000)"/>
                            </xsl:variable>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount">
                                    <xsl:value-of select="number($un)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="concat('MIL ',$centenas)"/>
                    </xsl:when>
                    <xsl:when test="$amount &lt; 1000000">
                        <xsl:variable name="miles">
                            <xsl:value-of
                                select="substring-before(format-number(number($amount div 1000),'#.000000'),'.')"
                            />
                        </xsl:variable>

                        <xsl:variable name="milesLetra">
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount" select="$miles"/>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:variable name="centenas">
                            <xsl:value-of select="number($amount mod 1000)"/>
                        </xsl:variable>

                        <xsl:choose>
                            <xsl:when test="$centenas &gt; 0 ">
                                <xsl:variable name="decenas">
                                    <xsl:call-template name="EnLetras">
                                        <xsl:with-param name="amount">
                                            <xsl:value-of select="$centenas"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:value-of select="concat($milesLetra,' MIL ',$decenas)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($milesLetra,' MIL')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$amount &gt;= 1000000">
                        <xsl:variable name="millones" select="floor($amount div 1000000)"/>
                        <xsl:variable name="resto" select="$amount mod 1000000"/>
                        <xsl:call-template name="EnLetras">
                            <xsl:with-param name="amount" select="$millones"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="$millones = 1"><xsl:text> MILLON</xsl:text></xsl:when>
                            <xsl:otherwise><xsl:text> MILLONES</xsl:text></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$resto &gt; 0">
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="EnLetras">
                                <xsl:with-param name="amount" select="$resto"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                <!-- FIN ESCENARIOS -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="Dolares">
        <xsl:param name="amount"/>
        <xsl:choose>
            <xsl:when test="$amount &gt; 1">
                <xsl:value-of select="' DOLARES'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="' DOLAR'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
