import { useMemo } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { generateXslt } from '../../core/xsltGenerator';
import { transformXmlToHtml } from '../../core/xmlTransformer';
import { extractXmlData } from '../../core/xmlParser';
import { baseTemplate as template } from '../../generated/templates';
import { bundleXslt } from '../../core/referenceXslt';

export default function PreviewFrame() {
  const { xmlString, currentConfig, userStyle } = useConfigStore();

  const htmlContent = useMemo(() => {
    if (!xmlString || !currentConfig) return null;

    try {
      const baseTemplate = template;

      let xmlData = null;
      try {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(xmlString, 'text/xml');
        if (!xmlDoc.querySelector('parsererror')) xmlData = extractXmlData(xmlDoc);
      } catch (e) { /* ignore */ }
      const xslt = generateXslt(baseTemplate, currentConfig, userStyle, xmlData);
      return transformXmlToHtml(xmlString, bundleXslt(xslt));
    } catch (err) {
      return `<div style="color:red;padding:20px;"><h3>Error generando preview</h3><pre>${err.message}</pre></div>`;
    }
  }, [xmlString, currentConfig, userStyle]);

  if (!htmlContent) {
    return (
      <div className="h-full flex items-center justify-center text-gray-400">
        <p>Sube un XML para ver el preview</p>
      </div>
    );
  }

  return (
    <iframe
      srcDoc={htmlContent}
      sandbox="allow-same-origin"
      className="w-full h-full border-0 bg-white"
      title="Preview del RG"
    />
  );
}
