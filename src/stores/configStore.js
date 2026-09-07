import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { useHistoryStore } from './historyStore';

const defaultStyle = () => ({
  colorPrimary: '#020873', colorFont: '#333333', colorBorder: '#808080',
  colorTotalesBg: '#e6e6e6', colorTotalPagarBg: '#D1D5DB',
  fontSize: '7pt', fontSizeHeader: '12pt', fontFamily: 'Arial, Helvetica, sans-serif',
  borderRadius: '6px',
  footerText: 'DIGIFACT SERVICIOS, SOCIEDAD ANONIMA https://www.digifact.com.sv, NIT 0614-230822-102-5, NRC 318270-1',
  enabledFields: [],
});

// History stores the complete design, without duplicating the source XML.
const designState = ({ currentConfig, userStyle, docTitle, overrides, textOverrides, positions }) =>
  ({ currentConfig, userStyle, docTitle, overrides, textOverrides, positions });

export const useConfigStore = create(persist((set, get) => {
  const commit = (updates) => {
    const before = JSON.stringify(designState(get()));
    const patch = typeof updates === 'function' ? updates(get()) : updates;
    if (before === JSON.stringify(designState({ ...get(), ...patch }))) return;
    useHistoryStore.getState().snapshot(before);
    set(patch);
  };
  const restore = (direction) => {
    const state = useHistoryStore.getState()[direction](JSON.stringify(designState(get())));
    if (state) set(JSON.parse(state));
  };
  return {
    xmlString: null, metadata: null, currentConfig: null,
    customXslt: null, customXsltName: null, docTitle: null,
    userStyle: defaultStyle(), overrides: {}, textOverrides: {}, positions: {},
    loadDocument: (xmlString, metadata, currentConfig) => {
      useHistoryStore.getState().clear();
      set({ xmlString, metadata, currentConfig, overrides: {}, textOverrides: {}, positions: {}, docTitle: null });
    },
    setXmlString: (xmlString) => set({ xmlString }),
    setMetadata: (metadata) => set({ metadata }),
    setCurrentConfig: (currentConfig) => commit({ currentConfig }),
    setCustomXslt: (customXslt, customXsltName) => set({ customXslt, customXsltName }),
    setDocTitle: (docTitle) => commit({ docTitle }),
    setOverrides: (updates) => commit((state) => ({
      overrides: typeof updates === 'function' ? updates(state.overrides) : updates,
    })),
    setText: (id, text) => commit((state) => ({ textOverrides: { ...state.textOverrides, [id]: text } })),
    setPosition: (id, position) => commit(state => ({ positions: { ...state.positions, [id]: position } })),
    updateUserStyle: (updates) => commit((state) => ({ userStyle: { ...state.userStyle, ...updates } })),
    undo: () => restore('undo'),
    redo: () => restore('redo'),
    resetStyle: () => commit({ userStyle: defaultStyle(), overrides: {}, textOverrides: {}, positions: {}, docTitle: null }),
    resetAll: () => {
      useHistoryStore.getState().clear();
      set({ xmlString: null, metadata: null, currentConfig: null, customXslt: null,
        customXsltName: null, docTitle: null, userStyle: defaultStyle(), overrides: {}, textOverrides: {}, positions: {} });
    },
  };
}, {
  name: 'rg-generator-config',
  partialize: (state) => ({ ...designState(state), xmlString: state.xmlString,
    metadata: state.metadata, customXslt: state.customXslt, customXsltName: state.customXsltName }),
}));
