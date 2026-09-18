import { useEffect, useRef } from 'react';

export default function useResize(containerRef, overrides, setOverrides, renderKey, setRenderKey, active) {
  const state = useRef(null);

  useEffect(() => {
    const el = containerRef.current;
    if (!el || !active) return;
    const eventWindow = el.ownerDocument.defaultView || window;
    const eventBody = el.ownerDocument.body;

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
      const rowEl = dir === 'row' ? (handle.closest('[data-field-id]') || handle.closest('[data-rg-id]')) : null;
      const rgId = dir === 'row'
        ? (rowEl?.getAttribute('data-field-id') || rowEl?.getAttribute('data-rg-id') || '')
        : sectionName;
      if (!rgId) return;

      const targetEl = dir === 'row' ? rowEl : section;
      const rect = targetEl.getBoundingClientRect();
      const pageRect = el.getBoundingClientRect();
      const scale = pageRect.width / (el.offsetWidth || pageRect.width || 1) || 1;

      el.querySelectorAll('[draggable="true"]').forEach(n => {
        n.setAttribute('draggable', 'false');
      });
      handle.style.pointerEvents = 'auto';

      const prevOv = overrides[rgId] || {};
      const startPad = parseFloat(prevOv.paddingTop) || 0;

      state.current = {
        dir, rgId, startX: e.clientX, startY: e.clientY,
        startW: rect.width / scale, startH: rect.height / scale,
        scale,
        maxIndependentWidth: (pageRect.right - rect.left) / scale,
        maxIndependentHeight: (pageRect.bottom - rect.top) / scale,
        el: targetEl, startPad,
      };

      if (dir === 'row') eventBody.style.cursor = 'ns-resize';
      else if (dir === 'e' || dir === 'w') eventBody.style.cursor = 'ew-resize';
      else if (dir === 'h' || dir === 'n') eventBody.style.cursor = 'ns-resize';
      else eventBody.style.cursor = 'nwse-resize';

      eventBody.style.userSelect = 'none';
      el.setAttribute('data-resizing', '1');
    };

    const onMouseMove = (e) => {
      if (!state.current) return;
      e.preventDefault();

      const { dir, startX, startY, startW, startH, maxIndependentWidth, maxIndependentHeight, scale, startPad, el: sectionEl } = state.current;
      const dx = (e.clientX - startX) / scale;
      const dy = (e.clientY - startY) / scale;

      const clamp = (v, min, max) => Math.min(Math.max(v, min), Math.max(min, max));

      if (dir === 'row') {
        const pad = clamp(startPad + dy, 0, 200);
        const cells = sectionEl.tagName === 'TR' ? sectionEl.querySelectorAll('td') : [sectionEl];
        cells.forEach(cell => {
          cell.style.paddingTop = pad + 'px';
          cell.style.paddingBottom = pad + 'px';
        });
        sectionEl.style.flex = 'none';
      } else if (dir === 'e') {
        sectionEl.style.width = clamp(startW + dx, 20, maxIndependentWidth) + 'px';
      } else if (dir === 'w') {
        sectionEl.style.width = clamp(startW - dx, 20, maxIndependentWidth) + 'px';
      } else if (dir === 'h') {
        sectionEl.style.height = clamp(startH + dy, 20, maxIndependentHeight) + 'px';
      } else if (dir === 'n') {
        sectionEl.style.height = clamp(startH - dy, 20, maxIndependentHeight) + 'px';
      } else if (dir === 'he') {
        sectionEl.style.width = clamp(startW + dx, 20, maxIndependentWidth) + 'px';
        sectionEl.style.height = clamp(startH + dy, 20, maxIndependentHeight) + 'px';
      }

      sectionEl.style.flex = 'none';
    };

    const onMouseUp = () => {
      if (!state.current) return;

      const { dir, rgId, startPad, el: sectionEl } = state.current;
      const w = sectionEl.style.width;
      const h = sectionEl.style.height;

      const padTarget = sectionEl.tagName === 'TR' ? sectionEl.querySelector('td') : sectionEl;
      const rowPad = padTarget ? padTarget.style.paddingTop : '';

      state.current = null;
      eventBody.style.cursor = '';
      eventBody.style.userSelect = '';
      el.removeAttribute('data-resizing');

      setOverrides((prev) => {
        const next = { ...(prev[rgId] || {}) };
        if (w) next.width = w;
        if (h) next.height = h;
        if (dir === 'row' && rowPad && rowPad !== `${startPad}px`) {
          next.paddingTop = rowPad;
          next.paddingBottom = rowPad;
        }
        return { ...prev, [rgId]: next };
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
    eventWindow.addEventListener('mousemove', onMouseMove);
    eventWindow.addEventListener('mouseup', onMouseUp);

    return () => {
      el.removeEventListener('mousedown', onMouseDown);
      el.removeEventListener('dragstart', onDragStart, true);
      eventWindow.removeEventListener('mousemove', onMouseMove);
      eventWindow.removeEventListener('mouseup', onMouseUp);
    };
  }, [containerRef, overrides, setOverrides, renderKey, setRenderKey, active]);
}
