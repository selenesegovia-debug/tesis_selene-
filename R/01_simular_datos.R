# 01_simular_datos.R
# Genera datos SINTÉTICOS con la misma estructura que tendrán los datos reales.
# Sirve para probar que el análisis (script 02) corre de principio a fin.
# NO representan resultados del estudio: los efectos son inventados.
# Ejecutar desde la raíz del repositorio.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

set.seed(2027)
dir.create("data/simulated", showWarnings = FALSE, recursive = TRUE)

# ---- Diseño ----
cajas <- expand.grid(
  cultivar = c("Sekoya Grande", "Luna"),
  momento  = c("origen", "destino"),
  bm       = c("sin", "con"),
  rep      = 1:3,
  stringsAsFactors = FALSE
) |>
  arrange(momento, bm, cultivar, rep) |>
  mutate(caja_id = sprintf("C%02d", row_number()),
         tipo    = "experimental")

# Efectos inventados (solo para probar el código)
cajas <- cajas |>
  mutate(
    efecto_bm_firm = ifelse(bm == "con", ifelse(momento == "origen", -0.15, -0.06), 0),
    efecto_bm_logit = ifelse(bm == "con", ifelse(momento == "origen", 1.0, 0.4), 0),
    u_firm  = rnorm(n(), 0, 0.05),   # variación entre cajas
    u_logit = rnorm(n(), 0, 0.30),
    mu_firm = ifelse(cultivar == "Sekoya Grande", 1.50, 1.40) + efecto_bm_firm + u_firm,
    p_noac  = plogis(-2.2 + 0.4 * (cultivar == "Luna") + efecto_bm_logit + u_logit)
  )

# ---- Frutos (50 por caja y por grupo) ----
por_fruto <- function(d, n = 50) {
  d[rep(seq_len(nrow(d)), each = n), ] |>
    group_by(caja_id) |>
    mutate(fruto_n = row_number()) |>
    ungroup()
}

firmeza <- por_fruto(cajas) |>
  mutate(
    firmpro_N_mm       = rnorm(n(), mu_firm, 0.20),
    baxlo_mejilla1_Ush = rnorm(n(), 75 + 20 * (mu_firm - 1.4), 4),
    baxlo_mejilla2_Ush = rnorm(n(), 75 + 20 * (mu_firm - 1.4), 4),
    reemplazo          = 0
  ) |>
  select(caja_id, fruto_n, firmpro_N_mm, baxlo_mejilla1_Ush, baxlo_mejilla2_Ush, reemplazo)

visual <- por_fruto(cajas) |>
  mutate(
    no_ac        = rbinom(n(), 1, p_noac),
    pruina_nivel = sample(1:4, n(), replace = TRUE, prob = c(0.55, 0.25, 0.15, 0.05)),
    deshid_nivel = sample(1:5, n(), replace = TRUE, prob = c(0.50, 0.25, 0.15, 0.07, 0.03)),
    condicion    = ifelse(no_ac == 0, "aceptable",
                          ifelse(runif(n()) < 0.5, "blando", "pudricion"))
  ) |>
  select(caja_id, fruto_n, pruina_nivel, deshid_nivel, condicion)

color <- por_fruto(cajas) |>
  mutate(L = rnorm(n(), 55, 3), C = rnorm(n(), 18, 2), h = rnorm(n(), 330, 8)) |>
  select(caja_id, fruto_n, L, C, h)

# ---- Pesos de clamshells (6 por caja) ----
peso <- por_fruto(cajas, n = 6) |>
  rename(clamshell_id = fruto_n) |>
  mutate(
    peso_t0_g  = rnorm(n(), 125, 1),
    perd_35    = pmax(rnorm(n(), 1.0 + 0.2 * (cultivar == "Luna"), 0.15), 0) / 100,
    perd_5     = pmax(rnorm(n(), 0.2, 0.05), 0) / 100,
    perd_10    = pmax(rnorm(n(), 0.3, 0.05), 0) / 100,
    peso_35d_g = peso_t0_g  * (1 - perd_35),
    peso_5C_g  = peso_35d_g * (1 - perd_5),
    peso_10C_g = peso_5C_g  * (1 - perd_10),
    pudricion_visible = 0L,
    exudado           = 0L
  ) |>
  select(caja_id, clamshell_id, peso_t0_g, peso_35d_g, peso_5C_g, peso_10C_g,
         pudricion_visible, exudado)

# ---- Datos por caja: SST y volumen de NaOH ----
cajas_out <- cajas |>
  mutate(
    SST_pct     = rnorm(n(), 12.5, 0.6),
    vol_NaOH_mL = rnorm(n(), 3.9, 0.25)     # AT ≈ 0,5 % ácido cítrico
  ) |>
  select(caja_id, tipo, cultivar, momento, bm, SST_pct, vol_NaOH_mL)

write_csv(cajas_out, "data/simulated/cajas.csv")
write_csv(peso,      "data/simulated/clamshells_peso.csv")
write_csv(visual,    "data/simulated/frutos_visual.csv")
write_csv(firmeza,   "data/simulated/frutos_firmeza.csv")
write_csv(color,     "data/simulated/frutos_color.csv")

message("Datos SINTÉTICOS guardados en data/simulated/ (no son resultados del estudio).")
