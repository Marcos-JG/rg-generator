import { useConfigStore } from '../../stores/configStore';

export default function ColumnConfig() {
  const currentConfig = useConfigStore((s) => s.currentConfig);

  if (!currentConfig) return null;

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Columnas de Ítems
      </h3>
      <p className="text-xs text-gray-500">
        {currentConfig.itemColumns.length} columnas configuradas
      </p>
      <ul className="item-column-list" aria-label="Columnas de ítems y sus anchos">
        {currentConfig.itemColumns.map((col) => (
          <li key={col.id} className="item-column-row">
            <span className="item-column-label">{col.label}</span>
            <span className="item-column-width" aria-label={`Ancho: ${col.width}`}>{col.width}</span>
            <span className="item-column-required">{col.required && <span aria-label="Columna obligatoria" title="Columna obligatoria">*</span>}</span>
          </li>
        ))}
      </ul>
      <p className="text-xs text-gray-500">* Columna obligatoria</p>
    </div>
  );
}
