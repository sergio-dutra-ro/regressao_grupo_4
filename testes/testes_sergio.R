library(tidyverse)
library(tidymodels)
library(reglin)
library(car)
library(gridExtra)
tidymodels_prefer()

set.seed(64)

# Transformando em V. categóricas
casas <- read_csv("casas.csv") |>
  mutate(across(where(is.character), as.factor))

casas <- casas |>
  mutate(
    preco = log(preco),
    quartos = as.integer(quartos),
    banheiros = as.integer(banheiros),
    andares = as.integer(andares),
    vagas_garagem = as.integer(vagas_garagem),
    area_lote = area_lote
  )
glimpse(casas)

# Separação dos dados
casas_split <- initial_split(casas, prop = 0.80)
casas_train <- training(casas_split)
casas_test  <- testing(casas_split)

# Definição do modelo inicial
fit_nulo <- lm(preco ~ 1, data = casas)
fit_full <- lm(preco ~., data = casas)
