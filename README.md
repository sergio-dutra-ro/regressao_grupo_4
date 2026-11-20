# Trabalho de Análise de Regressão — Grupo 4

Análise econométrica e preditiva dos preços de venda de imóveis residenciais em Windsor, Ontário (Canadá, 1987), desenvolvida em **R** e **Quarto** (`relatorio.qmd` $\rightarrow$ `relatorio.pdf`).

- **Grupo:** Grupo 4
- **Autores:**
  - Gabriel Bahia Leite
  - Gabriel Carvalho Gomes
  - Guilherme Belloni Nogueira
  - Gustavo Costa Sales
  - Rafael Lucas Novais da Silva
  - Sérgio dos Reis

---

## 1. Estrutura do Diretório

```text
regressao_grupo_4/
├── dados/
│   └── casas.csv       # Base de dados (546 imóveis e 12 variáveis)
├── relatorio.qmd       # Documento Quarto único (código R + análise das 6 partes)
├── .gitignore          # Filtro de arquivos temporários (R, Quarto, LaTeX, IDE)
└── README.md           # Guia de organização, pacotes e fluxo do grupo
```

---

## 2. Pré-requisitos e Pacotes Necessários

Para compilar o relatório completo em PDF, certifique-se de ter instalados:

1. **R** (versão $\ge 4.2$)
2. **Quarto CLI** ([https://quarto.org/docs/get-started/](https://quarto.org/docs/get-started/))
3. **TinyTeX** (distribuição LaTeX enxuta usada pelo Quarto para gerar PDFs):
   ```bash
   quarto install tinytex
   ```

### Instalação dos Pacotes R (Partes 1 a 6)

Execute o comando abaixo no console do R para instalar todos os pacotes utilizados ao longo do trabalho:

```r
pacotes <- c(
  # Manipulação, visualização e relatórios (Parte 1 e uso geral)
  "tidyverse", "knitr", "kableExtra", "patchwork", "corrplot", "GGally", "scales",
  # Diagnóstico, inferência e seleção de modelos (Partes 2 a 5)
  "car", "lmtest", "broom", "MASS",
  # Validação preditiva e comparação com KNN (Parte 6)
  "tidymodels", "kknn"
)

novos <- pacotes[!(pacotes %in% installed.packages()[, "Package"])]
if (length(novos) > 0) install.packages(novos, repos = "https://cloud.r-project.org")
```

Para compilar o documento em PDF via terminal:

```bash
quarto render relatorio.qmd
```

---

## 3. Guia de Colaboração e Divisão das Seções (`relatorio.qmd`)

O arquivo `relatorio.qmd` já está estruturado com o cabeçalho YAML configurado para PDF acadêmico e com as **6 seções** numeradas. A **Parte 1** já está integralmente implementada.

### Objeto de Dados Compartilhado (`casas`)

O chunk inicial `setup-dados` (na Seção 1) já realiza a leitura de `dados/casas.csv` e disponibiliza o tibble **`casas`** pronto para todas as seções seguintes:
- Variáveis numéricas (`<dbl>`): `preco`, `area_lote`, `quartos`, `banheiros`, `andares`, `vagas_garagem`.
- Variáveis categóricas binárias (`<fct>`): `entrada_carro`, `area_recreacao`, `porao`, `aquecimento_gas`, `ar_condicionado`, `area_preferencial`.
- Todas as variáveis categóricas já estão configuradas com `levels = c("não", "sim")`, de modo que **`"não"` é a categoria de referência (baseline)** nas funções `lm()` e `tidymodels`.
- **Importante:** Não sobrescreva o objeto `casas` original nas seções seguintes. Se precisar criar colunas transformadas (ex.: `log_preco`, `area_lote_quad`) ou partições de treino/teste, crie novos objetos específicos da sua seção (ex.: `casas_p4`, `casas_treino`, `casas_teste`).

### Onde Cada Integrante Deve Trabalhar

Localize no arquivo `relatorio.qmd` o comentário `<!-- TODO: PARTE X ... -->` correspondente à sua etapa e insira seu texto e seus chunks **exclusivamente dentro da sua seção**:

| Integrante / Etapa | Seção no `relatorio.qmd` | Prefixo de Chunks Sugerido | Escopo Principal |
| :--- | :--- | :--- | :--- |
| **Parte 1** *(Concluída)* | `# Introdução e Análise Exploratória` | `p1-` | Contextualização, dicionário de variáveis, preparação da base `casas`, tabelas resumo, distribuições, boxplots e correlações. |
| **Parte 2** | `# Modelo de Regressão Múltipla Inicial` | `p2-` | Ajuste do modelo completo (`mod_inicial <- lm(preco ~ ., data = casas)`), interpretação de todos os coeficientes (numéricos e dummies), testes $t$ individuais, teste $F$ global, $R^2$ e $R^2$ ajustado. |
| **Parte 3** | `# Análise de Adequação do Modelo Inicial` | `p3-` | Diagnóstico de resíduos (linearidade, homocedasticidade, normalidade via QQ-plot/Shapiro-Wilk/Breusch-Pagan), alavancagem ($h_{ii}$), resíduos estudentizados, distância de Cook e DFFITS. |
| **Parte 4** | `# Transformações e Regressão Polinomial` | `p4-` | Avaliação de transformação na resposta (ex.: $\ln(\text{preco})$ ou Box-Cox), inclusão de termos polinomiais (ex.: `poly(area_lote, 2)` ou `I(area_lote^2)`), reavaliação dos gráficos diagnósticos. |
| **Parte 5** | `# Multicolinearidade, Seleção de Variáveis e Somas de Quadrados Extra` | `p5-` | Cálculo de VIF (`car::vif`), análise de colinearidade, testes $F$ parciais (`anova(mod_reduzido, mod_completo)`) para blocos de variáveis e seleção de modelos (AIC/BIC/stepwise). |
| **Parte 6** | `# Validação de Modelos e Conclusões` | `p6-` | Divisão treino/teste com `tidymodels` (`initial_split`), comparação preditiva entre os melhores modelos lineares e KNN (`nearest_neighbor`) via RMSE, MAE e $R^2$ no conjunto de teste, síntese prática e conclusão final. |

### Boas Práticas para Evitar Conflitos no Git

1. **Não edite fora da sua seção:** Mantenha suas alterações restritas ao espaço entre o título da sua seção (`# ...`) e o título da seção seguinte.
2. **Nomeie seus chunks com o prefixo da sua parte:** Por exemplo, `p2-ajuste-modelo`, `p3-residuos`, `p4-boxcox`. O Quarto exige que todos os rótulos (`#| label:`) do documento sejam únicos.
3. **Se precisar de um pacote adicional:** Carregue-o no primeiro chunk da sua própria seção com `library(nome_do_pacote)` (as opções globais `message: false` e `warning: false` já ocultam mensagens de carregamento no PDF).
4. **Teste antes de enviar:** Sempre execute `quarto render relatorio.qmd` localmente para confirmar que o PDF compila sem erros antes de fazer commit/push.
