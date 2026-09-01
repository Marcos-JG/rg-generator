import { useConfigStore } from '../../stores/configStore';
import Input from '../shared/Input';

export default function ColumnConfig() {
  const currentConfig = useConfigStore((s) => s.currentConfig);

  if (!currentConfig) return null;

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Columnas de Ítems
      </h3>
      <p className="text-xs text-gray-500">
        {currentConfig.itemColumns.length} columnas configuradas (editing coming soon)
      </p>
      <div className="space-y-1">
        {currentConfig.itemColumns.map((col) => (
          <div key={col.id} className="flex items-center gap-2 text-xs">
            <span className="w-16 font-mono text-gray-600">{col.id}</span>
            <span className="flex-1">{col.label}</span>
            <span className="text-gray-400">{col.width}</span>
            {col.required && <span className="text-red-500">*</span>}
          </div>
        ))}
      </div>
    </div>
  );
}
