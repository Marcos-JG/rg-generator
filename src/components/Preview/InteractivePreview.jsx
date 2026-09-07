import { useState, useRef, useLayoutEffect, useMemo } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { useHistoryStore } from '../../stores/historyStore';
import { extractXmlData } from '../../core/xmlParser';
import useSelection from './useSelection';
import useFieldDrag from './useFieldDrag';
import useFreeMove from './useFreeMove';
import useResize from './useResize';
import useColumnResize from './useColumnResize';
import { buildPreviewHtml } from './buildPreviewHtml';
import StylePanel from './PreviewToolbar';
import { editableHtml, applySelection } from '../../core/editableHtml';

export default function InteractivePreview() {
  const { xmlString, currentConfig, userStyle, customXslt, docTitle, overrides, setOverrides, textOverrides, positions, setPosition } = useConfigStore();
  const canUndo = useHistoryStore((s) => s.past.length > 0);
  const canRedo = useHistoryStore((s) => s.future.length > 0);
  const [renderKey, setRenderKey] = useState(0);
  const [moveMode, setMoveMode] = useState('elements');
  const containerRef = useRef(null);

  const active = Boolean(xmlString && currentConfig && !customXslt);

  useFieldDrag(containerRef, renderKey, setRenderKey, active && moveMode === 'reorder');
  useResize(containerRef, overrides, setOverrides, renderKey, setRenderKey, active);
  useColumnResize(containerRef, setOverrides, renderKey, setRenderKey, active);

  const {
    hovered, selected, setSelected,
    onClick, onDblClick, onMouseOver, onMouseOut,
    updateStyle, applyUndo, applyRedo,
  } = useSelection(containerRef, overrides, setOverrides, renderKey, setRenderKey);
  useFreeMove(containerRef, active, moveMode, setSelected);
  useLayoutEffect(() => {
    if (containerRef.current && active) applySelection(containerRef.current, { selected, hovered });
  });

  const handleContainerClick = (e) => {
    onClick(e);
  };

  if (!xmlString || !currentConfig) {
    return <div className="h-full flex items-center justify-center text-gray-400"><p>Sube un XML para ver el preview</p></div>;
  }

  let xmlData = null;
  let xmlDoc = null;
  try {
    const parser = new DOMParser();
    xmlDoc = parser.parseFromString(xmlString, 'text/xml');
    if (!xmlDoc.querySelector('parsererror')) {
      xmlData = extractXmlData(xmlDoc);
    }
  } catch (e) { /* ignore */ }

  let html;
  let xsltError = null;

  if (customXslt && xmlDoc) {
    try {
      const xsltParser = new DOMParser();
      const xsltDoc = xsltParser.parseFromString(customXslt, 'text/xml');
      const xsltErrorNode = xsltDoc.querySelector('parsererror');
      if (xsltErrorNode) {
        xsltError = 'Error al parsear el XSLT: ' + xsltErrorNode.textContent.substring(0, 100);
      } else {
        const processor = new XSLTProcessor();
        processor.importStylesheet(xsltDoc);
        const resultDoc = processor.transformToDocument(xmlDoc);
        const serializer = new XMLSerializer();
        html = serializer.serializeToString(resultDoc);
      }
    } catch (e) {
      xsltError = 'Error al transformar con XSLT: ' + e.message;
    }
  }

  if (!html) {
    html = buildPreviewHtml({
      currentConfig, userStyle, xmlData, overrides, docTitle,
    });
    html = editableHtml(html, textOverrides, positions);
  }

  return (
    <div className="h-full overflow-auto bg-gray-100 p-4 relative">
      {active && <div className="mb-3 flex flex-wrap items-center gap-2 text-xs">
        <label className="flex items-center gap-2">Arrastrar
          <select aria-label="Modo de movimiento" className="rounded border bg-white px-2 py-2" value={moveMode} onChange={e => { setMoveMode(e.target.value); setSelected(''); }}>
            <option value="elements">Campos libremente</option>
            <option value="blocks">Bloques completos</option>
            <option value="reorder">Reordenar filas</option>
          </select>
        </label>
        <button className="rounded border bg-white px-3 py-2 disabled:opacity-40" disabled={!canUndo} onClick={applyUndo}>Deshacer</button>
        <button className="rounded border bg-white px-3 py-2 disabled:opacity-40" disabled={!canRedo} onClick={applyRedo}>Rehacer</button>
        {selected && positions[selected] && <button className="rounded border bg-white px-3 py-2" onClick={() => setPosition(selected, { x: 0, y: 0, z: positions[selected].z })}>Restablecer posición</button>}
        <span className="text-gray-500">Arrastra para mover · Flechas para ajustar · Esc cancela · Doble clic edita</span>
        <span className="ml-auto text-gray-500">Guardado automático en este navegador</span>
      </div>}
      <style>{`
        [data-preview-content] {
          font-family: Arial, sans-serif;
          font-size: 7pt;
          text-align: left;
          background: white;
        }
        [data-preview-content] table {
          font-family: Arial, sans-serif;
          font-size: 7pt;
          background: white;
        }
        [data-preview-content] td {
          vertical-align: top;
          border-color: #808080;
          padding-left: 0.02in;
          padding-right: 0.02in;
          padding-top: 0.02in;
          padding-bottom: 0.02in;
        }
        [data-preview-content] .rg-hover { outline: 2px dashed rgba(59,130,246,0.6) !important; outline-offset: -2px; }
        [data-preview-content] .rg-sel { outline: 2px solid #3b82f6 !important; outline-offset: -2px; }
        .col-resize-handle { position:absolute; top:0; right:0; width:6px; height:100%; cursor:col-resize; z-index:10; pointer-events:auto; }
        .col-resize-handle:hover { background:rgba(59,130,246,0.4); }
        [data-preview-content] th { position:relative; }
        [data-preview-content][data-move-mode="elements"] [data-rg-id],
        [data-preview-content][data-move-mode="blocks"] [data-rg-id] { cursor: move; touch-action: none; }
        [data-preview-content] [contenteditable="true"] { cursor: text; }
        [data-preview-content] .field-draggable { cursor: grab; }
        [data-preview-content] .field-draggable:active { cursor: grabbing; }
        [data-preview-content] .field-drop-above { box-shadow: 0 -2px 0 0 #22c55e; }
        [data-preview-content] .field-drop-below { box-shadow: 0 2px 0 0 #22c55e; }
        [data-preview-content] .field-drop-left { box-shadow: -2px 0 0 0 #22c55e; }
        [data-preview-content] .field-drop-right { box-shadow: 2px 0 0 0 #22c55e; }
      `}</style>

      {selected && active && (
        <StylePanel
          selected={selected}
          overrides={overrides}
          updateStyle={updateStyle}
          onClose={() => setSelected('')}
          resetStyle={() => {
            setOverrides((prev) => {
              const next = { ...prev };
              delete next[selected];
              const prefix = selected.replace(/^(section-|)/, (m) => m ? '' : 'section-');
              delete next[prefix];
              return next;
            });
            setRenderKey((k) => k + 1);
          }}
        />
      )}

      {customXslt && (
        <div className="mb-2 px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-700 flex items-center gap-2">
          <svg className="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Usando XSLT personalizado — editá en el generador normal para cambios visuales</span>
        </div>
      )}

      {xsltError && (
        <div className="mb-2 px-3 py-2 bg-red-50 border border-red-200 rounded-lg text-xs text-red-700">
          {xsltError}
        </div>
      )}

      <PreviewContent
        ref={containerRef}
        className="bg-white shadow-lg"
        data-preview-content
        data-move-mode={moveMode}
        style={{ width: '8.5in', height: '11in', margin: '0 auto', padding: '0.25in', boxSizing: 'border-box', position: 'relative', overflow: 'hidden', cursor: 'default' }}
        html={html}
        onClick={handleContainerClick}
        onDoubleClick={onDblClick}
        onMouseOver={onMouseOver}
        onMouseOut={onMouseOut}
      />
    </div>
  );
}

function PreviewContent({ html, ...props }) {
  const content = useMemo(() => ({ __html: html }), [html]);
  return <div {...props} dangerouslySetInnerHTML={content} />;
}
