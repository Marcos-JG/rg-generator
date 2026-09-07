import { useState, useEffect, useCallback } from 'react';
import { useHistoryStore } from '../../stores/historyStore';
import { useConfigStore } from '../../stores/configStore';
import { findSelectable, findTextContent } from './helpers';

export default function useSelection(containerRef, overrides, setOverrides, renderKey, setRenderKey) {
  const [hovered, setHovered] = useState('');
  const [selected, setSelected] = useState('');
  const setDocTitle = useConfigStore((s) => s.setDocTitle);

  const saveSnapshot = useHistoryStore((s) => s.snapshot);
  const undoHist = useHistoryStore((s) => s.undo);
  const redoHist = useHistoryStore((s) => s.redo);

  const applyUndo = useCallback(() => {
    const s = undoHist();
    if (s && containerRef.current) {
      const data = JSON.parse(s);
      setOverrides(data.overrides || {});
      setRenderKey((k) => k + 1);
    }
  }, [undoHist]);

  const applyRedo = useCallback(() => {
    const s = redoHist();
    if (s && containerRef.current) {
      const data = JSON.parse(s);
      setOverrides(data.overrides || {});
      setRenderKey((k) => k + 1);
    }
  }, [redoHist]);

  useEffect(() => {
    const kd = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'z') { e.preventDefault(); applyUndo(); return; }
      if ((e.ctrlKey || e.metaKey) && e.key === 'y') { e.preventDefault(); applyRedo(); return; }
      if (e.key === 'Escape') { setSelected(''); return; }

      if (!selected || e.target.contentEditable === 'true') return;

      const step = e.shiftKey ? 10 : 1;
      const map = { ArrowLeft: ['left', -step], ArrowRight: ['left', step], ArrowUp: ['top', -step], ArrowDown: ['top', step] };
      const entry = map[e.key];
      if (!entry) return;
      if (selected.startsWith('grid-row') || selected.startsWith('header-row')) return;

      e.preventDefault();

      const el = containerRef.current?.querySelector(`[data-rg-id="${selected}"]`);
      let targetKey = selected;
      if (el) {
        const section = el.closest('[data-drag-section]');
        if (section) targetKey = 'section-' + section.getAttribute('data-drag-section');
      }

      const [prop, delta] = entry;
      setOverrides((prev) => {
        const cur = prev[targetKey] || {};
        const curVal = parseFloat(cur[prop]) || 0;
        return { ...prev, [targetKey]: { ...cur, [prop]: curVal + delta + 'px' } };
      });
      setRenderKey((k) => k + 1);
    };
    window.addEventListener('keydown', kd);
    return () => window.removeEventListener('keydown', kd);
  }, [applyUndo, applyRedo, selected]);

  const onClick = (e) => {
    if (containerRef.current?.hasAttribute('data-col-dragging')) return;
    if (e.target.closest('.col-resize-handle')) return;
    const hit = findSelectable(e.target);
    if (hit) {
      e.stopPropagation();
      const dataEl = hit.el.closest('[data-rg-id]');
      const rgId = dataEl?.getAttribute('data-rg-id');
      if (!rgId) return;
      setSelected(rgId);
      setHovered('');
    } else {
      setSelected('');
    }
  };

  const onDblClick = (e) => {
    const hit = findSelectable(e.target);
    if (!hit) return;
    const txt = findTextContent(hit.el);
    if (!txt) return;
    e.stopPropagation();
    saveSnapshot(JSON.stringify({ overrides }));
    const wrap = txt.nodeType === 3 ? txt.parentElement : txt;
    const rgId = hit.el.closest('[data-rg-id]')?.getAttribute('data-rg-id');
    wrap.contentEditable = 'true';
    wrap.focus();
    wrap.style.outline = '2.5px solid #22c55e';
    wrap.style.outlineOffset = '2px';
    const range = document.createRange();
    range.selectNodeContents(wrap);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
    wrap.addEventListener('blur', () => {
      wrap.contentEditable = 'false';
      wrap.style.outline = '';
      wrap.style.outlineOffset = '';
      if (rgId === 'doc-title') {
        const newText = wrap.textContent.trim();
        setDocTitle(newText || null);
        setRenderKey((k) => k + 1);
      }
    }, { once: true });
  };

  const onMouseOver = (e) => {
    if (containerRef.current?.hasAttribute('data-col-dragging') || containerRef.current?.hasAttribute('data-resizing')) return;
    const hit = findSelectable(e.target);
    if (hit) {
      const dataEl = hit.el.closest('[data-rg-id]');
      setHovered(dataEl?.getAttribute('data-rg-id') || '');
    } else {
      setHovered('');
    }
  };

  const onMouseOut = () => {
    if (containerRef.current?.hasAttribute('data-col-dragging') || containerRef.current?.hasAttribute('data-resizing')) return;
    setHovered('');
  };

  const updateStyle = (prop, val) => {
    if (!selected) return;
    saveSnapshot(JSON.stringify({ overrides }));
    setOverrides((prev) => ({
      ...prev,
      [selected]: { ...prev[selected], [prop]: val },
    }));
    setRenderKey((k) => k + 1);
  };

  return {
    hovered, selected, setSelected,
    onClick, onDblClick, onMouseOver, onMouseOut,
    updateStyle, applyUndo, applyRedo,
  };
}
