const COUNTRY_NAMES = {
  SV: 'El Salvador',
  GT: 'Guatemala',
  CR: 'Costa Rica',
  PA: 'Panamá',
  DO: 'República Dominicana',
};

const DOC_TYPE_NAMES_SV = {
  '01': 'FACTURA',
  '03': 'COMPROBANTE DE CRÉDITO FISCAL',
  '04': 'NOTA DE REMISIÓN',
  '05': 'NOTA DE DÉBITO',
  '06': 'NOTA DE CRÉDITO',
  '07': 'RECIPO POR DONACIÓN',
  '08': 'RECIBO',
  '09': 'FACTURA ESPECIAL',
};

const DOC_TYPE_NAME_TO_CODE_SV = Object.fromEntries(
  Object.entries(DOC_TYPE_NAMES_SV).map(([code, name]) => [name, code])
);

const DOC_TYPE_ALIASES = {
  'FACT': '01',
  'CCF': '03',
  'NABN': '04',
  'NDEB': '05',
  'NCRE': '06',
  'RDON': '07',
  'RECI': '08',
  'FESP': '09',
};

function resolveDocType(raw) {
  if (!raw) return { docType: null, docTypeName: null };
  const trimmed = raw.trim();
  if (DOC_TYPE_NAMES_SV[trimmed]) return { docType: trimmed, docTypeName: DOC_TYPE_NAMES_SV[trimmed] };
  if (DOC_TYPE_NAME_TO_CODE_SV[trimmed]) return { docType: DOC_TYPE_NAME_TO_CODE_SV[trimmed], docTypeName: trimmed };
  if (DOC_TYPE_ALIASES[trimmed]) return { docType: DOC_TYPE_ALIASES[trimmed], docTypeName: DOC_TYPE_NAMES_SV[DOC_TYPE_ALIASES[trimmed]] || trimmed };
  return { docType: trimmed, docTypeName: trimmed };
}

function buildLogoUrl(country, nit, ambient) {
  const env = ambient === '00' ? 'TEST/' : '';
  return `https://digifact-logo.s3.amazonaws.com/${country.toUpperCase()}/logo/${env}${nit}.jpg`;
}

function getTextContent(doc, selector) {
  const el = doc.querySelector(selector);
  return el ? el.textContent : null;
}

function getAttributeValue(doc, selector, attr) {
  const el = doc.querySelector(selector);
  return el ? el.getAttribute(attr) : null;
}

function getNrcFromTaxInfo(doc) {
  const infos = doc.querySelectorAll('Seller > TaxIDAdditionalInfo > Info');
  for (const info of infos) {
    if (info.getAttribute('Name') === 'NRC') {
      return info.getAttribute('Value');
    }
  }
  return null;
}

export function parseXmlMetadata(xmlDoc) {
  const countryCode = (getTextContent(xmlDoc, 'CountryCode') || '').toLowerCase();
  const rawDocType = getTextContent(xmlDoc, 'Header > DocType') || getTextContent(xmlDoc, 'Header > DocTypeCode');
  const { docType, docTypeName } = resolveDocType(rawDocType);
  const ambient = getTextContent(xmlDoc, 'Header > AdditionalIssueType');
  const nit = getTextContent(xmlDoc, 'Seller > TaxID');

  return {
    country: countryCode,
    countryName: COUNTRY_NAMES[countryCode] || countryCode,
    docType,
    docTypeName: docTypeName || `DocType ${docType}`,
    guid: getTextContent(xmlDoc, 'Header > GUID'),
    issuedDate: getTextContent(xmlDoc, 'Header > IssuedDateTime'),
    ambient,
    currency: getTextContent(xmlDoc, 'Header > Currency'),

    seller: {
      nit,
      name: getTextContent(xmlDoc, 'Seller > Name'),
      nrc: getNrcFromTaxInfo(xmlDoc),
      phone: getTextContent(xmlDoc, 'Seller > Contact > PhoneList > Phone'),
      email: getTextContent(xmlDoc, 'Seller > Contact > EmailList > Email'),
      address: getTextContent(xmlDoc, 'Seller > AddressInfo > Address'),
    },

    buyer: {
      nit: getTextContent(xmlDoc, 'Buyer > TaxID'),
      name: getTextContent(xmlDoc, 'Buyer > Name'),
      email: getTextContent(xmlDoc, 'Buyer > Contact > EmailList > Email'),
      address: getTextContent(xmlDoc, 'Buyer > AddressInfo > Address'),
    },

    itemCount: xmlDoc.querySelectorAll('Items > Item').length,

    logoUrl: buildLogoUrl(countryCode, nit, ambient),
  };
}

export function parseXmlFile(xmlString) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(xmlString, 'text/xml');

  const parseError = doc.querySelector('parsererror');
  if (parseError) {
    throw new Error('XML mal formado: ' + parseError.textContent);
  }

  return {
    doc,
    metadata: parseXmlMetadata(doc),
  };
}

function getInfoValue(doc, selector, name) {
  const infos = doc.querySelectorAll(selector);
  for (const info of infos) {
    if (info.getAttribute('Name') === name) {
      return info.getAttribute('Value') || '';
    }
  }
  return '';
}

function findInfoValue(doc, name) {
  const allInfos = doc.querySelectorAll('Info');
  for (const info of allInfos) {
    if (info.getAttribute('Name') === name) {
      return info.getAttribute('Value') || '';
    }
  }
  return '';
}

function getAdditionalInfoValue(doc, name) {
  return getInfoValue(doc, 'Totals > AdditionalInfo > Info', name);
}

export function extractXmlData(xmlDoc) {
  const sellerAdditionalInfos = xmlDoc.querySelectorAll('Seller > TaxIDAdditionalInfo > Info');
  const sellerActividadCodigo = getInfoValue(xmlDoc, 'Seller > TaxIDAdditionalInfo > Info', 'CodigoActividad');
  const sellerActividadDesc = getInfoValue(xmlDoc, 'Seller > TaxIDAdditionalInfo > Info', 'DescActividad');
  const sellerNombreComercial = getInfoValue(xmlDoc, 'Seller > AdditionlInfo > Info', 'NombreComercial');
  const sellerTipoEstablecimiento = getInfoValue(xmlDoc, 'Seller > AdditionlInfo > Info', 'TipoEstablecimiento');

  const seller = {
    Name: getTextContent(xmlDoc, 'Seller > Name') || '',
    NombreComercial: sellerNombreComercial,
    TaxID: getTextContent(xmlDoc, 'Seller > TaxID') || '',
    NRC: getNrcFromTaxInfo(xmlDoc) || '',
    CodigoActividad: sellerActividadCodigo,
    DescActividad: sellerActividadDesc,
    Address: getTextContent(xmlDoc, 'Seller > AddressInfo > Address') || '',
    Phone: getTextContent(xmlDoc, 'Seller > Contact > PhoneList > Phone') || '',
    Email: getTextContent(xmlDoc, 'Seller > Contact > EmailList > Email') || '',
    TipoEstablecimiento: sellerTipoEstablecimiento,
  };

  const buyerNRC = getInfoValue(xmlDoc, 'Buyer > TaxIDAdditionalInfo > Info', 'NRC');
  const buyer = {
    Name: getTextContent(xmlDoc, 'Buyer > Name') || '',
    TaxIDType: getTextContent(xmlDoc, 'Buyer > TaxIDType') || '',
    TaxID: getTextContent(xmlDoc, 'Buyer > TaxID') || '',
    NRC: buyerNRC,
    Email: getTextContent(xmlDoc, 'Buyer > Contact > EmailList > Email') || '',
    Address: getTextContent(xmlDoc, 'Buyer > AddressInfo > Address') || '',
  };

  const items = [];
  const itemEls = xmlDoc.querySelectorAll('Items > Item');
  itemEls.forEach((itemEl) => {
    const getVal = (sel) => itemEl.querySelector(sel)?.textContent || '';
    const getCharge = (code) => {
      const charges = itemEl.querySelectorAll('Charges > Charge');
      for (const ch of charges) {
        if (ch.querySelector('Code')?.textContent === code) {
          return ch.querySelector('Amount')?.textContent || '0.00';
        }
      }
      return '0.00';
    };
    items.push({
      Number: '',
      Qty: getVal('Quantity'),
      UnitOfMeasure: getVal('UnitOfMeasure'),
      Description: getVal('Description'),
      Price: getVal('UnitPrice'),
      Discount: getCharge('DESCUENTO'),
      NO_GRAVADO: getCharge('NO_GRAVADO'),
      VENTA_NO_SUJETA: getCharge('VENTA_NO_SUJETA'),
      VENTA_EXENTA: getCharge('VENTA_EXENTA'),
      VENTA_GRAVADA: getCharge('VENTA_GRAVADA'),
    });
  });

  const getCharge = (code, container) => {
    if (!container) return '0.00';
    const charges = container.querySelectorAll('Charge');
    for (const ch of charges) {
      if (ch.querySelector('Code')?.textContent === code) {
        return ch.querySelector('Amount')?.textContent || '0.00';
      }
    }
    return '0.00';
  };

  const totalsEl = xmlDoc.querySelector('Totals');
  const chargesEl = totalsEl?.querySelector('Charges');
  const totals = {
    SUBTOTAL: getCharge('SUBTOTAL', chargesEl),
    TOTAL_NO_GRAVADO: getCharge('TOTAL_NO_GRAVADO', chargesEl),
    TOTAL_GRAVADA: getCharge('TOTAL_GRAVADA', chargesEl),
    TOTAL_EXENTA: getCharge('TOTAL_EXENTA', chargesEl),
    TOTAL_NO_SUJETA: getCharge('TOTAL_NO_SUJETA', chargesEl),
    TOTAL_DESCUENTO: getCharge('TOTAL_DESCUENTO', chargesEl),
    TOTAL_PAGAR: getCharge('TOTAL_PAGAR', chargesEl),
    IVA: getCharge('IVA', chargesEl),
    IVA_PERCIBIDO: getAdditionalInfoValue(xmlDoc, 'IvaPercibido'),
    IVA_RETENIDO: getAdditionalInfoValue(xmlDoc, 'IvaRetenido'),
    RETENCION_RENTA: getAdditionalInfoValue(xmlDoc, 'RetencionRenta'),
    SEGURO: getAdditionalInfoValue(xmlDoc, 'Seguro'),
    FLETE: getAdditionalInfoValue(xmlDoc, 'Flete'),
    MONTO_TOTAL_OPERACION: getAdditionalInfoValue(xmlDoc, 'MontoTotalOperacion'),
    TOTAL_COMPRA: getCharge('TOTAL_COMPRA', chargesEl),
  };

  const header = {
    GUID: getTextContent(xmlDoc, 'Header > GUID') || '',
    IssuedDateTime: getTextContent(xmlDoc, 'Header > IssuedDateTime') || '',
    DocType: getTextContent(xmlDoc, 'Header > DocType') || '',
    Currency: getTextContent(xmlDoc, 'Header > Currency') || '',
    Secuencial: getInfoValue(xmlDoc, 'Header > AdditionalIssueDocInfo > Info', 'Secuencial'),
    CodEstPuntoV: getInfoValue(xmlDoc, 'Header > AdditionalIssueDocInfo > Info', 'CodEstPuntoV'),
    ReceptionSeal: findInfoValue(xmlDoc, 'selloRecibido'),
    Version: getTextContent(xmlDoc, 'Root > Version') || getTextContent(xmlDoc, 'Version') || '',
  };

  const inWords = getTextContent(xmlDoc, 'Totals > InWords') || '';

  return { seller, buyer, items, totals, header, inWords };
}
