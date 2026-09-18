import { bundleXsltDocument } from './referenceXslt';
import { normalizeXmlSource } from './xmlSource';
import { xmlFieldElement } from './xmlFields';

const XSL = 'http://www.w3.org/1999/XSL/Transform';
const selectable = new Set(['div', 'table', 'td', 'th', 'p', 'span', 'b', 'strong', 'img', 'hr', 'h1', 'h2', 'h3']);

function appendCss(doc, node, css) {
  const dynamic = [...node.children].find(child => child.namespaceURI === XSL &&
    child.localName === 'attribute' && child.getAttribute('name') === 'style');
  if (dynamic) {
    const suffix = doc.createElementNS(XSL, 'xsl:text');
    suffix.textContent = ';' + css;
    dynamic.appendChild(suffix);
  } else node.setAttribute('style', (node.getAttribute('style') || '') + ';' + css);
}

export function parseImportedXslt(source) {
  const doc = new DOMParser().parseFromString(normalizeXmlSource(source), 'application/xml');
  if (doc.querySelector('parsererror') || doc.documentElement.namespaceURI !== XSL ||
    !['stylesheet', 'transform'].includes(doc.documentElement.localName)) {
    throw new Error('El archivo no es una plantilla XSLT válida.');
  }
  if (Number(doc.documentElement.getAttribute('version')) > 1) {
    throw new Error('El editor admite plantillas XSLT 1.0.');
  }
  return doc;
}

// Patch literal result elements in the original stylesheet; never rebuild its
// XPath expressions, conditions, loops, named templates or includes.
export function editImportedXsltDocument(source, { overrides = {}, positions = {}, textOverrides = {}, xmlFields = [] }: import('../types/editor').EditorState = {}, preview = false) {
  const doc = parseImportedXslt(source);
  const elements = [...doc.getElementsByTagName('*')].filter(node =>
    node.namespaceURI !== XSL && selectable.has(node.localName) &&
    !node.closest('head, style, script') && !node.parentElement?.closest('xsl\\:attribute'));
  let textIndex = 0;
  elements.forEach((node, index) => {
    const id = `import-${index}`;
    if (preview) node.setAttribute('data-rg-id', id);
    const ov = overrides[id] || {};
    const css = document.createElement('div').style;
    for (const [property, value] of Object.entries(ov)) {
      if (typeof value !== 'string' && typeof value !== 'number') continue;
      if (property === 'separationX') css.paddingLeft = String(value);
      else if (property in css) css.setProperty(property.replace(/[A-Z]/g, letter => '-' + letter.toLowerCase()), String(value));
    }
    const position = positions[id];
    if (position) {
      css.transform = `translate(${position.x}px, ${position.y}px)`;
      css.position = 'relative';
      css.zIndex = String(position.z || 1);
    }
    if (css.cssText) appendCss(doc, node, css.cssText);
    if (position && (position.x || position.y)) {
      let parent = node.parentElement;
      while (parent && !['body', 'html'].includes(parent.localName)) {
        if (parent.namespaceURI !== XSL) appendCss(doc, parent, 'overflow:visible;');
        parent = parent.parentElement;
      }
    }
    // Static labels are editable. XML values remain live bindings.
    if (!['table', 'img', 'hr'].includes(node.localName)) {
      for (const text of [...node.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim())) {
        const textId = `import-label-${textIndex++}`;
        const key = `${textId}:text:0`;
        if (Object.hasOwn(textOverrides, key)) text.textContent = textOverrides[key];
        if (preview) {
          const span = doc.createElement('span');
          span.setAttribute('data-rg-text', key);
          text.replaceWith(span);
          span.appendChild(text);
        }
      }
    }
  });
  if (preview) {
    for (const loop of [...doc.getElementsByTagNameNS(XSL, '*')].filter(node => ['for-each', 'variable'].includes(node.localName))) {
      if (!/(?:^|\/)Items\/Item(?:$|\[|\))/.test(loop.getAttribute('select') || '')) continue;
      const table = loop.closest('table');
      if (table?.hasAttribute('data-rg-id')) {
        table.setAttribute('class', `${table.getAttribute('class') || ''} items-table`.trim());
        table.setAttribute('data-drag-section', 'items');
      }
    }
  }
  if (xmlFields.length) {
    const body = [...doc.getElementsByTagName('*')].find(node => node.localName === 'body' && node.namespaceURI !== XSL);
    if (!body) throw new Error('Para agregar datos, la plantilla debe tener un elemento body en su salida HTML.');
    appendCss(doc, body, 'position:relative;');
    for (const field of xmlFields) {
      const node = xmlFieldElement(doc, field, { overrides, positions, textOverrides }, preview);
      const value = doc.createElementNS(XSL, 'xsl:value-of');
      value.setAttribute('select', field.xpath);
      const span = doc.createElement('span');
      if (preview) span.setAttribute('data-rg-value', 'true');
      span.appendChild(value); node.appendChild(span); body.appendChild(node);
    }
  }
  return doc;
}

export function editImportedXslt(source, editor = {}, preview = false) {
  return new XMLSerializer().serializeToString(editImportedXsltDocument(source, editor, preview));
}

export function renderImportedXslt(xml, source, editor, dependencies = {}) {
  const stylesheet = bundleXsltDocument(editImportedXsltDocument(source, editor, true), dependencies);
  const input = new DOMParser().parseFromString(normalizeXmlSource(xml), 'application/xml');
  if (input.querySelector('parsererror')) throw new Error('El XML de ejemplo no es válido.');
  if (typeof XSLTProcessor === 'undefined') throw new Error('Este navegador no permite transformar XSLT. Abre el editor en un navegador con soporte XSLT.');
  const processor = new XSLTProcessor();
  processor.importStylesheet(stylesheet);
  const result = processor.transformToDocument(input);
  if (!result?.documentElement) throw new Error('No se pudo transformar el XML con esta plantilla.');
  return '<!DOCTYPE html>' + new XMLSerializer().serializeToString(result.documentElement);
}
