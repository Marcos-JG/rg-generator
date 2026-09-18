import { useConfigStore } from '../../stores/configStore';
import Input from '../shared/Input';

const FONTS = [
  ['Arial, Helvetica, sans-serif', 'Arial'], ['Helvetica, Arial, sans-serif', 'Helvetica'],
  ['Verdana, Geneva, sans-serif', 'Verdana'], ['Tahoma, sans-serif', 'Tahoma'],
  ['Trebuchet MS, sans-serif', 'Trebuchet MS'], ['Segoe UI, sans-serif', 'Segoe UI'],
  ['Calibri, Arial, sans-serif', 'Calibri'], ['Georgia, serif', 'Georgia'],
  ['Times New Roman, Times, serif', 'Times New Roman'], ['Garamond, serif', 'Garamond'],
  ['Courier New, Courier, monospace', 'Courier New'], ['Consolas, monospace', 'Consolas'],
];

function DesignNumber({ label, name, style, update, min, max, step = 1, unit = '' }) {
  return <div className="space-y-1"><label htmlFor={name} className="text-xs text-gray-600">{label}{unit ? ` (${unit})` : ''}</label><input id={name} type="number" min={min} max={max} step={step} placeholder="Original" className="w-full px-2 py-1" value={style[name] ? parseFloat(style[name]) : ''} onChange={e => update({ [name]: e.target.value === '' ? '' : `${Math.max(min, Math.min(max, Number(e.target.value)))}${unit}` })} /></div>;
}

function DesignSelect({ label, name, style, update, options }) {
  return <div className="space-y-1"><label htmlFor={name} className="text-xs text-gray-600">{label}</label><select id={name} className="w-full px-2 py-1" value={style[name] || ''} onChange={e => update({ [name]: e.target.value })}><option value="">Original</option>{options.map(([value, title]) => <option key={value} value={value}>{title}</option>)}</select></div>;
}

function DesignColor({ label, name, style, update, fallback }) {
  return <div className="space-y-1"><label htmlFor={name} className="text-xs text-gray-600">{label}</label><div className="flex items-center gap-2"><input id={name} type="color" value={style[name] || fallback} onChange={e => update({ [name]: e.target.value })} className="w-8 h-8 cursor-pointer" /><span className="text-xs">{style[name] || 'Original'}</span><button aria-label={`Restablecer ${label}`} className="ml-auto text-xs text-blue-600 cursor-pointer" onClick={() => update({ [name]: '' })}>Restablecer</button></div></div>;
}

export default function StyleConfig() {
  const { userStyle, updateUserStyle, resetStyle } = useConfigStore();

  return (
    <div className="space-y-3">
      <div className="space-y-1">
        <label htmlFor="documentPageSize" className="text-xs font-medium text-gray-700">Tamaño de la hoja</label>
        <select id="documentPageSize" className="w-full px-3 py-2" value={(userStyle.pageSize as string) || 'carta'} onChange={e => updateUserStyle({ pageSize: e.target.value })}>
          <option value="carta">Carta — 8.5 × 11 pulgadas</option>
          <option value="oficio">Oficio — 8.5 × 13 pulgadas</option>
        </select>
      </div>
      <details className="format-options inspector-design-section">
        <summary>Colores del documento</summary>
      <div className="grid grid-cols-2 gap-2">
        <div>
          <label className="text-xs text-gray-600">Color Primario</label>
          <div className="flex gap-1 items-center">
            <input
              type="color"
              value={userStyle.colorPrimary}
              onChange={(e) => updateUserStyle({ colorPrimary: e.target.value })}
              className="w-8 h-8 rounded cursor-pointer border-0"
            />
            <span className="text-xs font-mono">{userStyle.colorPrimary}</span>
          </div>
        </div>

        <div>
          <label className="text-xs text-gray-600">Color Fuente</label>
          <div className="flex gap-1 items-center">
            <input
              type="color"
              value={userStyle.colorFont}
              onChange={(e) => updateUserStyle({ colorFont: e.target.value })}
              className="w-8 h-8 rounded cursor-pointer border-0"
            />
            <span className="text-xs font-mono">{userStyle.colorFont}</span>
          </div>
        </div>

        <div>
          <label className="text-xs text-gray-600">Color Borde</label>
          <div className="flex gap-1 items-center">
            <input
              type="color"
              value={userStyle.colorBorder}
              onChange={(e) => updateUserStyle({ colorBorder: e.target.value })}
              className="w-8 h-8 rounded cursor-pointer border-0"
            />
            <span className="text-xs font-mono">{userStyle.colorBorder}</span>
          </div>
        </div>

        <div>
          <label className="text-xs text-gray-600">Fondo de totales</label>
          <div className="flex gap-1 items-center">
            <input
              type="color"
              value={userStyle.colorTotalesBg}
              onChange={(e) => updateUserStyle({ colorTotalesBg: e.target.value })}
              className="w-8 h-8 rounded cursor-pointer border-0"
            />
            <span className="text-xs font-mono">{userStyle.colorTotalesBg}</span>
          </div>
        </div>

        <div>
          <label className="text-xs text-gray-600">Fondo del total a pagar</label>
          <div className="flex gap-1 items-center">
            <input
              type="color"
              value={userStyle.colorTotalPagarBg}
              onChange={(e) => updateUserStyle({ colorTotalPagarBg: e.target.value })}
              className="w-8 h-8 rounded cursor-pointer border-0"
            />
            <span className="text-xs font-mono">{userStyle.colorTotalPagarBg}</span>
          </div>
        </div>
      </div>
      </details>
      <details className="format-options inspector-design-section" open>
        <summary>Fuente y texto</summary>
        <div className="space-y-3">
      <Input
        label="Tamaño de Fuente"
        id="fontSize"
        value={userStyle.fontSize}
        onChange={(v) => updateUserStyle({ fontSize: v, designFontSize: v })}
        placeholder="7pt"
      />

      <div className="flex flex-col gap-1">
        <label htmlFor="fontFamily" className="text-xs font-medium text-gray-700">Fuente</label>
        <select id="fontFamily" value={userStyle.fontFamily as string} onChange={e => updateUserStyle({ fontFamily: e.target.value, designFontFamily: e.target.value })} className="w-full px-3 py-2 border rounded">
          {!FONTS.some(([value]) => value === userStyle.fontFamily) && <option value={userStyle.fontFamily as string}>{userStyle.fontFamily}</option>}
          {FONTS.map(([value, label]) => <option key={value} value={value}>{label}</option>)}
        </select>
      </div>

      <details className="format-options">
        <summary>Más opciones de texto</summary>
        <DesignNumber label="Interlineado" name="designLineHeight" style={userStyle} update={updateUserStyle} min={0.5} max={4} step={0.1} />
        <DesignNumber label="Espacio entre letras" name="designLetterSpacing" style={userStyle} update={updateUserStyle} min={-3} max={10} step={0.1} unit="px" />
      </details>
        </div>
      </details>
      <details className="format-options inspector-design-section">
        <summary>Tablas y celdas</summary>
        <Input label="Esquinas redondeadas" id="borderRadius" value={userStyle.borderRadius} onChange={v => updateUserStyle({ borderRadius: v, designRadius: v })} placeholder="6px" />
        <DesignNumber label="Relleno de celdas" name="designCellPadding" style={userStyle} update={updateUserStyle} min={0} max={24} unit="px" />
        <DesignNumber label="Grosor de bordes" name="designBorderWidth" style={userStyle} update={updateUserStyle} min={0} max={8} unit="px" />
        <DesignSelect label="Estilo de bordes" name="designBorderStyle" style={userStyle} update={updateUserStyle} options={[[ 'solid', 'Continuo'], ['dashed', 'Discontinuo'], ['dotted', 'Punteado'], ['double', 'Doble'], ['none', 'Sin borde']]} />
        <DesignSelect label="Unión de bordes" name="designBorderCollapse" style={userStyle} update={updateUserStyle} options={[[ 'collapse', 'Unidos'], ['separate', 'Separados']]} />
        <DesignNumber label="Espacio entre celdas (bordes separados)" name="designBorderSpacing" style={userStyle} update={updateUserStyle} min={0} max={20} unit="px" />
        <DesignColor label="Texto del encabezado de ítems" name="designHeaderText" style={userStyle} update={updateUserStyle} fallback="#ffffff" />
        <DesignColor label="Filas alternas en ítems" name="designStripeColor" style={userStyle} update={updateUserStyle} fallback="#f1f5f9" />
      </details>
      <details className="format-options inspector-design-section">
        <summary>Fondo del documento</summary>
        <DesignColor label="Color de fondo" name="designBackground" style={userStyle} update={updateUserStyle} fallback="#ffffff" />
      </details>
      <p className="inspector-help">Para editar un solo elemento, selecciónalo en la vista previa.</p>
      <button
        onClick={resetStyle}
        className="text-xs text-blue-600 hover:underline cursor-pointer"
      >
        Restablecer estilos por defecto
      </button>
    </div>
  );
}
