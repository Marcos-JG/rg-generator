import { useMemo, useState } from 'react';
import { useConfigStore } from '../../stores/configStore';
import { XML_FIELD_MIME, XML_FIELD_TEXT_PREFIX, beginXmlFieldDrag, endXmlFieldDrag, xmlPaletteFields } from '../../core/xmlFields';

export default function XmlDataPalette() {
  const { xmlString, xmlFields = [], removeXmlField, clearXmlFields } = useConfigStore();
  const [search, setSearch] = useState('');
  const fields = useMemo(() => xmlString ? xmlPaletteFields(xmlString) : [], [xmlString]);
  if (!xmlString) return null;
  const matches = fields.filter(field => `${field.label} ${field.path} ${field.value}`.toLocaleLowerCase().includes(search.toLocaleLowerCase()));
  return <section className="space-y-3" aria-label="Datos del XML">
    <h3 className="font-semibold">Datos del XML</h3>
    <p className="text-xs text-gray-500">Arrastra un dato hasta la hoja para agregarlo. Los valores repetidos se muestran por separado.</p>
    <input aria-label="Buscar datos del XML" placeholder="Buscar dato o valor…" value={search} onChange={event => setSearch(event.currentTarget.value)} className="w-full border rounded-lg p-2 text-sm" />
    <div className="max-h-80 overflow-auto space-y-2">
      {matches.slice(0, 150).map(field => <div key={field.xpath} draggable onDragStart={event => {
        beginXmlFieldDrag(field.xpath);
        event.dataTransfer.setData(XML_FIELD_MIME, field.xpath);
        event.dataTransfer.setData('text/plain', XML_FIELD_TEXT_PREFIX + field.xpath);
        event.dataTransfer.effectAllowed = 'copy';
      }} onDragEnd={endXmlFieldDrag} className="border rounded-lg p-2 bg-white cursor-grab select-none text-xs" title={field.path}>
        <strong className="block">⠿ {field.label}</strong>
        <span className="block truncate text-gray-400">{field.path}</span>
        {field.kind === 'logo' ? <img src={field.value} alt="Logo del emisor" draggable={false} className="h-16 w-full object-contain" /> : <span className="block truncate">{field.value}</span>}
      </div>)}
      {!matches.length && <p className="text-xs text-gray-500">No hay datos que coincidan.</p>}
      {matches.length > 150 && <p className="text-xs text-gray-500">Usa la búsqueda para encontrar más datos.</p>}
    </div>
    {!!xmlFields.length && <div className="space-y-2"><div className="flex justify-between items-center gap-2"><h4 className="text-xs font-semibold">Agregados al diseño</h4><button onClick={clearXmlFields} className="text-xs text-red-600">Quitar todos</button></div>{xmlFields.map(field => <div key={field.id} className="flex items-center justify-between text-xs gap-2">
      <span className="truncate">{field.label}</span><button onClick={() => removeXmlField(field.id)} aria-label={`Quitar ${field.label}`} className="text-red-600">Quitar</button>
    </div>)}</div>}
  </section>;
}
