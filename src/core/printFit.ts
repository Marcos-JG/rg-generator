import { pageSize } from './pageSize';

// Measure the transformed document at print time, so future XML values also fit.
export function printFitScript(size?: unknown) {
  const paper = pageSize(size);
  return `(function(){
function fit(){
var root=document.querySelector('.dte-page-wrap')||document.body;
var box=root.getBoundingClientRect();
var ratio=box.width/(root.offsetWidth||box.width)||1;
var height=Math.max(root.scrollHeight,root.offsetHeight);
var width=Math.max(root.scrollWidth,root.offsetWidth);
Array.prototype.forEach.call(root.querySelectorAll('*'),function(el){
var r=el.getBoundingClientRect();height=Math.max(height,(r.bottom-box.top)/ratio);width=Math.max(width,(r.right-box.left)/ratio);
});
var scale=Math.min(1,(${paper.height}*96-2)/Math.max(1,height),(${paper.width}*96-2)/Math.max(1,width));
var style=document.getElementById('rg-print-fit');
if(!style){style=document.createElement('style');style.id='rg-print-fit';document.head.appendChild(style);}
style.textContent='@media print{@page{size:${paper.width}in ${paper.height}in;margin:0;}html,body{margin:0!important;padding:0!important;}'+(root===document.body?'body':'.dte-page-wrap')+'{zoom:'+scale+'!important;break-inside:avoid;margin-left:auto!important;margin-right:auto!important;}}';
}
window.addEventListener('beforeprint',fit);
window.addEventListener('load',fit);
})();`;
}

export function withPrintFit(html: string, size?: unknown) {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const script = doc.createElement('script');
  script.textContent = printFitScript(size);
  doc.head.appendChild(script);
  return '<!DOCTYPE html>' + doc.documentElement.outerHTML;
}
