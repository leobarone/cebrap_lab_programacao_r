# PNAD no R

Para este tutorial precisaremos de 2 pacotes: _dplyr_, que já conhecemos, e _survey_, para lidar com dados de survey. Se necessário, instale ambos antes de começar.

```{r}
library(dplyr)
library(survey)
```

## 

O IBGE oferece um pacote para abertura e manipulação dos dados da PNAD na [documentação oficial](https://ww2.ibge.gov.br/home/estatistica/populacao/trabalhoerendimento/pnad2015/microdados.shtm). No entanto, o pacote tem diversos problemas de funcionamento e a sua documentação é de baixa qualidade. Por esta razão, deixaremos ele de lado, mas faremos proveito de um dicionário construído para R contido na documentação.

Baixe, para atividade, os seguintes documentos: os arquivos de "Dados"; a pasta "Leitura em R"; e a pasta "Dicionários e inputs".

Separe no seu "working directory" os seguintes arquivos: "PES2015.txt" e "DOM2015.txt", ambos em "Dados"; o arquivo "dicPNAD2015.Rdata", que está na pasta "Leitura em R"; e os dicionários "Dicionаrio de variаveis de domicílios - PNAD 2015.xls" e "Dicionаrio de variаveis de pessoas - PNAD 2015.xls", ambos em "Dicionários e inputs".

Vamos começar abrindo o arquivo em formato 'RData'. Ele contém dois data frames, que representam os dicionários dos arquivos de pessoas e de domicílios.

```{r}
load("dicPNAD2015.Rdata")
```

Ambos data frames se assemelham aos dicionários da documentação oficial, que são os arquivos em formato '.xls'. Antes de prosseguir, veja se entende a organização dos dicionários.

O IBGE disponibiliza os arquivos de dados, em geral, em um formato diferente do que utilizamos no curso até agora. Em vez de usar um separador entre a colunas -- o que ocupa espaço na memória, o IBGE usa colunas em posição fixa. Por esta razão os dicionários trazem a informação da posição na qual cada coluna começa e qual é o seu tamanho. Os arquivos de dados também não contêm cabeçalho.

Vamos aproveitar que temos objetos de R que contêm as informações de tamanho e códigos das variáveis e destacá-los como vetores:

```{r}
tamanho <- dicpes2015$tamanho2 
codigo <- dicpes2015$cod2
```

Há uma pequena correção a ser feita na informação do tamanho da variável "V0102 - Número de controle". Seu tamanho no arquivo de dados é na verdade 6, e não 8, pois seus dois primeiros dígitos estão na variável anterior ('UF'). Está informação consta no dicionário em ".xls". Vamos corrigí-la no vetor:

```{r}
tamanho[3] <- 6
```

Para abrir dados em formato de colunas fixo ("fixed width format"), utilizamos a função _read.fwf_ e temos de informar os tamanhos das na exata sequência em que aparecem em cada linha, como vetor no parâmetro "width". Por sorte, já temos esse vetor. Caso contrário, teríamos que contruí-lo digitando (ou copiando do dicionário do Editor de Planilhs e arrumando como vetor). Como já temos os nomes das variáveis como vetor -- que deve ter o mesmo comprimento do vetor de tamanho dos campos, vamos aproveitar e utilizá-lo.

Para fins didáticos, vamos abrir apenas as 57193 primeiras linhas dos dados, que correspondem aos 7 estados da região Norte (veja o argumento "n").

```{r}
pes15 <- read.fwf("/home/lasagna/Dados/PES2015.txt", 
                  widths = tamanho, 
                  col.names = codigo,
                  n = 57193)
```

Simples, não? Se temos à disposição um vetor com o tamanho das colunas, abrir um arquivo com colunas de formato fixo é tão fácil quanto abrir um arquivo com colunas separadas por algum símbolo.

Vamos agora utilizar o que aprendemos do pacote _dplyr_ e preparar os dados para análise. Mesmo que se trate de um survey complexo, enquanto não estivermos produzindo estatísticas ou gerando colunas que dependem de combinações de linhas, sua manipulação é igual à de qualquer outra base dados.

Para o tutorial, escolhi algumas poucas variáveis. Vamos renomeá-las com a função _rename_, exluir as que não nos interessam com o comando _select_, filtrar os dados por alguns critérios e fazer transformações nas colunas que julgarmos necessárias.

As variáveis escolhidas são (use o comando abaixo para abrir o data frame de dicionário de pessoas):
```{r}
dicpes2015 %>%
  filter(cod2 == "UF" | cod2 == "V0085" | cod2 == "V0302" | cod2 == "V4718" |
         cod2 == "V4803" | cod2 == "V4727" | cod2 == "V4805" | cod2 == "V4808" | cod2 == "V4729")
```

Além de renomear e manter apenas as variáveis acima, vamos reduzir a base de dados para manter apenas pessoas entre 18 e 65, não estão em região metropolitana, que estejam ocupadas na semana de referência e com renda do trabalho menor que R$ 1.000.000,00 (para excluir is códigos númericos que representam missing values). Observe o dicionário em formato .xls e as transformações abaixo dentro do comando mutate.

Finalmente, vamos fazer algumas transformações em variáveis que utilizaremos em gráficos e tabelas. Em primeiro lugar, vamos (de maneira equivocada, mas aceitável para um exercício didático) transformar a variável de anos de estudo em numérica, forçando as categorias a valores entre 0 e 1. Volte ao dicionário para entender a transformação.

A seguir, vamos transformar a renda em logaritmo da renda natural. Também vamos reescrever os códigos numéricos da variável "sexo" (de 2 e 4 para 0 e 1) usando a função replace. Finalmente, vamos transformar os cógidos numéricos da variável "agric" em uma variável de texto e, para, na sequência, transformá-la em _factor_.

```{r}
dados <- pes15 %>%
  rename(idade = V8005,
         sexo = V0302,
         renda = V4718,
         educ = V4803,
         area_censitaria = V4727,
         ocup = V4805,
         agric = V4808,
         peso = V4729,
         projecao = V4609,
         inv_fra = V4610,
         peso_dom = V4611,	
         strat = V4617,
         psu = V4618) %>%
  select(UF, idade, sexo, renda, educ, area_censitaria, ocup, agric, peso, projecao, inv_fra, peso_dom, strat, psu) %>%
  filter(idade > 18 & idade < 65,
         area_censitaria == 2,
         ocup == 1,
         renda < 1000000) %>%
  mutate(educ = educ - 1,
         ln_renda = log(renda),
         sexo = replace(sexo, sexo == 2, 0),
         sexo = replace(sexo, sexo == 4, 1),
         agric = recode(agric, `1` = "agrícola", `2` = "não agrícola"),
         agric = factor(agric))
```

Se tiver tempo em sala, use o dicionário para escolher variáveis, seleção de linhas e transformações difentes da acima. Quando conseguir aplicar os "verbos" do _dplyr_ à PNAD, terá concluído o objetivo principal do curso!

## Pacote _survey_

Até agora, trabalhamos com a PNAD como se ela fosse qualquer outro conjunto de dados. Mas sabemos que, por se tratar de uma amostra estratificada de domicílios, em que as observações dentro do domicílio não são independentes entre si, e nas quais o peso das pessoas e domicílios depende dos estratos e do processo amostral, precisamos de outras ferramentas para produção de estatísticas descritivas e modelos.

O pacote _survey_ cumpre esta tarefa. Ele contém uma série de funções para descrever as variáveis de um survey, para produção de tabelas e de gráficos.

O primeiro passo ao utilizar o pacote de survey é informar qual é o desenho amostral do survey. Vamos falar um pouco sobre isso em sala.

Quando a finalidade for produzir estatísticas simples e modelos lineares bastante básicos (OLS, sem pesos ou clusterização de erros), precisamos informar apenas alguns poucos parâmetros. Faremos isso com a função _svydesign_, que produz objetos de classes "survey.design2" e "survey.design". Próprios do pacote.

"ids" é o parâmetro no qual informamos se a amostra é aleatória ("ids = ~1"). Em "data", informamos o objeto que contém os dados da amostra. "weights", obviamente, recebe o peso das observações. Para um uso simples da PNAD, podemos adotar os parâmetros abaixo.

```{r}
desenho <- svydesign(ids = ~psu, 
                     data = dados,
                     strata=~strat,
                     nest=TRUE,
                     weights = ~peso)
class(desenho)
```

Se quisermos conhecer o desenho da amostra a partir de um objeto da classe "survey.design", recorremos ao comando _summary_

```{r}
summary(desenho)
```

### Estatísticas descritivas

Vamos ver a seguir algumas funções simples para estatísticas descritivas de um objeto da classe "survey.design". Para tirar a média de uma variável, utilizamos _svymean_

```{r}
svymean(~renda, design = desenho)
```

Para calcular o somatório de uma variável, por sua vez, usamos _svytotal_

```{r}
svytotal(~idade, design = desenho)
```

Com _svyby_, aplicamos uma função de estatística descritiva (média, por exemplo) a uma variável (renda, por exemplo), por uma variável discreta (por exemplo, sexo):

```{r}
svyby(~renda, 
      by = ~sexo, 
      design=desenho, 
      FUN = svymean)
```
Se quisermos condicionar a estatística descritiva de uma variável por mais de uma variável discreta, basta complexificar o argumento "by" como no exemplo:

```{r}
svyby(~renda, 
      by = ~sexo + agric, 
      design=desenho, 
      FUN = svymean)
```

Apesar de correto, o formato da tabela não é muito agradável. 

Com a função _svytable_ produzimos tabelas de duas entradas (sem o sumário de estatísticas):

```{r}
svytable(~sexo + agric, 
         design = desenho)
```

Para obter proporções, podemos "envelopar" a tabela com a função _prop.table_

```{r}
# Proporção do total
prop.table(
  svytable(~sexo + agric, 
         design = desenho)
  )

# Proporção na linha
prop.table(
  svytable(~sexo + agric, 
         design = desenho),
  margin = 1
  )

# Proporção na coluna
prop.table(
  svytable(~sexo + agric, 
         design = desenho),
  margin = 1
  )

```

Se quisermos construir uma estatística condicional a uma seleção de linham podemos aplicar a função _subset_ no argumento "design", como no exemplo:

```{r}
svymean(~idade,  
        design = subset(desenho, sexo == 1))
```

Finalmente, se precisamos produzir um intervalo de confianças, _confint_ cumpre a tarefa:

```{r}
confint(svymean(~renda, design = desenho))
```

### Gráficos

Tal como com estatísticas descritivas, temos um conjunto de funções do pacote _survey_ para descrever graficamente os dados. Mas não se limite a tais funções: se você consegue produzir uma tabela, pode aplicar o resultado a outros pacotes gráficos do R -- como o _ggplot2_.

As funções gráficas se parece com as que acabamos de ver. _svyboxplot_ produz boxplots:

```{r}
svyboxplot(renda~1, 
           design = desenho, 
           main = "Dispersão da renda por sexo", 
           ylim = c(0,3000))
```

E alterando a fórmula podemos produzir boxplots por categoria de uma segunda variável:

```{r}
svyboxplot(renda~factor(sexo), 
           design = desenho, 
           main = "Dispersão da renda por sexo", 
           ylim = c(0,3000))
```

_svyplot_ é a função básica para gráficos de dispersão:

```{r}
svyplot(renda ~ educ, 
        design = desenho, 
        main = "Renda por anos de estudo completos", 
        ylim = c(0,4000)) 
```

Combinando _svymean_ com a função básica do R _barplot_, produzimos gráficos de barras:

```{r}
prop_agric <- svymean(~agric, 
                      design = desenho)
barplot(prop_agric, names.arg = c("Agrícola", "Não Agrícola"))
```

### Regressão linear (opcional)

Não vimos no curso como produzir modelos lineares no R. Para OLS, utilizamos função _lm_. O pacote _survey_ tem o seu equivalente de _lm_: a função _svyglm_. O uso é praticamente idêntico ao da função _lm_.

```{r}
reg <- svyglm(renda ~ educ + sexo, design = desenho)
summary(reg)
```


## Combinando arquivos de pessoas e domicílios

Quando trabalhamos com a PNAD, frequentemente combinamos os arquivos de domicílios e pessoas. Para fazer a combinação no R precisamos, em primeiro lugar, ter os dois data frames na memória. Seguinto o mesmo procedimento adotado anteriormente, vamos abrir o arquivo de domicílios:

```{r}
tamanho <- dicdom2015$tamanho 
codigo <- dicdom2015$cod
tamanho[3] <- 6
dom15 <- read.fwf("/home/lasagna/Dados/DOM2015.txt", 
                  widths = tamanho, 
                  col.names = codigo,
                  n = 21442)
```

A seguir, temos que escolher qual tipo de "join" faremos. Se você tem dúvida sobre essa parte, volte para o tutorial de bases de dados relacionais com o _dplyr_.

A escolha em nosso exemplo será combinar apenas os casos que estejam presentes tanto no arquivo de domicílios quanto no arquivo de pessoas. A combinação entre as bases de dados é feita por duas "chaves": as variáveis 'V0102' e 'V0103'. Aplicando a função _inner\_join_ temos:

```{r}
pnad_inner <- inner_join(pes15, dom15, by = c('V0102', 'V0103'))
```