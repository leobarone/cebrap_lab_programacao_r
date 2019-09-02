# Manipulação de dados com a gramática do Tidyverse

Um dos aspectos mais incríveis da linguagem R é o desenvolvimento de novas funcionalidades pela comunidade de usuários. Algumas das melhores soluções desenvolvidas são relacionadas à "gramática para bases de dados", ou seja, à maneira como importamos, organizamos, manipulamos e extraímos informações das bases de dados.

Neste tutorial vamos nos concentrar na "gramática" mais popular: o pacote _dplyr_, parte do _tidyverse_. Veremos, por enquanto, apenas 3 operações:

Há várias maneiras de se trabalhar com bases de dados em R e a "gramática" do _dplyr_ é a mais popular e, ao meu ver, simples. Há, inclusive, uma forma de se trabalhar com conjuntos de dados mais, digamos, antiga, que é a "gramática" original da linguagem, que chamaremos de "base" ou "básico". Podemos pensar na linguagem R como uma língua com diversos dialétos. Os dois dialétos "dominantes" para manipulação de dados são o "base" e o do pacote _dplyr_.

O pacote _dplyr_ é parte do _tidyverse_, que é tanto um pacote "guarda-chuva" em R (ou seja, que carrega diversos outros pacotes) e um "movimento" de reescrever a linguagem. Antes de começar, vamos carregar o pacote _tidyverse_ que, dentre outros, carrega o _dplyr_.

```{r}
library(tidyverse)
```

Além do _dplyr_, vamos utilizar também um novo pacote, _readr_, que é o pacote do _tidyverse_ para abertura de dados, como você pode ver no tutorial 4. Note que as funções do _readr_ são bastante parecidas com as funções de abertura de dados do "base", sendo que as funções do primeiro são grafados com "\_" (por exemplo, _read\_csv_ para abrir arquivos .csv) e as do segundo com "." (como em read.csv). As funções do pacote _readr_ são, no geral, mais rápidas e contém por padrão alguns parâmetros desejáveis (por exemplo, carregar variáveis de texto como "character" e não como "factor").

## Tibbles e data frames

A partir deste tutorial vamos trabalhar com as bases de dados do CETIC. Em particular, vamos começar trabalhando com a TICDOM. Faremos a abertura dos dados diretamente da internet com a função _read\_csv2_, que abre arquivos de texto com colunas separadas por ponto e vírgula, como a TICDOM. Lembre-se de abrir o dicionário dos dados para acompanhar o tutorial, que você pode baixar [aqui](http://cetic.br/media/microdados/154/ticdom_2017_domicilios_dicionario_de_variaveis_v1.1.xlsx).

Para abrir um arquivo diretamente da internet vamos guardar o url em um objeto de texto e utilizá-lo na função de abertura de dados como input:

```{r}
ticdom_url <- "http://cetic.br/media/microdados/153/ticdom_2017_domicilios_base_de_microdados_v1.1.csv"

ticdom <- read_csv2(ticdom_url)
```
As funções do pacote _readr_ abrem um tipo especial de _data.frame_ - um _tibble_. Tibbles são como data\_frames, mas contêm algumas características adicionais. Se executarmos apenas o nome do _tibble_, obteremos um resumo dos dados útil e fácil de ler. Note que, ao contrário de um _data.frame_ que imprime centenas de linhas e preenche nossa tela, um _tibble_ se limita às primeiras dez linhas:

```{r}
ticdom
```

## Introdução ao pacote dplyr

## Renomeando variáveis

Com certa frequência, obtemos dados cujos nomes das colunas são compostos, contêm acentuação, cecedilha e demais caracteres especiais. Dá um tremendo trabalho usar nomes com tais característica. O ideal é termos nomes sem espaço (você pode usar ponto ou subscrito para separar palavras em um nome composto) e que contenham preferencialmente letras minísculas sem acento e números. Vamos começar renomeando algumas variáveis no nosso banco de dados, cujos nomes vemos com o comando abaixo:

```{r}
names(ticdom)
```

O primeiro argumento da função _rename_ deve ser a base de dados cujos nomes das variáveis serão renomeados. Depois da primeira vírgula, inserimos todos as modificações de nomes, novamente separadas por vírgulas, e da seguinte maneira. Exemplo: nome\_novo = nome\_velho. Exemplo: nome\_novo = Nome_Velho. Veja o exemplo, em que damos novos nomes às variáveis "A1_B" e "a2_qtd_note", respectivamte se há algum notebook no domicílio e quantos há. 

```{r}
ticdom <- rename(ticdom, notebook = A1_B, notebook_n = a2_qtd_note)
```

O 'verbo' rename, da gramática do _dplyr_ é bastante mais simples do que usar do que o método anterior para renomear variáveis em um _data frame_.

## Uma gramática, duas formas

No _tidyverse_, existe uma outra sintaxe para executar a mesma tarefa de renomeação. Vamos olhar para ela (lembre-se de carregar novamente os dados, pois os nomes velhos já não existem mais):

```{r, eval = F}
ticdom <- read_csv2(ticdom_url)
ticdom <- ticdom %>%
  rename(notebook = A1_B,
         notebook_n = a2_qtd_note)
```

Usando o operador %>%, denominado _pipe_, retiramos de dentro da função _rename_ o banco de dados cujas variáveis serão renomeadas. As quebras de linha depois do %>% e dentro da função _rename_ são opcionais. Porém, o pardão é 'vertucalizar o código' e colcar os 'verbos' à esquerda, o que torna sua leitura mais confortável.

Compare com o código que havíamos executado anteriormente:

```{r, eval = F}
ticdom <- read_csv2(ticdom_url)
ticdom <- rename(ticdom, notebook = A1_B, notebook_n = a2_qtd_note)
```

Essa outra sintaxe tem uma vantagem grande sobre a anterior: ela permite emendar uma operação de transformação do banco de dados na outra. Veremos adiante como fazer isso. Por enquanto, tenha em mente que o resultado é o mesmo para qualquer uma das duas formas.


Vamos trabalhar com várias variáveis (sic) de uma única vez. Reabra o banco de dados:

```{r, include = F, echo=F}
ticdom <- read_csv2(ticdom_url)
```

Renomeie as variáveis "RENDA_FAMILIAR", "a2_qtd_note", "a2_qtd_desk", "a2_qtd_tab", "A4", "A5", "A9", "ESTRATO", "PESO" e "UPA".

```{r, include = F, echo=F}
ticdom <- ticdom %>% 
  rename(renda  = RENDA_FAMILIAR,
         notebook_n = a2_qtd_note,
         desktop_n = a2_qtd_desk,
         tablet_n = a2_qtd_tab,
         internet = A4,
         tipo_conexao = A7,
         preco_internet = A9,
         estrato = ESTRATO,
         peso = PESO,
         upa = UPA)
```

## Selecionando colunas

Algumas colunas podem ser dispensáveis em nosso banco de dados a depender da análise. Por exemplo, pode ser que nos interessem apenas as variáveis que já renomeamos. Para selecionar um conjunto de variáveis, utilizaremos o segundo verbo do _dplyr_ que aprenderemos: _select_

```{r}
ticdom <- select(ticdom,
                 renda,
                 notebook_n,
                 desktop_n,
                 tablet_n,
                 internet,
                 tipo_conexao,
                 preco_internet,
                 estrato,
                 peso,
                 upa)
```

ou usando o operador %>%, chamado __pipe__,

```{r}
ticdom <- ticdom %>% 
  select(renda,
         notebook_n,
         desktop_n,
         tablet_n,
         internet,
         tipo_conexao,
         preco_internet,
         estrato,
         peso,
         upa)
```

## Operador %>% para "emendar" tarefas

O que o operador __pipe__ faz é simplesmente colocar o primeiro argumento da função (no caso acima, o _data frame_), fora e antes da própria função. Ele permite lermos o código, informalmente, da seguinte maneira: "pegue o data frame x e aplique a ele esta função". Veremos abaixo que podemos fazer uma cadeia de operações ("pipeline"), que pode ser lida informalmente como: "pegue o data frame x e aplique a ele esta função, e depois essa, e depois essa outra, etc".

A grande vantagem de trabalharmos com o operador %>% é não precisar repetir o nome do _data frame_ diversas vezes ao aplicarmos a ele um conjunto de operações.

Vejamos agora como usamos o operador %>% para "emendar" tarefas, começando da abertura desde dados. Note que o primeiro input é o url da base de dados e, que, uma vez carregados, vai sendo transformado a cada novo verbo.

```{r}
ticdom <- ticdom_url %>% 
  read_csv2() %>% 
  rename(renda  = RENDA_FAMILIAR,
         notebook_n = a2_qtd_note,
         desktop_n = a2_qtd_desk,
         tablet_n = a2_qtd_tab,
         internet = A4,
         tipo_conexao = A7,
         preco_internet = A9,
         estrato = ESTRATO,
         peso = PESO,
         upa = UPA) %>% 
  select(renda,
         notebook_n,
         desktop_n,
         tablet_n,
         internet,
         tipo_conexao,
         preco_internet,
         estrato,
         peso,
         upa)
```

Em uma única sequência de operações, abrimos os dados, alteramos os nomes das variáveis e selecionamos as que permaneceriam no banco de dados. Esta forma de programa, tenha certeza, é bastante mais econômica e mais fácil de ler, para que possamos identificar erros mais facilmente.

## Transformando variáveis

Usaremos a função _mutate_ para operar transformações nas variáveis existentes e criar variáveis novas. Há inúmeras transformações possíveis e elas lembram bastante as funções de outros softwares, como MS Excel. Vamos ver algumas das mais importantes.

Por exemplo, diversas variáveis na TICDOM, como as referentes às perguntas sobre quantidade de computadores e tables, têm os valores 999999999 para indicar que a pergunta não se aplica. Podemos transformar esses valores em 0, fazendo sua substituição:

```{r}
ticdom <- ticdom %>%
  mutate(notebook_n = replace(notebook_n, notebook_n == 999999999, 0),
         desktop_n = replace(desktop_n, desktop_n == 999999999, 0),
         tablet_n = replace(tablet_n, tablet_n == 999999999, 0))
```


Como utilizamos os nomes das próprias variáveis à esquerda da operação de transformação, produziremos uma substituição e não haverá novas colunas na base de dados.

Vamos agora aproveitar que temos as variáveis transformadas e criar uma nova, que representa a soma de todos os computadores e tablets de cada domicílio. Vamos dar a ela o nome 'devices\_qtd' e, por utilizarmos um nome novo de variável, haverá uma nova coluna à direita dos dados.

```{r}
ticdom <- ticdom %>%
  mutate(devices_n = notebook_n + desktop_n + tablet_n)
```

Use o comando View para visualizar o resultado da coluna criada à direita do banco de dados. Simples, não? Basta inserimos dentro do 'verbo' _mutate_ a expressão da transformação que queremos, que, no caso, é uma soma de 3 outras variáveis.

Podemos examinar o resultado com a tabela:

```{r}
table(ticdom$devices_n)
```

Vamos supor, agora, que nos interessa que essa variável seja transformada em faixas arbitrárias: "0 devices", "1 a 2 devices" e "3 a 5 devices" e "6 ou mais devices". Produziremos uma nova variável, "devices_faixa", e utilizaremos a função "cut" para transformar a variável "devices_n":

```{r}
ticdom <- ticdom %>% 
  mutate(devices_faixa = cut(devices_n,
                             c(-Inf, 0, 2, 5, Inf),
                             c("0", "1 a 2", "3 a 5", "6 ou mais")))
```

Os valores "-Inf" e "Inf" representa infinitos negativo e positivo, respectivamente, e servem para não delimitar as pontas das faixas onde produziremos os cortes. Os cortes centrais são dados em 0, 2 e 5. Podemos examinar o resultado com a tabela cruzada:

```{r}
table(ticdom$devices_n, ticdom$devices_faixa)
```

## Filtrando linhas

Por vezes, queremos trabalhar apenas com um conjunto de linhas do nosso banco de dados. Por exemplo, se quisermos selecionar apenas os respondentes com renda familiar "De R$ 1.874,01 até R$ 2.811,00" (valor 3 na variável renda), utilizamos o verbo 'filter' com a condição desejada. Note que estamos criando um novo data frame que contém a seleção de linhas produzida:

```{r}
ticdom_renda3 <- ticdom %>% 
  filter(renda == 3)
```

Além da igualdade, poderíamos usar outros símbolos: maior (>). maior ou igual (>=), menor (<), menor ou igual (<=) e diferente (!=) para selecionar casos. Para casos de _NA_, podemos usar a função is.na(), pois a igualdade '== NA' é inválida em R. Vamos supor agora que queremos todos os respondentes com renda até R$ 2.811,00 (valores 1, 2 e 3 na variável renda) e também os que não têm renda (valor 9):

```{r}
ticdom_baixa <- ticdom %>% 
  filter(renda <= 3 | renda == 9)
```

Note que, para dizer que para combinarmos as condições de seleção de linha, utilizamos uma barra vertical. A barra é o símbolo "ou", e indica que todas as observações que atenderem a uma ou outra condição serão incluídas.

Vamos supor que queremos estabelecer agora condições para a seleção de linhas a partir de duas variáveis. Por exemplo, queremos incluir as mesmas faixas de renda já escolhidas  e que também tenham internet em casa. O símbolo da conjunção "e" é "&". Veja como utilizá-lo:

```{r}
ticdom_baixa <- ticdom %>% 
  filter(renda <= 3 | renda == 9 & internet == 1)
```

Ao usar duas variáveis diferentes para filter e a conjunção "e", podemos escrever o comando separando as condições por vírgula e dispensar o operador "&":

```{r}
ticdom_baixa <- ticdom %>% 
  filter(renda <= 3 | renda == 9,
         internet == 1)
```

Você pode combinar quantas condições precisar. Se houver ambiguidade quanto à ordem das condições, use parênteses das mesma forma que usamos com operações aritméticas.

# Exercício

Para treinar o que acabamos de ver, abra novamente os dados e produza as seguintes transformações nos dados:

1 - renomeie as variáveis "AREA" e "A4" com o verbo _rename_;

2 - com o verbo _select_, mantenha na base de dados apenas as duas variáveis renomeadas;

3 - com o verbo _mutate_, modifique a variável A4 para transformar os valores 97 ('Não sabe') e 98 ('Não respondeu') em NA (que é o símbolo de missing values em R). Você precisará usar a função _replace_ dentro do verbo _mutate_.

4 - selecine, com _filter_, apenas os respondentes de área rural.

