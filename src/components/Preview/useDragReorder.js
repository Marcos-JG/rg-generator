import { useRef, useEffect, useState } from 'react';

const HIGHLIGHT = '2px dashed #3b82f6';

export default function useDragReorder(setSectionOrder, saveSnapshot, setRenderKey) {
  const dragRef = useRef({ item: null, overItem: null });
  const [node, setNode] = useState(null);

  const clearHighlights = () => {
    if (!node) return;
    node.querySelectorAll('[data-drag-section]').forEach((s) => {
      s.style.outline = '';
      s.style.outlineOffset = '';
    });
  };

  const setRef = (el) => {
    setNode(el);
  };

  useEffect(() => {
    if (!node) return;

    const onDragStart = (e) => {
      const section = e.target.closest('[data-drag-section]');
      if (!section) return;
      const id = section.getAttribute('data-drag-section');
      dragRef.current.item = id;
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', id);
      section.style.opacity = '0.4';
      document.body.style.userSelect = 'none';
    };

    const onDragOver = (e) => {
      const section = e.target.closest('[data-drag-section]');
      if (!section || !dragRef.current.item) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      clearHighlights();
      section.style.outline = HIGHLIGHT;
      section.style.outlineOffset = '4px';
      dragRef.current.overItem = section.getAttribute('data-drag-section');
    };

    const onDrop = (e) => {
      e.preventDefault();
      clearHighlights();
      const src = dragRef.current.item;
      const target = dragRef.current.overItem;
      if (!src || !target || src === target) {
        dragRef.current.item = null;
        dragRef.current.overItem = null;
        document.body.style.userSelect = '';
        return;
      }
      saveSnapshot();
      setSectionOrder((prev) => {
        const o = [...prev];
        const di = o.indexOf(src);
        const ti = o.indexOf(target);
        if (di === -1 || ti === -1) return prev;
        o.splice(di, 1);
        o.splice(ti, 0, src);
        return o;
      });
      dragRef.current.item = null;
      dragRef.current.overItem = null;
      document.body.style.userSelect = '';
      setRenderKey((k) => k + 1);
    };

    const onDragEnd = () => {
      clearHighlights();
      node.querySelectorAll('[data-drag-section]').forEach((s) => { s.style.opacity = ''; });
      dragRef.current.item = null;
      dragRef.current.overItem = null;
      document.body.style.userSelect = '';
    };

    node.addEventListener('dragstart', onDragStart);
    node.addEventListener('dragover', onDragOver);
    node.addEventListener('drop', onDrop);
    node.addEventListener('dragend', onDragEnd);
    return () => {
      node.removeEventListener('dragstart', onDragStart);
      node.removeEventListener('dragover', onDragOver);
      node.removeEventListener('drop', onDrop);
      node.removeEventListener('dragend', onDragEnd);
    };
  }, [node]);

  return setRef;
}
