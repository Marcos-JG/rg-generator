// @vitest-environment jsdom
import { afterEach, expect, it, vi } from 'vitest';
import { attachXmlFieldDrop } from '../src/components/Preview/useXmlFieldDrop';
import { beginXmlFieldDrag, endXmlFieldDrag, xmlDataFields, XML_FIELD_MIME, XML_FIELD_TEXT_PREFIX } from '../src/core/xmlFields';

const xml = '<Root><Extra>OC-123</Extra></Root>';
const datum = () => xmlDataFields(xml)[0];
const cleanups: (() => void)[] = [];
afterEach(() => { cleanups.splice(0).forEach(cleanup => cleanup()); endXmlFieldDrag(); document.body.innerHTML = ''; vi.restoreAllMocks(); });
function drag(target: Element, type: string, payload: Record<string, string> = {}) {
  const event = new MouseEvent(type, { bubbles: true, cancelable: true, clientX: 150, clientY: 200 });
  Object.defineProperty(event, 'dataTransfer', { value: { types: Object.keys(payload), getData: name => payload[name] || '', dropEffect: '' } });
  target.dispatchEvent(event);
  return event;
}
function page() {
  const page = document.createElement('div'); document.body.appendChild(page);
  Object.defineProperties(page, { offsetWidth: { value: 400 }, clientWidth: { value: 400 } });
  page.getBoundingClientRect = () => ({ left: 50, top: 100, width: 400, height: 700 }) as DOMRect;
  return page;
}
it('receives a field over existing content before competing drop handlers', () => {
  const root = page(), child = document.createElement('table'); root.appendChild(child);
  const added = []; cleanups.push(attachXmlFieldDrop(root, () => xml, field => added.push(field)));
  child.addEventListener('drop', event => { event.stopPropagation(); throw new Error('Reorder intercepted the field'); });
  expect(drag(child, 'dragover', { [XML_FIELD_MIME]: datum().xpath }).defaultPrevented).toBe(true);
  drag(child, 'drop', { [XML_FIELD_MIME]: datum().xpath });
  expect(added).toHaveLength(1); expect(added[0]).toMatchObject({ xpath: datum().xpath, label: 'Extra', x: 100, y: 100 });
});
it('receives a cross-frame drop even when custom transfer types are missing', () => {
  const frame = document.createElement('iframe'); document.body.appendChild(frame);
  const doc = frame.contentDocument, added = [];
  cleanups.push(attachXmlFieldDrop(doc.body, () => xml, field => added.push(field)));
  beginXmlFieldDrag(datum().xpath);
  expect(drag(doc.documentElement, 'dragover').defaultPrevented).toBe(true);
  drag(doc.documentElement, 'drop');
  expect(added).toHaveLength(1); expect(added[0].xpath).toBe(datum().xpath);
});
it('supports the plain-text fallback without treating ordinary text as a field', () => {
  const root = page(), added = []; cleanups.push(attachXmlFieldDrop(root, () => xml, field => added.push(field)));
  drag(root, 'drop', { 'text/plain': 'Texto cualquiera' }); expect(added).toEqual([]);
  drag(root, 'drop', { 'text/plain': XML_FIELD_TEXT_PREFIX + datum().xpath }); expect(added).toHaveLength(1);
});
it('uses the current XML rather than a stale field list', () => {
  const root = page(), added = []; let current = xml;
  cleanups.push(attachXmlFieldDrop(root, () => current, field => added.push(field)));
  current = '<Root><NewValue>Nuevo</NewValue></Root>';
  drag(root, 'drop', { [XML_FIELD_MIME]: xmlDataFields(current)[0].xpath }); expect(added[0].label).toBe('NewValue');
  drag(root, 'drop', { [XML_FIELD_MIME]: datum().xpath }); expect(added).toHaveLength(1);
});
it('does not receive drops outside the page or after detaching the listener', () => {
  const root = page(), added = [], cleanup = attachXmlFieldDrop(root, () => xml, field => added.push(field));
  drag(document.body, 'drop', { [XML_FIELD_MIME]: datum().xpath }); expect(added).toEqual([]);
  cleanup(); drag(root, 'drop', { [XML_FIELD_MIME]: datum().xpath }); expect(added).toEqual([]);
});
it('deletes the chosen field from its preview button before selection handlers run', () => {
  vi.spyOn(window, 'confirm').mockReturnValue(true);
  const root = page(), removed = [];
  root.innerHTML = '<div data-rg-id="xml-field-test"><button data-rg-remove="xml-field-test">×</button></div>';
  const cleanup = attachXmlFieldDrop(root, () => xml, () => {}, id => removed.push(id)); cleanups.push(cleanup);
  const event = new MouseEvent('click', { bubbles: true, cancelable: true });
  root.querySelector('button').dispatchEvent(event);
  expect(removed).toEqual(['xml-field-test']); expect(event.defaultPrevented).toBe(true);
});
it('keeps the field when deletion is cancelled', () => {
  const confirm = vi.spyOn(window, 'confirm').mockReturnValue(false);
  const root = page(), removed = [];
  root.innerHTML = '<button data-rg-remove="xml-field-test">×</button>';
  cleanups.push(attachXmlFieldDrop(root, () => xml, () => {}, id => removed.push(id)));
  root.querySelector('button').click();
  expect(confirm).toHaveBeenCalledWith('¿Estás seguro de que quieres eliminar este elemento?');
  expect(removed).toEqual([]);
});
