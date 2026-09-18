import type { UserStyle } from '../types/editor';
import { pageSize } from './pageSize';

// Opt-in document settings; existing templates keep their original appearance.
export function designCss(style: Partial<UserStyle> = {}, root = '.rg-design') {
  const rules: string[] = [];
  if (style.pageSize && root === 'body') {
    const size = pageSize(style.pageSize);
    rules.push(`@page{size:${size.width}in ${size.height}in;margin:0;} body{width:${size.width}in;min-height:${size.height}in;margin:0 auto;} body .page{width:${size.width}in!important;min-height:${size.height}in!important;}`);
  }
  const add = (selector: string, property: string, value: unknown) => {
    if (typeof value !== 'string' || !value) return;
    const css = document.createElement('div').style;
    css.setProperty(property, value);
    if (css.getPropertyValue(property)) rules.push(`${selector}{${property}:${css.getPropertyValue(property)}!important;}`);
  };
  for (const [key, property] of [['designFontFamily', 'font-family'], ['designFontSize', 'font-size'], ['designLineHeight', 'line-height'], ['designLetterSpacing', 'letter-spacing']] as const) {
    add(`${root}, ${root} :not([style*="${property}"])`, property, style[key]);
  }
  const page = root === '.rg-design' ? '[data-preview-content], .dte-page-wrap' : root === 'body' ? 'html, body' : root;
  add(`${page}, ${root}`, 'background-color', style.designBackground);
  if (style.designBackground) {
    add(`${root} table:not([bgcolor]):not([style*="background"])`, 'background-color', 'transparent');
    add(page, 'print-color-adjust', 'exact');
  }
  add(`${root} td:not([data-rg-id]), ${root} th:not([data-rg-id])`, 'padding', style.designCellPadding);
  add(`${root} table`, 'border-collapse', style.designBorderCollapse);
  add(`${root} table`, 'border-spacing', style.designBorderSpacing);
  add(`${root} [data-drag-section]:not([style*="border-radius"]), ${root} td, ${root} th`, 'border-radius', style.designRadius);
  add(`${root} td:not([style*="border-width"]), ${root} th:not([style*="border-width"])`, 'border-width', style.designBorderWidth);
  add(`${root} td:not([style*="border-style"]), ${root} th:not([style*="border-style"])`, 'border-style', style.designBorderStyle);
  add(`${root} .items-table th`, 'color', style.designHeaderText);
  add(`${root} .items-table tbody tr:nth-child(even) td`, 'background-color', style.designStripeColor);
  return rules.join('\n');
}
