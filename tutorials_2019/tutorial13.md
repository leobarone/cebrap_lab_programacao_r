# TICDOM - gráficos simples a partir de dados de survey

Nos dois últimos encontros aprendemos como manipular data frames _dplyr_, utilizar o conhecimento sobre data frames para trabalharmos dados de survey utilizando o pacote _srvyr_ e como produzir visualizações com _ggplot2_. Vamos combinar o que aprendemos em um exemplo simples de como produzir gráficos com dados de survey, especificamente da TICDOM indivíduos.

Além disso, vamos fazer rapidamente a distinção entre as geometrias _geom\_bar_ e _geom\_col_, bastante semelhantes entre si, para notar que a última será bastante mais último que a primeira ao utilizarmos dados de survey.

# Carregando e preparando os dados

Vamos começar carregando os pacotes para não perdermos o hábito, lembrando que parte dos pacotes que precisamos, _dplyr_, _ggplot2_, _readr_ e mais alguns outos fazem parte do 'guarda-chuva' _tidyverse_.

```{r}
library(tidyverse)
library(srvyr)
```

A seguir, vamos abrir os dados da TICDOM indivíduos, como já fizemos anteriormente:

```{r}
ticdom_url <- "http://cetic.br/media/microdados/181/ticdom_2017_individuos_base_de_microdados_v1.3.csv"

ticdom <- read_csv2(ticdom_url)
```

Por se tratar de um survey, precisamos contemplar o desenho amostral na análise de dados. Com _srvyr_, criamos um novo objeto a partir dos dados carregados designando-o como um objeto de survey:

```{r}
ticdom_srvy <- ticdom %>%
  as_survey_design(ids = UPA, strata = ESTRATO, weights = PESO)
```

Pronto! Podemos começar a análise.

# Uso de internet no Brasil em 2017

Nosso objetivo é bastante simples: criar um gráfico de barras que represente a proporção de pessoas que responderam "Sim" e "Não" à seguinte pergunta do questionário individual da TICDOM: 'C3: Quando o respondente usou a Internet pela última vez?', cujas respostas possíveis são: '1- Há menos de 3 meses'; '2- Entre 3 meses e 12 meses'; '3- Mais de 12 meses atrás'; e '4- Não se aplica'.

Podemos utilizar a combinação _group\_by_ e _summarise_ para produzir uma tabela simples com a contagem para cada resposta:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total())
```

Nosso desafio agora será trabalhar esses dados para transformá-los em um gráfico interessante.

# Geometria de barras ou de colunas?

Nesse momento, convém notar que, diferentemente do que fizemos no tutorial sobre visualização, não podemos utilizar a geometria _geom\_bar_ para produzir um gráfico a partir da variável C3. Veja os erros:

```{r}
ticdom_srvy %>% 
  ggplot() +
  geom_bar(aes(x = C3))
```

Como estamos trabalhando com um objeto da classe "tbl_svy", não podemos aplicar diretamente a função _ggplot_, pois esta requer um data frame.

```{r}
class(ticdom_srvy)
```

A solução é gerar um tabela, como acabamos de fazer, e produzir o gráfico a partir da tabela. Veja, porém, o erro que geramos ao tentar aplicar  _geom\_bar_ à tabela:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>% 
  ggplot() +
  geom_bar(aes(x = C3))
```

O que aconteceu? A geometria _geom\_bar_ conta em quantas linha cada resposta aparece. Mas, como nosso data frame é uma tabela que já agrupou as respotas com a respectiva contagem, esse geometria não funciona.

A geometria correta para este caso é  _geom\_col_, que não vimos no tutorial sobre visualização de dados. Veja o seu funcionamento:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>% 
  ggplot() +
  geom_col(aes(x = C3,
               y = n))
```

Além da variável C3, precisamos informar também qual é a variável que contém a contagem de respostas.

Veja que este gráfico é bastante informativo. Porém, é um pouco 'bruto'. Precisamos refiná-lo.

# Pipeline, _dplyr_ e _ggplot2_

Podemos combinar as função dos pacotes _dplyr_ e _ggplot2_ para produzir gráficos em um único pipeline. Antes de 'entregar' ao _ggplot_ os dados, podemos modificar seus aspectos para facilitar o trabalho de visualização. Além disso, após produzirmos a base dos gráfico, podemos alterar seus aspectos estéticos para produzir gráficos mais claros e informativos.

Vamos trabalhar no nosso exemplo.

Em primeiro lugar, vamos excluir os respondentes aos quais a pergunta não se aplica adicionando um _filter_:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>% 
  filter(C3 != '99')
```

Em primeiro lugar, vamos alterar o conteúdo a ser informado. Em vez de contagem de pessoas, vamos calcular o percentual em cada resposta. Fazemos isso adicionando um _mutate_ ao nosso código:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>%
  filter(C3 != '99') %>% 
  mutate(percentual = n / sum(n))
```

Fácil, não? Mas nossos leitores não saberão ainda o que os códigos numéricos da variável C3 significam. Assim, vamos transformá-la em factor com os textos das possíveis respostas -- por enquanto ele é character, apesar dos códigos serem numéricos. Faremos isso ainda dentro do _mutate_

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>%
  filter(C3 != '99') %>% 
  mutate(percentual = n / sum(n) * 100,
         C3 = replace(C3, C3 == '1', 'Há menos de 3 meses'),
         C3 = replace(C3, C3 == '2', 'Entre 3 meses e 12 meses'),
         C3 = replace(C3, C3 == '3', 'Mais de 12 meses atrás'),
         C3 = factor(C3, ordered = T, 
                     levels = c('Há menos de 3 meses',
                                'Entre 3 meses e 12 meses',
                                'Mais de 12 meses atrás')))
```

Bem melhor, não? Pronto, agora os dados estão preparados para a produção de um gráfico mais completo:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>%
  filter(C3 != '99') %>% 
  mutate(percentual = n / sum(n) * 100,
         C3 = replace(C3, C3 == '1', 'Há menos de 3 meses'),
         C3 = replace(C3, C3 == '2', 'Entre 3 meses e 12 meses'),
         C3 = replace(C3, C3 == '3', 'Mais de 12 meses atrás'),
         C3 = factor(C3, ordered = T, 
                     levels = c('Há menos de 3 meses',
                                'Entre 3 meses e 12 meses',
                                'Mais de 12 meses atrás'))) %>% 
  ggplot() +
  geom_col(aes(x = C3, 
               y = percentual))
```

Finalmente, e sem entrar em detalhes, podemos utilizar diversos recursos do _ggplot2_ para alterar cor, legenda, título, inserir texto e por aí vai:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>%
  filter(C3 != '99') %>% 
  mutate(percentual = n / sum(n) * 100,
         C3 = replace(C3, C3 == '1', 'Há menos de 3 meses'),
         C3 = replace(C3, C3 == '2', 'Entre 3 meses e 12 meses'),
         C3 = replace(C3, C3 == '3', 'Mais de 12 meses atrás'),
         C3 = factor(C3, ordered = T, 
                     levels = c('Há menos de 3 meses',
                                'Entre 3 meses e 12 meses',
                                'Mais de 12 meses atrás'))) %>% 
  ggplot() +
  geom_col(aes(x = C3, 
               y = percentual,
               fill = C3)) +
  geom_text(aes(x = C3,
                y = percentual,
                label = paste(format(percentual, digits = 2), " %")),
            position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = alpha(c("red", "blue", "yellow"), 0.5)) + 
  ggtitle("Frequência de uso de internet no Brasil - 2017") +
  xlab("Quando o respondente usou a Internet pela última vez?") +
  ylab("Percentual de usuários (%)") +
  theme(legend.position = "none") 
```

"Ah, puxa, mas era melhor não ter excluído os respondentes para os quais não se aplica a questão. O correto seria considerá-los como pessoas que nunca usaram a internet!"

Não tem problema. Reaproveitamos o código com pequenas modificações, tais como a exclusão do _filter_, a atribuição de um texto à esta resposta e a escolha de uma cor:

```{r}
ticdom_srvy %>% 
  group_by(C3) %>%
  summarise(n = survey_total()) %>%
  mutate(percentual = n / sum(n) * 100,
         C3 = replace(C3, C3 == '1', 'Há menos de 3 meses'),
         C3 = replace(C3, C3 == '2', 'Entre 3 meses e 12 meses'),
         C3 = replace(C3, C3 == '3', 'Mais de 12 meses atrás'),
         C3 = replace(C3, C3 == '99', 'Nunca usuou internet'),
         C3 = factor(C3, ordered = T, 
                     levels = c('Há menos de 3 meses',
                                'Entre 3 meses e 12 meses',
                                'Mais de 12 meses atrás',
                                'Nunca usuou internet'))) %>% 
  ggplot() +
  geom_col(aes(x = C3, 
               y = percentual,
               fill = C3)) +
  geom_text(aes(x = C3,
                y = percentual,
                label = paste(format(percentual, digits = 2), " %")),
            position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = alpha(c("red", "blue", "yellow", "green"), 0.5)) + 
  ggtitle("Frequência de uso de internet no Brasil - 2017") +
  xlab("Quando o respondente usou a Internet pela última vez?") +
  ylab("Percentual de usuários (%)") +
  theme(legend.position = "none") 
```

Uma vez que você têm modelos de gráficos prontos, alterar ou refazer um gráfico, ou mesmo utilizá-lo para outra variável é imediato.
