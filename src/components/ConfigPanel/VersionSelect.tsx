import { useConfigStore } from '../../stores/configStore';

const VERSIONS = [
  { value: 'v2-0-0', label: 'v2.0.0 (Actual)' },
];

export default function VersionSelect() {
  const currentConfig = useConfigStore((s) => s.currentConfig);

  if (!currentConfig) return null;

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Versión del Catálogo
      </h3>
      <select
        className="w-full px-3 py-2 border border-gray-300 rounded text-sm bg-white"
        value={currentConfig.version}
        disabled
      >
        {VERSIONS.map((v) => (
          <option key={v.value} value={v.value}>
            {v.label}
          </option>
        ))}
      </select>
      <p className="text-xs text-gray-500">Versión detectada del config: {currentConfig.version}</p>
    </div>
  );
}
