# 00_aleatorizacion.R
# Genera el diseño del ensayo (24 cajas experimentales + 6 base) y asigna al azar
# la posición de cada caja en la cámara de fumigación y en la cámara de AC.
# Ejecutar desde la raíz del repositorio.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

# Semilla fija: NO cambiar una vez generada la aleatorización real.
set.seed(20261201)

# ---- 1. Diseño factorial 2 x 2 x 2 con 3 cajas por combinación ----
experimentales <- expand.grid(
  cultivar = c("Sekoya Grande", "Luna"),
  momento  = c("origen", "destino"),
  bm       = c("sin", "con"),
  rep      = 1:3,
  stringsAsFactors = FALSE
) |>
  mutate(tipo = "experimental")

# ---- 2. Posiciones al azar ----
# Fumigación: dentro de cada tanda (origen / destino), los dos cultivares van juntos.
# Si el testigo se mantiene en una cámara o módulo separado del BM, agrupar también
# por 'bm' (group_by(momento, bm)). Confirmar con los profesores (ver docs/protocolo-experimental.md, sección 8).
experimentales <- experimentales |>
  group_by(momento) |>
  mutate(pos_fumigacion = sample(n())) |>
  ungroup() |>
  # Cámara de AC: las 24 cajas comparten cámara durante los 35 días.
  mutate(pos_AC = sample(n()))

# ---- 3. Identificadores ----
experimentales <- experimentales |>
  arrange(momento, bm, cultivar, rep) |>
  mutate(caja_id = sprintf("C%02d", row_number()))

# ---- 4. Cajas de medición base (no se aleatorizan; análisis descriptivo) ----
base <- tibble(
  cultivar = rep(c("Sekoya Grande", "Luna"), each = 3),
  tipo     = "base",
  caja_id  = sprintf("B%02d", 1:6)
)

diseno <- bind_rows(experimentales, base) |>
  select(caja_id, tipo, cultivar, momento, bm, pos_fumigacion, pos_AC)

dir.create("data/design", showWarnings = FALSE, recursive = TRUE)
write_csv(diseno, "data/design/diseno_aleatorizacion.csv", na = "")

print(diseno, n = Inf)
message("Diseño guardado en data/design/diseno_aleatorizacion.csv")
