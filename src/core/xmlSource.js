// Remove only leading encoding markers, including a UTF-8 BOM previously read
// as Latin-1. Never replace this sequence inside labels or XML values.
export function normalizeXmlSource(source) {
  return source.replace(/^(?:\uFEFF|\u00EF\u00BB\u00BF)+/, '');
}

export async function readXmlSource(file) {
  const bytes = new Uint8Array(await file.arrayBuffer());
  let encoding = 'utf-8';
  if ((bytes[0] === 0xff && bytes[1] === 0xfe) || (bytes[0] === 0x3c && bytes[1] === 0)) encoding = 'utf-16le';
  else if ((bytes[0] === 0xfe && bytes[1] === 0xff) || (bytes[0] === 0 && bytes[1] === 0x3c)) encoding = 'utf-16be';
  else if (!(bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf)) {
    const declaration = new TextDecoder('windows-1252').decode(bytes.subarray(0, 200));
    encoding = declaration.match(/<\?xml\s[^?]*encoding\s*=\s*["']([^"']+)["']/i)?.[1] || encoding;
  }
  return normalizeXmlSource(new TextDecoder(encoding).decode(bytes));
}
