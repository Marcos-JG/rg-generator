import { useEffect, useRef } from 'react';

export default function useColumnResize(containerRef, setOverrides, renderKey, setRenderKey, active) {
  const state = useRef(null);

  useEffect(() => {
    const el = containerRef.current;
    if (!el || !active) return;

    const onMouseDown = (e) => {
      const handle = e.target.closest('.col-resize-handle');
      if (!handle) return;
      e.preventDefault();
      e.stopPropagation();

      if (handle.hasAttribute('data-label-resize')) {
        const td = handle.closest('td');
        if (!td) return;
        const section = td.closest('[data-drag-section]');
        if (!section) return;

        const sectionName = section.getAttribute('data-drag-section');
        const sectionRid = 'section-' + sectionName;
        const startW = td.getBoundingClientRect().width;

        el.querySelectorAll('[draggable="true"]').forEach((n) => n.setAttribute('draggable', 'false'));
        el.setAttribute('data-col-dragging', 'true');

        state.current = { type: 'label', sectionRid, section, startX: e.clientX, startW };
        document.body.style.cursor = 'col-resize';
        document.body.style.userSelect = 'none';
        return;
      }

      const th = handle.closest('th[data-rg-id]');
      if (!th) return;

      const rid = th.getAttribute('data-rg-id');
      const startW = th.getBoundingClientRect().width;

      el.querySelectorAll('[draggable="true"]').forEach((n) => n.setAttribute('draggable', 'false'));
      el.setAttribute('data-col-dragging', 'true');

      state.current = { type: 'col', rid, startX: e.clientX, startW, th };
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
    };

    const onMouseMove = (e) => {
      if (!state.current) return;
      e.preventDefault();

      const s = state.current;
      const dx = e.clientX - s.startX;

      if (s.type === 'label') {
        const sectionW = s.section.getBoundingClientRect().width;
        const w = Math.max(30, Math.min(s.startW + dx, sectionW - 20));
        s.section.querySelectorAll('tr[data-field-id] > td:first-child').forEach(td => {
          td.style.width = w + 'px';
        });
      } else {
        const table = s.th.closest('table');
        const tableW = table ? table.getBoundingClientRect().width : el.clientWidth;
        const numCols = table ? table.querySelectorAll('th').length : 1;
        const maxW = Math.max(50, tableW - (numCols - 1) * 30);
        const w = Math.max(30, Math.min(s.startW + dx, maxW));
        s.th.style.width = w + 'px';
      }
    };

    const onMouseUp = () => {
      if (!state.current) return;
      const s = state.current;

      state.current = null;
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
      el.removeAttribute('data-col-dragging');

      if (s.type === 'label') {
        const firstTd = s.section.querySelector('tr[data-field-id] > td:first-child');
        const labelWidth = firstTd ? firstTd.style.width : '';
        if (labelWidth) {
          setOverrides((prev) => ({
            ...prev,
            [s.sectionRid]: { ...(prev[s.sectionRid] || {}), labelWidth },
          }));
        }
      } else {
        const w = s.th.style.width;
        if (w) {
          setOverrides((prev) => ({
            ...prev,
            [s.rid]: { ...(prev[s.rid] || {}), width: w },
          }));
        }
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
  }, [containerRef, setOverrides, renderKey, setRenderKey, active]);
}
