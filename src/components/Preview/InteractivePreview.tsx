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
import { documentCss } from '../../core/documentCss';
import { appendXmlFieldsHtml, xmlValue } from '../../core/xmlFields';
import useXmlFieldDrop from './useXmlFieldDrop';
import { normalizeXmlSource } from '../../core/xmlSource';

export default function InteractivePreview() {
  const { xmlString, currentConfig, userStyle, customXslt, docTitle, overrides, setOverrides, textOverrides, positions, setPosition, xmlFields = [] } = useConfigStore();
  const canUndo = useHistoryStore((s) => s.past.length > 0);
  const canRedo = useHistoryStore((s) => s.future.length > 0);
  const [renderKey, setRenderKey] = useState(0);
  const [moveMode, setMoveMode] = useState('elements');
  const containerRef = useRef(null);

  const active = Boolean(xmlString && currentConfig && !customXslt);
  useXmlFieldDrop(containerRef, active);

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
    return <div className="studio-empty"><div className="empty-paper" aria-hidden="true"><svg viewBox="0 0 64 80" fill="none"><rect x="1" y="1" width="62" height="78" rx="7" stroke="currentColor"/><path d="M16 23h32M16 32h23M16 48h32M16 57h32" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/></svg></div><span className="empty-eyebrow">TU ESPACIO CREATIVO</span><h2>Cada detalle, a tu manera.</h2><p>Abre el menú ☰ y elige Documento para importar un XML.<br/>Después, mueve, ajusta y da forma a tus ideas.</p><div className="empty-features"><span>Edición libre</span><span>Guardado local</span><span>Exportación</span></div></div>;
  }

  let xmlData = null;
  let xmlDoc = null;
  try {
    const parser = new DOMParser();
    xmlDoc = parser.parseFromString(normalizeXmlSource(xmlString), 'text/xml');
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
    html = appendXmlFieldsHtml(html, xmlFields, xpath => xmlDoc ? xmlValue(xmlDoc, xpath) : '', { overrides, textOverrides });
    html = editableHtml(html, textOverrides, positions);
  }

  return (
    <div className="studio-canvas h-full overflow-auto p-4 relative">
      {active && <div className="studio-canvas-toolbar flex items-center gap-1 text-xs" role="toolbar" aria-label="Herramientas del lienzo">
        <label className="canvas-mode">
          <span className="sr-only">Arrastrar</span>
          <select aria-label="Modo de movimiento" className="rounded border bg-white px-2 py-2" value={moveMode} onChange={e => { setMoveMode(e.target.value); setSelected(''); }}>
            <option value="elements">Campos libremente</option>
            <option value="blocks">Bloques completos</option>
            <option value="reorder">Reordenar filas</option>
          </select>
        </label>
        <span className="canvas-toolbar-divider" aria-hidden="true" />
        <button className="canvas-icon-button" title="Deshacer" aria-label="Deshacer" disabled={!canUndo} onClick={applyUndo}>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 7 4 12l5 5M5 12h8a6 6 0 0 1 6 6"/></svg>
        </button>
        <button className="canvas-icon-button" title="Rehacer" aria-label="Rehacer" disabled={!canRedo} onClick={applyRedo}>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m15 7 5 5-5 5m4-5h-8a6 6 0 0 0-6 6"/></svg>
        </button>
        {selected && positions[selected] && <button className="canvas-icon-button" title="Restablecer posición" aria-label="Restablecer posición" onClick={() => setPosition(selected, { x: 0, y: 0, z: positions[selected].z })}>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 4v6h6M5.5 15a7 7 0 1 0 .2-6.2L4 10"/></svg>
        </button>}
        <span className="canvas-saved" title="Los cambios se guardan automáticamente" aria-label="Guardado automático activo" />
      </div>}
      <style>{`
        ${documentCss('[data-preview-content]')}
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
        style={{ width: '8.5in', minHeight: '11in', height: 'auto', margin: '0 auto', padding: '0.25in', boxSizing: 'border-box', position: 'relative', overflow: 'visible', cursor: 'default' }}
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
