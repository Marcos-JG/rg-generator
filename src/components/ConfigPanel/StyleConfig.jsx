import { useConfigStore } from '../../stores/configStore';
import Input from '../shared/Input';

export default function StyleConfig() {
  const { userStyle, updateUserStyle, resetStyle } = useConfigStore();

  return (
    <div className="space-y-3">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Estilo Visual
      </h3>

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
          <label className="text-xs text-gray-600">Bg Totales</label>
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
          <label className="text-xs text-gray-600">Bg Total Pagar</label>
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

      <Input
        label="Tamaño de Fuente"
        id="fontSize"
        value={userStyle.fontSize}
        onChange={(v) => updateUserStyle({ fontSize: v })}
        placeholder="7pt"
      />

      <Input
        label="Fuente"
        id="fontFamily"
        value={userStyle.fontFamily}
        onChange={(v) => updateUserStyle({ fontFamily: v })}
        placeholder="Arial, Helvetica, sans-serif"
      />

      <Input
        label="Radio de Borde"
        id="borderRadius"
        value={userStyle.borderRadius}
        onChange={(v) => updateUserStyle({ borderRadius: v })}
        placeholder="6px"
      />

      <button
        onClick={resetStyle}
        className="text-xs text-blue-600 hover:underline cursor-pointer"
      >
        Restablecer estilos por defecto
      </button>
    </div>
  );
}
