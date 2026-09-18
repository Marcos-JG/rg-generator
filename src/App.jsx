import Header from './components/Layout/Header';
import Sidebar from './components/Layout/Sidebar';
import XmlUploader from './components/ConfigPanel/XmlUploader';
import DocInfo from './components/ConfigPanel/DocInfo';
import VersionSelect from './components/ConfigPanel/VersionSelect';
import FieldToggles from './components/ConfigPanel/FieldToggles';
import ColumnConfig from './components/ConfigPanel/ColumnConfig';
import LayoutConfig from './components/ConfigPanel/LayoutConfig';
import StyleConfig from './components/ConfigPanel/StyleConfig';
import FooterConfig from './components/ConfigPanel/FooterConfig';
import AdendaConfig from './components/ConfigPanel/AdendaConfig';
import InteractivePreview from './components/Preview/InteractivePreview';
import DownloadButton from './components/Preview/DownloadButton';
import ImportedPreview from './components/Preview/ImportedPreview';
import { useConfigStore } from './stores/configStore';
import { useEffect, useRef, useState } from 'react';

export default function App() {
  const imported = useConfigStore(state => Boolean(state.customXslt && state.xmlString));
  const [panel, setPanel] = useState('documento');
  const [menuOpen, setMenuOpen] = useState(false);
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
      <Header menuOpen={menuOpen} onToggleMenu={() => setMenuOpen(open => !open)} menuButton={menuButton} />

      <div className="flex flex-1 overflow-hidden">
        <div id="studio-menu" className="studio-menu" hidden={!menuOpen}>
        <Sidebar panel={panel} onPanelChange={setPanel}>
          <div hidden={panel !== 'documento'} className="inspector-group">
          <XmlUploader />
          <DocInfo />
          <VersionSelect />
          </div>
          <div hidden={panel !== 'contenido'} className="inspector-group">
          <FieldToggles />
          <ColumnConfig />
          <AdendaConfig />
          <FooterConfig />
          </div>
          <div hidden={panel !== 'diseno'} className="inspector-group">
          <StyleConfig />
          <LayoutConfig />
          </div>
        </Sidebar>
        </div>

        <main className="studio-workspace flex-1 min-w-0 flex flex-col overflow-hidden relative" aria-label="Área de edición">
          <div className="flex-1 min-h-0 overflow-auto">
            {imported ? <ImportedPreview /> : <InteractivePreview />}
          </div>
          <div className="studio-export">
            <DownloadButton />
          </div>
        </main>
      </div>
    </div>
  );
}
