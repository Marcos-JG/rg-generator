import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const root = new URL('../', import.meta.url);
const files = { baseTemplate: 'base.xsl', reference: 'XSLTS3_dtesv_Carta_06141602171030_fel_1.xslt', shared: 'RG-SharedSV_fel_2.xslt', words: 'Shared_ENLETRAS_fel_2.xslt' };
mkdirSync(new URL('src/generated/', root), { recursive: true });
writeFileSync(fileURLToPath(new URL('src/generated/templates.ts', root)),
  '// Generated from public/templates by scripts/generate-templates.mjs.\n' + Object.entries(files).map(([name, file]) =>
    `export const ${name}: string = ${JSON.stringify(readFileSync(new URL(`public/templates/${file}`, root), 'utf8'))};`).join('\n'));
