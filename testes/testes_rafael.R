library(tidyverse)
library(tidymodels)
library(reglin)
library(car)
library(gridExtra)

tidymodels_prefer()

casas <- read_csv("casas.csv") |>
  mutate(across(where(is.character), as.factor))

glimpse(casas)


# Separação dos dados
set.seed(64)

casas_split <- initial_split(casas, prop = 0.80)

casas_train <- training(casas_split)
casas_test  <- testing(casas_split)


# Definição do modelo inicial
lm_model <- linear_reg() |>
  set_engine("lm")

lm_wflow <- workflow() |>
  add_model(lm_model) |>
  add_formula(preco ~ .)

# Ajuste e avaliação
lm_fit <- fit(lm_wflow, data = casas_train)

fit1 <- extract_fit_engine(lm_fit)

ggresiduals(fit1)

# Ajuste com log
log_wflow <- workflow() |>
  add_model(lm_model) |>
  add_formula(log(preco) ~ .)

log_fit <- fit(log_wflow, data = casas_train)

fit2 <- extract_fit_engine(log_fit)

ggresiduals(fit2)


# Aplicação do stepwise
fit_log <- lm(log(preco) ~ ., data = casas_train)
fit_full <- lm(log(preco) ~ .^2, data = casas_train)

fit_step <- stats::step(
  fit_log,
  direction = "both",
  scope = list(upper = formula(fit_full))
)

formula(fit_step)

anova(fit_log, fit_step)

# "Convertendo" para um workflow
log_wflow <- workflow() |>
  add_model(lm_model) |>
  add_formula(log(preco) ~ .)

step_wflow <- workflow() |>
  add_model(lm_model) |>
  add_formula(formula(fit_step))

# Ajuste pelo tidymodels
res_log  <- last_fit(log_wflow, split = casas_split)
res_step <- last_fit(step_wflow, split = casas_split)

# Tabela para comparação
bind_rows(
  collect_metrics(res_log)  |> mutate(modelo = "Log Linear"),
  collect_metrics(res_step) |> mutate(modelo = "Log Stepwise")
) |>
  select(modelo, .metric, .estimate) |>
  pivot_wider(names_from = .metric, values_from = .estimate)

car::Anova(fit_step, type = 3)
