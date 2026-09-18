import { useLayoutEffect } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { XML_FIELD_MIME, XML_FIELD_TEXT_PREFIX, activeXmlFieldDrag, endXmlFieldDrag, xmlPaletteFields } from '../../core/xmlFields';
import type { XmlField } from '../../types/editor';

export function attachXmlFieldDrop(page: HTMLElement, getXml: () => string, add: (field: XmlField) => void, remove?: (id: string) => void) {
    const doc = page.ownerDocument;
    const inside = (event: DragEvent) => page === doc.body || page.contains(event.target as Node);
    const isField = (event: DragEvent) => Boolean(activeXmlFieldDrag() || Array.from(event.dataTransfer?.types || []).includes(XML_FIELD_MIME));
    const over = (event: DragEvent) => {
      if (!inside(event) || !isField(event)) return;
      event.preventDefault(); event.stopPropagation();
      if (event.dataTransfer) event.dataTransfer.dropEffect = 'copy';
    };
    const drop = (event: DragEvent) => {
      if (!inside(event)) return;
      const text = event.dataTransfer?.getData('text/plain') || '';
      const xpath = event.dataTransfer?.getData(XML_FIELD_MIME) || activeXmlFieldDrag() ||
        (text.startsWith(XML_FIELD_TEXT_PREFIX) ? text.slice(XML_FIELD_TEXT_PREFIX.length) : null);
      if (!xpath) return;
      event.preventDefault(); event.stopPropagation();
      const field = xmlPaletteFields(getXml() || '').find(field => field.xpath === xpath);
      endXmlFieldDrag();
      if (!field) return;
      const box = page.getBoundingClientRect();
      const scale = page.offsetWidth && box.width ? box.width / page.offsetWidth : 1;
      // Absolute positioning is relative to the padding box, including a
      // scrolled iframe and a canvas viewed at a different zoom level.
      const x = Math.max(0, Math.min(Math.max(0, page.clientWidth - 40), (event.clientX - box.left) / scale - page.clientLeft + page.scrollLeft));
      const y = Math.max(0, (event.clientY - box.top) / scale - page.clientTop + page.scrollTop);
      add({ id: `xml-field-${crypto.randomUUID()}`, xpath: field.xpath, label: field.label, x, y, ...(field.kind ? { kind: field.kind } : {}) });
    };
    const click = (event: MouseEvent) => {
      const button = (event.target as Element).closest?.('[data-rg-remove]');
      if (!button || !page.contains(button) || !remove) return;
      event.preventDefault(); event.stopImmediatePropagation(); remove(button.getAttribute('data-rg-remove'));
    };
    doc.addEventListener('dragover', over, true); doc.addEventListener('drop', drop, true); doc.addEventListener('click', click, true);
    return () => { doc.removeEventListener('dragover', over, true); doc.removeEventListener('drop', drop, true); doc.removeEventListener('click', click, true); };
}

export default function useXmlFieldDrop(ref, active: boolean, _documentKey = 0) {
  useLayoutEffect(() => {
    const page: HTMLElement = ref.current;
    if (!page || !active) return;
    return attachXmlFieldDrop(page, () => useConfigStore.getState().xmlString, field => useConfigStore.getState().addXmlField(field), id => useConfigStore.getState().removeXmlField(id));
  });
}
