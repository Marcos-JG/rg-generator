import { reference, shared, words } from '../generated/templates';
import { normalizeXmlSource } from './xmlSource';

const XSL = 'http://www.w3.org/1999/XSL/Transform';
const XMLNS = 'http://www.w3.org/2000/xmlns/';
const dependencies = { 'RG-SharedSV_fel_2.xslt': shared, 'Shared_ENLETRAS_fel_2.xslt': words };

export function isReferenceDocument(config) {
  return config.country?.toLowerCase() === 'sv' && String(config.docType) === '03';
}

// Bundle the shared templates with their namespace bindings, including prefixes
// used only inside XPath expressions (XMLSerializer cannot infer those).
export function bundleXsltDocument(source, extraDependencies = {}, chain = []) {
  const parser = new DOMParser();
  const doc = typeof source === 'string' ? parser.parseFromString(normalizeXmlSource(source), 'application/xml') : source;
  const parseError = doc.querySelector('parsererror');
  if (parseError) throw new Error(`No se pudo leer ${chain.at(-1) || 'la plantilla preparada para editar'}: ${parseError.textContent.trim().slice(0, 350)}`);
  if (doc.getElementsByTagNameNS(XSL, 'import').length) throw new Error('Esta plantilla usa xsl:import; todavía no se admite su prioridad de plantillas en la preview.');
  for (const include of [...doc.getElementsByTagNameNS(XSL, 'include')]) {
    const href = include.getAttribute('href');
    const name = href.split(/[?#]/)[0].split(/[\\/]/).pop();
    const content = extraDependencies[href] || extraDependencies[name] || dependencies[href] || dependencies[name];
    if (!content) throw new Error('Carga el archivo incluido: ' + href);
    if (chain.includes(name)) throw new Error('Los includes forman un ciclo: ' + [...chain, name].join(' → '));
    const dependency = bundleXsltDocument(content, extraDependencies, [...chain, name]).documentElement;
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
  return doc;
}

export function bundleXslt(source, extraDependencies = {}) {
  return new XMLSerializer().serializeToString(bundleXsltDocument(source, extraDependencies));
}

export function generateReferenceXslt() {
  // Preserve the reference layout and relative includes exactly as supplied.
  return reference;
}
