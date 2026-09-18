export function pageSize(value?: unknown) {
  const height = value === 'oficio' ? 13 : 11;
  return { width: 8.5, height, contentHeight: height - 0.5 };
}
