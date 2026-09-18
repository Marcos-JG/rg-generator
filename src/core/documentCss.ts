// Shared by the canvas, standalone HTML and the result of an XSLT transform.
export const documentCss = (root = '.dte-page-wrap') => `
${root}, ${root} * { box-sizing:border-box; }
${root} { width:8.5in; min-height:11in; margin:0 auto; padding:0.25in; position:relative;
  background:white; font-family:Arial,sans-serif; font-size:7pt; text-align:left;
  line-height:1.5; letter-spacing:-.015em; font-synthesis:none; }
${root} * { margin:0; padding:0; border:0 solid; }
${root} table { border-collapse:collapse; border-color:inherit; text-indent:0;
  background:white; font-family:Arial,sans-serif; font-size:7pt; }
${root} td { vertical-align:top; border-color:#808080; padding:0.02in; }
${root} img { display:block; vertical-align:middle; max-width:100%; height:auto; }
${root} b, ${root} strong { font-weight:bolder; }
`;
