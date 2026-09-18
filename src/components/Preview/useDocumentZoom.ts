import { useEffect } from 'react';
import type { RefObject } from 'react';

export function attachDocumentZoom(viewport: HTMLElement, change: (step: number) => void) {
  const wheel = (event: WheelEvent) => {
    if (!event.ctrlKey || !event.deltaY) return;
    const target = event.target as Element;
    if (target.closest?.('input, select, textarea, [contenteditable="true"], .studio-canvas-toolbar')) return;
    event.preventDefault();
    event.stopPropagation();
    change(event.deltaY < 0 ? 25 : -25);
  };
  const frames = new Map<HTMLIFrameElement, Document>();
  const bindFrames = () => {
    viewport.querySelectorAll<HTMLIFrameElement>('iframe[data-imported-preview]').forEach(frame => {
      const doc = frame.contentDocument;
      if (!doc || frames.get(frame) === doc) return;
      frames.get(frame)?.removeEventListener('wheel', wheel, true);
      doc.addEventListener('wheel', wheel, { capture: true, passive: false });
      frames.set(frame, doc);
    });
  };
  viewport.addEventListener('wheel', wheel, { capture: true, passive: false });
  viewport.addEventListener('load', bindFrames, true);
  const observer = new MutationObserver(bindFrames);
  observer.observe(viewport, { childList: true, subtree: true });
  bindFrames();
  return () => {
    observer.disconnect();
    viewport.removeEventListener('wheel', wheel, true);
    viewport.removeEventListener('load', bindFrames, true);
    frames.forEach(doc => doc.removeEventListener('wheel', wheel, true));
  };
}

export default function useDocumentZoom(ref: RefObject<HTMLDivElement>, setZoom) {
  useEffect(() => {
    if (!ref.current) return;
    return attachDocumentZoom(ref.current, step => setZoom(previous => Math.max(25, Math.min(200, previous + step))));
  }, [ref, setZoom]);
}
