import { useState } from 'react';
import { useConfigStore } from '../../stores/configStore';

export default function AdendaConfig() {
  const currentConfig = useConfigStore((s) => s.currentConfig);
  const setCurrentConfig = useConfigStore((s) => s.setCurrentConfig);

  const [newName, setNewName] = useState('');
  const [newLabel, setNewLabel] = useState('');
  const [editingIdx, setEditingIdx] = useState(null);
  const [editLabel, setEditLabel] = useState('');

  if (!currentConfig) return null;

  const fields = currentConfig.adendaFields || [];

  const updateFields = (next) => {
    setCurrentConfig({ ...currentConfig, adendaFields: next });
  };

  const addField = () => {
    const name = newName.trim();
    if (!name) return;
    const label = newLabel.trim() || name;
    updateFields([...fields, { id: name, label, required: false }]);
    setNewName('');
    setNewLabel('');
  };

  const startEdit = (idx, label) => {
    setEditingIdx(idx);
    setEditLabel(label);
  };

  const saveEdit = (idx) => {
    const label = editLabel.trim();
    if (!label) return;
    const next = fields.map((f, i) => (i === idx ? { ...f, label } : f));
    updateFields(next);
    setEditingIdx(null);
    setEditLabel('');
  };

  const removeField = (idx) => {
    const next = fields.filter((_, i) => i !== idx);
    updateFields(next);
    if (editingIdx === idx) setEditingIdx(null);
  };

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Datos Adicionales
      </h3>
      <p className="text-xs text-gray-500">
        Los campos se cargan desde el XML. Podés editarlos, agregarlos o eliminarlos.
      </p>

      {fields.length === 0 && (
        <p className="text-xs text-gray-400">No hay campos de datos adicionales.</p>
      )}

      <ul className="space-y-1">
        {fields.map((f, idx) => {
          const name = f.id || f.name;
          const label = f.label || name;
          return (
            <li key={`${name}-${idx}`} className="flex items-center gap-1 border border-gray-200 rounded px-2 py-1">
              {editingIdx === idx ? (
                <input
                  value={editLabel}
                  onChange={(e) => setEditLabel(e.target.value)}
                  onBlur={() => saveEdit(idx)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') saveEdit(idx);
                    if (e.key === 'Escape') setEditingIdx(null);
                  }}
                  autoFocus
                  className="flex-1 min-w-0 border rounded px-1 py-0.5 text-xs"
                />
              ) : (
                <button
                  onClick={() => startEdit(idx, label)}
                  title="Editar etiqueta"
                  className="flex-1 min-w-0 text-left text-xs text-gray-700 hover:bg-gray-50 rounded px-1 py-0.5 cursor-pointer"
                >
                  <span className="block truncate">{label}</span>
                  <span className="block text-[10px] text-gray-400 truncate">{name}</span>
                </button>
              )}
              <button
                onClick={() => removeField(idx)}
                title="Eliminar"
                className="text-gray-300 hover:text-red-500 text-xs cursor-pointer px-1"
              >
                ✕
              </button>
            </li>
          );
        })}
      </ul>

      <div className="border border-dashed border-gray-300 rounded p-2 space-y-1.5">
        <div className="flex gap-1">
          <input
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            placeholder="Nombre (del XML)"
            className="flex-1 min-w-0 border rounded px-2 py-1 text-xs"
          />
          <input
            value={newLabel}
            onChange={(e) => setNewLabel(e.target.value)}
            placeholder="Etiqueta"
            className="flex-1 min-w-0 border rounded px-2 py-1 text-xs"
          />
        </div>
        <button
          onClick={addField}
          disabled={!newName.trim()}
          className="w-full px-2 py-1 rounded text-xs border cursor-pointer border-gray-200 text-gray-600 hover:border-blue-400 hover:text-blue-600 disabled:opacity-40"
        >
          + Agregar campo
        </button>
      </div>
    </div>
  );
}
