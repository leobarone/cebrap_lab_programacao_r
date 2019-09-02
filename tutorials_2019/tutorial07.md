# Voltando à TICDOM

Agora que já temos em nosso repertório diversos verbos do _dplyr_, vamos ver como aplicar essa gramática com dados de survey, cujo desenho amostral deve ser considerado. Vamos começar carregando o pacote _tidyverse_

```{r}
library(tidyverse)
```

Voltaremos agora a trabalhar com a TICDOM. Deta vez, utilizaremos a base de indivíduos. Faremos a abertura dos dados diretamente da internet com a função _read\_csv2_, que abre arquivos de texto com colunas separadas por ponto e vírgula, como a TICDOM. Lembre-se de abrir o dicionário dos dados para acompanhar o tutorial, que você pode baixar [aqui](http://cetic.br/media/microdados/154/ticdom_2017_domicilios_dicionario_de_variaveis_v1.1.xlsx):

```{r}
ticdom_url <- "http://cetic.br/media/microdados/181/ticdom_2017_individuos_base_de_microdados_v1.3.csv"

ticdom <- read_csv2(ticdom_url)
```

## Agrupando dados de survey desconsiderando o desenho amostral

A partir do que aprendemos no tutorial sobre _group\_by_ e _summarise_, pareceria simples produzir tabelas com dados de survey. Vejamos dois exemplos. No prmeiro, vamos calcular a média de idade na amostra. A seguir, vamos calcular a média de idade por sexo:

```{r}
ticdom %>%
  summarise(media_idade = mean(IDADE))
```

```{r}
ticdom %>%
  group_by(SEXO) %>% 
  summarise(media_idade = mean(IDADE))
```

A média e tabela parecem corretas. No entanto, o cálculo de médias desconsiderando o desenho amostral, seja para toda a amostra ou para cada um dos grupos, está incorreta. As observações têm pesos diferentes e percentem a estratos diferentes da amostra. Como corrigir esse problema e reescrever o código?

## Survey em R: _survey_ vs _srvyr_

A principal solução para dados de survey em R até a pouco tempo era o pacote _survey_. Você pode aprender sobre como trabalhar com dados da PNAD com o pacote _survey_ neste tutorial [aqui](https://github.com/leobarone/cebrap_lab_cetic_programacao_r/blob/master/tutorials/tutorial09.md)

O pacote _survey_, no entanto, traz uma restrição bastante importante: seu uso é imcompatível com a gramática do _dplyr_ que, além de ágil, é a mais popular em R. _survey_ traz um dialéto próprio e limita seu uso às funções que foram implementadas pelos desenvolvedores do pacote.

Felizmente, surgiu recentemente um novo pacote que permite considerar o desenho amostral de um survey ao trabalhar com a gramática do _dplyr_: _srvyr_. Você pode ler um pouco sobre a comparação entre os dois pacotes nesta [vinheta](https://cran.r-project.org/web/packages/srvyr/vignettes/srvyr-vs-survey.html). Recomendo como complementação a este tutorial.

Vamos instalar e carregar o pacote _srvyr_. antes de avançar:

```{r}
install.packages('srvyr')
library(srvyr)
```


## Corrigindo o exemplo anterior com _srvyr_

Vamos corrigir os exemplos que produzimos acima (media de idade e media de idade por sexo) com o pacote _srvyr_ e examinar o código:

Em primeiro lugar, a média de devices:

```{r}
ticdom %>%
  as_survey_design(ids = UPA, strata = ESTRATO, weights = PESO) %>% 
  summarise(media_IDADE = survey_mean(IDADE))
```

E depois a tabela:

```{r}
ticdom %>%
  as_survey_design(ids = UPA, strata = ESTRATO, weights = PESO) %>% 
  group_by(SEXO) %>% 
  summarise(media_devices = survey_mean(IDADE))
```

Veja que há duas mudanças em ambos os códigos. Em primeiro lugar, introduzimos uma nova linha antes do agrupamento. Utilizamos _as\_survey\_design_ para fazer justamente o que nos faltava: informar e considerar o desenho amostral antes de proceder com a produção de estatísticas descritivas.

A segunda mudança está dentro de _summarise_. Não podemos mais utilizar a função _mean_ para produzir a média. Temos, agora, que utilizar as funções substitutas do pacote  _srvyr_ dentro do verbo _summarise_.

Uma maneira mais econômica de trabalhar com os dados de survey sem repetir a linha que informa o desenho amostral é criar um novo objeto que contenha os dados + o desenho:

```{r}
ticdom_srvyr <- ticdom %>%
  as_survey_design(ids = UPA, strata = ESTRATO, weights = PESO)
```

Para facilitar a tarefa, convém transformar as variáveis que incluíremos nas margens da tabela como factor:

```{r}
ticdom_srvyr <- ticdom_srvyr %>%
  mutate(sexo_f = as.factor(SEXO),
         raca_f = as.factor(RACA),
         pea_f = as.factor(PEA))
```


A confecção de tabelas é, neste caso, simplificada. Veja alguns exemplos.

Para obter as proporções de uma variável discreta em uma tabela, com seus respectivos desvios padrão, basta fazer:

```{r}
ticdom_srvyr %>%
  group_by(sexo_f) %>%
  summarize(proporcao = survey_mean())
```

Veja que não colocamos nada dentro da função _survey\_mean_, pois estamos apenas observando a variável 'de grupo'. O conteúdo das células diz respeito a esta variável e não a uma terceira, como fizemos há pouco e faremos a seguir.

Se o objetivo for obter a contagem de casos (com expansão da amostra) fazemos:

```{r}
ticdom_srvyr %>%  group_by(SEXO) %>%

  group_by(sexo_f) %>%
  summarize(contagem = survey_total())
```

Seja com _survey\_mean_ ou _survey\_total_, é possível alterar o resultado da função, que por default traz o desvio padrão, para intervalo de confiança de 95% com o argumento 'vartype':

```{r}
ticdom_srvyr %>%
  group_by(sexo_f) %>%
  summarize(proporcao = survey_mean(vartype = "ci"))
```

O procedimento para 2 ou mais variáveis é semelhante. Basta adicionar as demais variáveis ao agrupamento.

```{r}
ticdom_srvyr %>%
  group_by(sexo_f, raca_f) %>%
  summarize(proporcao = survey_mean())
```

Com 3 variáveis:

```{r}
ticdom_srvyr %>%
  group_by(sexo_f, raca_f, pea_f) %>%
  summarize(proporcao = survey_mean())
```

Lembrando que com _spread_ podemos tornar a tabela de agrupamento por 2 variáveis em uma tabela de duas entradas. Para retirar o desvio padrão da proporção investigada, convém adicionar o verbo _select_ com o nome do desvio padrão precedido pelo sinal negativo:

```{r}
ticdom_srvyr %>%
  group_by(sexo_f, raca_f) %>%
  summarize(proporcao = survey_mean()) %>%
  select(-proporcao_se) %>% 
  spread(sexo_f, proporcao)
```

Podemos, como já fizemos acima, fazer com que o conteúdo sumarizado não seja apenas a proporção em cada respota da variável de agrupamento, mas uma estatística descritiva de uma terceira variável.  Além disso, ademais de _survey\_mean_ e _survey\_total_, podemos utilizar outras função sumário do pacote _srvyr_: _survey\_mediam_, _survey\_quantile_.

```{r}
ticdom_srvyr %>%  
  group_by(sexo_f) %>% 
  summarise(media = survey_mean(IDADE),
            soma = survey_total(IDADE),
            quantil_25 = survey_quantile(IDADE, quantiles = 0.25),
            quantil_75 = survey_quantile(IDADE, quantiles =  0.75))
```

As tabelas de duas entradas (gerada por agrupamentos de duas variáveis) podem também ter como conteúdo de célula uma terceira variável:

```{r}
ticdom_srvyr %>%
  group_by(sexo_f, raca_f) %>% 
  summarise(media = survey_mean(IDADE)) %>%
  select(-media_se) %>% 
  spread(sexo_f, media)
```

## Para onde vamos

Podemos parar por aqui. Mas já temos o suficiente para reprduzir inúmeras tabelas de resultados geradas a partir de surveys.