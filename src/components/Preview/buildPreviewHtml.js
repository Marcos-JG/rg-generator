import { cssStr } from './helpers';
import { buildFooterText } from '../../core/svFormat';

export function buildPreviewHtml({ currentConfig, userStyle, xmlData, overrides, selected, hovered, docTitle }) {
  const s = { ...currentConfig.style, ...userStyle };
  const cls = (name, rgId) => {
    let c = name;
    if (selected === rgId) c += ' rg-sel';
    else if (hovered === rgId) c += ' rg-hover';
    return c;
  };

  const buildWithOverrides = (sel, baseStyles) => {
    const ov = overrides[sel] || {};
    const merged = { ...baseStyles, ...ov };
    if (ov.width || ov.height) {
      merged.flex = 'none';
      delete merged.flexGrow;
      delete merged.flexShrink;
      delete merged.flexBasis;
      delete merged.minWidth;
      delete merged.minHeight;
    }
    return merged;
  };

  let colCounter = 0;
  const nextColId = () => `col-${colCounter++}`;

  const tdLabel = (rid, label) => {
    const st = buildWithOverrides(rid, { fontWeight: 'bold', width: '35%', whiteSpace: 'nowrap', padding: '2px 4px' });
    return `<td style="${cssStr(st)}">${label}</td>`;
  };
  const tdVal = (rid, val) => {
    const st = buildWithOverrides(`${rid}-val`, { padding: '2px 4px' });
    return `<td style="${cssStr(st)}">${val}</td>`;
  };

  const mkRow = (rid, label, val) => {
    if (!val) return '';
    return `<tr data-rg-id="${rid}" data-field-id="${rid}" draggable="true" class="field-draggable">${tdLabel(rid, label)}${tdVal(rid, val)}</tr>`;
  };

  const emisorFieldOrder = currentConfig.fieldOrders?.seller || ['seller-name', 'seller-nit', 'seller-nrc', 'seller-actividad', 'seller-address', 'seller-phone', 'seller-email', 'seller-nombre-comercial', 'seller-tipo-establecimiento'];
  const emisorRowMap = {
    'seller-name': mkRow('seller-name', 'Nombre o Razón Social:', xmlData?.seller?.Name),
    'seller-nit': mkRow('seller-nit', 'NIT:', xmlData?.seller?.TaxID),
    'seller-nrc': mkRow('seller-nrc', 'NRC:', xmlData?.seller?.NRC),
    'seller-actividad': mkRow('seller-actividad', 'Actividad Económica:', xmlData?.seller?.CodigoActividad && xmlData?.seller?.DescActividad ? `${xmlData.seller.CodigoActividad} – ${xmlData.seller.DescActividad}` : ''),
    'seller-address': mkRow('seller-address', 'Dirección:', xmlData?.seller?.Address),
    'seller-phone': mkRow('seller-phone', 'Teléfono:', xmlData?.seller?.Phone),
    'seller-email': mkRow('seller-email', 'Correo Electrónico:', xmlData?.seller?.Email),
    'seller-nombre-comercial': mkRow('seller-nombre-comercial', 'Nombre Comercial:', xmlData?.seller?.NombreComercial),
    'seller-tipo-establecimiento': mkRow('seller-tipo-establecimiento', 'Tipo de Establecimiento:', xmlData?.seller?.TipoEstablecimiento),
  };
  const sellerRows = emisorFieldOrder.map(id => emisorRowMap[id]).filter(Boolean).join('');

  const receptorFieldOrder = currentConfig.fieldOrders?.buyer || ['buyer-name', 'buyer-taxidtype', 'buyer-nit', 'buyer-nrc', 'buyer-address', 'buyer-email'];
  const receptorRowMap = {
    'buyer-name': mkRow('buyer-name', 'Nombre o Razón Social:', xmlData?.buyer?.Name),
    'buyer-taxidtype': mkRow('buyer-taxidtype', 'Tipo Doc. Identificación:', xmlData?.buyer?.TaxIDType),
    'buyer-nit': mkRow('buyer-nit', 'NIT:', xmlData?.buyer?.TaxID),
    'buyer-nrc': mkRow('buyer-nrc', 'NRC:', xmlData?.buyer?.NRC),
    'buyer-address': mkRow('buyer-address', 'Dirección:', xmlData?.buyer?.Address),
    'buyer-email': mkRow('buyer-email', 'Correo Electrónico:', xmlData?.buyer?.Email),
  };
  const buyerRows = receptorFieldOrder.map(id => receptorRowMap[id]).filter(Boolean).join('');

  const itemsFieldOrder = (currentConfig.fieldOrders?.items || currentConfig.itemColumns.map(c => c.id)).map(id => id.replace(/^item-col-/, ''));
  const itemColumnMap = {};
  currentConfig.itemColumns.forEach(c => { itemColumnMap[c.id] = c; });
  const orderedItemColumns = itemsFieldOrder.map(id => itemColumnMap[id]).filter(Boolean);

  const colIds = orderedItemColumns.map(() => nextColId());

  const itemHdrs = orderedItemColumns
    .map((c, i) => {
      const rid = colIds[i];
      const st = buildWithOverrides(rid, {
        width: c.width, border: `1px solid ${s.colorBorder}`, padding: '4px',
        backgroundColor: s.colorPrimary, color: 'white', textAlign: 'center',
        fontSize: s.fontSize, position: 'relative',
      });
      return `<th class="${cls('', rid)}" data-rg-id="${rid}" data-field-id="item-col-${c.id}" draggable="true" style="${cssStr(st)}">${c.label}<div class="col-resize-handle" data-col-index="${i}"></div></th>`;
    }).join('');

  const issuedDate = xmlData?.header?.IssuedDateTime || '';
  const formattedDate = issuedDate
    ? `${issuedDate.substring(8, 10)}-${issuedDate.substring(5, 7)}-${issuedDate.substring(0, 4)}`
    : '[Fecha Emisión]';
  const formattedTime = issuedDate ? issuedDate.substring(11, 19) : '';
  const controlNumber = xmlData?.header?.DocType && xmlData?.header?.CodEstPuntoV && xmlData?.header?.Secuencial
    ? `DTE-${xmlData.header.DocType}-${xmlData.header.CodEstPuntoV}-${xmlData.header.Secuencial}`
    : '';
  const numControl = xmlData?.items?.length ? controlNumber : '[Num. Control]';

  const fmtMoney = (v) => { const n = parseFloat(v); return isNaN(n) || n === 0 ? null : n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); };

  const TOTALS_MAP = {
    VENTA_GRAVADA: xmlData?.totals?.TOTAL_GRAVADA,
    VENTA_EXENTA: xmlData?.totals?.TOTAL_EXENTA,
    VENTA_NO_SUJETA: xmlData?.totals?.TOTAL_NO_SUJETA,
    TOTAL_NO_GRAVADO: xmlData?.totals?.TOTAL_NO_GRAVADO,
    SUBTOTAL: xmlData?.totals?.SUBTOTAL,
    DESCUENTO: xmlData?.totals?.TOTAL_DESCUENTO,
    IVA: xmlData?.totals?.IVA,
    IVA_PERCIBIDO: xmlData?.totals?.IVA_PERCIBIDO,
    IVA_RETENIDO: xmlData?.totals?.IVA_RETENIDO,
    RETENCION_RENTA: xmlData?.totals?.RETENCION_RENTA,
    MONTO_TOTAL_OPERACION: xmlData?.totals?.MONTO_TOTAL_OPERACION,
    TOTAL_PAGAR: xmlData?.totals?.TOTAL_PAGAR,
  };

  const totalsFields = currentConfig.totalsFields || [];
  const totalsFieldOrder = (currentConfig.fieldOrders?.totals || totalsFields.map(f => f.id)).map(id => id.replace(/^total-/, ''));
  const totalsFieldMap = {};
  totalsFields.forEach(f => { totalsFieldMap[f.id] = f; });

  const totalRow = (field) => {
    const rid = `total-${field.id}`;
    const val = fmtMoney(TOTALS_MAP[field.id]);
    const isPagar = field.id === 'TOTAL_PAGAR';
    const st = buildWithOverrides(rid, { padding: '4px 8px', border: `1px solid ${s.colorBorder}` });
    const bgStyle = isPagar
      ? `background-color:${s.colorTotalPagarBg};font-weight:bold;font-size:110%`
      : `background-color:${s.colorTotalesBg};font-weight:bold`;
    return `<tr data-rg-id="${rid}" data-field-id="${rid}" draggable="true" class="field-draggable ${cls(isPagar ? 'total-pagar' : 'total-row', rid)}" style="${bgStyle}">
      <td style="${cssStr(st)}">${field.label}</td>
      <td style="${cssStr(st)};text-align:right">${val || '0.00'}</td>
    </tr>`;
  };

  const totalsHtml = totalsFieldOrder
    .map(id => totalsFieldMap[id])
    .filter((f) => f && (f.required || fmtMoney(TOTALS_MAP[f.id]) !== null))
    .map((f) => totalRow(f))
    .join('');

  const logoUrl = xmlData?.seller?.TaxID
    ? `https://digifact-logo.s3.amazonaws.com/SV/logo/${xmlData.seller.TaxID}.jpg`
    : '';

  const qrGuid = xmlData?.header?.GUID || '';
  const qrAmbiente = xmlData?.items?.length ? '00' : '';
  const qrFecha = issuedDate ? issuedDate.substring(0, 10) : '';
  const qrSite = qrGuid ? `https://admin.factura.gob.sv/consultaPublica?ambiente=${qrAmbiente}%7CcodGen=${qrGuid}%7CfechaEmi=${qrFecha}` : '';
  const qrUrl = qrSite ? `https://cert.digifact.com.sv/QRService/api/QR?data=${encodeURIComponent(qrSite)}&size=100x100` : '';

  const makeItemRows = () => {
    const src = xmlData?.items || [];
    const list = src.length ? src : Array.from({ length: 3 }, () => null);
    return list.map((item, i) => {
      const cells = orderedItemColumns.map((c) => {
        const rid = `item-${i}-${c.id}`;
        const isNum = ['Number', 'Qty', 'Price', 'Discount', 'NO_GRAVADO', 'VENTA_NO_SUJETA', 'VENTA_EXENTA', 'VENTA_GRAVADA'].includes(c.id);
        const st = buildWithOverrides(rid, {
          border: `1px solid ${s.colorBorder}`, padding: '4px',
          ...(isNum ? { textAlign: 'right' } : {}),
          fontSize: s.fontSize,
        });
        let v = c.id === 'Number' ? String(i + 1) : item?.[c.id] || '-';
        return `<td data-rg-id="${rid}" style="${cssStr(st)}">${v}</td>`;
      }).join('');
      return `<tr>${cells}</tr>`;
    }).join('');
  };

  const renderSection = (sec) => {
    if (sec === 'emisor') {
      const emisorSt = buildWithOverrides('section-emisor', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const emisorInnerSt = buildWithOverrides('emisor', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const emisorHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-emisor" data-drag-section="emisor" class="${cls('section', 'section-emisor')}" draggable="true"
        style="${cssStr(emisorSt)}">
        ${emisorHandles}
        <div data-rg-id="emisor" class="${cls('section', 'emisor')}" style="${cssStr(emisorInnerSt)}">
          <div style="text-align:center;font-weight:bold;margin-bottom:4px">EMISOR</div>
          <div data-rg-id="section-seller" class="${cls('section', 'section-seller')}" style="border:1px solid ${s.colorBorder};border-radius:5px;height:calc(100% - 24px);box-sizing:border-box">
            <table width="100%" height="100%" cellPadding="0" cellSpacing="0" border="0">${sellerRows}</table>
          </div>
        </div>
      </div>`;
    }
    if (sec === 'receptor') {
      const receptorSt = buildWithOverrides('section-receptor', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const receptorInnerSt = buildWithOverrides('receptor', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const receptorHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-receptor" data-drag-section="receptor" class="${cls('section', 'section-receptor')}" draggable="true"
        style="${cssStr(receptorSt)}">
        ${receptorHandles}
        <div data-rg-id="receptor" class="${cls('section', 'receptor')}" style="${cssStr(receptorInnerSt)}">
          <div style="text-align:center;font-weight:bold;margin-bottom:4px">RECEPTOR</div>
          <div data-rg-id="section-buyer" class="${cls('section', 'section-buyer')}" style="border:1px solid ${s.colorBorder};border-radius:5px;height:calc(100% - 24px);box-sizing:border-box">
            <table width="100%" height="100%" cellPadding="0" cellSpacing="0" border="0">${buyerRows}</table>
          </div>
        </div>
      </div>`;
    }
    if (sec === 'items') {
      const itemsSt = buildWithOverrides('section-items', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const itemsHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-items" data-drag-section="items" class="${cls('section', 'section-items')}" draggable="true"
        style="${cssStr(itemsSt)}">
        ${itemsHandles}
        <table data-rg-id="table-items" class="${cls('items-table', 'table-items')}" style="width:100%;border-collapse:collapse">
          <thead><tr>${itemHdrs}</tr></thead>
          <tbody>${makeItemRows()}</tbody>
        </table>
      </div>`;
    }
    if (sec === 'totals' && totalsHtml) {
      const totalsSt = buildWithOverrides('section-totals', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const totalsInnerSt = buildWithOverrides('totals', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const totalsHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-totals" data-drag-section="totals" class="${cls('section', 'section-totals')}" draggable="true"
        style="${cssStr(totalsSt)}">
        ${totalsHandles}
        <div data-rg-id="totals" class="${cls('totals-section', 'totals')}" style="${cssStr(totalsInnerSt)}">
          <table class="totals-table" style="width:100%;height:100%;border-collapse:collapse">
            ${totalsHtml}
          </table>
        </div>
      </div>`;
    }
    if (sec === 'observaciones') {
      const obsSt = buildWithOverrides('section-observaciones', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const obsInnerSt = buildWithOverrides('observaciones', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const obsHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-observaciones" data-drag-section="observaciones" class="${cls('section', 'section-observaciones')}" draggable="true"
        style="${cssStr(obsSt)}">
        ${obsHandles}
        <div data-rg-id="observaciones" class="${cls('section', 'observaciones')}" style="${cssStr(obsInnerSt)}">
          <div style="border:1px solid ${s.colorBorder};border-radius:5px;height:100%;box-sizing:border-box;display:flex;flex-direction:column">
            <div style="flex:1;padding:4px">
              <span style="font-weight:bold">Valor en Letras:&nbsp;</span>${xmlData?.inWords || '[Valor en Letras]'}
            </div>
            <div style="padding:4px">
              <span style="font-weight:bold">Condición de la Operación:&nbsp;</span>${xmlData?.condicionOperacion || '[Condición de la Operación]'}
            </div>
            ${(xmlData?.payments || []).map((p) => `
              <div style="padding:4px">
                <span style="font-weight:bold">Forma de Pago:&nbsp;</span>${p.label}${p.amount && p.amount !== '0.00' ? ` (${p.amount})` : ''}
              </div>
            `).join('')}
          </div>
        </div>
      </div>`;
    }
    if (sec === 'datos-adicionales') {
      const daSt = buildWithOverrides('section-datos-adicionales', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const daInnerSt = buildWithOverrides('datos-adicionales', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const daHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      const daRow = (label) => `<tr data-rg-id="da-${label}" data-field-id="da-${label}" class="field-draggable" draggable="true">
        <td style="font-weight:bold;white-space:nowrap;padding:2px 4px;width:35%">${label}:&nbsp;</td>
        <td style="padding:2px 4px">${xmlData?.adenda?.[label] || `[${label}]`}</td>
      </tr>`;
      return `<div data-rg-id="section-datos-adicionales" data-drag-section="datos-adicionales" class="${cls('section', 'section-datos-adicionales')}" draggable="true"
        style="${cssStr(daSt)}">
        ${daHandles}
        <div data-rg-id="datos-adicionales" class="${cls('section', 'datos-adicionales')}" style="${cssStr(daInnerSt)}">
          <div style="border:1px solid ${s.colorBorder};border-radius:5px;height:100%;box-sizing:border-box;padding:4px">
            <table width="100%" cellPadding="0" cellSpacing="0" border="0">
              <tbody>
                ${daRow('REFERENCIA_INTERNA')}
                ${daRow('CodigoCliente')}
                ${daRow('Num_OrdenCompra')}
                ${daRow('CondicionPago')}
                ${daRow('NRC_COF')}
                ${daRow('FechaVencimiento')}
              </tbody>
            </table>
          </div>
        </div>
      </div>`;
    }
    if (sec === 'footer') {
      const footerOv = overrides['footer'] || {};
      const footerSt = buildWithOverrides('section-footer', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const footerInnerSt = buildWithOverrides('footer', { textAlign: footerOv.textAlign || 'center', paddingTop: '10px', paddingBottom: '10px', borderTop: `1px solid ${s.colorBorder}`, fontSize: '80%', color: '#666', height: '100%', boxSizing: 'border-box' });
      const resizeHandles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-footer" data-drag-section="footer" class="${cls('section', 'section-footer')}" draggable="true"
        style="${cssStr(footerSt)}">
        ${resizeHandles}
        <div data-rg-id="footer" class="${cls('footer', 'footer')}" style="${cssStr(footerInnerSt)}">
          ${buildFooterText(xmlData, userStyle.footerText || 'DIGIFACT SERVICIOS, SOCIEDAD ANONIMA https://www.digifact.com.sv, NIT 0614-230822-102-5, NRC 318270-1')}
        </div>
      </div>`;
    }
    return '';
  };

  const layoutGrid = currentConfig.layoutGrid || [['emisor', 'receptor'], ['items'], ['totals', 'observaciones'], ['datos-adicionales'], ['footer']];

  const gridHtml = layoutGrid.map((row, rowIdx) => {
    const cellsHtml = row.map(sec => renderSection(sec)).join('');
    return `<div data-rg-id="grid-row-${rowIdx}" style="display:flex;gap:8px;margin-bottom:15px;align-items:flex-start">${cellsHtml}</div>`;
  }).join('');

  const renderHeaderSection = (sec) => {
    if (sec === 'header-logo') {
      const outerSt = buildWithOverrides('section-header-logo', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const innerSt = buildWithOverrides('header-logo', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', alignItems: 'center' });
      const handles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-header-logo" data-drag-section="header-logo" class="${cls('section', 'section-header-logo')}" draggable="true"
        style="${cssStr(outerSt)}">
        ${handles}
        <div data-rg-id="header-logo" class="${cls('section', 'header-logo')}" style="${cssStr(innerSt)}">
          ${logoUrl ? `<img src="${logoUrl}" width="150" alt="[logo]" style="display:block" />` : '<div style="width:150px;height:60px;border:1px dashed #ccc;display:flex;align-items:center;justify-content:center;color:#999;font-size:10px">Logo</div>'}
        </div>
      </div>`;
    }
    if (sec === 'header-ids') {
      const outerSt = buildWithOverrides('section-header-ids', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const innerSt = buildWithOverrides('header-ids', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const handles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-header-ids" data-drag-section="header-ids" class="${cls('section', 'section-header-ids')}" draggable="true"
        style="${cssStr(outerSt)}">
        ${handles}
        <div data-rg-id="header-ids" class="${cls('section', 'header-ids')}" style="${cssStr(innerSt)}">
          <div data-rg-id="header-guid" class="${cls('header-guid', 'header-guid')}" style="font-weight:700;font-size:9pt;line-height:1.6">
            <strong>Código de Generación: </strong>${xmlData?.header?.GUID || '[GUID]'}<br/>
            <strong>Número de Control: </strong>${numControl}<br/>
            <strong>Sello de Recepción: </strong><span style="font-weight:normal">${xmlData?.header?.ReceptionSeal || '[Sello de Recepción]'}</span>
          </div>
        </div>
      </div>`;
    }
    if (sec === 'header-qr') {
      const outerSt = buildWithOverrides('section-header-qr', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const innerSt = buildWithOverrides('header-qr', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', justifyContent: 'center', alignItems: 'flex-end' });
      const handles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-header-qr" data-drag-section="header-qr" class="${cls('section', 'section-header-qr')}" draggable="true"
        style="${cssStr(outerSt)}">
        ${handles}
        <div data-rg-id="header-qr" class="${cls('section', 'header-qr')}" style="${cssStr(innerSt)}">
          ${qrUrl ? `<img src="${qrUrl}" width="125" height="125" alt="QR" />` : '<div style="width:125px;height:125px;border:1px dashed #ccc;display:flex;align-items:center;justify-content:center;color:#999;font-size:10px">QR</div>'}
        </div>
      </div>`;
    }
    if (sec === 'header-info') {
      const outerSt = buildWithOverrides('section-header-info', { flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px' });
      const innerSt = buildWithOverrides('header-info', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', fontWeight: '700', fontSize: '9pt', lineHeight: '1.6' });
      const handles = `<div data-resize="n" draggable="false" style="position:absolute;top:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="w" draggable="false" style="position:absolute;left:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="e" draggable="false" style="position:absolute;right:-3px;top:0;width:6px;height:100%;cursor:ew-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="h" draggable="false" style="position:absolute;bottom:-3px;left:0;width:100%;height:6px;cursor:ns-resize;z-index:10;pointer-events:auto"></div>
        <div data-resize="he" draggable="false" style="position:absolute;bottom:-3px;right:-3px;width:12px;height:12px;cursor:nwse-resize;z-index:10;pointer-events:auto"></div>`;
      return `<div data-rg-id="section-header-info" data-drag-section="header-info" class="${cls('section', 'section-header-info')}" draggable="true"
        style="${cssStr(outerSt)}">
        ${handles}
        <div data-rg-id="header-info" class="${cls('section', 'header-info')}" style="${cssStr(innerSt)}">
          <div><strong>Modelo de Facturación: </strong>Previo</div>
          <div><strong>Tipo de Transmisión: </strong>Normal</div>
          <div><strong>Fecha y Hora de Generación: </strong>${formattedDate} Hora: ${formattedTime}</div>
        </div>
      </div>`;
    }
    return '';
  };

  const headerLayoutGrid = currentConfig.headerLayoutGrid || [['header-logo'], ['header-ids', 'header-qr', 'header-info']];
  const headerGridHtml = headerLayoutGrid.map((row, rowIdx) => {
    const cellsHtml = row.map(sec => renderHeaderSection(sec)).join('');
    return `<div data-rg-id="header-row-${rowIdx}" style="display:flex;gap:8px;margin-top:10px;align-items:flex-end">${cellsHtml}</div>`;
  }).join('');

  const headerTitleSt = buildWithOverrides('header-title', { textAlign: 'center', fontWeight: '700', fontSize: '14pt', color: s.colorPrimary });

  return `<div style="font-family:${s.fontFamily};font-size:${s.fontSize};color:${s.colorFont}">
    <div data-rg-id="header" class="${cls('header', 'header')}" style="margin-bottom:15px">
      <div data-rg-id="header-title" class="${cls('doc-type', 'doc-type')}" style="${cssStr(headerTitleSt)}">
        DOCUMENTO TRIBUTARIO ELECTRÓNICO<br/>${docTitle || currentConfig.title}
      </div>
      <div style="display:flex;justify-content:flex-end;font-weight:700;white-space:nowrap">Ver. ${xmlData?.header?.Version || '1.0'}</div>
      ${headerGridHtml}
    </div>

    ${gridHtml}
  </div>`;
}
