import { useState, useRef } from 'react';
import { useConfigStore } from '../../stores/configStore';

const SECTION_LABELS = {
  emisor: 'Emisor',
  receptor: 'Receptor',
  items: 'Ítems',
  totals: 'Totales',
  observaciones: 'Observaciones',
  'datos-adicionales': 'Datos Adicionales',
  footer: 'Footer',
  'header-logo': 'Logo',
  'header-ids': 'GUID',
  'header-qr': 'Código QR',
  'header-info': 'Info Documento',
};

const ALL_SECTIONS = ['emisor', 'receptor', 'items', 'totals', 'observaciones', 'datos-adicionales', 'footer'];
const ALL_HEADER_SECTIONS = ['header-logo', 'header-ids', 'header-qr', 'header-info'];

const DEFAULT_GRID = [
  ['emisor', 'receptor'],
  ['items'],
  ['totals', 'observaciones'],
  ['datos-adicionales'],
  ['footer'],
];

const DEFAULT_HEADER_GRID = [['header-logo'], ['header-ids', 'header-qr', 'header-info']];

function DragIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor" className="text-gray-400">
      <circle cx="5" cy="3" r="1.5"/>
      <circle cx="11" cy="3" r="1.5"/>
      <circle cx="5" cy="8" r="1.5"/>
      <circle cx="11" cy="8" r="1.5"/>
      <circle cx="5" cy="13" r="1.5"/>
      <circle cx="11" cy="13" r="1.5"/>
    </svg>
  );
}

function PlusIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="2" className="text-gray-400">
      <line x1="8" y1="3" x2="8" y2="13"/><line x1="3" y1="8" x2="13" y2="8"/>
    </svg>
  );
}

function CloseIcon() {
  return (
    <svg width="12" height="12" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="2" className="text-gray-400 hover:text-red-500">
      <line x1="4" y1="4" x2="12" y2="12"/><line x1="12" y1="4" x2="4" y2="12"/>
    </svg>
  );
}

function RowIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" className="text-gray-400">
      <rect x="1" y="4" width="6" height="8" rx="1"/>
      <rect x="9" y="4" width="6" height="8" rx="1"/>
    </svg>
  );
}

export default function LayoutConfig() {
  const currentConfig = useConfigStore((s) => s.currentConfig);
  const setCurrentConfig = useConfigStore((s) => s.setCurrentConfig);

  const [grid, setGrid] = useState(() => {
    return currentConfig?.layoutGrid || [...DEFAULT_GRID.map(r => [...r])];
  });

  const [headerGrid, setHeaderGrid] = useState(() => {
    return currentConfig?.headerLayoutGrid || [...DEFAULT_HEADER_GRID.map(r => [...r])];
  });

  const [dragInfo, setDragInfo] = useState(null);
  const [dropTarget, setDropTarget] = useState(null);
  const [dragScope, setDragScope] = useState(null);
  const dragRef = useRef(null);

  if (!currentConfig) return null;

  const usedSections = new Set(grid.flat());
  const unusedSections = ALL_SECTIONS.filter(s => !usedSections.has(s));

  const usedHeaderSections = new Set(headerGrid.flat());
  const unusedHeaderSections = ALL_HEADER_SECTIONS.filter(s => !usedHeaderSections.has(s));

  const updateGrid = (newGrid) => {
    setGrid(newGrid);
    const updatedConfig = { ...currentConfig, layoutGrid: newGrid };
    setCurrentConfig(updatedConfig);
  };

  const updateHeaderGrid = (newGrid) => {
    setHeaderGrid(newGrid);
    const updatedConfig = { ...currentConfig, headerLayoutGrid: newGrid };
    setCurrentConfig(updatedConfig);
  };

  const handleDragStart = (e, section, rowIdx, colIdx) => {
    dragRef.current = { section, fromRow: rowIdx, fromCol: colIdx };
    setDragInfo({ section, fromRow: rowIdx, fromCol: colIdx });
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', section);
    setTimeout(() => e.target.style.opacity = '0.4', 0);
  };

  const handleDragEnd = (e) => {
    e.target.style.opacity = '';
    setDragInfo(null);
    setDropTarget(null);
    dragRef.current = null;
  };

  const handleRowDragOver = (e, rowIdx) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    setDropTarget({ type: 'row', rowIdx });
  };

  const handleRowDrop = (e, targetRowIdx) => {
    e.preventDefault();
    e.stopPropagation();
    const info = dragRef.current;
    if (!info) return;

    const newGrid = grid.map(r => [...r]);
    const { section, fromRow, fromCol } = info;

    if (fromRow !== undefined && fromCol !== undefined) {
      newGrid[fromRow].splice(fromCol, 1);
      if (newGrid[fromRow].length === 0) newGrid.splice(fromRow, 1);
    }

    const insertAt = Math.min(targetRowIdx, newGrid.length);
    newGrid.splice(insertAt, 0, [section]);

    updateGrid(newGrid);
    setDragInfo(null);
    setDropTarget(null);
    dragRef.current = null;
  };

  const handleCardDragOver = (e, targetRowIdx, targetColIdx) => {
    e.preventDefault();
    e.stopPropagation();
    e.dataTransfer.dropEffect = 'move';
    setDropTarget({ type: 'card', rowIdx: targetRowIdx, colIdx: targetColIdx });
  };

  const handleCardDrop = (e, targetRowIdx, targetColIdx) => {
    e.preventDefault();
    e.stopPropagation();
    const info = dragRef.current;
    if (!info) return;

    const newGrid = grid.map(r => [...r]);
    const { section, fromRow, fromCol } = info;

    if (fromRow !== undefined && fromCol !== undefined) {
      newGrid[fromRow].splice(fromCol, 1);
      if (newGrid[fromRow].length === 0) newGrid.splice(fromRow, 1);
      const adjustedRow = fromRow < targetRowIdx ? targetRowIdx - 1 : targetRowIdx;
      const insertCol = Math.min(targetColIdx, newGrid[adjustedRow]?.length || 0);
      newGrid[adjustedRow].splice(insertCol, 0, section);
    } else {
      const targetRow = newGrid[targetRowIdx] || [];
      const insertCol = Math.min(targetColIdx, targetRow.length);
      targetRow.splice(insertCol, 0, section);
      if (!newGrid[targetRowIdx]) newGrid.push(targetRow);
    }

    updateGrid(newGrid);
    setDragInfo(null);
    setDropTarget(null);
    dragRef.current = null;
  };

  const handleAddToRow = (section, rowIdx) => {
    const newGrid = grid.map(r => [...r]);
    newGrid[rowIdx].push(section);
    updateGrid(newGrid);
  };

  const handleNewRow = (section) => {
    const newGrid = [...grid, [section]];
    updateGrid(newGrid);
  };

  const handleRemove = (section, rowIdx, colIdx) => {
    const newGrid = grid.map(r => [...r]);
    newGrid[rowIdx].splice(colIdx, 1);
    if (newGrid[rowIdx].length === 0) newGrid.splice(rowIdx, 1);
    updateGrid(newGrid);
  };

  const handleHeaderDragStart = (e, section, rowIdx, colIdx) => {
    dragRef.current = { section, fromRow: rowIdx, fromCol: colIdx, scope: 'header' };
    setDragInfo({ section, fromRow: rowIdx, fromCol: colIdx });
    setDragScope('header');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', section);
    setTimeout(() => e.target.style.opacity = '0.4', 0);
  };

  const handleHeaderDragEnd = (e) => {
    e.target.style.opacity = '';
    setDragInfo(null);
    setDropTarget(null);
    setDragScope(null);
    dragRef.current = null;
  };

  const handleHeaderRowDragOver = (e, rowIdx) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    setDropTarget({ type: 'header-row', rowIdx });
  };

  const handleHeaderRowDrop = (e, targetRowIdx) => {
    e.preventDefault();
    e.stopPropagation();
    const info = dragRef.current;
    if (!info || info.scope !== 'header') return;

    const newGrid = headerGrid.map(r => [...r]);
    const { section, fromRow, fromCol } = info;

    if (fromRow !== undefined && fromCol !== undefined) {
      newGrid[fromRow].splice(fromCol, 1);
      if (newGrid[fromRow].length === 0) newGrid.splice(fromRow, 1);
    }

    const insertAt = Math.min(targetRowIdx, newGrid.length);
    newGrid.splice(insertAt, 0, [section]);

    updateHeaderGrid(newGrid);
    setDragInfo(null);
    setDropTarget(null);
    setDragScope(null);
    dragRef.current = null;
  };

  const handleHeaderCardDragOver = (e, targetRowIdx, targetColIdx) => {
    e.preventDefault();
    e.stopPropagation();
    e.dataTransfer.dropEffect = 'move';
    setDropTarget({ type: 'header-card', rowIdx: targetRowIdx, colIdx: targetColIdx });
  };

  const handleHeaderCardDrop = (e, targetRowIdx, targetColIdx) => {
    e.preventDefault();
    e.stopPropagation();
    const info = dragRef.current;
    if (!info || info.scope !== 'header') return;

    const newGrid = headerGrid.map(r => [...r]);
    const { section, fromRow, fromCol } = info;

    if (fromRow !== undefined && fromCol !== undefined) {
      newGrid[fromRow].splice(fromCol, 1);
      if (newGrid[fromRow].length === 0) newGrid.splice(fromRow, 1);
      const adjustedRow = fromRow < targetRowIdx ? targetRowIdx - 1 : targetRowIdx;
      const insertCol = Math.min(targetColIdx, newGrid[adjustedRow]?.length || 0);
      newGrid[adjustedRow].splice(insertCol, 0, section);
    } else {
      const targetRow = newGrid[targetRowIdx] || [];
      const insertCol = Math.min(targetColIdx, targetRow.length);
      targetRow.splice(insertCol, 0, section);
      if (!newGrid[targetRowIdx]) newGrid.push(targetRow);
    }

    updateHeaderGrid(newGrid);
    setDragInfo(null);
    setDropTarget(null);
    setDragScope(null);
    dragRef.current = null;
  };

  const handleHeaderAddToRow = (section, rowIdx) => {
    const newGrid = headerGrid.map(r => [...r]);
    newGrid[rowIdx].push(section);
    updateHeaderGrid(newGrid);
  };

  const handleHeaderRemove = (section, rowIdx, colIdx) => {
    const newGrid = headerGrid.map(r => [...r]);
    newGrid[rowIdx].splice(colIdx, 1);
    if (newGrid[rowIdx].length === 0) newGrid.splice(rowIdx, 1);
    updateHeaderGrid(newGrid);
  };

  const renderGridBlock = (gridData, unused, scope, handlers) => {
    const isBody = scope === 'body';
    return (
      <>
        {gridData.map((row, rowIdx) => (
          <div
            key={`${scope}-row-${rowIdx}`}
            onDragOver={(e) => handlers.onRowDragOver(e, rowIdx)}
            onDrop={(e) => handlers.onRowDrop(e, rowIdx)}
            className={`rounded-md border p-2 transition-colors ${
              dropTarget?.type === `${scope}-row` && dropTarget.rowIdx === rowIdx
                ? 'border-blue-400 bg-blue-50'
                : 'border-gray-200'
            }`}
          >
            <div className="flex items-center justify-between mb-1">
              <div className="flex items-center gap-1">
                <RowIcon />
                <span className="text-[10px] text-gray-400">
                  Fila {rowIdx + 1}
                </span>
              </div>
              {row.length === 0 && (
                <button
                  onClick={() => handlers.onRemoveRow(rowIdx)}
                  className="text-[10px] text-gray-400 hover:text-red-500 cursor-pointer"
                  title="Eliminar fila vacía"
                >
                  <CloseIcon />
                </button>
              )}
            </div>
            <div className="flex flex-wrap gap-1">
              {row.map((section, colIdx) => (
                <div
                  key={section}
                  draggable
                  onDragStart={(e) => handlers.onDragStart(e, section, rowIdx, colIdx)}
                  onDragOver={(e) => handlers.onCardDragOver(e, rowIdx, colIdx)}
                  onDrop={(e) => handlers.onCardDrop(e, rowIdx, colIdx)}
                  onDragEnd={handlers.onDragEnd}
                  className={`
                    flex items-center gap-1.5 px-2.5 py-1.5 rounded-md border text-xs cursor-grab active:cursor-grabbing
                    transition-colors duration-100
                    ${dragInfo?.section === section && dragScope === scope ? 'opacity-40' : ''}
                    ${dropTarget?.type === `${scope}-card` && dropTarget.rowIdx === rowIdx && dropTarget.colIdx === colIdx
                      ? 'border-blue-400 bg-blue-50' : 'border-gray-200 bg-white hover:bg-gray-50'}
                  `}
                >
                  <DragIcon />
                  <span className="font-medium text-gray-700 select-none">{SECTION_LABELS[section]}</span>
                  <button
                    onClick={() => handlers.onRemove(section, rowIdx, colIdx)}
                    className="ml-1 text-gray-300 hover:text-red-500 cursor-pointer"
                    title="Quitar de esta fila"
                  >
                    <CloseIcon />
                  </button>
                </div>
              ))}
              {row.length < 2 && unused.length > 0 && (
                <div className="relative group">
                  <button className="flex items-center gap-1 px-2 py-1.5 rounded-md border border-dashed border-gray-300 text-xs text-gray-400 hover:border-blue-400 hover:text-blue-500 cursor-pointer">
                    <PlusIcon />
                  </button>
                  <div className="absolute left-0 top-full mt-1 hidden group-hover:block z-10 bg-white border border-gray-200 rounded-md shadow-lg p-1 min-w-[120px]">
                    {unused.map(s => (
                      <button
                        key={s}
                        onClick={() => handlers.onAddToRow(s, rowIdx)}
                        className="block w-full text-left px-2 py-1 text-xs text-gray-700 hover:bg-blue-50 rounded cursor-pointer"
                      >
                        + {SECTION_LABELS[s]}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        ))}
        <button
          onClick={() => handlers.onNewRow?.('')}
          className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md border border-dashed border-gray-300 text-xs text-gray-500 hover:border-blue-400 hover:text-blue-500 cursor-pointer w-full justify-center"
        >
          <PlusIcon />
          <span className="select-none">Nueva fila</span>
        </button>
        {unused.length > 0 && (
          <div className="border border-dashed border-gray-300 rounded-md p-2">
            <div className="text-[10px] text-gray-400 mb-1">Secciones sin asignar</div>
            <div className="flex flex-wrap gap-1">
              {unused.map(section => (
                <div className="relative group" key={section}>
                  <button
                    onClick={() => handlers.onNewRow?.(section)}
                    className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md border border-dashed border-gray-300 text-xs text-gray-500 hover:border-blue-400 hover:text-blue-500 cursor-pointer"
                  >
                    <PlusIcon />
                    <span className="select-none">{SECTION_LABELS[section]}</span>
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </>
    );
  };

  const headerHandlers = {
    onDragStart: handleHeaderDragStart,
    onDragEnd: handleHeaderDragEnd,
    onRowDragOver: handleHeaderRowDragOver,
    onRowDrop: handleHeaderRowDrop,
    onCardDragOver: handleHeaderCardDragOver,
    onCardDrop: handleHeaderCardDrop,
    onAddToRow: handleHeaderAddToRow,
    onNewRow: (section) => {
      if (section) updateHeaderGrid([...headerGrid, [section]]);
      else updateHeaderGrid([...headerGrid, []]);
    },
    onRemove: handleHeaderRemove,
    onRemoveRow: (rowIdx) => {
      const newGrid = headerGrid.filter((_, i) => i !== rowIdx);
      updateHeaderGrid(newGrid);
    },
  };

  const bodyHandlers = {
    onDragStart: handleDragStart,
    onDragEnd: handleDragEnd,
    onRowDragOver: handleRowDragOver,
    onRowDrop: handleRowDrop,
    onCardDragOver: handleCardDragOver,
    onCardDrop: handleCardDrop,
    onAddToRow: handleAddToRow,
    onNewRow: (section) => {
      if (section) updateGrid([...grid, [section]]);
      else updateGrid([...grid, []]);
    },
    onRemove: handleRemove,
    onRemoveRow: (rowIdx) => {
      const newGrid = grid.filter((_, i) => i !== rowIdx);
      updateGrid(newGrid);
    },
  };

  return (
    <div className="border border-gray-200 rounded-lg p-3 space-y-3">
      <h3 className="text-sm font-semibold text-gray-700">Encabezado</h3>
      {renderGridBlock(headerGrid, unusedHeaderSections, 'header', headerHandlers)}

      <hr className="border-gray-200 my-2" />

      <h3 className="text-sm font-semibold text-gray-700">Cuerpo del Documento</h3>
      {renderGridBlock(grid, unusedSections, 'body', bodyHandlers)}
    </div>
  );
}
