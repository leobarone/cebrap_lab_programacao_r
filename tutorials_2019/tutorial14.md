# Abrindo e tratando diversos arquivos de dados simultaneamente

Quando trabalhos com pesquisas realizadas periodicamente e que contenham variáveis semelhantes nos diferentes anos -- como PNAD, Censo e a própria TICDOM --  é comum querermos combinar dados de várias coletas para a análise. Vamos ver rapidamente duas estratégias para fazer isso neste tutorial. Antes de prosseguir, carregue os pacotes necessários:

```{r}
library(tidyverse)
library(srvyr)
```

Nosso exemplo vamos produzir um gráfico bastante simples com o percentual de usuários de internet em cada um dos anos a partir dos dados de indivíduos da TICDOM de 2015 a 2017.

## Abrindo e tratando cada uma das bases individualmente

Vamos ver duas estratégias para lidar com o problema. A primeira, mais simples porém mais custosa, consiste em abrirmos e tratarmos cada um dos anos separadamente para, ao final, combinar os resultados. Vamos ver como proceder para combinar a TICDOM indivíduos de 3 anos diferentes, 2015, 2016 e 2017.

Antes de abrirmos os dados, convém observar os dicionários de cada uma das pesquisas para se certificar de que uma pergunta de interesse -- por exemplo, uso de internet -- está contida nos dados de todos os anos (variável C1: 'O respondente já usou internet?').

A seguir, vamos obter do website do CETIC o url do arquivo '.csv' que contém os dados do primeiro ano com o qual trabalharemos, 2015:

```{r}
url_2015 <- 'http://cetic.br/media/microdados/81/ticdom_2015_individuos_base_de_microdados_v1.0.csv'
```

Nosso primeiro passo será padronizar a grafia do nome das variáveis, renomeando. Chamaremos a variável C1 de 'internet'. Como trabalharemos com dados provenientes de um survey, também homogeneizaremos os nomes das variáveis relativas ao desenho amostra, respectivamente peso e estrato.

```{r}
ticdom_2015 <- url_2015 %>% 
  read_csv2() %>% 
  rename(internet = C1, peso = Peso, estrato = ESTRATO) 
```

Vamos repetir o procedimento para todos os anos. Note que em cada ano, C1, peso e estrato podem ter nomes diferentes. Em 2015 2017, a grafia de estrato é 'ESTRATO', equanto em 2016 é 'Estrato'. Peso, por outro lado, aparece como 'Peso' em 2015 e 2016, mas como 'PESO' em 2017.

```{r}
url_2016 <- 'http://cetic.br/media/microdados/82/ticdom_2016_individuos_base_de_microdados_v1.0.csv'

ticdom_2016 <- url_2016 %>% 
  read_csv2() %>% 
  rename(internet = C1, peso = Peso, estrato = Estrato) 

url_2017 <- 'http://cetic.br/media/microdados/181/ticdom_2017_individuos_base_de_microdados_v1.3.csv'

ticdom_2017 <- url_2017 %>% 
  read_csv2() %>% 
  rename(internet = C1, peso = PESO, estrato = ESTRATO) 
```

Pronto! Temos 3 data frames, um para cada ano, com as variáveis necessárias -- internet, peso e estrato -- padronizadas.

Para cada um dos anos, produziremos uma pequena tabela que contém o total de respondentes e o percentual para cada resposta à pergunta C1. Veja como fazer para 2015. Leia o código com calma e retome o conteúdo dos tutoriais anteriores se precisar.

```{r}
ticdom_2015 %>% 
  as_survey_design(strata = estrato, weights = peso) %>%
  group_by(internet) %>% 
  summarise(n = survey_total()) %>% 
  mutate(percentual = n / sum(n))
```

Só nos interesse um valor dessa tabela para a construção do gráfico: o percentual de respondetes que já usou internet (para 2015, 65.7\%). Vamos agora adicionar mais umas linhas para selecionarmos apenas com estar informação ao código e guardar o resultado em um objeto:

```{r}
pct_usuarios_2015 <- ticdom_2015 %>% 
  as_survey_design(strata = estrato, weights = peso) %>%
  group_by(internet) %>% 
  summarise(n = survey_total()) %>% 
  mutate(percentual = n / sum(n)) %>%
  filter(internet == 1) %>% 
  pull(percentual)
```

Repetindo o mesmo procedimento para 2016 e 2017:

```{r}
pct_usuarios_2016 <- ticdom_2016 %>% 
  as_survey_design(strata = estrato, weights = peso) %>%
  group_by(internet) %>% 
  summarise(n = survey_total()) %>% 
  mutate(percentual = n / sum(n)) %>%
  filter(internet == 1) %>% 
  pull(percentual)

  pct_usuarios_2017 <- ticdom_2017 %>% 
  as_survey_design(strata = estrato, weights = peso) %>%
  group_by(internet) %>% 
  summarise(n = survey_total()) %>% 
  mutate(percentual = n / sum(n)) %>%
  filter(internet == 1) %>% 
  pull(percentual)
```

Vamos combinar os 3 números em um único vetor:

```{r}
percentual <- c(pct_usuarios_2015, pct_usuarios_2016, pct_usuarios_2017)
```

Construir rapidamente um data frame:

```{r}
dados_grafico <- data.frame(ano = 2015:2017, percentual)
```

E produzir o gráfico:

```{r}
dados_grafico %>% 
  ggplot(aes(ano, percentual, fill = factor(ano))) +
  geom_col() + 
  geom_text(aes(label = format(percentual * 100, digits = 4)), vjust = -0.1) +
  ggtitle('Percentual de usuários de internet por ano') +
  ylab('% de usuários') +
  xlab('Ano') + 
  theme(legend.position="none")
```

Funciona, certo? Contudo, há um problema nessa estratégia. Temos que repetir o código para tratar os dados e produzir as estimativas para cada ano. Se estivéssemos trabalhando com uma década, em vez de um triênio, perderíamos rapidamente a parcimônia.

## Abrindo e tratando os dados em um For Loop

Há uma maneira bastante mais eficiente de lidar com esse problema. Nosso primeiro passo é pensar o que varia para cadda um dos anos.

No nosso caso, mudam apenas: o próprio ano; o url; e a grafia dos nomes das variáveis C1, peso e estrato (no exemplo a grafia de C1 não varia, mas poderia variar se estívessemos trabalhando com vários anos).

Nossa segunda estratégia começa pela criação de um vetor para cada elemento que varia a cada ano:

```{r}
anos <- 2015:2017
url_dados <- c(url_2015, url_2016, url_2017)
var_peso <- c('Peso', 'Peso', 'PESO')
var_estrato <- c('ESTRATO', 'Estrato', 'ESTRATO')
var_c1 <- c('C1', 'C1', 'C1')
```

Vamos agora criar, para fins didáticos  um pedaço de código que percorra, ao mesmo tempo, todos os nosso vetores. Faremos um for loop para que, a cada iteração (no nosso caso temos 3 iterações), tenhamos disponível um url, ano e grafias de variáveis diferentes.

```{r}
for (i in 1:3){
  print(paste('Iteração', i))
  print(url_dados[i])
  print(anos[i])
  print(var_peso[i])
  print(var_estrato[i])
  print(var_c1[i])
}
```

A seguir, aproveitaremos o código de abertura e tratamento dos dados acima utilizado para criar um instrução que irá dentro do for loop. Apagaremos os 'prints' e começaremos a utilizar os elementos do vetores, que são variáveis a cada iteração, dentro do código de abertura e tratamento dos dados.

Antes de começarmos o for loop, criaremos um objeto vazio que receberá os dados produzidos a cada iteração

Um detalhe importante: quando estivermos utilizando o nome de variável dentro de maneira genérica dentro do for loop, precisaremos adicionar dois pontos de exclamação antes para que os verbos do dplyr não confudam nome de variável com um simples texto.

```{r}
uso_internet <- NULL

for(i in 1:3){

  uso_internet_ano <- url_dados[i] %>% 
    read_csv2() %>% 
    rename(internet = !!var_c1[i]) %>%
    mutate(internet = as.character(internet)) %>% 
    as_survey_design(strata = !!var_estrato[i], weights = !!var_peso[i]) %>%
    group_by(internet) %>% 
    summarise(n = survey_total()) %>% 
    mutate(percentual = n / sum(n),
           ano = anos[i]) %>%
    filter(internet == 1) 
  
  uso_internet <- bind_rows(uso_internet, uso_internet_ano)
  
}
```

Nosso resultado é um data frame com 5 variáveis, dentre as quais as duas que precisamos para gerar o gráfico. Sem fazer praticamente nenhuma modificação, reaproveitamos o código utilizado anteriormente para gerar o gráfico de barras:

```{r}
uso_internet %>% 
  ggplot(aes(ano, percentual, fill = factor(ano))) +
  geom_col() + 
  geom_text(aes(label = format(percentual * 100, digits = 4)), vjust = -0.1) +
  ggtitle('Percentual de usuários de internet por ano') +
  ylab('% de usuários') +
  xlab('Ano') + 
  theme(legend.position="none")
```

Veja que, nessa estratégia, o custo de adicionar novos anos é bastante baixo. Basta adicionar novas posições aos vetores que contém os elementos que variam a cada ano e reexecutar o código.