'use client';
import dynamic from 'next/dynamic';
// The editor uses DOMParser, XSLTProcessor and locally persisted document state.
const Editor = dynamic(() => import('../App'), { ssr: false, loading: () => <main className="studio-empty">Cargando editor…</main> });
export default function Page() { return <Editor />; }
