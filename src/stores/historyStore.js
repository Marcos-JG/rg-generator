import { create } from 'zustand';

const MAX_HISTORY = 50;

export const useHistoryStore = create((set, get) => ({
  past: [],
  future: [],

  snapshot: (state) => {
    const { past } = get();
    const newPast = [...past, state].slice(-MAX_HISTORY);
    set({ past: newPast, future: [] });
  },

  undo: () => {
    const { past, future } = get();
    if (past.length === 0) return null;
    const previous = past[past.length - 1];
    const current = past[past.length - 1];
    set({
      past: past.slice(0, -1),
      future: [current, ...future].slice(0, MAX_HISTORY),
    });
    return previous;
  },

  redo: () => {
    const { past, future } = get();
    if (future.length === 0) return null;
    const next = future[0];
    set({
      past: [...past, next].slice(-MAX_HISTORY),
      future: future.slice(1),
    });
    return next;
  },

  canUndo: () => get().past.length > 0,
  canRedo: () => get().future.length > 0,

  clear: () => set({ past: [], future: [] }),
}));
