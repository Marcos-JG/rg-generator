// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { attachDocumentZoom } from '../src/components/Preview/useDocumentZoom';

it('intercepts Ctrl + wheel only in the document viewport and preserves ordinary scroll', () => {
  const viewport = document.createElement('div');
  const outside = document.createElement('div');
  document.body.append(viewport, outside);
  const steps = [];
  const cleanup = attachDocumentZoom(viewport, step => steps.push(step));
  const send = (target, ctrlKey, deltaY) => {
    const event = new WheelEvent('wheel', { ctrlKey, deltaY, bubbles: true, cancelable: true });
    target.dispatchEvent(event); return event.defaultPrevented;
  };
  expect(send(viewport, true, -100)).toBe(true);
  expect(send(viewport, true, 100)).toBe(true);
  expect(send(viewport, false, 100)).toBe(false);
  expect(send(outside, true, 100)).toBe(false);
  expect(steps).toEqual([25, -25]);
  cleanup(); expect(send(viewport, true, -100)).toBe(false);
  viewport.remove(); outside.remove();
});

it('handles Ctrl + wheel inside imported previews and releases the iframe listener', () => {
  const viewport = document.createElement('div');
  const iframe = document.createElement('iframe');
  iframe.setAttribute('data-imported-preview', '');
  viewport.appendChild(iframe); document.body.appendChild(viewport);
  const steps = [];
  const cleanup = attachDocumentZoom(viewport, step => steps.push(step));
  const event = new iframe.contentWindow.WheelEvent('wheel', { ctrlKey: true, deltaY: -100, bubbles: true, cancelable: true });
  iframe.contentDocument.body.dispatchEvent(event);
  expect(event.defaultPrevented).toBe(true); expect(steps).toEqual([25]);
  cleanup(); viewport.remove();
});
