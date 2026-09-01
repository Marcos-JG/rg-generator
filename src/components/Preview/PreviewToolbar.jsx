export default function StylePanel({ selected, overrides, updateStyle, onClose, resetStyle }) {
  const ov = overrides[selected] || {};
  const sectionOv = selected ? overrides[selected.replace(/^(section-|)/, (m) => m ? '' : 'section-')] || {} : {};
  const hasOverrides = Object.keys(ov).length > 0 || Object.keys(sectionOv).length > 0;
  return (
    <aside className="fixed left-0 top-0 bottom-0 z-50 w-72 bg-white shadow-xl border-r flex flex-col">
      <div className="flex items-center justify-between p-3 border-b bg-gray-50">
        <span className="text-xs font-bold text-blue-600 uppercase truncate">{selected}</span>
        <button onClick={onClose} className="text-gray-400 hover:text-red-500 text-sm cursor-pointer">✕</button>
      </div>
      <div className="flex-1 overflow-y-auto p-3 space-y-3 text-xs">
        <Row label="Color">
          <input type="color" value={ov.color || '#333333'} onChange={(e) => updateStyle('color', e.target.value)} className="w-6 h-6 cursor-pointer border-0" />
          <span className="font-mono text-gray-400">{ov.color || '-'}</span>
        </Row>
        <Row label="Fondo">
          <input type="color" value={ov.backgroundColor || '#ffffff'} onChange={(e) => updateStyle('backgroundColor', e.target.value)} className="w-6 h-6 cursor-pointer border-0" />
        </Row>
        <Row label="Fuente">
          <input type="range" min="8" max="24" value={parseInt(ov.fontSize) || 12} onChange={(e) => updateStyle('fontSize', e.target.value + 'px')} className="flex-1" />
          <span className="w-10 text-right">{ov.fontSize || 'auto'}</span>
        </Row>
        <Row label="Grosor">
          <select value={ov.fontWeight || 'normal'} onChange={(e) => updateStyle('fontWeight', e.target.value)} className="flex-1 border rounded px-2 py-1">
            <option value="normal">Normal</option>
            <option value="bold">Negrita</option>
            <option value="300">Light</option>
            <option value="600">Semi-bold</option>
          </select>
        </Row>
        <Row label="Padding">
          <input type="text" value={ov.padding || ''} onChange={(e) => updateStyle('padding', e.target.value)} className="flex-1 border rounded px-2 py-1" placeholder="8px" />
        </Row>
        <Row label="Borde">
          <input type="text" value={ov.borderRadius || ''} onChange={(e) => updateStyle('borderRadius', e.target.value)} className="flex-1 border rounded px-2 py-1" placeholder="6px" />
        </Row>
        <Row label="Alineación">
          <div className="flex gap-1">
            {['left', 'center', 'right'].map(a => (
              <button key={a} onClick={() => {
                updateStyle('textAlign', a);
                updateStyle('justifyContent', a === 'left' ? 'flex-start' : a === 'right' ? 'flex-end' : 'center');
              }}
                className={`px-2 py-1 rounded text-[10px] border cursor-pointer ${ov.textAlign === a ? 'bg-blue-100 border-blue-400 text-blue-700' : 'border-gray-200 text-gray-500 hover:bg-gray-50'}`}>
                {a === 'left' ? 'Izq' : a === 'center' ? 'Centro' : 'Der'}
              </button>
            ))}
          </div>
        </Row>
        <Row label="Ancho">
          <input type="text" value={ov.width || ''} onChange={(e) => updateStyle('width', e.target.value)} className="flex-1 border rounded px-2 py-1" placeholder="100%" />
        </Row>
        <Row label="Alto">
          <input type="text" value={ov.height || ''} onChange={(e) => updateStyle('height', e.target.value)} className="flex-1 border rounded px-2 py-1" placeholder="auto" />
        </Row>
        <Row label="Margen Sup">
          <input type="text" value={ov.marginTop || ''} onChange={(e) => updateStyle('marginTop', e.target.value)} className="flex-1 border rounded px-2 py-1" placeholder="0px" />
        </Row>
        <Row label="Margen Inf">
          <input type="text" value={ov.marginBottom || ''} onChange={(e) => updateStyle('marginBottom', e.target.value)} className="flex-1 border rounded px-2 py-1" placeholder="0px" />
        </Row>
      </div>
      <p className="text-[10px] text-gray-400 p-3 border-t">Doble clic para editar texto inline</p>
      {hasOverrides && (
        <button onClick={resetStyle} className="m-3 mb-4 px-3 py-2 bg-red-50 text-red-600 text-xs font-medium rounded border border-red-200 hover:bg-red-100 cursor-pointer">
          Restablecer tamaño original
        </button>
      )}
    </aside>
  );
}

function Row({ label, children }) {
  return <div className="flex flex-col gap-1"><label className="text-gray-500">{label}</label><div className="flex items-center gap-2">{children}</div></div>;
}
