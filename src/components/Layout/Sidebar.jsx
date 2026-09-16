import { useConfigStore } from '../../stores/configStore';

const panels = [['documento', 'Documento'], ['contenido', 'Contenido'], ['diseno', 'Diseño']];
export default function Sidebar({ children, panel, onPanelChange }) {
  const resetAll = useConfigStore(s => s.resetAll);
  return (
    <aside className="studio-sidebar" aria-label="Configuración del documento">
      <div className="inspector-heading"><span>Inspector</span><span className="inspector-caption">Personaliza tu documento</span></div>
      <nav className="studio-segments" aria-label="Secciones del inspector">
        {panels.map(([id, label]) => <button key={id} aria-pressed={panel === id} onClick={() => onPanelChange(id)}>{label}</button>)}
      </nav>
      <div className="inspector-scroll">{children}</div>
      <div className="inspector-bottom"><span>Un espacio para cada detalle.</span><button onClick={resetAll}>Limpiar documento</button></div>
    </aside>
  );
}
