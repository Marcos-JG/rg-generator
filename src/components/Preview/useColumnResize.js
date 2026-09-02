import { useEffect, useRef } from 'react';

export default function useColumnResize(containerRef, setOverrides, renderKey, setRenderKey) {
  const state = useRef(null);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const getThRid = (handle) => {
      const th = handle.closest('th[data-rg-id]');
      return th ? th.getAttribute('data-rg-id') : null;
    };

    const onMouseDown = (e) => {
      const handle = e.target.closest('.col-resize-handle');
      if (!handle) return;
      e.preventDefault();
      e.stopPropagation();

      const th = handle.closest('th[data-rg-id]');
      if (!th) return;

      const rid = th.getAttribute('data-rg-id');
      const startW = th.getBoundingClientRect().width;

      el.querySelectorAll('[draggable="true"]').forEach((n) => n.setAttribute('draggable', 'false'));
      el.setAttribute('data-col-dragging', 'true');

      state.current = { rid, startX: e.clientX, startW, th };
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
    };

    const onMouseMove = (e) => {
      if (!state.current) return;
      e.preventDefault();
      const { th, startX, startW } = state.current;
      const dx = e.clientX - startX;
      const w = Math.max(30, startW + dx);
      th.style.width = w + 'px';
    };

    const onMouseUp = () => {
      if (!state.current) return;
      const { rid, th } = state.current;
      const w = th.style.width;

      state.current = null;
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
      el.removeAttribute('data-col-dragging');

      if (w) {
        setOverrides((prev) => ({
          ...prev,
          [rid]: { ...(prev[rid] || {}), width: w },
        }));
      }
      setRenderKey((k) => k + 1);
    };

    const onDragStart = (e) => {
      if (state.current || e.target.closest('.col-resize-handle')) {
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
