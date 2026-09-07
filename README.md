# RG Generator

Editor visual de representaciones gráficas de documentos XML, construido con React y Vite.

## Desarrollo

- `npm install`: instalar dependencias.
- `npm run dev`: abrir el servidor de desarrollo.
- `npm run build`: generar la aplicación.
- `npm test`: ejecutar las pruebas.
- `npm run lint`: revisar el código.

## Edición visual

El menú **Arrastrar** permite mover campos libremente por la hoja, mover bloques completos (emisor, receptor, totales, logo, etc.) o reordenar filas. Los campos pueden salir de su sección original y superponerse a otros elementos. Se conserva el espacio original para no desplazar los demás campos. Las posiciones se guardan y se incluyen en HTML/PDF.

Las flechas ajustan el elemento seleccionado en pasos de 1 píxel; Shift+flecha mueve 10 píxeles. Escape cancela un arrastre. Cada arrastre completo ocupa un paso del historial. **Restablecer posición** devuelve el elemento a su ubicación inicial.

Carga un XML para iniciar un documento. Haz clic en un elemento para modificar sus estilos y doble clic sobre un texto para editar ese fragmento. Enter confirma la edición, Escape la cancela y Shift+Enter permite saltos de línea. También se confirma al salir del texto.

Los botones Deshacer y Rehacer recuperan cambios de texto, estilos, tamaños y configuración. Atajos: Ctrl/Cmd+Z, Ctrl/Cmd+Shift+Z y Ctrl/Cmd+Y. Dentro de un campo de texto se conservan los atajos de edición del navegador.

El documento actual, su XML y sus cambios se guardan automáticamente en el almacenamiento local del navegador. Al recargar se recupera el trabajo. Cargar otro XML inicia un documento nuevo y vacía su historial. El historial no se conserva entre recargas. Borrar los datos del navegador elimina el diseño guardado.

## Exportación y alcance actual

HTML y la impresión/PDF incluyen los cambios visibles y excluyen las marcas de selección y los controles de tamaño. Cambiar el texto mostrado no modifica el XML original.

La descarga XSLT sigue utilizando la plantilla base y los ajustes generales; todavía no incorpora las modificaciones individuales del editor. La exportación XSLT fiel al diseño es una etapa pendiente, junto con inserción de elementos, capas y agrupación.

Un XSLT externo se muestra tal cual y no admite los controles de edición visual.
