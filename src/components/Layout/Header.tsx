import { useConfigStore } from '../../stores/configStore';
import DownloadButton from '../Preview/DownloadButton';
import { useEffect, useState } from 'react';

export default function Header({ menuOpen, onToggleMenu, menuButton, zoom, onZoomChange, onResetView }) {
  const title = useConfigStore(s => s.docTitle || s.currentConfig?.title);
  const [fullscreen, setFullscreen] = useState(false);
  const [viewError, setViewError] = useState('');
  useEffect(() => {
    const update = () => setFullscreen(Boolean(document.fullscreenElement));
    document.addEventListener('fullscreenchange', update);
    return () => document.removeEventListener('fullscreenchange', update);
  }, []);
  const toggleFullscreen = async () => {
    try {
      setViewError('');
      if (document.fullscreenElement) await document.exitFullscreen();
      else await document.documentElement.requestFullscreen();
    } catch { setViewError('El navegador no pudo abrir la pantalla completa.'); }
  };
  return (
    <header className="studio-header">
      <div className="studio-brand">
        <button ref={menuButton} className="studio-menu-button" aria-label={menuOpen ? 'Cerrar menú' : 'Abrir menú'} aria-expanded={menuOpen} aria-controls="studio-menu" onClick={onToggleMenu}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" aria-hidden="true">{menuOpen ? <path d="m6 6 12 12M6 18 18 6"/> : <path d="M4 6h16M4 12h16M4 18h16"/>}</svg>
        </button>
        <img className="studio-logo" src={`/rg-studio-logo.png`} alt="Logo de RG Studio" width="42" height="42" />
        <div><h1>RG Studio</h1><p>Editor de documentos</p></div>
      </div>
      <div className="studio-document-title"><span>{title || 'Sin título'}</span><small>{title ? 'Documento de trabajo' : 'Tu próximo documento empieza aquí'}</small></div>
      <div className="studio-header-tools" role="toolbar" aria-label="Controles de vista y exportación">
        <select aria-label="Zoom de la vista previa" value={zoom} onChange={e => onZoomChange(Number(e.target.value))}>
          {[25,50,75,100,125,150,175,200].map(value => <option key={value} value={value}>{value}%</option>)}
        </select>
        <button className="studio-view-button" aria-label="Alejar" title="Alejar" disabled={zoom <= 25} onClick={() => onZoomChange(Math.max(25, zoom - 25))}><svg viewBox="0 0 24 24"><circle cx="10" cy="10" r="6"/><path d="m15 15 5 5M7 10h6"/></svg></button>
        <button className="studio-view-button" aria-label="Acercar" title="Acercar" disabled={zoom >= 200} onClick={() => onZoomChange(Math.min(200, zoom + 25))}><svg viewBox="0 0 24 24"><circle cx="10" cy="10" r="6"/><path d="m15 15 5 5M7 10h6M10 7v6"/></svg></button>
        <button className="studio-view-button" aria-label="Restablecer vista" title="Restablecer vista" onClick={onResetView}><svg viewBox="0 0 24 24"><path d="M19 8a8 8 0 1 0 1 6M19 3v5h-5"/></svg></button>
        <button className="studio-view-button" aria-label={fullscreen ? 'Salir de pantalla completa' : 'Pantalla completa'} title="Pantalla completa" aria-pressed={fullscreen} onClick={toggleFullscreen}><svg viewBox="0 0 24 24"><path d="M14 4h6v6M20 4l-7 7M10 20H4v-6M4 20l7-7"/></svg></button>
        <div className="studio-header-export"><DownloadButton /></div>
        {viewError && <span className="studio-view-error" role="status">{viewError}</span>}
      </div>
    </header>
  );
}
