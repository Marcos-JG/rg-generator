import { useConfigStore } from '../../stores/configStore';

export default function Sidebar({ children }) {
  const resetAll = useConfigStore((s) => s.resetAll);

  return (
    <aside className="w-80 bg-gray-50 border-r border-gray-200 overflow-y-auto flex flex-col">
      <div className="p-4 flex-1 space-y-4">
        {children}
      </div>
      <div className="p-4 border-t border-gray-200">
        <button
          onClick={resetAll}
          className="w-full text-sm text-red-600 hover:text-red-800 hover:underline cursor-pointer"
        >
          Limpiar todo
        </button>
      </div>
    </aside>
  );
}
