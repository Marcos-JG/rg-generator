import { z } from 'zod';

const FieldSchema = z.object({
  id: z.string(),
  label: z.string(),
  required: z.boolean(),
});

const ColumnSchema = FieldSchema.extend({
  width: z.string().regex(/^\d+%$/),
});

const TotalsFieldSchema = z.object({
  id: z.string(),
  label: z.string(),
  required: z.boolean(),
  xpath: z.string().optional(),
});

export const ConfigSchema = z.object({
  country: z.enum(['sv', 'gt', 'cr', 'pa', 'do']),
  docType: z.string(),
  title: z.string(),
  version: z.string(),
  sellerFields: z.array(FieldSchema).min(1),
  buyerFields: z.array(FieldSchema).min(1),
  itemColumns: z.array(ColumnSchema).min(1),
  totalsFields: z.array(TotalsFieldSchema).min(1),
  layoutGrid: z.array(z.array(z.string())).optional(),
  headerLayoutGrid: z.array(z.array(z.string())).optional(),
  fieldOrders: z.object({
    seller: z.array(z.string()).optional(),
    buyer: z.array(z.string()).optional(),
    items: z.array(z.string()).optional(),
    totals: z.array(z.string()).optional(),
    observaciones: z.array(z.string()).optional(),
  }).optional(),
  showSumasRow: z.boolean(),
  showDteBox: z.boolean(),
  dteBoxFields: z.array(z.string()),
  showFooter: z.boolean(),
  showQR: z.boolean(),
  style: z.object({
    colorPrimary: z.string().regex(/^#[0-9A-Fa-f]{6}$/),
    colorBorder: z.string(),
    colorTotalesBg: z.string(),
    colorTotalPagarBg: z.string(),
    fontSize: z.string(),
    fontSizeHeader: z.string(),
    fontFamily: z.string(),
    borderRadius: z.string(),
  }),
});

export function validateConfig(config, sourceLabel) {
  const result = ConfigSchema.safeParse(config);
  if (!result.success) {
    throw new Error(`Config inválido (${sourceLabel}): ${result.error.message}`);
  }
  return result.data;
}
