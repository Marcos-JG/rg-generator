import type { CSSProperties } from 'react';
import type { extractXmlData, parseXmlFile } from '../core/xmlParser';

export interface Field { id: string; label: string; required?: boolean; width?: string; xpath?: string; name?: string; value?: string; addedByUser?: boolean }
export interface DocumentConfig {
  country: string; docType: string; title: string; version: string;
  sellerFields: Field[]; buyerFields: Field[]; itemColumns: Field[]; totalsFields: Field[];
  adendaFields: Field[]; observationFields: Field[]; dteBoxFields: string[];
  layoutGrid?: string[][]; headerLayoutGrid?: string[][]; showFooter: boolean; showQR: boolean;
  style: Record<string, string>;
  fieldOrders?: Record<string, string[]>; adendaDefaults?: Field[];
}
export type ElementStyle = CSSProperties & { separationX?: string; labelWidth?: string; order?: number; fieldOrder?: string[]; columnOrder?: string[]; [key: string]: string | number | string[] | undefined };
export type Overrides = Record<string, ElementStyle>;
export interface Position { x: number; y: number; z?: number }
export interface XmlField { id: string; xpath: string; label: string; x: number; y: number }
export interface EditorState { overrides?: Overrides; positions?: Record<string, Position>; textOverrides?: Record<string, string>; xmlFields?: XmlField[] }
export type UserStyle = Record<string, string | string[]> & { enabledFields: string[]; docTitle?: string };
export type XmlData = ReturnType<typeof extractXmlData>;
export type Metadata = ReturnType<typeof parseXmlFile>['metadata'];
export type Update<T> = T | ((previous: T) => T);
export interface DesignState {
  xmlFields: XmlField[];
  currentConfig: DocumentConfig | null; userStyle: UserStyle; docTitle: string | null;
  overrides: Overrides; textOverrides: Record<string, string>; positions: Record<string, Position>;
}
export interface ConfigStore extends DesignState {
  addXmlField(field: XmlField): void; removeXmlField(id: string): void;
  xmlString: string | null; metadata: Metadata | null;
  customXslt: string | null; customXsltName: string | null; customXsltFiles: Record<string, string>;
  loadDocument(xml: string, metadata: Metadata, config: DocumentConfig): void;
  setXmlString(xml: string): void; setMetadata(metadata: Metadata): void; setCurrentConfig(config: DocumentConfig): void;
  setCustomXslt(source: string | null, name: string | null): void; addCustomXsltFiles(files: Record<string, string>): void;
  setDocTitle(title: string): void; setOverrides(update: Update<Overrides>): void;
  setText(id: string, text: string): void; setPosition(id: string, position: Position): void;
  updateUserStyle(update: Partial<UserStyle>): void;
  undo(): void; redo(): void; resetStyle(): void; resetAll(): void;
}
export interface HistoryStore {
  past: string[]; future: string[]; snapshot(state: string): void;
  undo(current: string): string | null; redo(current: string): string | null;
  canUndo(): boolean; canRedo(): boolean; clear(): void;
}
