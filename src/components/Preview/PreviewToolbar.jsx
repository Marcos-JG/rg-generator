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
          <PxInput value={ov.padding} onChange={(v) => updateStyle('padding', v)} />
        </Row>
        <Row label="Separación X (dato)">
          <PxInput value={ov.separationX} onChange={(v) => updateStyle('separationX', v)} placeholders={[0, 4, 8, 12]} />
        </Row>
        <Row label="Separación Arriba">
          <PxInput value={ov.marginTop} onChange={(v) => updateStyle('marginTop', v)} placeholders={[0, 2, 4, 8]} />
        </Row>
        <Row label="Separación Abajo">
          <PxInput value={ov.marginBottom} onChange={(v) => updateStyle('marginBottom', v)} placeholders={[0, 2, 4, 8]} />
        </Row>
        <Row label="Borde (radio)">
          <PxInput value={ov.borderRadius} onChange={(v) => updateStyle('borderRadius', v)} placeholders={[0, 6, 10, 15]} />
        </Row>
        <Row label="Alineación">
          <div className="flex gap-1">
            {['left', 'center', 'right'].map(a => (
              <button key={a} onClick={() => {
                updateStyle({ textAlign: a, justifyContent: a === 'left' ? 'flex-start' : a === 'right' ? 'flex-end' : 'center' });
              }}
                className={`px-2 py-1 rounded text-[10px] border cursor-pointer ${ov.textAlign === a ? 'bg-blue-100 border-blue-400 text-blue-700' : 'border-gray-200 text-gray-500 hover:bg-gray-50'}`}>
                {a === 'left' ? 'Izq' : a === 'center' ? 'Centro' : 'Der'}
              </button>
            ))}
          </div>
        </Row>
        <Row label="Ancho">
          <SizeInput value={ov.width} onChange={(v) => updateStyle('width', v)} allowPercent />
        </Row>
        <Row label="Alto">
          <SizeInput value={ov.height} onChange={(v) => updateStyle('height', v)} />
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
    <div className="flex-1 flex items-center gap-1">
      <input
        type="number"
        value={num}
        min="0"
        step="1"
        onChange={(e) => set(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' && e.target.value === '') set(0);
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

function SizeInput({ value, onChange, allowPercent }) {
  const { num, unit } = parseSize(value);
  const set = (n, u) => {
    const v = u === 'auto' ? 'auto' : `${n}${u}`;
    onChange(n === '' || n == null ? '' : v);
  };
  return (
    <div className="flex-1 flex items-center gap-1">
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
