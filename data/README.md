# Datos

## Carpetas

| Carpeta | Contenido | Se puede editar |
|---|---|---|
| `templates/` | Planillas vacías (solo encabezados) para terreno y laboratorio | Sí, vía *pull request* |
| `design/` | `diseno_aleatorizacion.csv`, generado por `R/00_aleatorizacion.R` | No a mano; se regenera |
| `raw/` | Datos originales tal como se registraron | **Nunca** |
| `processed/` | Datos limpios, listos para `R/02_modelos_y_contrastes.R` | Solo mediante scripts |
| `simulated/` | Datos **sintéticos** para probar el código | Se regeneran con `R/01_simular_datos.R` |

## Archivos de datos

Todos son CSV con coma, UTF-8, punto decimal. El significado de cada columna está en [`diccionario_datos.csv`](diccionario_datos.csv).

| Archivo | Una fila es… | Filas esperadas |
|---|---|---|
| `cajas.csv` | una caja (diseño + SST + volumen de NaOH) | 30 (24 experimentales + 6 base) |
| `clamshells_peso.csv` | un *clamshell* de pesaje | 24 cajas × 6 = 144 |
| `frutos_visual.csv` | un fruto del grupo 1 (pruina, deshidratación, condición) | 24 × 50 = 1.200 |
| `frutos_firmeza.csv` | un fruto del grupo 2 (FirmPro y Baxlo) | hasta 1.200 |
| `frutos_color.csv` | un fruto del grupo 3 (L\*, C\*, h°) | hasta 1.200 |
| `calibre_base.csv` | un fruto de las cajas base | 100 (50 por cultivar) |
| `registro_condiciones.csv` | una operación de fumigación o AC | pocas |

Los archivos de frutos solo llevan `caja_id`: cultivar, momento y BM se unen desde `cajas.csv`, para no repetir el diseño en cada fila.

## Reglas

1. `raw/` no se toca. Correcciones se hacen en `processed/` con un script y quedan documentadas.
2. Valores faltantes: celda vacía (nunca 0, `-` ni `NA` escrito a mano).
3. Códigos de categoría exactamente como en el diccionario (minúsculas, sin tildes en `pudricion`).
4. Si agregas una columna, actualiza el diccionario en el mismo PR.
5. Los datos reales y los simulados jamás comparten carpeta.
