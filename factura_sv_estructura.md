# Estructura Factura Electrónica (01) - El Salvador

**Versión documento:** V2.0.0 (vigente) / V2.2.0 (próxima)
**Formatos:** JSON / XML
**País:** SV (El Salvador)

---

## SECCIÓN R - RAÍZ (NUC)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| R02 | Version | Versión del formato (1 para doc 01) | SÍ | A | 1 |
| R03 | CountryCode | Código del país (SV) | SÍ | A | 2 |

---

## SECCIÓN A - HEADER (Información general)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| A02 | DocType | Tipo de documento (01) | SÍ | A | 2 |
| A07 | GUID | Código de generación (UUID v4) | SÍ | A | 36 |
| A03 | IssuedDateTime | Fecha y hora de emisión | SÍ | F | 25 |
| A04 | AdditionalIssueType | Ambiente de destino (00=Pruebas, 01=Producción) | SÍ | A | 2 |
| A05 | Currency | Moneda de la operación (USD) | No | A | 3 |
| A06 | AdditionalIssueDocInfo | Información adicional del documento | SÍ | L | - |

### AdditionalIssueDocInfo (A06)

| ID | Campo | Descripción | Valores | Obligatorio |
|----|-------|-------------|---------|-------------|
| AI01 | Secuencial | Número secuencial 15 dígitos | Ej: 000000000000001 | SÍ |
| AI02 | CodEstPuntoV | Código del establecimiento | Ej: M001P001 | SÍ |
| AI03 | TipoModelo | Modelo de facturación | 1=Previo, 2=Diferido | SÍ |
| AI04 | TipoOperacion | Tipo de transmisión | 1=Normal, 2=Contingencia | SÍ |

---

## SECCIÓN B - SELLER (Emisor)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| B02 | TaxID | NIT del emisor | SÍ | A | 9-14 |
| B04 | Name | Nombre, denominación o razón social | SÍ | A | 1-250 |
| B05 | Contact | Información de contacto | SÍ | O | - |
| B0511 | Phone | Número telefónico | SÍ | L | 8-30 |
| B0521 | Email | Correo electrónico | SÍ | L | 3-100 |
| B06 | AdditionlInfo | Información adicional del emisor | SÍ | L | - |
| B07 | AddressInfo | Dirección del emisor | SÍ | O | - |
| B071 | Address | Dirección complemento | SÍ | A | 1-200 |
| B072 | District | Código del municipio | SÍ | A | 2 |
| B073 | State | Código del departamento | SÍ | A | 2 |
| B074 | Country | País (SV) | SÍ | A | 2 |

### AdditionlInfo del Emisor (B06)

| ID | Campo | Descripción | Obligatorio |
|----|-------|-------------|-------------|
| BI01 | NRC | NRC del emisor (sin guion) | SÍ |
| BI02 | CodigoActividad | Código de actividad económica (5-6 dígitos) | SÍ |
| BI03 | GiroComercial | Giro comercial | SÍ |

---

## SECCIÓN C - BUYER (Receptor)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| C02 | TaxID | ID tributario del receptor | SÍ | A | 9-14 |
| C03 | TaxIDType | Tipo de documento de identificación | No | A | 2 |
| C04 | TaxIDAdditionalInfo | Info tributaria adicional del receptor | No | L | - |
| C05 | Name | Nombre del receptor | Cond.* | A | 1-250 |
| C06 | Contact | Información de contacto | No | O | - |
| C0611 | Phone | Número telefónico | No | L | 8-30 |
| C0621 | Email | Correo electrónico | No | L | 3-100 |
| C07 | AdditionlInfo | Info adicional del receptor | No | L | - |
| C08 | AddressInfo | Dirección del receptor | No | O | - |
| C081 | Address | Dirección complemento | No | A | 1-200 |
| C082 | District | Código del municipio | No | A | 2 |
| C083 | State | Código del departamento | No | A | 2 |
| C084 | Country | País (SV) | No | A | 2 |

**\*Obligatorio cuando operaciones ≥ $200.00**

### Tipo de Documento de Identificación (C03)

| Código | Descripción |
|--------|-------------|
| 36 | NIT |
| 13 | DUI |
| 37 | Otro |
| 03 | Pasaporte |
| 02 | Carnet de Residente |

---

## SECCIÓN D - ITEMS (Detalle)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| D02 | Item | Cada ítem de la transacción | SÍ | O | - |
| D03 | Number | Número correlativo del ítem | SÍ | N | 1-2000 |
| D04 | Codes | Códigos del ítem | No | L | - |
| D05 | Type | Tipo de ítem | SÍ | A | 1 |
| D06 | Description | Descripción del producto/servicio | SÍ | A | 1-1000 |
| D07 | Qty | Cantidad | SÍ | N | 1-10p1-8 |
| D08 | UnitOfMeasure | Unidad de medida | No | A | 1-2 |
| D09 | Price | Precio unitario | SÍ | N | 1-9p2-8 |
| D10 | Discounts | Descuentos por ítem | No | L | - |
| D1011 | Amount | Monto del descuento | No | N | 1-11p2-8 |
| D11 | Taxes | Impuestos aplicados al ítem | Cond.** | L | - |
| D1111 | Code | Código de tributo | Cond.** | A | 2 |
| D1113 | Amount | IVA retenido (0.00 para doc 01) | Cond.** | N | 1-9p2-8 |
| D12 | Charges | Tipo de venta del ítem | SÍ | L | - |
| D1211 | Code | Código de venta | SÍ | A | 1-20 |
| D1212 | Amount | Monto de venta | SÍ | N | 1-9p2-8 |
| D13 | Totals | Resumen de precios del ítem | SÍ | O | - |
| D131 | TotalItem | Precio total del ítem | SÍ | N | 1-11p2-8 |
| D14 | AdditionalInfo | Información adicional | No | L | - |

**\*\*Requerido si D1211 = VENTA_GRAVADA**

### Tipo de Ítem (D05)

| Código | Descripción |
|--------|-------------|
| 1 | Bienes |
| 2 | Servicios |
| 3 | Ambos (Bienes y Servicios) |
| 4 | Otros tributos por ítem |

### Unidad de Medida (D08) - Principales

| Código | Descripción |
|--------|-------------|
| 1 | Metro |
| 23 | Litro |
| 24 | Botella |
| 30 | Tonelada |
| 34 | Kilogramo |
| 36 | Libra |
| 59 | Unidad |
| 99 | Otra |

### Códigos de Tributos (D1111) - Sección 1

| Código | Descripción |
|--------|-------------|
| 20 | Impuesto al Valor Agregado 13% |
| C3 | IVA Exportaciones 0% |
| 59 | Turismo: alojamiento 5% |
| 71 | Turismo: salida del país aérea $7.00 |
| D1 | FOVIAL ($0.20 Ctvs. por galón) |
| C8 | COTRANS ($0.10 Ctvs. por galón) |
| D5 | Otras tasas casos especiales |
| D4 | Otros impuestos casos especiales |

### Códigos de Tributos (D1111) - Sección 2

| Código | Descripción |
|--------|-------------|
| A8 | Impuesto Especial al Combustible (0%, 0.5%, 1%) |
| 57 | Impuesto industria de Cemento |
| 90 | Impuesto especial a la primera matrícula |
| A6 | Impuesto ad-valorem armas de fuego |

### Tipos de Venta (D1211)

| Código | Descripción |
|--------|-------------|
| VENTA_NO_SUJETA | Ventas no sujetas |
| VENTA_EXENTA | Ventas exentas |
| VENTA_GRAVADA | Ventas gravadas (con IVA incluido) |
| NO_GRAVADO | Montos no gravados |

**Nota:** Solo un tipo de venta puede tener monto diferente de 0.00 por ítem.

---

## SECCIÓN E - TOTALS (Totales)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| E02 | TotalTaxes | Impuestos aplicados (consolidados) | SÍ | L | - |
| E021 | TotalTax | Cada tributo | SÍ | O | - |
| E0211 | Code | Código del tributo | SÍ | A | 2 |
| E0212 | Description | Nombre del tributo | SÍ | A | 1-50 |
| E0213 | Amount | Monto consolidado del tributo | SÍ | N | - |
| E03 | TotalCharges | Totales por tipo de venta | SÍ | L | - |
| E031 | TotalCharge | Cada tipo de venta | SÍ | O | - |
| E0311 | Code | Tipo de venta | SÍ | A | 1-20 |
| E0312 | Amount | Monto total | SÍ | N | 1-11p2 |
| E04 | TotalDiscounts | Descuentos globales | No | L | - |
| E041 | Discount | Cada descuento | No | O | - |
| E0411 | Code | Tipo de descuento | No | A | 1-20 |
| E0412 | Amount | Monto del descuento | No | N | 1-11p2 |
| E05 | GrandTotal | Total de la factura | SÍ | O | - |
| E051 | InvoiceTotal | Precio total a pagar | SÍ | N | 1-11p2 |
| E06 | InWords | Valor en letras | SÍ | A | 1-200 |
| E07 | AdditionalInfo | Información adicional | No | L | - |

### Totales por Tipo de Venta (E0311)

| Código | Descripción |
|--------|-------------|
| TOTAL_NO_SUJETA | Total ventas no sujetas |
| TOTAL_EXENTA | Total ventas exentas |
| TOTAL_GRAVADA | Total ventas gravadas |
| TOTAL_NO_GRAVADO | Total montos no gravados |
| TOTAL_COMPRA | Suma de todas las operaciones (doc 14) |

### Descuentos Globales (E0411)

| Código | Descripción |
|--------|-------------|
| NO_SUJETA | Descuento sobre ventas no sujetas |
| EXENTA | Descuento sobre ventas exentas |
| GRAVADA | Descuento sobre ventas gravadas |
| PORCENTAJE_DESCUENTO | Porcentaje global de descuento |
| DESCUENTO | Descuento sobre operaciones afectas (doc 11, 14) |

### Fórmula GrandTotal (doc 01)

```
Subtotal = (TOTAL_NO_SUJETA + TOTAL_EXENTA + TOTAL_GRAVADA) - (Descuentos globales)
ValorTributos = Sumatoria tributos (excepto C5, C6, C7)
TotalPagar = Subtotal + ValorTributos - RetencionRenta - IVARetenido + TotalNoGravado
```

---

## SECCIÓN F - PAYMENTS (Formas de pago)

| ID | Campo | Descripción | Obligatorio | Tipo | Tamaño |
|----|-------|-------------|-------------|------|--------|
| F01 | Payments | Grupo de formas de pago | Cond.*** | L | - |
| F02 | Payment | Cada forma de pago | SÍ | O | - |
| F021 | Code | Código de forma de pago | SÍ | A | 2-5 |
| F022 | Amount | Monto de la cuota | SÍ | N | 1-11p2 |
| F023 | AditionalData | Info adicional del pago | No | L | - |

**\*\*\*Obligatorio si Condición de operación (EI04) = 1 (contado) o 3 (otro)**

### Códigos de Forma de Pago (F021)

| Código | Descripción |
|--------|-------------|
| 01 | Billetes y monedas |
| 02 | Tarjeta Débito |
| 03 | Tarjeta Crédito |
| 04 | Cheque |
| 05 | Transferencia-Depósito Bancario |
| 08 | Dinero electrónico |
| 09 | Monedero electrónico |
| 11 | Bitcoin |
| 12 | Otras Criptomonedas |
| 13 | Cuentas por pagar del receptor |
| 14 | Giro bancario |
| 99 | Otros (indicar medio de pago) |

---

## Códigos de Municipios (B072, C082)

| Código | Departamento | Municipio |
|--------|--------------|-----------|
| 01 | Ahuachapán | - |
| 13 | Ahuachapán | Ahuachapán Norte |
| 14 | Ahuachapán | Ahuachapán Centro |
| 15 | Ahuachapán | Ahuachapán Sur |
| 02 | Santa Ana | - |
| 14 | Santa Ana | Santa Ana Norte |
| 15 | Santa Ana | Santa Ana Centro |
| 16 | Santa Ana | Santa Ana Este |
| 17 | Santa Ana | Santa Ana Oeste |
| 03 | Sonsonate | - |
| 17 | Sonsonate | Sonsonate Norte |
| 18 | Sonsonate | Sonsonate Centro |
| 19 | Sonsonate | Sonsonate Este |
| 20 | Sonsonate | Sonsonate Oeste |
| 04 | Chalatenango | - |
| 34 | Chalatenango | Chalatenango Norte |
| 35 | Chalatenango | Chalatenango Centro |
| 36 | Chalatenango | Chalatenango Sur |
| 05 | La Libertad | - |
| 23 | La Libertad | La Libertad Norte |
| 24 | La Libertad | La Libertad Centro |
| 25 | La Libertad | La Libertad Oeste |
| 26 | La Libertad | La Libertad Este |
| 27 | La Libertad | La Libertad Costa |
| 28 | La Libertad | La Libertad Sur |
| 06 | San Salvador | - |
| 20 | San Salvador | San Salvador Norte |
| 21 | San Salvador | San Salvador Oeste |
| 22 | San Salvador | San Salvador Este |
| 23 | San Salvador | San Salvador Centro |
| 24 | San Salvador | San Salvador Sur |
| 07 | Cuscatlán | - |
| 17 | Cuscatlán | Cuscatlán Norte |
| 18 | Cuscatlán | Cuscatlán Sur |
| 08 | La Paz | - |
| 23 | La Paz | La Paz Oeste |
| 24 | La Paz | La Paz Centro |
| 25 | La Paz | La Paz Este |
| 09 | Cabañas | - |
| 10 | Cabañas | Cabañas Oeste |
| 11 | Cabañas | Cabañas Este |
| 10 | San Vicente | - |
| 14 | San Vicente | San Vicente Norte |
| 15 | San Vicente | San Vicente Sur |
| 11 | Usulután | - |
| 24 | Usulután | Usulután Norte |
| 25 | Usulután | Usulután Este |
| 12 | San Miguel | - |
| 21 | San Miguel | San Miguel Norte |
| 22 | San Miguel | San Miguel Centro |
| 23 | San Miguel | San Miguel Oeste |
| 13 | Morazán | - |
| 27 | Morazán | Morazán Norte |
| 28 | Morazán | Morazán Sur |
| 14 | La Unión | - |
| 19 | La Unión | La Unión Norte |
| 20 | La Unión | La Unión Sur |

---

## Códigos de Departamentos (B073, C083)

| Código | Departamento |
|--------|--------------|
| 00 | Otro (Extranjeros) |
| 01 | Ahuachapán |
| 02 | Santa Ana |
| 03 | Sonsonate |
| 04 | Chalatenango |
| 05 | La Libertad |
| 06 | San Salvador |
| 07 | Cuscatlán |
| 08 | La Paz |
| 09 | Cabañas |
| 10 | San Vicente |
| 11 | Usulután |
| 12 | San Miguel |
| 13 | Morazán |
| 14 | La Unión |

---

## Notas Importantes

1. **API Case-Sensitive**: Los nombres de campos son sensibles a mayúsculas/minúsculas.
2. **Versión 1**: Para documentos 01, 07, 08, 09, 11, 14 y 15.
3. **IVA incluido**: En documento 01, los precios ya incluyen IVA. El código 20 (IVA 13%) lleva Amount = 0.00.
4. **GUID único**: Debe ser UUID v4, único por documento.
5. **Moneda**: Solo se acepta USD.
6. **>Total ítem**: Se calcula como `VentaGravada + VentaExenta + VentaNoSujeta`.
