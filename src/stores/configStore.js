import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useConfigStore = create(
  persist(
    (set, get) => ({
      xmlString: null,
      metadata: null,
      currentConfig: null,
      customXslt: null,
      customXsltName: null,
      docTitle: null,
      userStyle: {
        colorPrimary: '#020873',
        colorFont: '#333333',
        colorBorder: '#808080',
        colorTotalesBg: '#e6e6e6',
        colorTotalPagarBg: '#D1D5DB',
        fontSize: '7pt',
        fontSizeHeader: '12pt',
        fontFamily: 'Arial, Helvetica, sans-serif',
        borderRadius: '6px',
        footerText: 'Documento generado por RG Generator',
        enabledFields: [],
      },

      setXmlString: (xmlString) => set({ xmlString }),
      setMetadata: (metadata) => set({ metadata }),
      setCurrentConfig: (config) => set({ currentConfig: config }),
      setCustomXslt: (customXslt, customXsltName) => set({ customXslt, customXsltName }),
      setDocTitle: (docTitle) => set({ docTitle }),

      updateUserStyle: (updates) =>
        set((state) => ({
          userStyle: { ...state.userStyle, ...updates },
        })),

      resetStyle: () =>
        set({
          userStyle: {
            colorPrimary: '#020873',
            colorFont: '#333333',
            colorBorder: '#808080',
            colorTotalesBg: '#e6e6e6',
            colorTotalPagarBg: '#D1D5DB',
            fontSize: '7pt',
            fontSizeHeader: '12pt',
            fontFamily: 'Arial, Helvetica, sans-serif',
            borderRadius: '6px',
            footerText: 'Documento generado por RG Generator',
            enabledFields: [],
          },
        }),

      resetAll: () =>
        set({
          xmlString: null,
          metadata: null,
          currentConfig: null,
          customXslt: null,
          customXsltName: null,
          docTitle: null,
          userStyle: {
            colorPrimary: '#020873',
            colorFont: '#333333',
            colorBorder: '#808080',
            colorTotalesBg: '#e6e6e6',
            colorTotalPagarBg: '#D1D5DB',
            fontSize: '7pt',
            fontSizeHeader: '12pt',
            fontFamily: 'Arial, Helvetica, sans-serif',
            borderRadius: '6px',
            footerText: 'Documento generado por RG Generator',
            enabledFields: [],
          },
        }),
    }),
    {
      name: 'rg-generator-config',
      partialize: (state) => ({
        userStyle: state.userStyle,
      }),
    }
  )
);
