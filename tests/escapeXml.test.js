import { describe, it, expect } from 'vitest';
import { escapeXml } from '../src/core/escapeXml.js';

describe('escapeXml', () => {
  it('escapes ampersand', () => {
    expect(escapeXml('A & B')).toBe('A &amp; B');
  });

  it('escapes less than', () => {
    expect(escapeXml('a < b')).toBe('a &lt; b');
  });

  it('escapes greater than', () => {
    expect(escapeXml('a > b')).toBe('a &gt; b');
  });

  it('escapes double quotes', () => {
    expect(escapeXml('say "hello"')).toBe('say &quot;hello&quot;');
  });

  it('escapes single quotes', () => {
    expect(escapeXml("it's")).toBe('it&apos;s');
  });

  it('returns empty string for null/undefined', () => {
    expect(escapeXml(null)).toBe('');
    expect(escapeXml(undefined)).toBe('');
  });

  it('converts numbers to string', () => {
    expect(escapeXml(42)).toBe('42');
  });

  it('handles complex mixed content', () => {
    expect(escapeXml('Tom & Jerry < "friends"')).toBe('Tom &amp; Jerry &lt; &quot;friends&quot;');
  });
});
