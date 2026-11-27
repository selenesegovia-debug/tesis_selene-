# Protocolo experimental

Fuente: proyecto de tesis (2026). Este documento resume el protocolo para uso operativo en laboratorio.

## 1. Material biológico

| | ‘Sekoya Grande’ | ‘Luna’ |
|---|---|---|
| Procedencia | Región del Biobío | Ñancul, Villarrica |
| Obtentor | Fall Creek (‘FC13-122’) | Fall Creek (Luna Blue® ‘FC12-205’) |
| Maduración | Media | Tardía |
| Rasgos descritos | Fruta muy grande y uniforme, firme, azul claro, buen desempeño en almacenamiento prolongado | Calibre mediano (16-17 mm), 1,9 g, excelente pruina, cicatriz pequeña sin exudación |
| Firmeza a la cosecha | — | 70-83 °Ush (Baxlo); 1,35-1,53 N mm⁻¹ (FirmPro) |
| Vida de almacenamiento informada | — | 35 a 42 días |

Ambos cultivares son de alto requerimiento de frío.

## 2. Preparación de la fruta (común a todos los tratamientos)

1. Selección en línea de proceso.
2. SO₂ a granel: **180 (µL L⁻¹) h**.
3. Envasado en *clamshells* de **125 g**; **12 por caja** de cartón de 1,5 kg, con bolsa **Smartpac de 0,3 % de ventilación**.

**Cajas necesarias:** 15 por cultivar (12 de tratamientos, 3 de medición base) = **30 cajas**.

## 3. Tratamientos

Fumigación con BM: **64 g m⁻³, 4,5 °C, 3 h**. Cada testigo recibe el mismo tiempo y temperatura **sin BM**.

| N.º | Tratamiento | Secuencia |
|---|---|---|
| 1 | BM en origen | Fumigación con BM → transporte al CEPOC → AC 0 °C × 35 d → 5 °C × 2 d → 10 °C × 2 d |
| 2 | Testigo en origen | Manejo equivalente sin BM → transporte → AC 0 °C × 35 d → 5 °C × 2 d → 10 °C × 2 d |
| 3 | BM en destino | Transporte → AC 0 °C × 35 d → fumigación con BM → 5 °C × 2 d → 10 °C × 2 d |
| 4 | Testigo en destino | Transporte → AC 0 °C × 35 d → manejo equivalente sin BM → 5 °C × 2 d → 10 °C × 2 d |

**Atmósfera controlada (constante en todos los tratamientos, no es factor):** 12 % CO₂ y 6 % O₂ a 0 °C.

## 4. Diseño

Completamente aleatorizado, factorial 2 × 2 × 2 (cultivar × momento × BM), **3 cajas por combinación = 24 cajas**. Unidad experimental: la caja. Las **6 cajas de medición base** (3 por cultivar) se describen aparte y no entran al análisis factorial.

- Ambos cultivares ingresan juntos a cada tanda.
- La posición de las cajas se asigna al azar dentro de cada cámara (script `R/00_aleatorizacion.R`).

## 5. Muestreo al final de la evaluación

Por cada caja:

```
12 clamshells
├── 6 → solo pérdida de peso (no se abren durante el ensayo)
└── 6 → evaluaciones finales (se abren, los frutos se mezclan)
        ├── Grupo 1 (50 frutos) → pruina, deshidratación visual, condición
        ├── Grupo 2 (50 frutos) → firmeza: FirmPro y luego Baxlo
        └── Grupo 3 (50 frutos) → color interno y luego jugo para SST y AT
```

**Frutos con pudrición o blandos** al tacto se excluyen de firmeza, color interno, SST y AT, y se reemplazan por frutos sanos al azar del remanente de la misma caja. Si no alcanzan, se registra el número efectivamente medido (`n_frutos_firmeza`, `n_frutos_color` en `cajas.csv`).

El valor por caja es el promedio (o porcentaje) de los frutos evaluados.

## 6. Calendario de mediciones de peso

| Momento | Código en planilla |
|---|---|
| Antes del almacenamiento | `peso_t0_g` |
| A los 35 días a 0 °C | `peso_35d_g` |
| Tras 2 días a 5 °C | `peso_5C_g` |
| Tras 2 días a 10 °C | `peso_10C_g` |

Se registra cualquier *clamshell* con pudrición visible o exudado.

## 7. Registro de condiciones (trazabilidad)

En cada tanda y en la AC se registran las condiciones reales, porque la variación entre tandas y cámaras no está en el error experimental:

- Fumigación: concentración de BM, temperatura y duración.
- AC: concentraciones de O₂ y CO₂, y temperatura durante el almacenamiento.

Plantilla: [`data/templates/registro_condiciones.csv`](../data/templates/registro_condiciones.csv).

## 8. Punto a confirmar antes de ejecutar

El texto del proyecto indica que cada testigo se maneja “en la misma tanda y cámara” que la fruta fumigada. Conviene dejar explícito con los profesores cómo se separa físicamente el testigo del gas (por ejemplo, cámara o módulo distinto dentro de la misma tanda), para evitar exposición accidental al BM y para que el script de aleatorización agrupe las posiciones como corresponde.
