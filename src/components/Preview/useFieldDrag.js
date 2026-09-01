import { useEffect, useRef, useCallback } from 'react';
import { useConfigStore } from '../../stores/configStore';

const DEFAULT_SELLER_ORDER = ['seller-name', 'seller-nit', 'seller-nrc', 'seller-actividad', 'seller-address', 'seller-phone', 'seller-email', 'seller-nombre-comercial', 'seller-tipo-establecimiento'];
const DEFAULT_BUYER_ORDER = ['buyer-name', 'buyer-nit', 'buyer-nrc', 'buyer-address', 'buyer-email'];

export default function useFieldDrag(containerRef, renderKey, setRenderKey) {
  const currentConfig = useConfigStore((s) => s.currentConfig);
  const setCurrentConfig = useConfigStore((s) => s.setCurrentConfig);
  const dragData = useRef(null);

  const findDraggableParent = useCallback((el) => {
    let cur = el;
    while (cur && cur.tagName !== 'BODY') {
      if ((cur.tagName === 'TR' || cur.tagName === 'TH') && cur.hasAttribute('data-field-id')) {
        return cur;
      }
      cur = cur.parentElement;
    }
    return null;
  }, []);

  const findSection = useCallback((el) => {
    let cur = el;
    while (cur && cur.tagName !== 'BODY') {
      if (cur.hasAttribute('data-drag-section')) {
        return cur.getAttribute('data-drag-section');
      }
      cur = cur.parentElement;
    }
    return null;
  }, []);

  const getOrderedFields = useCallback((section) => {
    if (!currentConfig) return [];
    const fieldOrders = currentConfig.fieldOrders || {};
    if (section === 'seller' || section === 'emisor') {
      return fieldOrders.seller || DEFAULT_SELLER_ORDER;
    }
    if (section === 'buyer' || section === 'receptor') {
      return fieldOrders.buyer || DEFAULT_BUYER_ORDER;
    }
    if (section === 'items') {
      return fieldOrders.items || currentConfig.itemColumns.map(c => `item-col-${c.id}`);
    }
    if (section === 'totals') {
      return fieldOrders.totals || currentConfig.totalsFields.map(f => `total-${f.id}`);
    }
    return [];
  }, [currentConfig]);

  const updateFieldOrder = useCallback((section, newOrder) => {
    if (!currentConfig) return;
    const fieldOrders = { ...(currentConfig.fieldOrders || {}) };
    if (section === 'seller' || section === 'emisor') fieldOrders.seller = newOrder;
    else if (section === 'buyer' || section === 'receptor') fieldOrders.buyer = newOrder;
    else if (section === 'items') fieldOrders.items = newOrder;
    else if (section === 'totals') fieldOrders.totals = newOrder;

    setCurrentConfig({ ...currentConfig, fieldOrders });
    setRenderKey(k => k + 1);
  }, [currentConfig, setCurrentConfig, setRenderKey]);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const onDragStart = (e) => {
      const fieldEl = findDraggableParent(e.target);
      if (!fieldEl) return;

      const section = findSection(fieldEl);
      if (!section) return;

      dragData.current = {
        fieldName: fieldEl.getAttribute('data-field-id'),
        section,
      };

      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', dragData.current.fieldName);
      requestAnimationFrame(() => { fieldEl.style.opacity = '0.4'; });
    };

    const clearDropIndicators = () => {
      el.querySelectorAll('.field-drop-above, .field-drop-below, .field-drop-left, .field-drop-right').forEach(n => {
        n.classList.remove('field-drop-above', 'field-drop-below', 'field-drop-left', 'field-drop-right');
      });
    };

    const onDragOver = (e) => {
      if (!dragData.current) return;
      const fieldEl = findDraggableParent(e.target);
      if (!fieldEl) return;

      const section = findSection(fieldEl);
      if (section !== dragData.current.section) return;

      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';

      clearDropIndicators();

      const rect = fieldEl.getBoundingClientRect();
      if (fieldEl.tagName === 'TH') {
        fieldEl.classList.add(e.clientX < rect.left + rect.width / 2 ? 'field-drop-left' : 'field-drop-right');
      } else {
        fieldEl.classList.add(e.clientY < rect.top + rect.height / 2 ? 'field-drop-above' : 'field-drop-below');
      }
    };

    const onDrop = (e) => {
      e.preventDefault();
      clearDropIndicators();

      const targetFieldEl = findDraggableParent(e.target);
      if (!targetFieldEl || !dragData.current) return;

      const targetSection = findSection(targetFieldEl);
      if (targetSection !== dragData.current.section) return;

      const { fieldName: dragFieldName, section } = dragData.current;
      const targetFieldName = targetFieldEl.getAttribute('data-field-id');
      if (dragFieldName === targetFieldName) return;

      const currentOrder = getOrderedFields(section);
      const newOrder = currentOrder.filter(id => id !== dragFieldName);
      const toIdx = newOrder.indexOf(targetFieldName);
      if (toIdx === -1) return;

      const rect = targetFieldEl.getBoundingClientRect();
      let insertIdx;
      if (targetFieldEl.tagName === 'TH') {
        insertIdx = e.clientX < rect.left + rect.width / 2 ? toIdx : toIdx + 1;
      } else {
        insertIdx = e.clientY < rect.top + rect.height / 2 ? toIdx : toIdx + 1;
      }

      newOrder.splice(insertIdx, 0, dragFieldName);
      updateFieldOrder(section, newOrder);
    };

    const onDragEnd = () => {
      dragData.current = null;
      clearDropIndicators();
      el.querySelectorAll('[data-field-id]').forEach(n => { n.style.opacity = ''; });
    };

    el.addEventListener('dragstart', onDragStart);
    el.addEventListener('dragover', onDragOver);
    el.addEventListener('drop', onDrop);
    el.addEventListener('dragend', onDragEnd);

    return () => {
      el.removeEventListener('dragstart', onDragStart);
      el.removeEventListener('dragover', onDragOver);
      el.removeEventListener('drop', onDrop);
      el.removeEventListener('dragend', onDragEnd);
    };
  }, [containerRef, findDraggableParent, findSection, getOrderedFields, updateFieldOrder, renderKey]);
}
