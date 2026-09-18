import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import '../index.css';
export const metadata: Metadata = { title: 'RG Studio', description: 'Editor visual de documentos XML y plantillas XSLT' };
export default function RootLayout({ children }: { children: ReactNode }) {
  return <html lang="es"><body>{children}</body></html>;
}
