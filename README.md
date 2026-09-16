# RG Generator

Editor visual de representaciones gráficas de documentos XML, construido con React y Vite.

## Desarrollo

- `npm install`: instalar dependencias.
- `npm run dev`: abrir el servidor de desarrollo.
- `npm run build`: generar la aplicación.
- `npm test`: ejecutar las pruebas.
- `npm run lint`: revisar el código.

## Edición visual

El menú **Arrastrar** permite mover campos libremente por la hoja, mover bloques completos (emisor, receptor, totales, logo, etc.) o reordenar filas. Los campos pueden salir de su sección original y superponerse a otros elementos. Se conserva el espacio original para no desplazar los demás campos. Las posiciones se guardan y se incluyen en HTML, PDF y XSLT.

Cambiar el ancho o el alto de un bloque no modifica el tamaño ni la posición de sus vecinos en la misma fila. Si un bloque crece sobre el espacio de otro, ambos pueden superponerse.

La tabla de ítems se mueve como una sola unidad para mantener unidos los encabezados y sus datos. Sus columnas pueden cambiar de ancho o reordenarse; el detalle acompaña siempre a la columna correspondiente.

Las flechas ajustan el elemento seleccionado en pasos de 1 píxel; Shift+flecha mueve 10 píxeles. Escape cancela un arrastre. Cada arrastre completo ocupa un paso del historial. **Restablecer posición** devuelve el elemento a su ubicación inicial.

Carga un XML para iniciar un documento. Haz clic en un elemento para modificar sus estilos y doble clic sobre un texto para editar ese fragmento. Enter confirma la edición, Escape la cancela y Shift+Enter permite saltos de línea. También se confirma al salir del texto.

Los botones Deshacer y Rehacer recuperan cambios de texto, estilos, tamaños y configuración. Atajos: Ctrl/Cmd+Z, Ctrl/Cmd+Shift+Z y Ctrl/Cmd+Y. Dentro de un campo de texto se conservan los atajos de edición del navegador.

El documento actual, su XML y sus cambios se guardan automáticamente en el almacenamiento local del navegador. Al recargar se recupera el trabajo. Cargar otro XML inicia un documento nuevo y vacía su historial. El historial no se conserva entre recargas. Borrar los datos del navegador elimina el diseño guardado.

## Exportación y alcance actual

HTML y la impresión/PDF incluyen los cambios visibles y excluyen las marcas de selección y los controles de tamaño. Cambiar el texto mostrado no modifica el XML original.

La descarga XSLT utiliza la misma estructura y estilos que el lienzo. Conserva filas, tamaños, posiciones, columnas y textos editados, mientras consulta los datos del XML y repite los ítems durante la transformación. Es compatible con XSLT 1.0 y .NET XslCompiledTransform. Para crédito fiscal SV (03), guarda también RG-SharedSV_fel_2.xslt y Shared_ENLETRAS_fel_2.xslt en la misma carpeta; los demás tipos incorporan estas dependencias en el archivo. La prueba editorXsltParity transforma dos XML con .NET y compara texto, estructura y estilos con la preview.

Un XSLT externo se muestra tal cual y no admite los controles de edición visual.
