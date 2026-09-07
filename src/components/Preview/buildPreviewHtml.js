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


  const sectionVerticalSpacing = (rid, sectionKey) => {
    const self = overrides[rid] || {};
    const section = overrides[sectionKey] || {};
    const mTop = self.marginTop || section.marginTop;
    const mBottom = self.marginBottom || section.marginBottom;
    const gapX = self.separationX || section.separationX;
    return {
      paddingTop: mTop,
      paddingBottom: mBottom,
      gapX,
    };
  };

  const labelWidthFor = (rid) => {
    let sectionKey;
    if (rid.startsWith('seller-')) sectionKey = 'section-emisor';
    else if (rid.startsWith('buyer-')) sectionKey = 'section-receptor';
    else if (rid.startsWith('total-')) sectionKey = 'section-totals';
    else sectionKey = 'section-datos-adicionales';
    return overrides[sectionKey]?.labelWidth || '35%';
  };

  const tdLabel = (rid, label, sp) => {
    const st = buildWithOverrides(rid, { fontWeight: 'bold', width: labelWidthFor(rid), whiteSpace: 'nowrap', padding: '2px 4px' });
    delete st.marginTop;
    delete st.marginBottom;
    delete st.separationX;
    if (sp?.paddingTop) st.paddingTop = sp.paddingTop;
    if (sp?.paddingBottom) st.paddingBottom = sp.paddingBottom;
    const colHandle = `<div class="col-resize-handle" data-label-resize="1"></div>`;
    return `<td style="position:relative;${cssStr(st)}">${label}${colHandle}</td>`;
  };
  const tdVal = (rid, val, sp) => {
    const st = buildWithOverrides(`${rid}-val`, { padding: '2px 4px' });
    delete st.marginTop;
    delete st.marginBottom;
    delete st.separationX;
    if (sp?.paddingTop) st.paddingTop = sp.paddingTop;
    if (sp?.paddingBottom) st.paddingBottom = sp.paddingBottom;
    if (sp?.gapX) st.paddingLeft = sp.gapX;
    return `<td style="${cssStr(st)}">${val}</td>`;
  };

  const mkRow = (rid, label, val) => {
    if (!val) return '';
    const sectionKey = rid.startsWith('seller-') ? 'emisor' : rid.startsWith('buyer-') ? 'receptor' : null;
    const sp = sectionKey ? sectionVerticalSpacing(rid, sectionKey) : null;
    return `<tr data-rg-id="${rid}" data-field-id="${rid}" draggable="true" class="field-draggable">${tdLabel(rid, label, sp)}${tdVal(rid, val, sp)}</tr>`;
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

  const colIds = orderedItemColumns.map(c => `col-${c.id}`);

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
    const rowHandle = `<div data-resize="row" style="position:absolute;left:0;right:0;bottom:-4px;height:7px;z-index:30;cursor:ns-resize;pointer-events:auto"></div>`;
    const labelColHandle = `<div class="col-resize-handle" data-label-resize="1"></div>`;
    const labelStyle = `position:relative;width:${labelWidthFor(rid)};${cssStr(st)}`;
    const valStyle = `${cssStr(st)};text-align:right`;
    return `<tr data-rg-id="${rid}" data-field-id="${rid}" draggable="true" class="field-draggable ${cls(isPagar ? 'total-pagar' : 'total-row', rid)}" style="position:relative;${bgStyle}">
      <td style="${labelStyle}">${field.label}${labelColHandle}${rowHandle}</td>
      <td style="${valStyle}">${val || '0.00'}</td>
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

  const sectionOuterStyle = (extra = {}) => ({ flex: '1', minWidth: '0', cursor: 'grab', position: 'relative', minHeight: '40px', overflow: 'hidden', ...extra });

  const sectionHandles = () => `<div data-resize="n" draggable="false" style="position:absolute;top:0;left:0;width:100%;height:6px;cursor:ns-resize;z-index:20;pointer-events:auto"></div>
    <div data-resize="w" draggable="false" style="position:absolute;left:0;top:0;width:6px;height:100%;cursor:ew-resize;z-index:20;pointer-events:auto"></div>
    <div data-resize="e" draggable="false" style="position:absolute;right:0;top:0;width:6px;height:100%;cursor:ew-resize;z-index:20;pointer-events:auto"></div>
    <div data-resize="h" draggable="false" style="position:absolute;bottom:0;left:0;width:100%;height:6px;cursor:ns-resize;z-index:20;pointer-events:auto"></div>
    <div data-resize="he" draggable="false" style="position:absolute;bottom:0;right:0;width:12px;height:12px;cursor:nwse-resize;z-index:20;pointer-events:auto"></div>`;

  const renderSection = (sec) => {
    if (sec === 'emisor') {
      const emisorSt = buildWithOverrides('section-emisor', sectionOuterStyle());
      const emisorInnerMerged = buildWithOverrides('emisor', { height: '100%', width: '100%', boxSizing: 'border-box' });
      delete emisorInnerMerged.marginTop;
      delete emisorInnerMerged.marginBottom;
      delete emisorInnerMerged.separationX;
      delete emisorInnerMerged.separationY;
      const emisorInnerSt = emisorInnerMerged;
      const emisorHandles = sectionHandles();
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
      const receptorSt = buildWithOverrides('section-receptor', sectionOuterStyle());
      const receptorInnerMerged = buildWithOverrides('receptor', { height: '100%', width: '100%', boxSizing: 'border-box' });
      delete receptorInnerMerged.marginTop;
      delete receptorInnerMerged.marginBottom;
      delete receptorInnerMerged.separationX;
      delete receptorInnerMerged.separationY;
      const receptorInnerSt = receptorInnerMerged;
      const receptorHandles = sectionHandles();
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
      const itemsSt = buildWithOverrides('section-items', sectionOuterStyle());
      const itemsHandles = sectionHandles();
      return `<div data-rg-id="section-items" data-drag-section="items" class="${cls('section', 'section-items')}" draggable="true"
        style="${cssStr(itemsSt)}">
        ${itemsHandles}
        <table data-rg-id="table-items" class="${cls('items-table', 'table-items')}" style="width:100%;height:100%;border-collapse:collapse">
          <thead><tr>${itemHdrs}</tr></thead>
          <tbody>${makeItemRows()}</tbody>
        </table>
      </div>`;
    }
    if (sec === 'totals' && totalsHtml) {
      const totalsSt = buildWithOverrides('section-totals', sectionOuterStyle());
      const totalsInnerSt = buildWithOverrides('totals', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const totalsHandles = sectionHandles();
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
      const obsSt = buildWithOverrides('section-observaciones', sectionOuterStyle());
      const obsInnerMerged = buildWithOverrides('observaciones', { height: '100%', width: '100%', boxSizing: 'border-box' });
      delete obsInnerMerged.marginTop;
      delete obsInnerMerged.marginBottom;
      delete obsInnerMerged.separationX;
      delete obsInnerMerged.separationY;
      const obsInnerSt = obsInnerMerged;
      const obsHandles = sectionHandles();
      const obsAlign = overrides['observaciones']?.textAlign;
      const obsAlignCss = obsAlign ? `text-align:${obsAlign};` : '';
      const obsFields = [
        { id: 'VALOR_EN_LETRAS', label: 'Valor en Letras' },
        { id: 'CONDICION_OPERACION', label: 'Condición de la Operación' },
        { id: 'FORMA_DE_PAGO', label: 'Forma de Pago' },
      ];
      const obsOrder = (currentConfig.fieldOrders?.observaciones || obsFields.map((f) => `obs-${f.id}`))
        .map((id) => id.replace(/^obs-/, ''));
      const obsById = {};
      obsFields.forEach((f) => { obsById[f.id] = f; });
      const orderedObs = obsOrder.map((id) => obsById[id]).filter(Boolean);
      const sectionOv = overrides['observaciones'] || {};
      const sectionMarginTop = sectionOv.marginTop;
      const sectionMarginBottom = sectionOv.marginBottom;
      const sectionSepX = sectionOv.separationX;
      const obsRow = (field) => {
        const rid = `obs-${field.id}`;
        const fieldOv = overrides[rid] || {};
        const fieldAlign = fieldOv.textAlign || obsAlign || 'left';
        const gapX = fieldOv.separationX || sectionSepX;
        const mTop = fieldOv.marginTop || sectionMarginTop;
        const mBottom = fieldOv.marginBottom || sectionMarginBottom;
        let val;
        if (field.id === 'VALOR_EN_LETRAS') {
          val = xmlData?.inWords || '[Valor en Letras]';
        } else if (field.id === 'CONDICION_OPERACION') {
          val = xmlData?.condicionOperacion || '[Condición de la Operación]';
        } else if (field.id === 'FORMA_DE_PAGO') {
          const pmts = xmlData?.payments || [];
          val = pmts.length
            ? pmts.map((p) => `${p.label}${p.amount && p.amount !== '0.00' ? ' (' + p.amount + ')' : ''}`).join(', ')
            : '[Forma de Pago]';
        }
        const alignCss = fieldAlign === 'center' ? 'justify-content:center;text-align:center;' : fieldAlign === 'right' ? 'justify-content:flex-end;text-align:right;' : 'justify-content:flex-start;text-align:left;';
        const rowHandle = `<div data-resize="row" style="position:absolute;left:0;right:0;bottom:-4px;height:7px;z-index:30;cursor:ns-resize;pointer-events:auto"></div>`;
        const rowPadTop = fieldOv.paddingTop ? 'padding-top:' + fieldOv.paddingTop + ';' : '';
        const rowPadBottom = fieldOv.paddingBottom ? 'padding-bottom:' + fieldOv.paddingBottom + ';' : '';
        return `<div data-rg-id="${rid}" data-field-id="${rid}" class="field-draggable" draggable="true"
          style="position:relative;display:flex;${alignCss}padding:2px 4px;${gapX ? 'gap:' + gapX + ';' : ''}${mTop ? 'margin-top:' + mTop + ';' : ''}${mBottom ? 'margin-bottom:' + mBottom + ';' : ''}${rowPadTop}${rowPadBottom}flex-wrap:wrap;align-items:baseline">
          ${rowHandle}
          <span style="font-weight:bold;white-space:nowrap;flex-shrink:0">${field.label}:&nbsp;</span>
          <span style="min-width:0">${val}</span>
        </div>`;
      };
      const justify = obsAlign === 'center' ? 'center' : obsAlign === 'right' ? 'flex-end' : 'flex-start';
      return `<div data-rg-id="section-observaciones" data-drag-section="observaciones" class="${cls('section', 'section-observaciones')}" draggable="true"
        style="${cssStr(obsSt)}">
        ${obsHandles}
        <div data-rg-id="observaciones" class="${cls('section', 'observaciones')}" style="${cssStr(obsInnerSt)}">
          <div style="border:1px solid ${s.colorBorder};border-radius:5px;height:100%;box-sizing:border-box;display:flex;flex-direction:column;justify-content:${justify};${obsAlignCss}">
            ${orderedObs.map((f) => obsRow(f)).join('')}
          </div>
        </div>
      </div>`;
    }
    if (sec === 'datos-adicionales') {
      const daSt = buildWithOverrides('section-datos-adicionales', sectionOuterStyle());
      const daInnerMerged = buildWithOverrides('datos-adicionales', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', flexDirection: 'column' });
      delete daInnerMerged.marginTop;
      delete daInnerMerged.marginBottom;
      delete daInnerMerged.separationX;
      delete daInnerMerged.separationY;
      const daInnerSt = daInnerMerged;
      const daHandles = sectionHandles();
      const daAlign = overrides['datos-adicionales']?.textAlign;
      const daBoxAlign = daAlign ? `text-align:${daAlign};` : '';
      const daGap = overrides['datos-adicionales']?.gap ? `gap:${overrides['datos-adicionales'].gap};` : '';
      const adendaFields = currentConfig.adendaFields?.length
        ? currentConfig.adendaFields
        : (xmlData?.adendaDefaults || []);
      if (!adendaFields.length) return '';
      const daFields = adendaFields.map((f) => {
        if (!f) return null;
        const name = f.id || f.name;
        return { field: f, name };
      }).filter(Boolean);
      const adendaOrder = (currentConfig.fieldOrders?.['datos-adicionales'] || daFields.map((f) => `da-${f.name}`))
        .map((id) => id.replace(/^da-/, ''));
      const idToField = {};
      daFields.forEach((f) => { idToField[f.name] = f; });
      const orderedDaFields = adendaOrder.map((name) => idToField[name]).filter(Boolean);
      const daRow = (field) => {
        const label = field.label || field.name || field.id;
        const name = field.name;
        const rid = `da-${name}`;
        const alignOv = overrides[rid] || {};
        const alignVal = alignOv.textAlign;
        const daSecOv = overrides['datos-adicionales'] || {};
        const padTop = alignOv.marginTop || daSecOv.marginTop;
        const padBottom = alignOv.marginBottom || daSecOv.marginBottom;
        const gapX = alignOv.separationX || daSecOv.separationX;
        const labelSt = { fontWeight: 'bold', whiteSpace: 'nowrap', padding: '2px 4px', width: labelWidthFor(rid) };
        const valSt = { padding: '2px 4px' };
        if (padTop) { labelSt.paddingTop = padTop; valSt.paddingTop = padTop; }
        if (padBottom) { labelSt.paddingBottom = padBottom; valSt.paddingBottom = padBottom; }
        if (gapX) valSt.paddingLeft = gapX;
        const labelOv = buildWithOverrides(rid, labelSt);
        delete labelOv.marginTop; delete labelOv.marginBottom; delete labelOv.separationX;
        const labelCss = cssStr({ ...labelOv, ...(alignVal ? { textAlign: alignVal } : {}) });
        const valOv = buildWithOverrides(`${rid}-val`, valSt);
        delete valOv.marginTop; delete valOv.marginBottom; delete valOv.separationX;
        const valCss = cssStr({ ...valOv, ...(alignVal ? { textAlign: alignVal } : {}) });
        const daColHandle = `<div class="col-resize-handle" data-label-resize="1"></div>`;
        return `<tr data-rg-id="${rid}" data-field-id="${rid}" class="field-draggable" draggable="true">
        <td style="position:relative;${labelCss}">${label}:&nbsp;${daColHandle}</td>
        <td style="${valCss}">${xmlData?.adenda?.[name] || `[${label}]`}</td>
      </tr>`;
      };
      return `<div data-rg-id="section-datos-adicionales" data-drag-section="datos-adicionales" class="${cls('section', 'section-datos-adicionales')}" draggable="true"
        style="${cssStr(daSt)}">
        ${daHandles}
        <div data-rg-id="datos-adicionales" class="${cls('section', 'datos-adicionales')}" style="${cssStr(daInnerSt)}">
          <div style="border:1px solid ${s.colorBorder};border-radius:5px;height:100%;box-sizing:border-box;display:flex;flex-direction:column;padding:4px;${daBoxAlign}${daGap}">
            <table width="100%" cellPadding="0" cellSpacing="0" border="0">
              <tbody>
                ${orderedDaFields.map((f) => daRow(f)).join('')}
              </tbody>
            </table>
          </div>
        </div>
      </div>`;
    }
    if (sec === 'footer') {
      const footerOv = overrides['footer'] || {};
      const footerSt = buildWithOverrides('section-footer', sectionOuterStyle());
      const footerInnerSt = buildWithOverrides('footer', { textAlign: footerOv.textAlign || 'center', paddingTop: '10px', paddingBottom: '10px', borderTop: `1px solid ${s.colorBorder}`, fontSize: '80%', color: '#666', height: '100%', boxSizing: 'border-box' });
      const resizeHandles = sectionHandles();
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
    return `<div data-rg-id="grid-row-${rowIdx}" style="display:flex;gap:8px;margin-bottom:15px;align-items:flex-start;overflow:hidden">${cellsHtml}</div>`;
  }).join('');

  const renderHeaderSection = (sec) => {
    if (sec === 'header-logo') {
      const outerSt = buildWithOverrides('section-header-logo', sectionOuterStyle());
      const innerSt = buildWithOverrides('header-logo', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', alignItems: 'center' });
      const handles = sectionHandles();
      return `<div data-rg-id="section-header-logo" data-drag-section="header-logo" class="${cls('section', 'section-header-logo')}" draggable="true"
        style="${cssStr(outerSt)}">
        ${handles}
        <div data-rg-id="header-logo" class="${cls('section', 'header-logo')}" style="${cssStr(innerSt)}">
          ${logoUrl ? `<img src="${logoUrl}" width="150" alt="[logo]" style="display:block" />` : '<div style="width:150px;height:60px;border:1px dashed #ccc;display:flex;align-items:center;justify-content:center;color:#999;font-size:10px">Logo</div>'}
        </div>
      </div>`;
    }
    if (sec === 'header-ids') {
      const outerSt = buildWithOverrides('section-header-ids', sectionOuterStyle());
      const innerSt = buildWithOverrides('header-ids', { height: '100%', width: '100%', boxSizing: 'border-box' });
      const handles = sectionHandles();
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
      const outerSt = buildWithOverrides('section-header-qr', sectionOuterStyle());
      const innerSt = buildWithOverrides('header-qr', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', justifyContent: 'center', alignItems: 'flex-end' });
      const handles = sectionHandles();
      return `<div data-rg-id="section-header-qr" data-drag-section="header-qr" class="${cls('section', 'section-header-qr')}" draggable="true"
        style="${cssStr(outerSt)}">
        ${handles}
        <div data-rg-id="header-qr" class="${cls('section', 'header-qr')}" style="${cssStr(innerSt)}">
          ${qrUrl ? `<img src="${qrUrl}" width="125" height="125" alt="QR" />` : '<div style="width:125px;height:125px;border:1px dashed #ccc;display:flex;align-items:center;justify-content:center;color:#999;font-size:10px">QR</div>'}
        </div>
      </div>`;
    }
    if (sec === 'header-info') {
      const outerSt = buildWithOverrides('section-header-info', sectionOuterStyle());
      const innerSt = buildWithOverrides('header-info', { height: '100%', width: '100%', boxSizing: 'border-box', display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', fontWeight: '700', fontSize: '9pt', lineHeight: '1.6' });
      const handles = sectionHandles();
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
