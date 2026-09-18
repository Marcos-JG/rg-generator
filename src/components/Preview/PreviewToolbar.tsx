import { elementLabel } from '../../core/editorElements';
import { createPortal } from 'react-dom';
import { useConfigStore } from '../../stores/configStore';
import { useEffect, useState } from 'react';

export default function StylePanel({ selected, overrides, updateStyle, onClose, resetStyle }) {
  const field = useConfigStore(s => s.xmlFields.find(item => item.id === selected));
  const label = useConfigStore(s => s.textOverrides[`${selected}:text:0`]);
  const setText = useConfigStore(s => s.setText);
  const ov = overrides[selected] || {};
  const hasOverrides = Object.keys(ov).length > 0;
  const [tab, setTab] = useState('texto');
  useEffect(() => setTab(field?.kind === 'logo' ? 'apariencia' : 'texto'), [selected]);
  return createPortal(
    <aside className="studio-selection-panel fixed z-[80] w-72 flex flex-col" aria-label="Formato del elemento">
      <div className="flex items-center justify-between p-3 border-b bg-gray-50">
        <span className="text-xs font-bold text-blue-600 truncate">{field?.label || elementLabel(selected)}</span>
        <button onClick={onClose} aria-label="Cerrar formato" className="text-gray-400 hover:text-red-500 text-sm cursor-pointer">✕</button>
      </div>
      <nav className="format-tabs" aria-label="Opciones de formato">
        { [['texto', 'Texto'], ['apariencia', 'Aspecto'], ['tamano', 'Tamaño']].map(([id, title]) => <button key={id} aria-pressed={tab === id} onClick={() => setTab(id)}>{title}</button>) }
      </nav>
      <div className="format-panel-body flex-1 overflow-y-auto p-3 space-y-3 text-xs">
        <p className="format-tab-caption">{tab === 'texto' ? 'Fuente, color y alineación del texto.' : tab === 'apariencia' ? 'Fondo, bordes y efectos del elemento.' : 'Medidas y espacio alrededor del elemento.'}</p>
        <div hidden={tab !== 'texto'} className="space-y-3">
        {field && field.kind !== 'logo' && <div className="space-y-2 border-b pb-3">
          <label htmlFor="added-field-label" className="block text-gray-500">Etiqueta del dato</label>
          <input id="added-field-label" className="w-full border rounded px-2 py-1" value={label ?? `${field.label}: `} onChange={e => setText(`${selected}:text:0`, e.target.value)} />
          <p className="text-gray-500">El valor viene del XML. Puedes editar la etiqueta y el formato sin perder esa conexión.</p>
        </div>}
        <Row label="Color">
          <input type="color" value={ov.color || '#333333'} onChange={(e) => updateStyle('color', e.target.value)} className="w-6 h-6 cursor-pointer border-0" />
          <span className="font-mono text-gray-400">{ov.color || '-'}</span>
        </Row>
        </div>
        <div hidden={tab !== 'apariencia'} className="space-y-3">
        <Row label="Fondo">
          <input type="color" value={/^#[0-9a-f]{6}$/i.test(ov.backgroundColor || '') ? ov.backgroundColor : '#ffffff'} onChange={(e) => updateStyle('backgroundColor', e.target.value)} className="w-6 h-6 cursor-pointer border-0" />
        </Row>
        <Row label="Esquinas redondeadas">
          <PxInput value={ov.borderRadius} onChange={(v) => updateStyle('borderRadius', v)} placeholders={[0, 6, 10, 15]} />
        </Row>
        </div>
        <div hidden={tab !== 'texto'} className="space-y-3">
        <Choice label="Fuente" property="fontFamily" ov={ov} updateStyle={updateStyle} options={[
          ['Arial, sans-serif', 'Arial'], ['Helvetica, Arial, sans-serif', 'Helvetica'], ['Verdana, sans-serif', 'Verdana'], ['Georgia, serif', 'Georgia'], ['Times New Roman, serif', 'Times New Roman'], ['Courier New, monospace', 'Courier New'],
        ]} />
        <Row label="Tamaño del texto">
          <input type="range" aria-label="Tamaño de fuente" min="6" max="72" value={parseInt(ov.fontSize) || 12} onChange={(e) => updateStyle('fontSize', e.target.value + 'px')} className="flex-1" />
          <span className="w-10 text-right">{ov.fontSize || 'auto'}</span>
        </Row>
        <Row label="Peso del texto">
          <select value={ov.fontWeight || 'normal'} onChange={(e) => updateStyle('fontWeight', e.target.value)} className="flex-1 border rounded px-2 py-1">
            <option value="normal">Normal</option>
            <option value="bold">Negrita</option>
            <option value="300">Light</option>
            <option value="600">Semi-bold</option>
          </select>
        </Row>
        </div>
        <div hidden={tab !== 'tamano'} className="space-y-3">
        <Row label="Ancho">
          <SizeInput value={ov.width} onChange={(v) => updateStyle('width', v)} allowPercent />
        </Row>
        <Row label="Alto">
          <SizeInput value={ov.height} onChange={(v) => updateStyle('height', v)} />
        </Row>
        <details className="format-options">
        <summary>Espaciado</summary>
        <Row label="Relleno interior">
          <PxInput value={ov.padding} onChange={(v) => updateStyle('padding', v)} />
        </Row>
        <Row label="Espacio entre etiqueta y dato">
          <PxInput value={ov.separationX} onChange={(v) => updateStyle('separationX', v)} placeholders={[0, 4, 8, 12]} />
        </Row>
        <Row label="Margen superior">
          <PxInput value={ov.marginTop} onChange={(v) => updateStyle('marginTop', v)} placeholders={[0, 2, 4, 8]} />
        </Row>
        <Row label="Margen inferior">
          <PxInput value={ov.marginBottom} onChange={(v) => updateStyle('marginBottom', v)} placeholders={[0, 2, 4, 8]} />
        </Row>
        </details>
        </div>
        <div hidden={tab !== 'texto'} className="space-y-3">
        <Row label="Alineación">
          <div className="flex gap-1">
            {['left', 'center', 'right'].map(a => (
              <button key={a} onClick={() => {
                updateStyle({ textAlign: a, justifyContent: a === 'left' ? 'flex-start' : a === 'right' ? 'flex-end' : 'center', alignSelf: a === 'left' ? 'flex-start' : a === 'right' ? 'flex-end' : 'center' });
              }}
                className={`px-2 py-1 rounded text-[10px] border cursor-pointer ${ov.textAlign === a ? 'bg-blue-100 border-blue-400 text-blue-700' : 'border-gray-200 text-gray-500 hover:bg-gray-50'}`}>
                {a === 'left' ? 'Izq' : a === 'center' ? 'Centro' : 'Der'}
              </button>
            ))}
          </div>
        </Row>
        <details className="format-options">
          <summary>Más opciones de texto</summary>
          <Choice label="Estilo de texto" property="fontStyle" ov={ov} updateStyle={updateStyle} options={[[ 'normal', 'Normal'], ['italic', 'Cursiva']]} />
          <Choice label="Decoración" property="textDecoration" ov={ov} updateStyle={updateStyle} options={[['none', 'Sin decoración'], ['underline', 'Subrayado'], ['line-through', 'Tachado']]} />
          <Choice label="Mayúsculas y minúsculas" property="textTransform" ov={ov} updateStyle={updateStyle} options={[['none', 'Original'], ['uppercase', 'MAYÚSCULAS'], ['lowercase', 'minúsculas'], ['capitalize', 'Iniciales en mayúscula']]} />
          <NumberOption label="Interlineado" property="lineHeight" ov={ov} updateStyle={updateStyle} min={0.5} max={4} step={0.1} />
          <NumberOption label="Espacio entre letras (px)" property="letterSpacing" ov={ov} updateStyle={updateStyle} min={-5} max={20} step={0.1} unit="px" />
          <Choice label="Ajuste del texto" property="whiteSpace" ov={ov} updateStyle={updateStyle} options={[['normal', 'Ajustar líneas'], ['nowrap', 'Una sola línea'], ['pre-wrap', 'Conservar saltos y espacios']]} />
        </details>
        </div>
        <div hidden={tab !== 'apariencia'} className="space-y-3">
        <details className="format-options">
          <summary>Bordes y efectos</summary>
          <Choice label="Tipo de borde" property="borderStyle" ov={ov} updateStyle={updateStyle} options={[['none', 'Sin borde'], ['solid', 'Continuo'], ['dashed', 'Discontinuo'], ['dotted', 'Punteado'], ['double', 'Doble']]} />
          <NumberOption label="Grosor del borde (px)" property="borderWidth" ov={ov} updateStyle={updateStyle} min={0} max={20} unit="px" />
          <Row label="Color del borde"><input aria-label="Color del borde" type="color" value={ov.borderColor || '#808080'} onChange={e => updateStyle('borderColor', e.target.value)} /></Row>
          <Choice label="Sombra" property="boxShadow" ov={ov} updateStyle={updateStyle} options={[['none', 'Sin sombra'], ['0 2px 6px #00000026', 'Suave'], ['0 4px 12px #00000040', 'Media'], ['0 8px 20px #00000059', 'Intensa']]} />
          <NumberOption label="Opacidad (0–1)" property="opacity" ov={ov} updateStyle={updateStyle} min={0} max={1} step={0.05} />
          <Row label="Fondo transparente"><button className="border rounded px-2 py-1 cursor-pointer" onClick={() => updateStyle('backgroundColor', 'transparent')}>Quitar fondo</button></Row>
        </details>
        </div>
        <div hidden={tab !== 'tamano'} className="space-y-3">
        <details className="format-options">
          <summary>Espaciado por lado</summary>
          {(['Top', 'Right', 'Bottom', 'Left'] as const).map((side, index) => <Row key={side} label={`Relleno ${['superior', 'derecho', 'inferior', 'izquierdo'][index]}`}><PxInput value={ov[`padding${side}`]} onChange={v => updateStyle(`padding${side}`, v)} /></Row>)}
          <Row label="Margen izquierdo"><PxInput value={ov.marginLeft} onChange={v => updateStyle('marginLeft', v)} /></Row>
          <Row label="Margen derecho"><PxInput value={ov.marginRight} onChange={v => updateStyle('marginRight', v)} /></Row>
        </details>
        </div>
        <div hidden={tab !== 'apariencia'} className="space-y-3">
        <details className="format-options">
          <summary>Alineación e imágenes</summary>
          <Choice label="Alineación vertical en celdas" property="verticalAlign" ov={ov} updateStyle={updateStyle} options={[['top', 'Arriba'], ['middle', 'Centro'], ['bottom', 'Abajo']]} />
          <Choice label="Distribución vertical en bloques flex" property="justifyContent" ov={ov} updateStyle={updateStyle} options={[['flex-start', 'Inicio'], ['center', 'Centro'], ['flex-end', 'Final'], ['space-between', 'Separar elementos']]} />
          <Choice label="Ajuste de imagen" property="objectFit" ov={ov} updateStyle={updateStyle} options={[['contain', 'Imagen completa'], ['cover', 'Rellenar y recortar'], ['fill', 'Estirar'], ['none', 'Tamaño original']]} />
          <Choice label="Posición de imagen" property="objectPosition" ov={ov} updateStyle={updateStyle} options={[['center', 'Centro'], ['left', 'Izquierda'], ['right', 'Derecha'], ['top', 'Arriba'], ['bottom', 'Abajo']]} />
        </details>
        </div>
      </div>
      <p className="text-[10px] text-gray-400 p-3 border-t">Doble clic en una etiqueta para editarla.</p>
      {hasOverrides && (
        <button onClick={resetStyle} className="m-3 mb-4 px-3 py-2 bg-red-50 text-red-600 text-xs font-medium rounded border border-red-200 hover:bg-red-100 cursor-pointer">
          Restablecer formato original
        </button>
      )}
    </aside>,
    document.body
  );
}

function Choice({ label, property, ov, updateStyle, options }) {
  return <Row label={label}><select aria-label={label} className="w-full border rounded px-2 py-1" value={ov[property] || ''} onChange={e => updateStyle(property, e.target.value)}><option value="">Heredar del original</option>{options.map(([value, title]) => <option key={value} value={value}>{title}</option>)}</select></Row>;
}

function NumberOption({ label, property, ov, updateStyle, min, max, step = 1, unit = '' }) {
  return <Row label={label}><input aria-label={label} type="number" className="w-full border rounded px-2 py-1" min={min} max={max} step={step} placeholder="Original" value={ov[property] ? parseFloat(ov[property]) : ''} onChange={e => {
    const value = e.target.value;
    if (!value) updateStyle(property, '');
    else if (Number.isFinite(Number(value))) updateStyle(property, `${Math.min(max, Math.max(min, Number(value)))}${unit}`);
  }} /></Row>;
}

function Row({ label, children }) {
  return <div className="flex flex-col gap-1"><label className="text-gray-500">{label}</label><div className="flex items-center gap-2">{children}</div></div>;
}

function parseSize(v) {
  const m = String(v || '').trim().match(/^(-?[\d.]+)\s*(px|%|pt|em|in|auto)?$/i);
  if (v === 'auto' || String(v).toLowerCase() === 'auto') return { num: '', unit: 'auto' };
  if (!m) return { num: '', unit: 'px' };
  return { num: m[1], unit: (m[2] || 'px').toLowerCase() };
}

function PxInput({ value, onChange, placeholders = [0, 4, 10, 20] }) {
  const { num, unit } = parseSize(value);
  const set = (n) => onChange(n === '' || n == null ? '' : `${n}px`);
  return (
    <div className="flex-1 min-w-0 flex items-center gap-1">
      <input
        type="number"
        value={num}
        min="0"
        step="1"
        onChange={(e) => set(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' && e.currentTarget.value === '') set(0);
        }}
        className="flex-1 min-w-0 border rounded px-2 py-1"
        placeholder="—"
      />
      <span className="text-gray-400 text-[10px]">px</span>
      <div className="flex gap-0.5">
        {placeholders.map((p) => (
          <button
            key={p}
            title={`${p} px`}
            onClick={() => set(p)}
            className={`px-1.5 py-1 rounded text-[10px] border cursor-pointer ${num === String(p) ? 'bg-blue-100 border-blue-400 text-blue-700' : 'border-gray-200 text-gray-500 hover:bg-gray-50'}`}
          >
            {p}
          </button>
        ))}
      </div>
    </div>
  );
}

function SizeInput({ value, onChange, allowPercent = false }) {
  const { num, unit } = parseSize(value);
  const set = (n, u) => {
    const v = u === 'auto' ? 'auto' : `${n}${u}`;
    onChange(n === '' || n == null ? '' : v);
  };
  return (
    <div className="flex-1 min-w-0 flex items-center gap-1">
      <input
        type="number"
        value={num}
        min="0"
        step="1"
        disabled={unit === 'auto'}
        onChange={(e) => set(e.target.value, unit)}
        className="flex-1 min-w-0 border rounded px-2 py-1 disabled:bg-gray-100"
        placeholder="—"
      />
      <select
        value={unit}
        onChange={(e) => set(num || '100', e.target.value)}
        className="border rounded px-1 py-1 text-[10px]"
      >
        <option value="px">px</option>
        {allowPercent && <option value="%">%</option>}
        <option value="auto">auto</option>
      </select>
      <button
        title="Borrar"
        onClick={() => onChange('')}
        className="px-1.5 rounded border border-gray-200 text-gray-400 hover:text-red-500 hover:bg-red-50 cursor-pointer"
      >
        ✕
      </button>
    </div>
  );
}
