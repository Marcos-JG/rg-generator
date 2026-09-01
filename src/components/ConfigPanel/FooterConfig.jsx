import { useConfigStore } from '../../stores/configStore';
import Input from '../shared/Input';

export default function FooterConfig() {
  const { userStyle, updateUserStyle } = useConfigStore();

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
        Footer
      </h3>
      <Input
        label="Texto del pie de página"
        id="footerText"
        value={userStyle.footerText}
        onChange={(v) => updateUserStyle({ footerText: v })}
        placeholder="Documento generado por RG Generator"
      />
    </div>
  );
}
