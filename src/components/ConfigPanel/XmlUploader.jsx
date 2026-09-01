import { useState } from 'react';
import Dropzone from '../shared/Dropzone';
import { useConfigStore } from '../../stores/configStore';
import { parseXmlFile } from '../../core/xmlParser';
import { getConfig } from '../../configs';

export default function XmlUploader() {
  const { setXmlString, setMetadata, setCurrentConfig, customXslt, customXsltName, setCustomXslt } = useConfigStore();
  const [mode, setMode] = useState('xml');

  const handleXmlLoaded = (content, fileName) => {
    try {
      const { doc, metadata } = parseXmlFile(content);

      if (!metadata.country || !metadata.docTypeName) {
        alert('No se pudo detectar el país o tipo de documento del XML.');
        return;
      }

      const config = getConfig(metadata.country, metadata.docType);
      if (!config) {
        alert(`Este tipo de documento (${metadata.docTypeName}) no está configurado todavía para ${metadata.countryName}.`);
        return;
      }

      setXmlString(content);
      setMetadata(metadata);
      setCurrentConfig(config);
    } catch (err) {
      alert('Error al parsear el XML: ' + err.message);
    }
  };

  const handleXsltLoaded = (content, fileName) => {
    setCustomXslt(content, fileName);
  };

  const handleRemoveXslt = () => {
    setCustomXslt(null, null);
  };

  return (
    <div className="space-y-3">
      <div className="flex gap-1 bg-gray-100 rounded-lg p-1">
        <button
          onClick={() => setMode('xml')}
          className={`flex-1 text-xs py-1.5 rounded-md font-medium transition-colors cursor-pointer ${
            mode === 'xml' ? 'bg-white shadow text-blue-600' : 'text-gray-500 hover:text-gray-700'
          }`}
        >
          XML
        </button>
        <button
          onClick={() => setMode('xslt')}
          className={`flex-1 text-xs py-1.5 rounded-md font-medium transition-colors cursor-pointer ${
            mode === 'xslt' ? 'bg-white shadow text-blue-600' : 'text-gray-500 hover:text-gray-700'
          }`}
        >
          XSLT Propio
        </button>
      </div>

      {mode === 'xml' ? (
        <div>
          <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
            XML de Ejemplo
          </h3>
          <Dropzone onFileLoaded={handleXmlLoaded} />
        </div>
      ) : (
        <div>
          <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
            XSLT Personalizado
          </h3>
          <p className="text-xs text-gray-500 mb-2">
            Subí tu propio archivo .xsl o .xslt para usarlo en lugar del generado automáticamente.
          </p>

          {customXslt ? (
            <div className="space-y-2">
              <div className="flex items-center gap-2 p-2 bg-green-50 border border-green-200 rounded-lg">
                <svg className="w-5 h-5 text-green-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
                <span className="text-sm text-green-700 flex-1 truncate">{customXsltName}</span>
                <button
                  onClick={handleRemoveXslt}
                  className="text-green-500 hover:text-red-500 text-xs cursor-pointer shrink-0"
                >
                  Quitar
                </button>
              </div>

              <div className="p-2 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-700 leading-relaxed">
                <p className="font-medium mb-1">XSLT externo activo</p>
                <p>El preview muestra tu XSLT tal cual. Los controles visuales (colores, layout, campos) no aplican sobre XSLT externo.</p>
                <p className="mt-1">Para editar visualmente, quitá este XSLT y usá el generador normal.</p>
              </div>
            </div>
          ) : (
            <Dropzone onFileLoaded={handleXsltLoaded} accept=".xsl,.xslt" />
          )}
        </div>
      )}
    </div>
  );
}
