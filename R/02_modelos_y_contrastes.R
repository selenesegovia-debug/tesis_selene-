# 02_modelos_y_contrastes.R
# Modelos y contrastes planificados definidos a priori (ver docs/plan-analisis-estadistico.md).
# Ejecutar desde la raíz del repositorio.
#
# fuente = "simulated" -> prueba el flujo con datos sintéticos
# fuente = "processed" -> datos reales

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(ggplot2)
})

emm_options(lmer.df = "satterthwaite")

fuente <- "simulated"      # <- cambiar a "processed" con datos reales
ruta   <- function(x) file.path("data", fuente, paste0(x, ".csv"))
dir.create("results", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

if (fuente == "simulated") {
  message("AVISO: analizando datos SINTÉTICOS. Los resultados no son del estudio.")
}

# ---- 1. Lectura y preparación -----------------------------------------------
fijar_niveles <- function(d) {
  d |> mutate(
    cultivar = factor(cultivar, levels = c("Sekoya Grande", "Luna")),
    momento  = factor(momento,  levels = c("origen", "destino")),
    bm       = factor(bm,       levels = c("sin", "con"))
  )
}

cajas <- read_csv(ruta("cajas"), show_col_types = FALSE) |>
  filter(tipo == "experimental") |>
  fijar_niveles()
diseno <- cajas |> select(caja_id, cultivar, momento, bm)

leer_frutos <- function(nombre) {
  read_csv(ruta(nombre), show_col_types = FALSE) |>
    inner_join(diseno, by = "caja_id")
}

peso <- leer_frutos("clamshells_peso")
peso_caja <- peso |>
  group_by(caja_id) |>
  summarise(perdida_acum = mean((peso_t0_g - peso_10C_g) / peso_t0_g * 100, na.rm = TRUE),
            .groups = "drop")

cajas <- cajas |>
  left_join(peso_caja, by = "caja_id") |>
  mutate(AT_pct  = vol_NaOH_mL * 0.1 * 0.064 * 100 / 5,   # % ácido cítrico
         SST_AT  = SST_pct / AT_pct)

visual <- leer_frutos("frutos_visual") |>
  mutate(no_aceptable  = as.integer(condicion != "aceptable"),
         pruina_no_ac  = as.integer(pruina_nivel >= 3),
         deshid_no_ac  = as.integer(deshid_nivel >= 3))

firmeza <- leer_frutos("frutos_firmeza") |>
  mutate(baxlo_Ush = rowMeans(cbind(baxlo_mejilla1_Ush, baxlo_mejilla2_Ush)))

color <- leer_frutos("frutos_color")

# ---- 2. Funciones de ajuste -------------------------------------------------
rhs <- "cultivar * momento * bm"
ajustar_lm    <- function(y, d) lm(reformulate(rhs, response = y), data = d)
ajustar_lmer  <- function(y, d) lmer(reformulate(paste(rhs, "+ (1 | caja_id)"), response = y), data = d)
ajustar_glmer <- function(y, d) glmer(reformulate(paste(rhs, "+ (1 | caja_id)"), response = y),
                                      data = d, family = binomial)
# Si hay sobredispersión o separación casi completa: ver plan de análisis
# (beta-binomial, corrección de Firth o enfoque bayesiano).

# ---- 3. Utilidad: contraste -> tabla (sin ajuste; Holm se aplica por hipótesis) ----
tabla_contraste <- function(con, variable, binomial = FALSE) {
  s <- as.data.frame(summary(con, infer = TRUE, adjust = "none"))
  lcl <- intersect(c("lower.CL", "asymp.LCL"), names(s))[1]
  ucl <- intersect(c("upper.CL", "asymp.UCL"), names(s))[1]
  columnas_num <- c("estimate", "SE", "df", "lower.CL", "upper.CL", "asymp.LCL",
                    "asymp.UCL", "t.ratio", "z.ratio", "p.value", "null")
  contexto <- setdiff(names(s), columnas_num)
  out <- tibble(
    variable  = variable,
    contraste = do.call(paste, c(s[contexto], sep = " | ")),
    estimate  = s$estimate,
    lcl       = s[[lcl]],
    ucl       = s[[ucl]],
    p         = s$p.value
  )
  if (binomial) {   # en GLMM el contraste está en escala logit: se agrega la razón de odds
    out <- out |> mutate(OR = exp(estimate), OR_lcl = exp(lcl), OR_ucl = exp(ucl))
  }
  out
}

holm_hipotesis <- function(hipotesis, ...) {
  d <- bind_rows(...)
  d$p_holm <- p.adjust(d$p, method = "holm")   # conjunto: contrastes x variables primarias
  bind_cols(hipotesis = hipotesis, d)
}

# ---- 4. Contrastes planificados (Cuadro 2 del proyecto) ----------------------
# Convención de signos: BM = con - sin; cultivar = Sekoya Grande - Luna;
# momento = origen - destino.

H1 <- function(m, y, bin = FALSE) {   # cultivar en los testigos (bm = "sin"), promedio de momentos
  emm <- emmeans(m, ~ cultivar, at = list(bm = "sin"))
  tabla_contraste(contrast(emm, "pairwise"), y, bin)
}

H2 <- function(m, y, bin = FALSE) {   # BM vs testigo en cada momento
  bind_rows(
    tabla_contraste(contrast(emmeans(m, ~ bm | momento), "revpairwise"), y, bin) |>
      mutate(contraste = paste("ambos cultivares |", contraste)),
    tabla_contraste(contrast(emmeans(m, ~ bm | cultivar * momento), "revpairwise"), y, bin)
  )
}

H3 <- function(m, y, bin = FALSE) {   # (BM origen - testigo origen) - (BM destino - testigo destino)
  bind_rows(
    tabla_contraste(contrast(emmeans(m, ~ bm * momento),
                             interaction = c("revpairwise", "pairwise")), y, bin) |>
      mutate(contraste = paste("ambos cultivares |", contraste)),
    tabla_contraste(contrast(emmeans(m, ~ bm * momento | cultivar),
                             interaction = c("revpairwise", "pairwise")), y, bin)
  )
}

H4 <- function(m, y, bin = FALSE) {   # efecto BM en Sekoya Grande - efecto BM en Luna
  bind_rows(
    tabla_contraste(contrast(emmeans(m, ~ bm * cultivar | momento),
                             interaction = c("revpairwise", "pairwise")), y, bin),
    tabla_contraste(contrast(emmeans(m, ~ bm * cultivar),
                             interaction = c("revpairwise", "pairwise")), y, bin) |>
      mutate(contraste = paste("promedio de momentos |", contraste))
  )
}

# ---- 5. Modelos de las variables primarias ----------------------------------
m_peso <- ajustar_lm("perdida_acum", cajas)          # un valor por caja
m_firm <- ajustar_lmer("firmpro_N_mm", firmeza)      # frutos individuales
m_noac <- ajustar_glmer("no_aceptable", visual)      # proporción de frutos blandos o podridos

cat("\n=== ANOVA completo (contexto): pérdida de peso acumulada ===\n"); print(anova(m_peso))
cat("\n=== ANOVA completo (contexto): firmeza FirmPro ===\n");           print(anova(m_firm))
cat("\n=== Efectos fijos: % frutos blandos o con pudrición (logit) ===\n"); print(summary(m_noac)$coefficients)

resultados <- bind_rows(
  holm_hipotesis("H1 cultivar",     H1(m_peso, "perdida_acum"), H1(m_firm, "firmpro_N_mm")),
  holm_hipotesis("H2 efecto BM",    H2(m_firm, "firmpro_N_mm"), H2(m_noac, "no_aceptable", TRUE)),
  holm_hipotesis("H3 BM x momento", H3(m_firm, "firmpro_N_mm"), H3(m_noac, "no_aceptable", TRUE)),
  holm_hipotesis("H4 BM x cultivar", H4(m_firm, "firmpro_N_mm"), H4(m_noac, "no_aceptable", TRUE))
)

options(width = 200)
print(resultados, n = Inf)
write_csv(resultados, file.path("results", paste0("contrastes_planificados_", fuente, ".csv")))

# La clasificación (apoyada / parcialmente apoyada / no concluyente / no apoyada)
# se asigna leyendo estimación, IC y p de Holm según docs/plan-analisis-estadistico.md.
# Los IC mostrados no están ajustados por Holm: la decisión usa p_holm.

# ---- 6. Variables secundarias: EXPLORATORIAS, sin ajuste --------------------
cat("\n=== SECUNDARIAS (exploratorias, sin ajuste por multiplicidad) ===\n")
for (v in c("SST_pct", "AT_pct", "SST_AT")) {
  cat("\n--", v, "(ANOVA 3 factores)\n"); print(anova(ajustar_lm(v, cajas)))
}
for (v in c("baxlo_Ush")) {
  cat("\n--", v, "(modelo mixto)\n"); print(anova(ajustar_lmer(v, firmeza)))
}
for (v in c("L", "C", "h")) {
  cat("\n-- color interno", v, "(modelo mixto)\n"); print(anova(ajustar_lmer(v, color)))
}
for (v in c("pruina_no_ac", "deshid_no_ac")) {
  cat("\n--", v, "(GLMM binomial)\n"); print(summary(ajustar_glmer(v, visual))$coefficients)
}

# ---- 7. Figura descriptiva ---------------------------------------------------
g <- ggplot(firmeza, aes(x = interaction(momento, bm, sep = " · "), y = firmpro_N_mm, fill = bm)) +
  geom_boxplot(outlier.size = 0.6) +
  facet_wrap(~ cultivar) +
  labs(x = "Momento · BM", y = "Firmeza FirmPro (N/mm)",
       title = paste("Firmeza por tratamiento (datos:", fuente, ")")) +
  theme_minimal() +
  theme(legend.position = "none")
ggsave(file.path("figures", paste0("firmeza_por_tratamiento_", fuente, ".png")),
       g, width = 8, height = 4.5, dpi = 200)
message("Listo: resultados en results/ y figura en figures/.")
