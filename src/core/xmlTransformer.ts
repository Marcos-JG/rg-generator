export function transformXmlToHtml(xmlString, xsltString) {
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(xmlString, 'text/xml');
  const xsltDoc = parser.parseFromString(xsltString, 'text/xml');

  const parseError = xmlDoc.querySelector('parsererror');
  if (parseError) {
    throw new Error('XML de entrada mal formado');
  }

  const xsltError = xsltDoc.querySelector('parsererror');
  if (xsltError) {
    throw new Error('XSLT mal formado');
  }

  const processor = new XSLTProcessor();
  processor.importStylesheet(xsltDoc);

  const resultDoc = processor.transformToDocument(xmlDoc);
  const serializer = new XMLSerializer();
  return serializer.serializeToString(resultDoc);
}
