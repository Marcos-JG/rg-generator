import reference from '../../public/templates/XSLTS3_dtesv_Carta_06141602171030_fel_1.xslt?raw';
import shared from '../../public/templates/RG-SharedSV_fel_2.xslt?raw';
import words from '../../public/templates/Shared_ENLETRAS_fel_2.xslt?raw';

const XSL = 'http://www.w3.org/1999/XSL/Transform';
const XMLNS = 'http://www.w3.org/2000/xmlns/';
const dependencies = { 'RG-SharedSV_fel_2.xslt': shared, 'Shared_ENLETRAS_fel_2.xslt': words };

export function isReferenceDocument(config) {
  return config.country?.toLowerCase() === 'sv' && String(config.docType) === '03';
}

// Bundle the shared templates with their namespace bindings, including prefixes
// used only inside XPath expressions (XMLSerializer cannot infer those).
export function bundleXslt(source) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(source, 'application/xml');
  if (doc.querySelector('parsererror')) throw new Error('La plantilla XSLT contiene XML inválido.');
  for (const include of [...doc.getElementsByTagNameNS(XSL, 'include')]) {
    const content = dependencies[include.getAttribute('href')];
    if (!content) throw new Error('No se encontró la dependencia XSLT: ' + include.getAttribute('href'));
    const dependency = parser.parseFromString(content, 'application/xml').documentElement;
    for (const child of [...dependency.children]) {
      // The main stylesheet defines output settings; shared files only repeat encoding.
      if (child.namespaceURI === XSL && child.localName === 'output') continue;
      const imported = doc.importNode(child, true);
      for (const attr of [...dependency.attributes]) {
        if (attr.namespaceURI === XMLNS) imported.setAttributeNS(XMLNS, attr.name, attr.value);
      }
      include.parentNode.insertBefore(imported, include);
    }
    include.remove();
  }
  return new XMLSerializer().serializeToString(doc);
}

export function generateReferenceXslt() {
  // Preserve the reference layout and relative includes exactly as supplied.
  return reference;
}
