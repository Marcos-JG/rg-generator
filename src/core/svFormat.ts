export function formatNitSV(nit) {
  if (!nit) return '';
  const d = String(nit).replace(/\D/g, '');
  if (d.length === 14) return `${d.slice(0, 4)}-${d.slice(4, 10)}-${d.slice(10, 13)}-${d.slice(13)}`;
  if (d.length === 9) return `${d.slice(0, 4)}-${d.slice(4, 8)}-${d.slice(8)}`;
  return String(nit);
}

export function formatNrcSV(nrc) {
  if (!nrc) return '';
  const d = String(nrc).replace(/\D/g, '');
  if (d.length === 7) return `${d.slice(0, 6)}-${d.slice(6)}`;
  return String(nrc);
}

export function buildFooterText(xmlData, fallback) {
  const seller = xmlData?.seller || {};
  const name = seller.Name || '';
  const web = 'https://www.digifact.com.sv';
  const nit = seller.TaxID ? `NIT ${formatNitSV(seller.TaxID)}` : '';
  const nrc = seller.NRC ? `NRC ${formatNrcSV(seller.NRC)}` : '';

  const parts = [name, web, nit, nrc].filter(Boolean);
  const hasData = !!(name || nit || nrc);
  return hasData ? parts.join(', ') : (fallback || '');
}
