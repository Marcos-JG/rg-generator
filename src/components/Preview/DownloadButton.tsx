import { useConfigStore } from '../../stores/configStore';
import { generateXslt } from '../../core/xsltGenerator';
import { extractXmlData } from '../../core/xmlParser';
import Button from '../shared/Button';
import { cleanPreviewHtml } from '../../core/editableHtml';
import { baseTemplate } from '../../generated/templates';
import { documentCss } from '../../core/documentCss';
import { isReferenceDocument } from '../../core/referenceXslt';
import { editImportedXslt } from '../../core/importedXslt';
import { importedSnapshot } from './ImportedPreview';
import { normalizeXmlSource } from '../../core/xmlSource';
import { pageSize } from '../../core/pageSize';
import { withPrintFit } from '../../core/printFit';

const BASE_TEMPLATE = baseTemplate;


export default function DownloadButton() {
  const { xmlString, currentConfig, userStyle, metadata, customXslt, customXsltName, customXsltFiles, docTitle, overrides, positions, textOverrides, xmlFields = [] } = useConfigStore();
  const DOCUMENT_RENDER_CSS = documentCss('.dte-page-wrap', userStyle.pageSize);

  const handleDownloadXsl = () => {
    if (!currentConfig) return;

    let xslt;
    let fileName;

    if (customXslt) {
      xslt = editImportedXslt(customXslt, { overrides, positions, textOverrides, xmlFields, visualStyle: userStyle });
      fileName = customXsltName || 'custom.xsl';
    } else {
      let xmlData = null;
      if (xmlString) {
        try {
          const parser = new DOMParser();
          const xmlDoc = parser.parseFromString(xmlString, 'text/xml');
          if (!xmlDoc.querySelector('parsererror')) xmlData = extractXmlData(xmlDoc);
        } catch (e) { /* ignore */ }
      }
      xslt = generateXslt(BASE_TEMPLATE, currentConfig, { ...userStyle, docTitle }, xmlData, { overrides, positions, textOverrides, xmlFields });
      fileName = `RG-${metadata?.country || 'XX'}-${currentConfig.docType}-${currentConfig.title.replace(/\s+/g, '_')}.xsl`;
    }

    const blob = new Blob([xslt], { type: 'application/xml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const handleDownloadHtml = () => {
    const previewEl = document.querySelector('[data-preview-content]');
    const importedHtml = customXslt ? importedSnapshot() : null;
    if (!previewEl && !importedHtml) return;

    const fullHtml = importedHtml || `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>RG - ${currentConfig?.title || 'Preview'}</title>
  <style>${DOCUMENT_RENDER_CSS}</style>
</head>
<body>
  <div class="dte-page-wrap">${cleanPreviewHtml(previewEl)}</div>
</body>
</html>`;

    const blob = new Blob([withPrintFit(fullHtml, userStyle.pageSize)], { type: 'text/html' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `RG-${metadata?.country || 'XX'}-${currentConfig?.docType || 'XX'}-preview.html`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const handleDownloadPdf = () => {
    const previewEl = document.querySelector('[data-preview-content]');
    const importedHtml = customXslt ? importedSnapshot() : null;
    if (!previewEl && !importedHtml) return;

    const printCss = `
      @media print {
        @page { size: 8.5in ${pageSize(userStyle.pageSize).height}in; margin: 0; }
        body { font-size: 7pt; }
        .dte-page-wrap { width: 8.5in; margin: 0 auto; }
      }
    `;

    const fullHtml = importedHtml || `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>RG - ${currentConfig?.title || 'Preview'}</title>
  <style>${DOCUMENT_RENDER_CSS}${printCss}</style>
</head>
<body>
  <div class="dte-page-wrap">${cleanPreviewHtml(previewEl)}</div>
</body>
</html>`;

    const win = window.open('', '_blank');
    if (win) {
      win.document.write(withPrintFit(fullHtml, userStyle.pageSize));
      win.document.close();
      win.onload = () => win.print();
    }
  };

  return (
    <details className="export-popover">
      <summary aria-label="Abrir opciones de exportación">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12m0 0 4-4m-4 4-4-4M5 15v4h14v-4"/></svg>
        <span>Exportar</span>
      </summary>
      <div className="export-popover-content">
        <strong>Exportar documento</strong>
    <div className="export-actions flex gap-2">
      <Button onClick={handleDownloadXsl} disabled={!currentConfig}>
        {customXslt ? 'Descargar XSLT Propio' : 'Descargar .xsl'}
      </Button>
      <Button onClick={handleDownloadHtml} variant="secondary" disabled={!currentConfig}>
        Descargar .html
      </Button>
      <Button onClick={handleDownloadPdf} variant="secondary" disabled={!currentConfig}>
        Imprimir / PDF
      </Button>
    </div>
    {!customXslt && <p className="export-note mt-2 text-xs text-gray-500">{isReferenceDocument(currentConfig || {})
      ? 'El XSL usa el diseño actual del editor y los dos archivos compartidos. Guarda los tres en la misma carpeta.'
      : 'El XSL usa la configuración actual del documento. El HTML y PDF conservan además una captura exacta de la preview.'}</p>}
    {(customXslt || isReferenceDocument(currentConfig || {})) && <div className="export-shared mt-2 flex gap-4 text-xs text-blue-700">
      <a href={`/templates/RG-SharedSV_fel_2.xslt`} download="RG-SharedSV_fel_2.xslt">Descargar RG-SharedSV_fel_2.xslt</a>
      <a href={`/templates/Shared_ENLETRAS_fel_2.xslt`} download="Shared_ENLETRAS_fel_2.xslt">Descargar Shared_ENLETRAS_fel_2.xslt</a>
    </div>}
    {customXslt && Object.entries(customXsltFiles || {}).map(([name, content]) => <button key={name} className="text-xs text-blue-700" onClick={() => {
      const url = URL.createObjectURL(new Blob([normalizeXmlSource(content)], { type: 'application/xml' }));
      const link = document.createElement('a'); link.href = url; link.download = name;
      link.click(); URL.revokeObjectURL(url);
    }}>Descargar {name}</button>)}
      </div>
    </details>
  );
}
