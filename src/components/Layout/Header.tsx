import { useConfigStore } from '../../stores/configStore';

export default function Header({ menuOpen, onToggleMenu, menuButton }) {
  const title = useConfigStore(s => s.docTitle || s.currentConfig?.title);
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
      <span className="studio-local"><span aria-hidden="true"/>Espacio personal</span>
    </header>
  );
}
