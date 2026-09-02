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
import InteractivePreview from './components/Preview/InteractivePreview';
import DownloadButton from './components/Preview/DownloadButton';
import { useConfigStore } from './stores/configStore';

export default function App() {
  const metadata = useConfigStore((s) => s.metadata);

  return (
    <div className="h-screen flex flex-col bg-white">
      <Header />

      <div className="flex flex-1 overflow-hidden">
        <Sidebar>
          <XmlUploader />
          <DocInfo />
          <VersionSelect />
          <FieldToggles />
          <ColumnConfig />
          <LayoutConfig />
          <StyleConfig />
          <FooterConfig />
        </Sidebar>

        <main className="flex-1 flex flex-col overflow-hidden">
          <div className="flex-1 overflow-auto border-b border-gray-200">
            <InteractivePreview />
          </div>
          <div className="p-3 bg-gray-50 border-t border-gray-200">
            <DownloadButton />
          </div>
        </main>
      </div>
    </div>
  );
}
