import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { useHistoryStore } from './historyStore';
import { normalizeSavedDesign } from '../core/editorElements';
import { getConfig } from '../configs';
import type { ConfigStore, DesignState, UserStyle } from '../types/editor';

const defaultStyle = (): UserStyle => ({
  colorPrimary: '#020873', colorFont: '#333333', colorBorder: '#808080',
  colorTotalesBg: '#e6e6e6', colorTotalPagarBg: '#D1D5DB',
  fontSize: '7pt', fontSizeHeader: '12pt', fontFamily: 'Arial, Helvetica, sans-serif',
  borderRadius: '6px',
  footerText: 'DIGIFACT SERVICIOS, SOCIEDAD ANONIMA https://www.digifact.com.sv, NIT 0614-230822-102-5, NRC 318270-1',
  enabledFields: [],
});

// History stores the complete design, without duplicating the source XML.
const designState = ({ currentConfig, userStyle, docTitle, overrides, textOverrides, positions, xmlFields }: DesignState) =>
  ({ currentConfig, userStyle, docTitle, overrides, textOverrides, positions, xmlFields: xmlFields || [] });

export const useConfigStore = create<ConfigStore>()(persist((set, get) => {
  const commit = (updates: Partial<ConfigStore> | ((state: ConfigStore) => Partial<ConfigStore>)) => {
    const before = JSON.stringify(designState(get()));
    const patch = typeof updates === 'function' ? updates(get()) : updates;
    if (before === JSON.stringify(designState({ ...get(), ...patch }))) return;
    useHistoryStore.getState().snapshot(before);
    set(patch);
  };
  const restore = (direction: 'undo' | 'redo') => {
    const state = useHistoryStore.getState()[direction](JSON.stringify(designState(get())));
    if (state) set(JSON.parse(state));
  };
  return {
    xmlString: null, metadata: null, currentConfig: null,
    customXslt: null, customXsltName: null, customXsltFiles: {}, docTitle: null,
    userStyle: defaultStyle(), overrides: {}, textOverrides: {}, positions: {}, xmlFields: [],
    addXmlField: field => commit(state => ({ xmlFields: [...(state.xmlFields || []), field] })),
    removeXmlField: id => commit(state => {
      const overrides = { ...state.overrides }, positions = { ...state.positions }, textOverrides = { ...state.textOverrides };
      delete overrides[id]; delete positions[id];
      Object.keys(textOverrides).filter(key => key.startsWith(id + ':')).forEach(key => delete textOverrides[key]);
      return { xmlFields: (state.xmlFields || []).filter(field => field.id !== id), overrides, positions, textOverrides };
    }),
    loadDocument: (xmlString, metadata, currentConfig) => {
      useHistoryStore.getState().clear();
      set({ xmlString, metadata, currentConfig, overrides: {}, textOverrides: {}, positions: {}, xmlFields: [], docTitle: null });
    },
    setXmlString: (xmlString) => set({ xmlString }),
    setMetadata: (metadata) => set({ metadata }),
    setCurrentConfig: (currentConfig) => commit({ currentConfig }),
    setCustomXslt: (customXslt, customXsltName) => {
      useHistoryStore.getState().clear();
      set({ customXslt, customXsltName, customXsltFiles: {}, overrides: {}, positions: {}, textOverrides: {}, xmlFields: [] });
    },
    addCustomXsltFiles: files => set(state => ({ customXsltFiles: { ...state.customXsltFiles, ...files } })),
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
        customXsltName: null, customXsltFiles: {}, docTitle: null, userStyle: defaultStyle(), overrides: {}, textOverrides: {}, positions: {}, xmlFields: [] });
    },
  };
}, {
  name: 'rg-generator-config',
  version: 5,
  migrate: persisted => {
    const next = normalizeSavedDesign(persisted as ConfigStore);
    const country = next.metadata?.country?.toLowerCase();
    const docType = String(next.metadata?.docType || '');
    const fresh = getConfig(country, docType);
    if (fresh && next.currentConfig) {
      next.currentConfig = {
        ...fresh,
        ...next.currentConfig,
        country: fresh.country,
        docType: fresh.docType,
        title: fresh.title,
        sellerFields: fresh.sellerFields,
        buyerFields: fresh.buyerFields,
        totalsFields: fresh.totalsFields,
      };
    }
    return next;
  },
  partialize: (state) => ({ ...designState(state), xmlString: state.xmlString,
    metadata: state.metadata, customXslt: state.customXslt, customXsltName: state.customXsltName, customXsltFiles: state.customXsltFiles }),
}));
