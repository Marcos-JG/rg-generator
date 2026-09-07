import { useEffect, useRef } from 'react';

export default function useResize(containerRef, overrides, setOverrides, renderKey, setRenderKey, active) {
  const state = useRef(null);

  useEffect(() => {
    const el = containerRef.current;
    if (!el || !active) return;

    const onMouseDown = (e) => {
      const handle = e.target.closest('[data-resize="row"]')
        || e.target.closest('[data-resize="n"]')
        || e.target.closest('[data-resize="s"]')
        || e.target.closest('[data-resize="e"]')
        || e.target.closest('[data-resize="w"]')
        || e.target.closest('[data-resize="h"]')
        || e.target.closest('[data-resize="he"]');
      if (!handle) return;

      e.preventDefault();
      e.stopPropagation();

      const dir = handle.getAttribute('data-resize');
      const section = handle.closest('[data-drag-section]');
      if (!section) return;

      const sectionName = section.getAttribute('data-drag-section');
      const rgId = dir === 'row'
        ? (handle.closest('[data-field-id]')?.getAttribute('data-field-id') || '')
        : 'section-' + sectionName;
      if (!rgId) return;

      const targetEl = dir === 'row' ? handle.closest('[data-field-id]') : section;
      const rect = targetEl.getBoundingClientRect();

      el.querySelectorAll('[draggable="true"]').forEach(n => {
        n.setAttribute('draggable', 'false');
      });
      handle.style.pointerEvents = 'auto';

      const prevOv = overrides[rgId] || {};
      const startPad = parseFloat(prevOv.paddingTop) || 0;

      const cs = getComputedStyle(el);
      const padL = parseFloat(cs.paddingLeft) || 0;
      const padR = parseFloat(cs.paddingRight) || 0;
      const padT = parseFloat(cs.paddingTop) || 0;
      const padB = parseFloat(cs.paddingBottom) || 0;

      const row = section.parentElement;
      const rowSiblings = row ? Array.from(row.children).filter(c => c.hasAttribute('data-drag-section') && c !== section) : [];
      const sibCount = rowSiblings.length;
      const sibRgIds = rowSiblings.map(c => 'section-' + c.getAttribute('data-drag-section'));
      const rowGap = 8;
      const sibMinW = 50;
      const contentW = el.clientWidth - padL - padR;
      const isFirst = section === row.firstElementChild;

      state.current = {
        dir, rgId, startX: e.clientX, startY: e.clientY,
        startW: rect.width, startH: rect.height,
        offLeft: section.offsetLeft, offTop: section.offsetTop,
        maxW: el.clientWidth, maxH: el.clientHeight,
        padL, padR, padT, padB,
        contentW, isFirst,
        sibCount, rowGap, sibMinW,
        sibRgIds, rowSiblings,
        el: targetEl, startPad,
      };

      if (dir === 'row') document.body.style.cursor = 'ns-resize';
      else if (dir === 'e' || dir === 'w') document.body.style.cursor = 'ew-resize';
      else if (dir === 'h' || dir === 'n') document.body.style.cursor = 'ns-resize';
      else document.body.style.cursor = 'nwse-resize';

      document.body.style.userSelect = 'none';
      el.setAttribute('data-resizing', '1');
    };

    const onMouseMove = (e) => {
      if (!state.current) return;
      e.preventDefault();

      const { dir, startX, startY, startW, startH, offLeft, offTop, maxH, padL, padR, padT, padB, contentW, isFirst, sibCount, rowGap, sibMinW, rowSiblings, startPad, el: sectionEl } = state.current;
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;

      const clamp = (v, min, max) => Math.min(Math.max(v, min), Math.max(min, max));

      if (dir === 'row') {
        const pad = clamp(startPad + dy, 0, 200);
        const cells = sectionEl.tagName === 'TR' ? sectionEl.querySelectorAll('td') : [sectionEl];
        cells.forEach(cell => {
          cell.style.paddingTop = pad + 'px';
          cell.style.paddingBottom = pad + 'px';
        });
        sectionEl.style.flex = 'none';
      } else if (dir === 'e' || dir === 'he') {
        // Right border of this section.
        const totalGap = sibCount * rowGap;
        const totalSibMin = sibCount * sibMinW;
        const maxTarget = contentW - totalSibMin - totalGap;
        if (isFirst && sibCount > 0) {
          // Shared border with the next sibling: move both to keep sum = contentW
          const w = clamp(startW + dx, sibMinW, maxTarget);
          sectionEl.style.flex = 'none';
          sectionEl.style.width = w + 'px';
          const sibW = clamp(contentW - w - totalGap, sibMinW, maxTarget);
          rowSiblings[0].style.flex = 'none';
          rowSiblings[0].style.width = sibW + 'px';
           } else {
          // Last section; right border is page edge. Move both so sum stays = contentW.
          const w = clamp(startW + dx, sibMinW, maxTarget);
          sectionEl.style.flex = 'none';
          sectionEl.style.width = w + 'px';
          if (sibCount > 0) {
            const sibW = clamp(contentW - w - totalGap, sibMinW, maxTarget);
            rowSiblings[0].style.flex = 'none';
            rowSiblings[0].style.width = sibW + 'px';
          }
        }
      } else if (dir === 'w') {
        // Left border of this section.
        const totalGap = sibCount * rowGap;
        const totalSibMin = sibCount * sibMinW;
        const maxTarget = contentW - totalSibMin - totalGap;
        if (!isFirst && sibCount > 0) {
          // Shared border with the previous sibling: move previous inverse
          const w = clamp(startW - dx, sibMinW, maxTarget);
          sectionEl.style.flex = 'none';
          sectionEl.style.width = w + 'px';
          const sibW = clamp(contentW - w - totalGap, sibMinW, maxTarget);
          rowSiblings[0].style.flex = 'none';
          rowSiblings[0].style.width = sibW + 'px';
        } else {
          // First section; left border is page edge -> cannot grow left, only shrink.
          // Shrinking redistributes to the sibling so the row stays full.
          const w = clamp(startW - dx, sibMinW, contentW - (sibCount * sibMinW) - totalGap);
          sectionEl.style.flex = 'none';
          sectionEl.style.width = w + 'px';
          if (sibCount > 0) {
            const sibW = clamp(contentW - w - totalGap, sibMinW, maxTarget);
            rowSiblings[0].style.flex = 'none';
            rowSiblings[0].style.width = sibW + 'px';
          }
        }
      } else if (dir === 'h' || dir === 'he') {
        const maxBottom = maxH - padB;
        const h = clamp(startH + dy, 20, maxBottom - offTop);
        sectionEl.style.height = h + 'px';
      } else if (dir === 'n') {
        const minTop = padT;
        const maxHNorth = offTop + startH - minTop;
        const h = clamp(startH - dy, 20, maxHNorth);
        sectionEl.style.height = h + 'px';
      }

      sectionEl.style.flex = 'none';
    };

    const onMouseUp = () => {
      if (!state.current) return;

      const { dir, rgId, startPad, el: sectionEl, sibRgIds, rowSiblings } = state.current;
      const w = sectionEl.style.width;
      const h = sectionEl.style.height;

      const padTarget = sectionEl.tagName === 'TR' ? sectionEl.querySelector('td') : sectionEl;
      const rowPad = padTarget ? padTarget.style.paddingTop : '';

      state.current = null;
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
      el.removeAttribute('data-resizing');

      setOverrides((prev) => {
        const next = { ...(prev[rgId] || {}) };
        if (w) next.width = w;
        if (h) next.height = h;
        if (dir === 'row' && rowPad && rowPad !== `${startPad}px`) {
          next.paddingTop = rowPad;
          next.paddingBottom = rowPad;
        }
        const updated = { ...prev, [rgId]: next };
        if ((dir === 'e' || dir === 'w') && sibRgIds) {
          sibRgIds.forEach((sibRid, i) => {
            const sibEl = rowSiblings[i];
            if (sibEl && sibEl.style.width) {
              const sibOv = { ...(updated[sibRid] || {}), width: sibEl.style.width };
              updated[sibRid] = sibOv;
            }
          });
        }
        return updated;
      });

      setRenderKey((k) => k + 1);
    };

    const onDragStart = (e) => {
      if (state.current || e.target.closest('[data-resize]')) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    };

    el.addEventListener('mousedown', onMouseDown);
    el.addEventListener('dragstart', onDragStart, true);
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);

    return () => {
      el.removeEventListener('mousedown', onMouseDown);
      el.removeEventListener('dragstart', onDragStart, true);
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }, [containerRef, overrides, setOverrides, renderKey, setRenderKey, active]);
}
