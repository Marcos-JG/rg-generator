import { escapeXml } from './escapeXml.js';

export function replaceAllPlaceholders(template, key, value) {
  return template.replaceAll(`{{${key}}}`, value);
}

export function processTemplate(template, replacements) {
  let result = template;
  for (const [key, value] of Object.entries(replacements)) {
    result = replaceAllPlaceholders(result, key, value);
  }
  return result;
}
