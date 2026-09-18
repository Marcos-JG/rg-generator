import { useConfigStore } from '../../stores/configStore';

export default function DocInfo() {
  const metadata = useConfigStore((s) => s.metadata);
  const currentConfig = useConfigStore((s) => s.currentConfig);
  const docTitle = useConfigStore((s) => s.docTitle);
  const setDocTitle = useConfigStore((s) => s.setDocTitle);

  if (!metadata) return null;

  return (
    <div className="bg-gray-50 border border-gray-200 rounded-lg p-3 space-y-1">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-2">
        Documento Detectado
      </h3>
      <div className="grid grid-cols-2 gap-1 text-xs">
        <span className="text-gray-500">País:</span>
        <span className="font-medium">{metadata.countryName} ({metadata.country})</span>

        <span className="text-gray-500">Tipo:</span>
        <span className="font-medium">{metadata.docTypeName}</span>

        <span className="text-gray-500">NIT Emisor:</span>
        <span className="font-medium">{metadata.seller?.nit || 'N/A'}</span>

        <span className="text-gray-500">Ambiente:</span>
        <span className="font-medium">{metadata.ambient === '00' ? 'PRUEBAS' : 'PRODUCCIÓN'}</span>

        <span className="text-gray-500">Ítems:</span>
        <span className="font-medium">{metadata.itemCount}</span>

        <span className="text-gray-500">Moneda:</span>
        <span className="font-medium">{metadata.currency || 'N/A'}</span>
      </div>

      {currentConfig && (
        <div className="mt-2 pt-2 border-t border-gray-200">
          <label className="text-xs text-gray-500 block mb-1">Título del Documento</label>
          <input
            type="text"
            value={docTitle || ''}
            onChange={(e) => setDocTitle(e.target.value || null)}
            placeholder={currentConfig.title}
            className="w-full text-xs border border-gray-300 rounded px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-blue-400"
          />
          <p className="text-[10px] text-gray-400 mt-1">Dejar vacío para usar: {currentConfig.title}</p>
        </div>
      )}
    </div>
  );
}
