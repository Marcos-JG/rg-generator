import { useEffect, useMemo, useRef, useState } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { renderImportedXslt } from '../../core/importedXslt';
import { applySelection, cleanPreviewHtml } from '../../core/editableHtml';
import useFreeMove from './useFreeMove';
import StylePanel from './PreviewToolbar';

export function importedSnapshot() {
  const doc = document.querySelector('[data-imported-preview]')?.contentDocument;
  if (!doc?.body) return null;
  const head = doc.head.cloneNode(true);
  head.querySelectorAll('[data-import-editor], script').forEach(node => node.remove());
  return `<!DOCTYPE html><html><head>${head.innerHTML}</head><body>${cleanPreviewHtml(doc.body)}</body></html>`;
}

export default function ImportedPreview() {
  const { xmlString, customXslt, customXsltName, customXsltFiles, overrides, positions, textOverrides,
    setOverrides, setText, undo, redo } = useConfigStore();
  const page = useRef(null);
  const [ready, setReady] = useState(0);
  const [selected, setSelected] = useState('');
  const [height, setHeight] = useState(1056);
  const result = useMemo(() => {
    try { return { html: renderImportedXslt(xmlString, customXslt, { overrides, positions, textOverrides }, customXsltFiles) }; }
    catch (error) { return { error: error.message }; }
  }, [xmlString, customXslt, customXsltFiles, overrides, positions, textOverrides]);
  useFreeMove(page, Boolean(ready && !result.error), 'elements', setSelected, ready);
  useEffect(() => {
    if (!page.current || result.error) return;
    applySelection(page.current, { selected });
  }, [ready, selected, result]);
  useEffect(() => { setSelected(''); }, [customXslt]);
  const loaded = event => {
    const doc = event.currentTarget.contentDocument;
    if (!doc?.body) return;
    page.current = doc.body;
    doc.body.setAttribute('data-move-mode', 'elements');
    const style = doc.createElement('style');
    style.setAttribute('data-import-editor', 'true');
    style.textContent = 'body{position:relative;min-height:11in} [data-rg-id]{cursor:move;touch-action:none} .rg-sel{outline:2px solid #3b82f6!important;outline-offset:-2px} [contenteditable=true]{cursor:text;outline:2px solid #22c55e}';
    doc.head.appendChild(style);
    doc.body.addEventListener('dblclick', e => {
      const label = e.target.closest('[data-rg-text]');
      if (!label) return;
      const original = label.textContent;
      label.contentEditable = 'true';
      label.focus();
      let cancelled = false;
      const key = e => {
        e.stopPropagation();
        if (e.key === 'Escape') { cancelled = true; e.preventDefault(); label.blur(); }
        if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); label.blur(); }
      };
      label.addEventListener('keydown', key);
      label.addEventListener('blur', () => {
        label.removeEventListener('keydown', key);
        label.removeAttribute('contenteditable');
        if (cancelled) label.textContent = original;
        else if (label.textContent !== original) setText(label.dataset.rgText, label.textContent);
      }, { once: true });
    });
    doc.defaultView.addEventListener('keydown', e => {
      if (e.target.closest('input, textarea, [contenteditable=true]')) return;
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'z') {
        e.preventDefault(); if (e.shiftKey) redo(); else undo();
      }
    });
    const measure = () => setHeight(Math.max(1056, doc.body.scrollHeight, doc.documentElement.scrollHeight));
    doc.querySelectorAll('img').forEach(img => img.addEventListener('load', measure, { once: true }));
    measure();
    setReady(value => value + 1);
  };
  return <div className="studio-canvas h-full overflow-auto p-4 relative">
    <div className="studio-canvas-toolbar flex items-center gap-2 text-xs">
      <span className="truncate">{customXsltName}</span>
      <button onClick={undo}>Deshacer</button><button onClick={redo}>Rehacer</button>
      <span>Arrastra para mover · Doble clic para editar etiquetas</span>
    </div>
    {result.error ? <div role="alert" className="p-4 bg-red-50 text-red-700">{result.error}</div> :
      <iframe title="Editor del XSLT importado" data-imported-preview sandbox="allow-same-origin"
        srcDoc={result.html} onLoad={loaded} className="bg-white shadow-lg"
        style={{ display: 'block', width: '8.5in', height, border: 0, margin: '0 auto' }} />}
    {selected && !result.error && <StylePanel selected={selected} overrides={overrides}
      updateStyle={(property, value) => setOverrides(prev => ({ ...prev, [selected]: {
        ...prev[selected], ...(typeof property === 'object' ? property : { [property]: value }),
      } }))} onClose={() => setSelected('')} resetStyle={() => setOverrides(prev => {
        const next = { ...prev }; delete next[selected]; return next;
      })} />}
  </div>;
}
