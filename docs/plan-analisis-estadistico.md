# Plan de análisis estadístico

Todo lo que sigue está definido **a priori**, antes de tener datos.

## Modelos

Factores fijos: cultivar (‘Sekoya Grande’, ‘Luna’), momento (origen, destino), BM (con, sin) y sus interacciones. Unidad experimental: la caja (n = 3 por combinación; 24 cajas).

| Tipo de variable | Variables | Modelo | R |
|---|---|---|---|
| Un valor por caja | SST, AT, SST/AT, pérdida de peso acumulada | ANOVA de 3 factores (16 g.l. del error) | `lm` |
| Medida en frutos individuales | Firmeza (FirmPro, Baxlo), color interno (L\*, C\*, h°) | Modelo lineal mixto, caja como efecto aleatorio | `lmerTest::lmer` |
| Proporción de frutos | Pruina y deshidratación (aceptable vs. no), % blandos o con pudrición | GLMM binomial, enlace logit, caja como efecto aleatorio | `lme4::glmer` |

**Si hay sobredispersión:** distribución beta-binomial. **Si hay separación casi completa** (combinaciones sin eventos): corrección de Firth o enfoque bayesiano con previas débilmente informativas.

**Supuestos:** gráficos de normalidad y de residuos vs. ajustados, complementados con Shapiro-Wilk y Levene (interpretados con cautela por el bajo número de cajas). Si no se cumplen: transformación o varianza modelada por grupo.

## Hipótesis, contrastes y variables primarias

| Hipótesis | Contraste | Formulación | Variables primarias |
|---|---|---|---|
| **H1** Cultivar | ‘Sekoya Grande’ vs. ‘Luna’ en los testigos | Promedio de los dos testigos (origen y destino) de cada cultivar | Pérdida de peso acumulada y firmeza (FirmPro) |
| **H2** Efecto del BM | BM vs. testigo en cada momento | BM origen − testigo origen; BM destino − testigo destino (ambos cultivares y por cultivar) | Firmeza (FirmPro) y % de frutos blandos o con pudrición |
| **H3** BM × momento | Diferencia de efectos | (BM origen − testigo origen) − (BM destino − testigo destino) | Las mismas que H2 |
| **H4** BM × cultivar | Diferencia de efectos entre cultivares | Efecto del BM en ‘Sekoya Grande’ − efecto del BM en ‘Luna’, en cada momento y promediado | Las mismas que H2 |

Los contrastes se obtienen de las **medias marginales estimadas** del modelo (`emmeans`). Los valores *p* se ajustan por **Holm dentro de cada hipótesis**, considerando conjuntamente sus contrastes y sus dos variables primarias; no se ajusta entre hipótesis. Las variables secundarias son **exploratorias, sin ajuste**, y se identifican así.

## Criterio de decisión

Cada contraste se evalúa con la diferencia estimada (de medias o razón de odds) y su IC 95 %:

| Clasificación | Condición |
|---|---|
| **Apoyada** | El contraste va en la dirección planteada en **todas** las variables primarias y su IC excluye el cero tras el ajuste de Holm |
| **Parcialmente apoyada** | Se cumple lo anterior en **solo una** variable primaria, o va en la dirección planteada en todas pero el IC incluye el cero |
| **No concluyente** | IC amplio que incluye el cero; no permite descartar ni un efecto relevante ni uno nulo (esperable en las interacciones, con 3 cajas por combinación) |
| **No apoyada** | La estimación va en dirección contraria, o el IC es estrecho y centrado en cero |

- No se fija un umbral numérico de relevancia práctica: la amplitud del IC se describe en las unidades de cada variable y frente a la media de los testigos.
- En H3 y H4 el contraste es **bilateral**; la dirección esperada (mayor efecto en origen) se discute aparte.
- No se declara la hipótesis general en bloque: se presenta una **tabla resumen** con las cuatro partes.

## Magnitud de los efectos y poder

Se reportan diferencias de medias (o razones de odds) con IC 95 %. Con 24 cajas, 16 g.l. del error, α = 5 % y poder de 80 %, se detectarían diferencias de ≈ **1,2 DE** en efectos principales (12 cajas por nivel) y de ≈ **2,4 DE** en comparaciones entre dos combinaciones y en contrastes de interacción. Las diferencias menores se leen como tendencias.

## Software

R (R Core Team, 2026) con `lme4`, `lmerTest` y `emmeans`; InfoStat (Di Rienzo *et al.*, 2008) para el ANOVA clásico. El flujo reproducible está en [`R/02_modelos_y_contrastes.R`](../R/02_modelos_y_contrastes.R).

## Plantilla para la tabla resumen

| Hipótesis | Variables primarias | Estimación (IC 95 %) | *p* Holm | Clasificación |
|---|---|---|---|---|
| H1 Cultivar | | | | |
| H2 Efecto del BM | | | | |
| H3 BM × momento | | | | |
| H4 BM × cultivar | | | | |
