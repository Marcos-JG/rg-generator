import { expect, it } from 'vitest';
import { normalizeXmlSource, readXmlSource } from '../src/core/xmlSource';

const file = bytes => ({ arrayBuffer: async () => new Uint8Array(bytes).buffer });
it('removes native and misdecoded leading BOMs without altering document content', () => {
  expect(normalizeXmlSource('\uFEFFï»¿<root>ï»¿ José</root>')).toBe('<root>ï»¿ José</root>');
  expect(normalizeXmlSource('texto inválido<root/>')).toBe('texto inválido<root/>');
});
it('reads UTF-8 and UTF-16 files with their encoding markers', async () => {
  const xml = '<root>José</root>';
  expect(await readXmlSource(file([0xef, 0xbb, 0xbf, ...new TextEncoder().encode(xml)]))).toBe(xml);
  expect(await readXmlSource(file([0xff, 0xfe, ...[...xml].flatMap(c => [c.charCodeAt(0), 0])]))).toBe(xml);
  expect(await readXmlSource(file([0xfe, 0xff, ...[...xml].flatMap(c => [0, c.charCodeAt(0)])]))).toBe(xml);
});
it('respects a declared Latin-1 encoding and preserves accented labels', async () => {
  const xml = '<?xml version="1.0" encoding="ISO-8859-1"?><root>José</root>';
  expect(await readXmlSource(file([...xml].map(c => c.charCodeAt(0))))).toBe(xml);
});
