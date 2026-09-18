import { useState, useEffect, useRef } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { findSelectable } from './helpers';
import { movementDelta, movementTarget } from '../../core/freeMovement';

export default function useSelection(containerRef, overrides, setOverrides, renderKey, setRenderKey) {
  const [hovered, setHovered] = useState('');
  const [selected, setSelected] = useState('');
  const editing = useRef(false);
  const { undo: applyUndo, redo: applyRedo, setText, xmlString, customXslt } = useConfigStore();

  useEffect(() => { setSelected(''); setHovered(''); editing.current = false; }, [xmlString, customXslt]);

  useEffect(() => {
    const kd = (e) => {
      if (customXslt || !xmlString || containerRef.current?.hasAttribute('data-free-moving') || e.target.closest?.('input, textarea, select, [contenteditable="true"]')) return;
      const key = e.key.toLowerCase();
      if ((e.ctrlKey || e.metaKey) && key === 'z') {
        e.preventDefault();
        if (e.shiftKey) applyRedo(); else applyUndo();
        return;
      }
      if ((e.ctrlKey || e.metaKey) && key === 'y') { e.preventDefault(); applyRedo(); return; }
      if (e.key === 'Escape') { setSelected(''); return; }
      if (!selected) return;
      const step = e.shiftKey ? 10 : 1;
      const entry = { ArrowLeft: ['left', -step], ArrowRight: ['left', step], ArrowUp: ['top', -step], ArrowDown: ['top', step] }[e.key];
      if (!entry) return;
      e.preventDefault();
      const el = [...(containerRef.current?.querySelectorAll('[data-rg-id]') || [])].find(n => n.dataset.rgId === selected);
      if (!el) return;
      const [prop, delta] = entry;
      const page = containerRef.current;
      const bounds = page.getBoundingClientRect();
      const scale = bounds.width / (page.offsetWidth || bounds.width || 1) || 1;
      const move = movementDelta(el.getBoundingClientRect(), bounds, prop === 'left' ? delta * scale : 0, prop === 'top' ? delta * scale : 0, scale);
      const store = useConfigStore.getState();
      const current = store.positions[selected] || { x: 0, y: 0, z: 1 };
      store.setPosition(selected, { ...current, x: current.x + move.x, y: current.y + move.y });
    };
    window.addEventListener('keydown', kd);
    return () => window.removeEventListener('keydown', kd);
  }, [applyUndo, applyRedo, selected, setOverrides, setRenderKey, containerRef, xmlString, customXslt]);

  const busy = () => editing.current || customXslt || containerRef.current?.matches('[data-col-dragging], [data-resizing], [data-free-moving]');
  const selectionTarget = target => {
    const mode = containerRef.current?.dataset.moveMode;
    return mode === 'reorder'
      ? findSelectable(target)?.el.closest('[data-rg-id]')
      : movementTarget(target, mode);
  };
  const onClick = (e) => {
    if (busy() || e.target.closest('.col-resize-handle, [data-resize]')) return;
    setSelected(selectionTarget(e.target)?.getAttribute('data-rg-id') || '');
    setHovered('');
  };
  const onDblClick = (e) => {
    if (busy()) return;
    const wrap = e.target.closest('[data-rg-text]');
    if (!wrap) return;
    e.stopPropagation();
    const original = wrap.textContent;
    const id = wrap.getAttribute('data-rg-text');
    editing.current = true;
    wrap.setAttribute('contenteditable', 'true');
    wrap.setAttribute('tabindex', '-1');
    wrap.style.outline = '2px solid #22c55e';
    wrap.focus();
    const range = document.createRange();
    range.selectNodeContents(wrap);
    window.getSelection().removeAllRanges();
    window.getSelection().addRange(range);
    let cancelled = false;
    const keydown = event => {
      if (event.key === 'Escape') { event.preventDefault(); cancelled = true; wrap.blur(); }
      if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); wrap.blur(); }
      event.stopPropagation();
    };
    const paste = event => {
      event.preventDefault();
      const selection = window.getSelection();
      if (!selection.rangeCount) return;
      const range = selection.getRangeAt(0);
      range.deleteContents();
      const text = document.createTextNode(event.clipboardData.getData('text/plain'));
      range.insertNode(text);
      range.setStartAfter(text);
      range.collapse(true);
      selection.removeAllRanges(); selection.addRange(range);
    };
    wrap.addEventListener('keydown', keydown);
    wrap.addEventListener('paste', paste);
    wrap.addEventListener('blur', () => {
      const text = cancelled ? original : wrap.innerText ?? wrap.textContent;
      wrap.removeEventListener('keydown', keydown);
      wrap.removeEventListener('paste', paste);
      wrap.removeAttribute('contenteditable');
      wrap.removeAttribute('tabindex');
      wrap.style.outline = '';
      wrap.textContent = text;
      editing.current = false;
      if (!cancelled && text !== original) setText(id, text);
    }, { once: true });
  };
  const onMouseOver = (e) => {
    if (busy()) return;
    setHovered(selectionTarget(e.target)?.getAttribute('data-rg-id') || '');
  };
  const onMouseOut = () => { if (!busy()) setHovered(''); };
  const updateStyle = (prop, val) => {
    if (!selected || customXslt) return;
    const patch = typeof prop === 'object' ? prop : { [prop]: val };
    setOverrides(prev => ({ ...prev, [selected]: { ...prev[selected], ...patch } }));
  };
  return { hovered, selected, setSelected, onClick, onDblClick, onMouseOver, onMouseOut, updateStyle, applyUndo, applyRedo };
}
