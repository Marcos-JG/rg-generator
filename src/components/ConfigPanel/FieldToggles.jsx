import { useConfigStore } from '../../stores/configStore';
import Toggle from '../shared/Toggle';

export default function FieldToggles() {
  const { currentConfig, userStyle, updateUserStyle } = useConfigStore();

  if (!currentConfig) return null;

  const optionalSellerFields = currentConfig.sellerFields.filter((f) => !f.required);
  const optionalBuyerFields = currentConfig.buyerFields.filter((f) => !f.required);

  const toggleField = (fieldId) => {
    const current = userStyle.enabledFields || [];
    const updated = current.includes(fieldId)
      ? current.filter((id) => id !== fieldId)
      : [...current, fieldId];
    updateUserStyle({ enabledFields: updated });
  };

  if (optionalSellerFields.length === 0 && optionalBuyerFields.length === 0) {
    return null;
  }

  return (
    <div className="space-y-3">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Campos Opcionales
      </h3>

      {optionalSellerFields.length > 0 && (
        <div>
          <p className="text-xs text-gray-500 mb-1">Emisor</p>
          {optionalSellerFields.map((field) => (
            <Toggle
              key={field.id}
              id={`seller-${field.id}`}
              label={field.label}
              checked={(userStyle.enabledFields || []).includes(field.id)}
              onChange={() => toggleField(field.id)}
            />
          ))}
        </div>
      )}

      {optionalBuyerFields.length > 0 && (
        <div>
          <p className="text-xs text-gray-500 mb-1">Receptor</p>
          {optionalBuyerFields.map((field) => (
            <Toggle
              key={field.id}
              id={`buyer-${field.id}`}
              label={field.label}
              checked={(userStyle.enabledFields || []).includes(field.id)}
              onChange={() => toggleField(field.id)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
