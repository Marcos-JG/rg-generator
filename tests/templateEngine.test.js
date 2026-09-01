import { describe, it, expect } from 'vitest';
import { replaceAllPlaceholders, processTemplate } from '../src/core/templateEngine.js';

describe('templateEngine', () => {
  describe('replaceAllPlaceholders', () => {
    it('replaces a single placeholder', () => {
      const template = 'Hello {{NAME}}!';
      expect(replaceAllPlaceholders(template, 'NAME', 'World')).toBe('Hello World!');
    });

    it('replaces all occurrences', () => {
      const template = '{{COLOR}} and {{COLOR}} again';
      expect(replaceAllPlaceholders(template, 'COLOR', 'red')).toBe('red and red again');
    });

    it('leaves unmatched placeholders intact', () => {
      const template = '{{A}} and {{B}}';
      expect(replaceAllPlaceholders(template, 'A', '1')).toBe('1 and {{B}}');
    });
  });

  describe('processTemplate', () => {
    it('replaces multiple different placeholders', () => {
      const template = '{{A}} - {{B}} - {{A}}';
      const replacements = { A: 'foo', B: 'bar' };
      expect(processTemplate(template, replacements)).toBe('foo - bar - foo');
    });

    it('handles empty replacements', () => {
      const template = 'No placeholders here';
      expect(processTemplate(template, {})).toBe('No placeholders here');
    });
  });
});
