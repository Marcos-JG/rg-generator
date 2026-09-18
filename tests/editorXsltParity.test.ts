// @vitest-environment jsdom
import { it, expect } from 'vitest';
import { mkdtempSync, readFileSync, writeFileSync, copyFileSync, rmSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { execFileSync } from 'node:child_process';
import { generateXslt } from '../src/core/xsltGenerator';
import { extractXmlData } from '../src/core/xmlParser';
import { buildPreviewHtml } from '../src/components/Preview/buildPreviewHtml';
import { editableHtml, cleanPreviewHtml } from '../src/core/editableHtml';
import { documentCss } from '../src/core/documentCss';
import ccf from '../src/configs/sv/ccf.json';

const parse = (text, type='text/html') => new DOMParser().parseFromString(text,type);
// Compare semantic nodes and every layout/style attribute, ignoring editor-only
// decorations and whitespace used to indent template source.
function signature(node) {
  if (node.nodeType === 3) return node.textContent.trim() ? node.textContent.replace(/\s+/g,' ').trim() : null;
  if (node.nodeType !== 1) return null;
  const attrs = [...node.attributes].filter(a => !a.name.startsWith('xmlns') && a.name !== 'class')
    .map(a => [a.name, a.name === 'style' ? node.style.cssText : a.value]).sort();
  return [node.localName, attrs, [...node.childNodes].map(signature).filter(v => v !== null)];
}
it.skipIf(process.platform !== 'win32')('matches the edited canvas after .NET transformation, including a different XML', () => {
  const folder = mkdtempSync(join(tmpdir(),'rg-parity-'));
  const config = {...ccf, layoutGrid:[['emisor','receptor'],['items'],['totals'],['observaciones'],['datos-adicionales']],
    headerLayoutGrid:[['header-logo','header-qr'],['header-ids','header-info']],
    adendaFields:[{id:'CodigoCliente',label:'Cliente interno',addedByUser:true}]};
  const editor = { overrides:{ emisor:{height:'220px',width:'370px'}, receptor:{height:'220px'},
    observaciones:{width:'375px'}, 'header-title':{fontSize:'8pt'}, 'col-Description':{width:'30%'}, 'totals':{labelWidth:'35%'}, 'item-1-Description':{color:'red'} },
    positions:{'header-title':{x:25,y:15}, 'header-info':{x:10,y:5}},
    textOverrides:{'col-Description:text:0':'Detalle {producto} & servicio'} };
  try {
    for (const name of ['RG-SharedSV_fel_2.xslt','Shared_ENLETRAS_fel_2.xslt']) copyFileSync(resolve('public/templates',name),join(folder,name));
    const stylesheet=generateXslt('',config,{},null,editor);
    writeFileSync(join(folder,'design.xsl'),stylesheet);
    const xml=readFileSync('XML-preuba/02-ccf-doctype03.xml','utf8');
    const alternate=xml.replace('Distribuidora Chavarria, S.A. de C.V.','Empresa distinta')
      .replace('</Items>', '<Item><Quantity>3</Quantity><Description>SEGUNDO PRODUCTO</Description><UnitPrice>8.50</UnitPrice></Item></Items>')
      .replace('</AditionalData>', '<Data Name="APENDICE"><Info Name="NombreEntrega" Value="Ana"/><Info Name="DocuEntrega" Value="123"/><Info Name="NotaEntrega" Value="Entrega nueva"/></Data></AditionalData>')
      .replace('<Info Name="VALIDAR_REFERENCIA_INTERNA"', '<Info Name="Observaciones" Value="Una observación nueva"/><Info Name="VALIDAR_REFERENCIA_INTERNA"');
    for (const [index, source] of [xml,alternate].entries()) {
      writeFileSync(join(folder,'source.xml'),source);
      const transformed=execFileSync('powershell',['-NoProfile','-ExecutionPolicy','Bypass','-File',resolve('tests/transformXslt.ps1'),'-Stylesheet',join(folder,'design.xsl'),'-Xml',join(folder,'source.xml')],{encoding:'utf8',maxBuffer:4*1024*1024});
      const preview=editableHtml(buildPreviewHtml({currentConfig:config,userStyle:{},overrides:editor.overrides,xmlData:extractXmlData(parse(source,'text/xml'))}),editor.textOverrides,editor.positions);
      const expected=parse(cleanPreviewHtml(parse(preview).body));
      const actual=parse(transformed);
      expect(actual.querySelector('[data-resize], [contenteditable]')).toBeNull();
      expect(actual.body.textContent).not.toMatch(/RGXVALUE\d+END|NaN/);
      if (process.env.RG_PARITY_ARTIFACTS === '1') {
        mkdirSync('public/parity-check',{recursive:true});
        writeFileSync(`public/parity-check/preview-${index}.html`,`<!doctype html><style>html,body{margin:0}${documentCss()}</style><div class="dte-page-wrap">${expected.body.innerHTML}</div>`);
        writeFileSync(`public/parity-check/transformed-${index}.html`,transformed);
      }
      expect(signature(actual.querySelector('.dte-page-wrap').firstElementChild)).toEqual(signature(expected.body.firstElementChild));
    }
  } finally { rmSync(folder,{recursive:true,force:true}); }
},30000);

