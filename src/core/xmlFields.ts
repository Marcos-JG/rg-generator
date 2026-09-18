import { normalizeXmlSource } from './xmlSource';
import type { EditorState, XmlField } from '../types/editor';

export const XML_FIELD_MIME = 'application/x-rg-xml-field';
export const XML_FIELD_TEXT_PREFIX = 'rg-xml-field:';
// Some browsers remove custom transfer types on entry into the preview iframe.
let draggedXPath: string | null = null;
export const beginXmlFieldDrag = (xpath: string) => { draggedXPath = xpath; };
export const endXmlFieldDrag = () => { draggedXPath = null; };
export const activeXmlFieldDrag = () => draggedXPath;
export interface XmlDatum { xpath: string; label: string; path: string; value: string; kind?: 'logo' }
const literal = (value: string) => !value.includes("'") ? `'${value}'` :
  !value.includes('"') ? `"${value}"` : `concat(${value.split("'").map(part => `'${part}'`).join(`,"'",`)})`;
const nameTest = (node: Element | Attr) => `local-name()=${literal(node.localName)} and ${node.namespaceURI ? `namespace-uri()=${literal(node.namespaceURI)}` : 'not(namespace-uri())'}`;

// Absolute XPath 1.0 needs no stylesheet namespace declarations. Named Info
// entries retain their identity when siblings are reordered in another XML.
export function xmlDataFields(source: string): XmlDatum[] {
  const doc = new DOMParser().parseFromString(normalizeXmlSource(source), 'application/xml');
  if (doc.querySelector('parsererror')) return [];
  const fields: XmlDatum[] = [];
  const visit = (node: Element, parent: string, display: string) => {
    const siblings = [...(node.parentElement?.children || [node])].filter(other => other.localName === node.localName && other.namespaceURI === node.namespaceURI);
    const named = node.getAttribute('Name');
    const uniqueName = named && siblings.filter(other => other.getAttribute('Name') === named).length === 1;
    const identity = uniqueName ? `[@Name=${literal(named)}]` : `[${siblings.indexOf(node) + 1}]`;
    const xpath = `${parent}/*[${nameTest(node)}]${identity}`;
    const path = `${display}/${node.localName}${uniqueName ? ` (${named})` : siblings.length > 1 ? ` [${siblings.indexOf(node) + 1}]` : ''}`;
    for (const attr of [...node.attributes]) {
      if (attr.namespaceURI === 'http://www.w3.org/2000/xmlns/' || !attr.value.trim()) continue;
      fields.push({ xpath: `${xpath}/@*[${nameTest(attr)}]`, label: attr.localName === 'Value' && named ? named : attr.localName, path: `${path}/@${attr.localName}`, value: attr.value });
    }
    if (!node.children.length && node.textContent.trim()) fields.push({ xpath, label: named || node.localName, path, value: node.textContent.trim() });
    for (const child of [...node.children]) visit(child, xpath, path);
  };
  visit(doc.documentElement, '', '');
  return fields;
}

export function xmlValue(doc: Document, xpath: string): string {
  return doc.evaluate(xpath, doc, null, 2, null).stringValue;
}

export function xmlPaletteFields(source: string): XmlDatum[] {
  const fields = xmlDataFields(source);
  const taxId = fields.find(field => /\/Seller\/TaxID$/.test(field.path));
  if (!taxId) return fields;
  return [{ kind: 'logo', label: 'Logo del emisor', path: 'Logo del emisor',
    xpath: `concat('https://digifact-logo.s3.amazonaws.com/SV/logo/',${taxId.xpath},'.jpg')`,
    value: `https://digifact-logo.s3.amazonaws.com/SV/logo/${taxId.value}.jpg` }, ...fields];
}

export function xmlFieldElement(doc: Document, field: XmlField, editor: EditorState, preview: boolean): Element {
  const node = doc.createElement('div');
  const style = document.createElement('div').style;
  style.cssText = `position:absolute;left:${field.x}px;top:${field.y}px;width:220px;min-height:20px;z-index:10;font-size:12px;font-family:Arial,sans-serif;color:#111;white-space:pre-wrap;overflow-wrap:anywhere;`;
  if (field.kind === 'logo') { style.width = '160px'; style.height = '100px'; }
  for (const [key, value] of Object.entries(editor.overrides?.[field.id] || {})) {
    if ((typeof value === 'string' || typeof value === 'number') && key in style) style.setProperty(key.replace(/[A-Z]/g, char => '-' + char.toLowerCase()), String(value));
  }
  const position = editor.positions?.[field.id];
  if (position) style.transform = `translate(${position.x}px,${position.y}px)`;
  node.setAttribute('style', style.cssText);
  if (preview) {
    node.setAttribute('data-rg-id', field.id);
    node.setAttribute('data-drag-section', field.id);
    for (const [direction, edges, cursor] of [
      ['n', 'top:0;left:0;right:0;height:6px', 'ns-resize'],
      ['h', 'bottom:0;left:0;right:0;height:6px', 'ns-resize'],
      ['w', 'top:0;bottom:0;left:0;width:6px', 'ew-resize'],
      ['e', 'top:0;bottom:0;right:0;width:6px', 'ew-resize'],
      ['he', 'bottom:0;right:0;width:12px;height:12px', 'nwse-resize'],
    ]) {
      const handle = doc.createElement('div');
      handle.setAttribute('data-resize', direction);
      handle.setAttribute('draggable', 'false');
      handle.setAttribute('style', `position:absolute;${edges};cursor:${cursor};z-index:20;pointer-events:auto;`);
      node.appendChild(handle);
    }
    const remove = doc.createElement('button');
    remove.setAttribute('type', 'button'); remove.setAttribute('data-rg-remove', field.id);
    remove.setAttribute('hidden', '');
    remove.setAttribute('aria-label', `Eliminar ${field.label}`);
    remove.setAttribute('title', `Eliminar ${field.label}`);
    remove.setAttribute('style', 'position:absolute;top:-10px;right:-10px;width:20px;height:20px;border:1px solid #fecaca;border-radius:50%;background:white;color:#dc2626;font:16px Arial;line-height:18px;cursor:pointer;z-index:100;padding:0;');
    remove.textContent = '×'; node.appendChild(remove);
  }
  if (field.kind === 'logo') return node;
  const label = doc.createElement('span');
  label.textContent = editor.textOverrides?.[`${field.id}:text:0`] ?? `${field.label}: `;
  if (preview) label.setAttribute('data-rg-text', `${field.id}:text:0`);
  node.appendChild(label);
  return node;
}

export function appendXmlFieldsHtml(html: string, fields: XmlField[], resolve: (xpath: string) => string, editor: EditorState): string {
  if (!fields?.length) return html;
  const doc = new DOMParser().parseFromString(html, 'text/html');
  for (const field of fields) {
    const node = xmlFieldElement(doc, field, editor, true);
    if (field.kind === 'logo') {
      const image = doc.createElement('img');
      image.setAttribute('src', resolve(field.xpath)); image.setAttribute('alt', field.label);
      image.setAttribute('style', 'width:100%;height:100%;object-fit:contain;');
      image.setAttribute('draggable', 'false'); node.appendChild(image); doc.body.appendChild(node); continue;
    }
    const value = doc.createElement('span');
    value.setAttribute('data-rg-value', 'true');
    value.textContent = resolve(field.xpath);
    node.appendChild(value);
    doc.body.appendChild(node);
  }
  return doc.body.innerHTML;
}
