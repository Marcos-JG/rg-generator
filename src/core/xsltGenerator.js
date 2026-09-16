import { generateEditorXslt } from './editorXslt';

// Keep the public API used by the editor and existing integrations.
export function generateXslt(_baseTemplate, config, userStyle = {}, _xmlData = null, editorState = {}) {
  return generateEditorXslt(config, userStyle, editorState);
}
