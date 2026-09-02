import { useEffect, useRef } from 'react';

export default function useResize(containerRef, setOverrides, renderKey, setRenderKey) {
  const state = useRef(null);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const onMouseDown = (e) => {
      const handle = e.target.closest('[data-resize]');
      if (!handle) return;

      e.preventDefault();
      e.stopPropagation();

      const dir = handle.getAttribute('data-resize');
      const section = handle.closest('[data-drag-section]');
      if (!section) return;

      const sectionName = section.getAttribute('data-drag-section');
      const rgId = 'section-' + sectionName;
      const rect = section.getBoundingClientRect();

      el.querySelectorAll('[draggable="true"]').forEach(n => {
        n.setAttribute('draggable', 'false');
      });
      handle.style.pointerEvents = 'auto';

      state.current = {
        dir, rgId, startX: e.clientX, startY: e.clientY,
        startW: rect.width, startH: rect.height,
        offLeft: section.offsetLeft, offTop: section.offsetTop,
        maxW: el.clientWidth, maxH: el.clientHeight,
        el: section,
      };

      if (dir === 'e' || dir === 'w') document.body.style.cursor = 'ew-resize';
      else if (dir === 'h' || dir === 'n') document.body.style.cursor = 'ns-resize';
      else document.body.style.cursor = 'nwse-resize';

      document.body.style.userSelect = 'none';
    };

    const onMouseMove = (e) => {
      if (!state.current) return;
      e.preventDefault();

      const { dir, startX, startY, startW, startH, offLeft, offTop, maxW, maxH, el: sectionEl } = state.current;
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;

      const clamp = (v, min, max) => Math.min(Math.max(v, min), Math.max(min, max));

      if (dir === 'e' || dir === 'he') {
        const w = clamp(startW + dx, 50, maxW - offLeft);
        sectionEl.style.width = w + 'px';
      }
      if (dir === 'w') {
        const w = clamp(startW - dx, 50, offLeft + startW);
        sectionEl.style.width = w + 'px';
      }
      if (dir === 'h' || dir === 'he') {
        const h = clamp(startH + dy, 20, maxH - offTop);
        sectionEl.style.height = h + 'px';
      }
      if (dir === 'n') {
        const h = clamp(startH - dy, 20, offTop + startH);
        sectionEl.style.height = h + 'px';
      }

      sectionEl.style.flex = 'none';
    };

    const onMouseUp = () => {
      if (!state.current) return;

      const { rgId, el: sectionEl } = state.current;
      const w = sectionEl.style.width;
      const h = sectionEl.style.height;

      state.current = null;
      document.body.style.cursor = '';
      document.body.style.userSelect = '';

      setOverrides((prev) => ({
        ...prev,
        [rgId]: { ...(prev[rgId] || {}), ...(w ? { width: w } : {}), ...(h ? { height: h } : {}) },
      }));

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
  }, [containerRef, setOverrides, renderKey, setRenderKey]);
}
