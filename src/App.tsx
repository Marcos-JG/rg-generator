import Header from './components/Layout/Header';
import Sidebar from './components/Layout/Sidebar';
import XmlUploader from './components/ConfigPanel/XmlUploader';
import DocInfo from './components/ConfigPanel/DocInfo';
import VersionSelect from './components/ConfigPanel/VersionSelect';
import FieldToggles from './components/ConfigPanel/FieldToggles';
import StyleConfig from './components/ConfigPanel/StyleConfig';
import FooterConfig from './components/ConfigPanel/FooterConfig';
import AdendaConfig from './components/ConfigPanel/AdendaConfig';
import XmlDataPalette from './components/ConfigPanel/XmlDataPalette';
import InteractivePreview from './components/Preview/InteractivePreview';
import ImportedPreview from './components/Preview/ImportedPreview';
import { useConfigStore } from './stores/configStore';
import { useEffect, useRef, useState } from 'react';

export default function App() {
  const imported = useConfigStore(state => Boolean(state.customXslt && state.xmlString));
  const hasDocument = useConfigStore(state => Boolean(state.metadata));
  const generatorControls = useConfigStore(state => Boolean(state.currentConfig && !state.customXslt));
  const hasOptionalFields = useConfigStore(state => Boolean(state.currentConfig &&
    [...state.currentConfig.sellerFields, ...state.currentConfig.buyerFields].some(field => !field.required)));
  const [panel, setPanel] = useState('documento');
  const [menuOpen, setMenuOpen] = useState(false);
  const [zoom, setZoom] = useState(100);
  const previewViewport = useRef<HTMLDivElement>(null);
  const resetView = () => {
    setZoom(100);
    previewViewport.current?.scrollTo({ top: 0, left: 0 });
    previewViewport.current?.querySelector('.studio-canvas')?.scrollTo({ top: 0, left: 0 });
  };
  const menuButton = useRef(null);
  useEffect(() => {
    if (!menuOpen) return;
    const close = e => {
      if (e.key === 'Escape') {
        setMenuOpen(false);
        menuButton.current?.focus();
      }
    };
    window.addEventListener('keydown', close);
    return () => window.removeEventListener('keydown', close);
  }, [menuOpen]);

  return (
    <div className="studio-shell h-screen flex flex-col">
      <Header menuOpen={menuOpen} onToggleMenu={() => setMenuOpen(open => !open)} menuButton={menuButton} zoom={zoom} onZoomChange={setZoom} onResetView={resetView} />

      <div className="flex flex-1 overflow-hidden">
        <div id="studio-menu" className="studio-menu" hidden={!menuOpen}>
        <Sidebar panel={panel} onPanelChange={setPanel}>
          <div hidden={panel !== 'documento'} className="inspector-group">
          <XmlUploader />
          {hasDocument && <InspectorSection title="Información del documento" caption="Datos detectados y título"><DocInfo /></InspectorSection>}
          {generatorControls && <InspectorSection title="Versión del documento" caption="Configuración de la plantilla"><VersionSelect /></InspectorSection>}
          </div>
          <div hidden={panel !== 'contenido'} className="inspector-group">
          {hasDocument && <InspectorSection title="Agregar datos del XML" caption="Arrastra datos o el logo a la hoja" defaultOpen><XmlDataPalette /></InspectorSection>}
          {generatorControls && <>
          {hasOptionalFields && <InspectorSection title="Campos opcionales" caption="Mostrar u ocultar datos"><FieldToggles /></InspectorSection>}
          <InspectorSection title="Datos adicionales" caption="Agregar información complementaria"><AdendaConfig /></InspectorSection>
          <InspectorSection title="Pie del documento" caption="Texto y visibilidad del pie"><FooterConfig /></InspectorSection>
          </>}
          </div>
          <div hidden={panel !== 'diseno'} className="inspector-group">
          <StyleConfig />
          </div>
        </Sidebar>
        </div>

        <main className="studio-workspace flex-1 min-w-0 flex flex-col overflow-hidden relative" aria-label="Área de edición">
          <div ref={previewViewport} className="flex-1 min-h-0 overflow-auto">
            <div style={{ zoom: zoom / 100, height: '100%' }}>
            {imported ? <ImportedPreview /> : <InteractivePreview />}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

function InspectorSection({ title, caption, children, defaultOpen = false }) {
  return <details className="inspector-section" open={defaultOpen}>
    <summary><span>{title}<small>{caption}</small></span></summary>
    <div className="inspector-section-body">{children}</div>
  </details>;
}
