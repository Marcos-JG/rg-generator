import { JSDOM } from 'jsdom';
import { buildPreviewHtml } from '../src/components/Preview/buildPreviewHtml.js';
import sv from '../src/configs/sv/fact.json';
const h = buildPreviewHtml({ currentConfig: sv, userStyle: {}, xmlData: { seller: {Name:'ACME'}, buyer: {Name:'C'}, items: [{}], totals: {SubTotal:'100'} }, overrides: { 'section-emisor': { width: '500px' } }, selected: '', hovered: '', docTitle: null });
const d = new JSDOM(h, { pretendVisualViewport: true }).window.document;

const container = d.querySelector('[data-preview-content]');
const rows = d.querySelectorAll('[data-rg-id^="grid-row"]');
rows.forEach(r => {
  console.log('row overflow:', r.style.overflow, '| width style:', r.style.width);
  const sections = r.querySelectorAll('[data-drag-section]');
  sections.forEach(s => {
    console.log('  section:', s.getAttribute('data-drag-section'), '| overflow:', s.style.overflow, '| width:', s.style.width || 'flex:1');
  });
});

// Check receptor specifically
const receptor = d.querySelector('[data-drag-section="receptor"]');
console.log('receptor offsetLeft:', receptor?.offsetLeft);
console.log('receptor clientWidth:', receptor?.clientWidth);
console.log('container clientWidth:', container?.clientWidth);
console.log('container padding:', container?.style.padding);
