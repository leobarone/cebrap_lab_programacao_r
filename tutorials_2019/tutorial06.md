# Continuando com o Dplyr: Group by, Summarise, Arrange e Slice

## Novos verbos e dados de survey

No tutorial passado vimos 4 dos principais verbos do _dplyr_: _rename_, _select_, _mutate_ (para operações de colunas) e _filter_ (para seleção de casos). Não produzimos, entretanto, uma das operações mais importantes na manipulação de _data\_frames_: o agrupamento de casos a partir de uma ou mais variáveis.

O agrupamento de casos em uma base de dados convencional é bastante simples, como veremos a seguir. No entanto, ao trabalharmos com dados de survey, como é o caso da TICDOM, precisamos considerar o desenho amostral que produziu os dados. Ao agruparmos observações para calcularmos a média de uma variável em dados de survey, precisamos considerar, por exemplo, o peso de cada observação na amostra. Por essa razão, vamos abandonar temporariamente a TICDOM para avançar no aprendizado do _dplyr_. Uma vez que os verbos novos forem bem compreendidos, voltaremos à base para ver como realizar o mesmo procedimento com dados provenientes de survey.

## Fake data

Para esta atividade, vamos trabalhar com um banco de dados falso criado para a atividade.

Abra o banco de dados usando _read\_delim_:

```{r}
library(tidyverse)
url_fake_data <- "https://raw.githubusercontent.com/leobarone/ifch_intro_r/master/data/fake_data.csv"
fake <- read_delim(url_fake_data, delim = ";", col_names = T)
```
Fakeland é uma democracia muito estável que realiza eleições presidenciais a cada 4 anos. Vamos trabalhar com o conjunto de dados falso de cidadãos individuais de Fakeland que contém informações sobre suas características básicas e opiniões / posições políticas (falsas). A descrição das variáveis está abaixo:

- _age_: idade
- _sex_: sexo
- _educ_: nível educacional
- _income_: renda mensal medida em dinheiro falso (FM \ $)
- _savings_: Dinheiro falso total (FM \ $) na conta de poupança
- _marriage_: estado civil (sim = casado)
- _kids_: número de filhos
- _party_: afiliação partidária
- _turnout_: intenção de votar nas próximas eleições
- _vote\_history_: número de eleições presidenciais votou desde as eleições de 2002
- _economy_: opinião sobre o desempenho da economia nacional
- _incumbent_: opinião sobre o desempenho do presidente
- _candidate_: candidato preferido


## Agrupando com _filter_ e _pull_

Vamos supor que nos interessa comparar a renda entre grupos de sexo. Poderíamos, rapidamente selecionar as linhas de um dos grupos de sexo com o verbo _filter_:

```{r}
fake %>%
  filter(sex == "Male") 
```

```{r}
fake %>%
  filter(sex == "Female") 
```

Com o comando _pull_, podemos 'retirar' de um data frame uma coluna e tratá-la como um vetor destacado. _pull_ é mais um (de vários) verbos do _dplyr_:

```{r}
fake %>%
  filter(sex == "Male") %>%
  pull(income)
```

E, se adicionarmos à 'pipeline' um comando simples de estatística descritiva -- média, por exemplo -- calculamos uma estatística para o grupo para o qual selecionamos com _filter_:

```{r}
fake %>%
  filter(sex == "Male") %>%
  pull(income) %>%
  mean()
```

Note que não utilizamos o símbolo de atribuição '<-' e, portanto, não armazenamos o resultado em nenhum objeto.

Note também que podemos adicionar à pipeline qualquer função que não seja 'verbo' do _dplyr_, como comando _mean_.

Essa estratégia funciona para calcular uma medida qualquer para um grupo. Mas, em geral, interessa 'sumarizar' um variável -- como renda -- por uma variável de grupo -- como sexo -- sem destacar cada uma das categorias. Vamos ver como fazer isso.

## _summarise_

Uma maneira altenartiva ao que acabamos de realizar é utilizar o verbo _summarise_. Com ele, não precisamos extrair a variável do data frame para gerar um sumário estatístico. Veja como é simples:

```{r}
fake %>%
  filter(sex == "Male") %>%
  summarise(media_homens = mean(income))
```

```{r}
fake %>%
  filter(sex == "Female") %>%
  summarise(media_mulheres = mean(income))
```

## Agrupando com _group\_by_ by e _summarise_

Para agrupar os dados por uma ou mais variáveis na 'gramática' do _dplyr_ utilizamos o verbo _group\_by_ em combinação com _summarise_. Veja um exemplo antes de detalharmos seu uso:

```{r}
fake %>%
  group_by(sex) %>%
  summarise(media_renda = mean(income))
```

Veja que o resultado é uma tabela de duas linhas que contém a média de renda para grupo de sexo. O primeiro passo é justamente indicar qual é a variável -- discreta -- pela qual queremos agrupar os dados. Fazemos isso com _group\_by_

Na sequência, utilizamos _summarise_ para criar uma lista das operações que faremos em outras variáveis ao agrupar os dados. Por exemplo, estamos calculando a média da renda, que aparecerá com o nome 'media\_renda', para cada um dos grupos de sexo.

Execute novamente o código acima e observe atentamente sua estrutura antes de avançar.

O verbo _summarise_ permite mais de uma operação por agrupamento. Por exemplo, podemos calcular o desvio padrao da renda, a media da idade ('age') e a soma do número de eleições nas quais votou ('vote\_history'):

```{r}
fake %>%
  group_by(sex) %>%
  summarise(media_renda = mean(income),
            stdev_renda = sd(income),
            media_idade = mean(age),
            soma_eleicoes = sum(vote_history))
```

Simples, não? O comando _summarise_ é bastante flexível e aceita diversas operações. Veremos as mais comuns adiante.

E se quisermos, agora, utilizar mais de uma variável para agrupar os dados? Por exemplo, e se quisermos agrupar por sexo e candidato de preferência, como fazemos?

Basta adicionar outra variável dentro do comando _group\_by_:

```{r}
fake %>%
  group_by(sex, candidate) %>%
  summarise(media_renda = mean(income))
```

Observe bem a estrutura dos resultados que obtivemos. Em primeiro lugar, o resultado é sempre um data frame. Sempre que estivermos preparando os dados para gerar tabelas ou com gráficos, como veremos no encontro seguinte, produziremos um data frame para servir de 'input' para o gráfico ou tabela.

Em segundo, cada variável utilizada para agrupamento aparece como uma coluna diferente no novo data frame. Os dados estão 'colapsados' ou 'achatados' em um número de linhas que corresponde ao total de combinações de categorias das variáveis de agrupamento (por exemplo, "Female e Rilari", "Female e Trampi", etc).

Se pararmos para pensar, o data frame resultante do último comando tem exatamente o número de células de uma tabela de duas entradas ('crosstab'), mas as informações das margens da tabela estão como variáveis. Veremos como modificar isso adiante.

Finalmente, cada nova variável gerada com _summarise_ em nosso data frame 'achatado' recebe uma coluna. Para 'sumarizar' uma variável -- tirar média, somatória, contar, etc -- precisamos sempre de uma função de sumário.

## Funções de sumário estatístico

Vamos ver exemplos das funções de sumário estatístico mais utilizadas dentro do verbo _summarise_.

1- Média

```{r}
fake %>%
  group_by(sex) %>%
  summarise(media = mean(income))
```

2- Desvio padrão

```{r}
fake %>%
  group_by(sex) %>%
  summarise(desvpad = sd(income))
```


3- Mediana

```{r}
fake %>%
  group_by(sex) %>%
  summarise(mediana = median(income))
```

4- Quantis (no exemplo, quantis 10\%, 25\%, 75\%, 90\%)

```{r}
fake %>%
  group_by(sex) %>%
  summarise(quantil_10 = quantile(income, probs = 0.1),
            quantil_25 = quantile(income, probs = 0.25),
            quantil_75 = quantile(income, probs = 0.75),
            quantil_90 = quantile(income, probs = 0.9))
```

5- Mínimo e máximo

```{r}
fake %>%
  group_by(sex) %>%
  summarise(minimo = min(income),
            maximo = max(income))
```

6- Contagem e soma

```{r}
fake %>%
  group_by(sex) %>%
  summarise(contagem = n(),
            soma = sum(age))
```

Importante: quando houver algum "NA" (missing value) em uma variável numérica, é preciso utilizar o argumento "na.rm = TRUE" dentro da função de sumário. Veja como ficaria o código caso houvesse algum "NA":

```{r}
fake %>%
  group_by(sex) %>%
  summarise(media = mean(income, na.rm = TRUE))
```

A sessão Useful [Summary Functions](https://r4ds.had.co.nz/transform.html#summarise-funs) do livro R for Data Science traz uma relação mais completa de funçoes que podem ser usandas com summarise. O [“cheatsheet” da RStudio](https://github.com/rstudio/cheatsheets/raw/master/data-transformation.pdf) oferece uma lista para uso rápido.

## Transformando um agrupamento em um "crosstab" e exportando

Vamos retomar o exemplo do agrupamento por duas variáveis, sexo e candidato de preferência:

```{r}
fake %>%
  group_by(sex, candidate) %>%
  summarise(media_renda = mean(income))
```

Esse formato não costuma ser o usual em apresentação de dados. O mais comum é termos a informação que consta em nossas duas primeiras colunas como margens em uma tabela de duas entradas.

Na linguagem de manipulação de dados, o resultado acima está no formato "long" e todas as variáveis são representadas como colunas. Uma tabela de 2 entradas corresponde ao formato "wide".

Há dois verbos no _dplyr_ que transformam "long" em "wide" e vice-versa: _spread_ e _gather_. Como _spread_, tranformamos o nosso resultado acima na tabela desejada:

```{r}
fake %>%
  group_by(sex, candidate) %>%
  summarise(media_renda = mean(income)) %>%
  spread(sex, media_renda)
```

_spread_ precisa de 2 argumentos: a "key", que a variável que irá para a margem superior da tabela, e "value", que é a variável que ficará em seu conteúdo.

É fácil, inclusive, exportá-la para um editor de planilhas com a função _write\_csv_ (do pacote _readr_) ao final do pipeline:

```{r}
fake %>%
  group_by(sex, candidate) %>%
  summarise(media_renda = mean(income)) %>%
  spread(sex, media_renda) %>%
  write_csv("tabela_candidato_sexo_renda.csv")
```

Vá à sua pasta de trabalho e verifique que sua tabela está lá.

Veja que, como introduzimos um comando de exportação ao final do pipelina, não geramos nenhum objeto. Não há símbolo de atribuição em nosso código. Esse é um dos objetivo do uso do pipe (%>%): reduzir o número de objetos intermediários gerados.

### Spread e Gather caindo em desuso

Há notícias de que os verbos _spread_ e _gather_ cairão em desuso. Seus substituos serão _pivot\_wider_ e _pivot\_longer_. As 4 funções são parte do pacote _tidyr_, componente do _tidyverse_. O uso das novas funções é bem similar ao das antigas, e veja como fica a substituição de _spread_ por _pivot\_wider_ no código que produzimos. É possível que sua instalação do _tidyverse_ não contenha as novas funções e que o código abaixo não funcione.

```{r}
fake %>%
  group_by(sex, candidate) %>%
  summarise(media_renda = mean(income)) %>%
  pivot_wider(names_from = sex,
              values_from = media_renda)
```

## Mutate com Group By

Vamos supor que queremos manter os dados no mesmo formato, ou seja, sem 'achatá-los' por uma variável discreta, mas queremos uma nova coluna que represente a soma de uma variável por grupo -- para calcular percentuais de renda dentro de cada grupo de sexo, por exemplo. Vamos observar o resultado do uso conjunto de _group\_by_ e _mutate_. Para podermos observar o resultado, vamos armazenar os novos dados em um objeto chamado 'fake2' e utilizar o comando _View_. A última coluna de nossos dados agora é a soma da renda dentro de cada grupo.

```{r}
fake2 <- fake %>% 
  group_by(sex) %>%
  mutate(renda_grupo = mean(income))

View(fake2)
```

Quando utilizarmos _group\_by_ sem o _summarise_, é importante "desagrupar" os data frame, ou "desligar o agrupamento". Caso contrário, o agrupamento continuará ativo e afetando todas as operações seguintes. Repetindo o código com o desagrupamento:

```{r}
fake2 <- fake %>% 
  group_by(sex) %>%
  mutate(renda_grupo = mean(income)) %>%
  ungroup()
```

## Mais verbos do _dplyr_: _arrange_ e _slice_

Se quisermos ordenar, de forma crescente, nossos dados por idade, por exemplo, basta usar o comando _arrange_:

```{r}
fake %>% 
  arrange(age)
```

Em ordem decrescente teríamos:

```{r}
fake %>% 
  arrange(-age)
```

Se quisermos 'desempatar' o ordenamento por idade por uma segunda variável, basta adicioná-la ao _arrange_:

```{r}
fake %>% 
  arrange(-age, vote_history)
```

Quando trabalhamos com bases de dados de survey faz pouco sentido ordená-las. Entretanto, quando trabalhamos numa escala menor, com poucas linha, ou com a produção de tabelas, como nos exemplos acima, convém ordenar a tabela (veja que, neste ponto, faz pouco sentido diferenciar tabela de data frame, pois tornam-se sinônimos) por alguma variável de interesse.

Por exemplo, podemos ordenar os grupos de candidato de preferência por média de renda:

```{r}
fake %>% 
  group_by(candidate) %>% 
  summarise(media_renda = mean(income)) %>% 
  arrange(media_renda)
```

Fácil e útil.

Finalmente, vamos supor que queremos extrair da base de dados apenas os 10 indivíduos de menor idade Como "recortar" linhas dos dados pela posição das linhas?

Em primeiro lugar, vamos ordenar os dados por idade. A seguir, vamos aplicar o verbo _slice_ para recortar as 10 primeiras linhas:

```{r}
fake %>% 
  arrange(age) %>% 
  slice(1:10)
```

Se quisessemos recortar do 25, por exemplo, ao último, sem precisar especificar qual é o número da última posição, utilizamos _n()_:

```{r}
fake %>% 
  arrange(age) %>% 
  slice(25:n())
```

Note que a aplicação de _slice_ não afeta em nada as colunas.

