import { useEffect } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { movementTarget, movementDelta } from '../../core/freeMovement';

export default function useFreeMove(containerRef, active, mode, setSelected) {
  useEffect(() => {
    const page = containerRef.current;
    if (!page || !active || mode === 'reorder') return;
    let drag = null;
    let suppressClick = false;
    const finish = (cancel = false) => {
      if (!drag) return;
      const current = drag;
      drag = null;
      page.removeAttribute('data-free-moving');
      page.style.userSelect = current.userSelect;
      current.el.style.cssText = current.css;
      current.parents.forEach(([el, overflow]) => { el.style.overflow = overflow; });
      if (page.hasPointerCapture?.(current.pointerId)) page.releasePointerCapture(current.pointerId);
      if (current.moved) {
        suppressClick = true;
        if (!cancel) {
          useConfigStore.getState().setPosition(current.id, current.next);
          setSelected(current.id);
        }
      }
    };
    const down = e => {
      if (e.button !== 0 || drag || e.isPrimary === false) return;
      // Suppress only the synthetic click following a drag, never a new gesture.
      suppressClick = false;
      const el = movementTarget(e.target, mode);
      if (!el || !page.contains(el)) return;
      const positions = useConfigStore.getState().positions;
      const id = el.dataset.rgId;
      const start = positions[id] || { x: 0, y: 0 };
      const bounds = page.getBoundingClientRect();
      drag = { el, id, start, rect: el.getBoundingClientRect(), page: bounds,
        scale: bounds.width / (page.offsetWidth || bounds.width || 1) || 1,
        x: e.clientX, y: e.clientY, pointerId: e.pointerId, css: el.style.cssText,
        parents: [], userSelect: page.style.userSelect, moved: false,
        z: Math.max(0, ...Object.values(positions).map(p => p.z || 0)) + 1 };
      page.setAttribute('data-free-moving', 'true');
    };
    const move = e => {
      if (!drag || e.pointerId !== drag.pointerId) return;
      const currentPage = page.getBoundingClientRect();
      const dx = e.clientX - drag.x - (currentPage.left - drag.page.left);
      const dy = e.clientY - drag.y - (currentPage.top - drag.page.top);
      if (!drag.moved && Math.hypot(dx, dy) < 4) return;
      e.preventDefault();
      if (!drag.moved) {
        drag.moved = true;
        page.setPointerCapture?.(drag.pointerId);
        page.style.userSelect = 'none';
        let parent = drag.el.parentElement;
        while (parent && parent !== page) {
          drag.parents.push([parent, parent.style.overflow]);
          parent.style.overflow = 'visible';
          parent = parent.parentElement;
        }
      }
      const delta = movementDelta(drag.rect, drag.page, dx, dy, drag.scale);
      drag.next = { x: drag.start.x + delta.x, y: drag.start.y + delta.y, z: drag.z };
      drag.el.style.transform = `translate(${drag.next.x}px, ${drag.next.y}px)`;
      drag.el.style.position = 'relative';
      drag.el.style.zIndex = String(drag.z);
      drag.el.style.outline = '2px solid #3b82f6';
    };
    const up = e => { if (drag && drag.pointerId === e.pointerId) finish(); };
    const cancel = () => finish(true);
    const key = e => {
      if (drag && e.key === 'Escape') { e.preventDefault(); e.stopImmediatePropagation(); cancel(); }
    };
    const click = e => {
      if (e.target.closest('[contenteditable="true"], [data-resize], .col-resize-handle')) return;
      if (suppressClick) { suppressClick = false; e.stopPropagation(); return; }
      setSelected(movementTarget(e.target, mode)?.dataset.rgId || '');
      e.stopPropagation();
    };
    const nativeDrag = e => e.preventDefault();
    page.addEventListener('pointerdown', down);
    window.addEventListener('pointermove', move, { passive: false });
    window.addEventListener('pointerup', up);
    page.addEventListener('pointercancel', cancel);
    page.addEventListener('lostpointercapture', cancel);
    page.addEventListener('click', click, true);
    page.addEventListener('dragstart', nativeDrag);
    window.addEventListener('keydown', key, true);
    window.addEventListener('blur', cancel);
    return () => {
      cancel();
      page.removeEventListener('pointerdown', down);
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
      page.removeEventListener('pointercancel', cancel);
      page.removeEventListener('lostpointercapture', cancel);
      page.removeEventListener('click', click, true);
      page.removeEventListener('dragstart', nativeDrag);
      window.removeEventListener('keydown', key, true);
      window.removeEventListener('blur', cancel);
    };
  }, [containerRef, active, mode, setSelected]);
}
