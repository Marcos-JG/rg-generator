// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { printFitScript, withPrintFit } from '../src/core/printFit';

it('fits overflow to Carta only in print styles, keeping every block and screen dimensions', () => {
  const doc = new DOMParser().parseFromString('<html><head></head><body><div class="dte-page-wrap" style="min-height:1600px"><p>Responsables</p><footer>Pie</footer></div></body></html>', 'text/html');
  const root = doc.querySelector<HTMLElement>('.dte-page-wrap');
  root.getBoundingClientRect = () => ({ top: 0, left: 0, right: 816, bottom: 1600, width: 816, height: 1600 } as DOMRect);
  for (const [property, value] of Object.entries({ offsetWidth: 816, scrollWidth: 816, offsetHeight: 1600, scrollHeight: 1600 })) Object.defineProperty(root, property, { value });
  const callbacks = {};
  new Function('document', 'window', printFitScript('carta'))(doc, { addEventListener: (name, callback) => { callbacks[name] = callback; } });
  callbacks['beforeprint']();
  const css = doc.getElementById('rg-print-fit').textContent;
  expect(css).toContain('@media print'); expect(css).toContain('size:8.5in 11in');
  expect(Number(css.match(/zoom:([\d.]+)/)[1])).toBeCloseTo(1054 / 1600);
  expect(root.style.zoom).toBe(''); expect(root.style.minHeight).toBe('1600px');
  expect(root.textContent).toContain('Responsables'); expect(root.textContent).toContain('Pie');
});

it('includes the selected paper size in standalone HTML printing', () => {
  const doc = new DOMParser().parseFromString(withPrintFit('<html><body>RG</body></html>', 'oficio'), 'text/html');
  expect(doc.querySelector('script').textContent).toContain('size:8.5in 13in');
});
