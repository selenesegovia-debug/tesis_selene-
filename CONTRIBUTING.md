# Guía para contribuir

Gracias por querer aportar a este trabajo. Este repositorio sigue un flujo con ramas para que cualquier cambio pueda revisarse antes de entrar a la versión estable. Es corto, léelo completo antes de abrir tu primera rama.

## Ramas

| Rama | Para qué sirve | ¿Se escribe directo? |
|---|---|---|
| `main` | Versión estable. Cada hito de la tesis queda etiquetado aquí. | ❌ Nunca |
| `develop` | Integración del trabajo en curso. | ❌ Solo vía *pull request* |
| `docs/<tema>` | Protocolo, redacción, bibliografía, glosario. | ✅ |
| `data/<tema>` | Planillas, diccionario de datos, incorporación de datos. | ✅ |
| `analisis/<tema>` | Scripts de R, modelos, figuras. | ✅ |
| `revision/<quien>-<tema>` | Comentarios y correcciones de profesores o revisores. | ✅ |
| `fix/<tema>` | Corrección de errores puntuales. | ✅ |

Ejemplos: `docs/revision-bibliografica`, `analisis/modelo-firmeza`, `data/planilla-clamshells`, `revision/escalona-plan-estadistico`.

## Paso a paso

```bash
git switch develop && git pull                 # 1. parte desde develop actualizado
git switch -c analisis/modelo-firmeza          # 2. crea tu rama
# ... trabaja, haz commits pequeños ...
git push -u origin analisis/modelo-firmeza     # 3. súbela
# 4. abre un Pull Request hacia develop y espera revisión
```

Reglas del *pull request*:

1. Apunta a **`develop`**, no a `main`.
2. Un tema por rama; ramas cortas (idealmente unos pocos días).
3. Completa la plantilla del PR (se carga sola).
4. Al menos **una revisión** antes de integrar. Los cambios al plan estadístico o al protocolo los revisa la autora.
5. Se integra con **squash merge** para mantener `develop` legible.
6. Borra la rama después de integrar.

Los cambios de `develop` pasan a `main` solo en los hitos del [cronograma](docs/cronograma.md), con una etiqueta (por ejemplo `v0.2-primer-avance`).

## Mensajes de commit

Formato `tipo(ámbito): descripción en imperativo`, en español.

| Tipo | Uso |
|---|---|
| `docs` | Textos, bibliografía, README |
| `data` | Planillas, datos, diccionario |
| `analisis` | Código de análisis, modelos, figuras |
| `fix` | Corrección de un error |
| `chore` | Mantención (`.gitignore`, estructura, plantillas) |

Ejemplos: `analisis(firmeza): agrega contraste BM origen vs destino` · `data(diccionario): define columnas de color interno` · `docs(bibliografia): suma Retamales 2003`.

## Reglas para los datos

- **`data/raw/` es inmutable.** Un dato original no se edita ni se borra; si hay un error, se corrige en `data/processed/` con un script y se documenta el motivo.
- Solo formatos de texto (`.csv`). Nada de planillas con fórmulas ni archivos de más de unos pocos MB.
- Cada columna nueva se agrega a [`data/diccionario_datos.csv`](data/diccionario_datos.csv) en el mismo *pull request*.
- Los datos de `data/simulated/` son sintéticos y nunca se mezclan con los reales.
- No subas datos personales de terceros ni información confidencial del huerto o de la empresa.

## Reglas para el código

- Los scripts se ejecutan **desde la raíz** del repositorio y en orden numérico.
- Si el análisis usa azar, fija la semilla (`set.seed`) y déjala escrita.
- Antes del PR, comprueba que `R/02_modelos_y_contrastes.R` corre completo con los datos simulados.
- Cambios a los contrastes o criterios de decisión deben justificarse en el PR: están definidos **a priori** en el [plan de análisis](docs/plan-analisis-estadistico.md) y modificarlos después de ver datos reales invalidaría su lectura.

## Reportar un problema o proponer algo

Usa las plantillas de *issues*: hay una para errores en datos o análisis y otra para ideas o sugerencias.
