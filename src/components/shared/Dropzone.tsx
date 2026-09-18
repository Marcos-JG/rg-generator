import { useCallback, useId } from 'react';
import { readXmlSource } from '../../core/xmlSource';

export default function Dropzone({ onFileLoaded, accept = '.xml', className = '', text = '' }) {
  const inputId = useId();
  const kind = accept.includes('xsl') ? 'XSLT' : 'XML';
  const handleDrop = useCallback(
    async (e) => {
      e.preventDefault();
      e.stopPropagation();
      const file = e.dataTransfer?.files?.[0] || e.target?.files?.[0];
      if (!file) return;

      try { onFileLoaded(await readXmlSource(file), file.name); }
      catch (error) { alert('No se pudo leer el archivo: ' + error.message); }
    },
    [onFileLoaded]
  );

  const handleDragOver = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  return (
    <div
      onDrop={handleDrop}
      onDragOver={handleDragOver}
      className={`border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-blue-400 transition-colors cursor-pointer ${className}`}
    >
      <input
        type="file"
        accept={accept}
        onChange={handleDrop}
        className="hidden"
        id={inputId}
        aria-label={`Cargar ${kind}`}
      />
      <label htmlFor={inputId} className="cursor-pointer">
        <div className="text-gray-500">
          <svg className="mx-auto h-12 w-12 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
          </svg>
          <p className="text-lg font-medium">{text || `Arrastra un ${kind} aquí`}</p>
          <p className="text-sm mt-1">o haz clic para seleccionar</p>
        </div>
      </label>
    </div>
  );
}
