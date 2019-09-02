---
title: 'Tutorial 6'
output: html_document
---

```{r setup, include=F}
knitr::opts_chunk$set(echo = TRUE, eval=F, include=T)
```

# Manipulação de dados com a gramática do Tidyverse

## Tibbles e data frames

Nosso primeiro exemplo será a base de dados dos saques efetuados pelos beneficiários do Bolsa Família em janeiro de 2017. O arquivo de janeiro 2017 é um arquivo grande, com mais de 12 milhões de linhas, então pegamos uma amostra aleatória de apenas 10000 linhas.

O primeiro elemento útil do tidyverse já vimos - as funções do _readr_ que nos permitem abrir arquivos:

```{r}
library(tidyverse)

saques_amostra_201701 <- read_delim("https://raw.githubusercontent.com/leobarone/FLS6397/master/data/saques_amostra_201701.csv", delim = ";", col_names = T)
```

Lembre-se que isso abre um tipo especial de _data.frame_ - um _tibble_. Se executarmos apenas o nome do _tibble_, obteremos um resumo dos dados útil e fácil de ler. Note que, ao contrário de um _data.frame_ que imprime centenas de linhas e preenche nossa tela, um _tibble_ se limita às primeiras dez linhas.

```{r}
saques_amostra_201701
```

## Introdução ao pacote dplyr

Um dos aspectos mais incríveis da linguagem R é o desenvolvimento de novas funcionalidades pela comunidade de usuários. Algumas das melhores soluções desenvolvidas são relacionadas à "gramática para bases de dados", ou seja, à maneira como importamos, organizamos, manipulamos e extraímos informações das bases de dados.

Neste tutorial vamos nos concentrar na "gramática" mais popular: o pacote _dplyr_, parte do _tidyverse_. 

## Renomeando variáveis

Com certa frequência, obtemos dados cujos nomes das colunas são compostos, contêm acentuação, cecedilha e demais caracteres especiais. Dá um tremendo trabalho usar nomes com tais característica. O ideal é termos nomes sem espaço (você pode usar ponto ou subscrito para separar palavras em um nome composto), preferencialmente com letras minísculas sem acento e números, apenas. Vamos começar renomeando algumas variáveis no nosso banco de dados, cujos nomes vemos com o comando abaixo:

```{r}
names(saques_amostra_201701)
```

O primeiro argumento da função _rename_ deve ser a base de dados cujos nomes das variáveis serão renomeados. Depois da primeir vírgula, inserimos todos as modificações de nomes, novamente separadas por vírgulas, e da seguinte maneira. Exemplo: nome\_novo = nome\_velho. Caso os nomes tenha espaço, como no nosso exemplo, é preciso usar o acento agudo antes e depois do nome antigo para que o R entenda onde ele começa e termina. Exemplo: nome\_novo = \`Nome Velho\`. Veja o exemplo, em que damos novos nomes às variáveis "UF" e "Nome Município"

```{r}
saques_amostra_201701 <- rename(saques_amostra_201701, uf = UF, munic = `Nome Município`)
```
O 'verbo' rename, da gramática do _dplyr_ é bastante mais simples do que usar do que o método anterior para renomear variáveis em um _data frame_.

## Uma gramática, duas formas

No _tidyverse_, existe uma outra sintaxe para executar a mesma tarefa de renomeação. Vamos olhar para ela:

```{r, eval = F}
saques_amostra_201701 <- saques_amostra_201701 %>% rename(uf = UF, munic = `Nome Município`)
```

Usando o operador %>%, denominado _pipe_, retiramos de dentro da função _rename_ o banco de dados cujas variáveis serão renomeadas:

rename(dados, xxx) = dados %>% rename(xxx)

Essa outra sintaxe tem uma vantagem grande sobre a anterior: ela permite emendar uma operação de transformação do banco de dados na outra. Veremos adiante como fazer isso. Por enquanto, tenha em mente que o resultado é o mesmo para qualquer uma das duas formas.

## Exercício

Renomeie as variáveis "Código SIAFI Município", "Nome Favorecido", "Valor Parcela", "Mês Competência" e "Data do Saque" como "cod_munic", "nome", "valor", "mes", "data_saque", respectivamente.

```{r, include = F, echo=F}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  rename(cod_munic = `Código SIAFI Município`,
          nome = `Nome Favorecido`, 
          valor = `Valor Parcela`, 
          mes = `Mês Competência`,
          data_saque = `Data do Saque`)
```

## Selecionando colunas

Algumas colunas são claramente dispensáveis em nosso banco de dados. Por exemplo, já sabemos que "Código Função", "Código Subfunção", "Código Programa" e "Código Ação" não variam entre as linhas, pois todas se referem ao Programa Bolsa Família. Vamos ficar apenas com as variáveis que já havíamos renomeado. Para tanto, utilizaremos o segundo verbo do _dplyr_ que aprenderemos: _select_

```{r}
saques_amostra_201701 <- select(saques_amostra_201701, uf, munic, cod_munic, nome, valor, mes, data_saque)
```

ou usando o operador %>%, chamado __pipe__,

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% select(uf, munic, cod_munic, nome, valor, mes, data_saque)
```


## Operador %>% para "emendar" tarefas

O que o operador __pipe__ faz é simplesmente colocar o primeiro argumento da função (no caso acima, o _data frame_), fora e antes da própria função. Ele permite lermos o código, informalmente, da seguinte maneira: "pegue o data frame x e aplique a ele esta função". Veremos abaixo que podemos fazer uma cadeia de operações ("pipeline"), que pode ser lida informalmente como: "pegue o data frame x e aplique a ele esta função, e depois essa, e depois essa outra, etc".

A grande vantagem de trabalharmos com o operador %>% é não precisar repetir o nome do _data frame_ diversas vezes ao aplicarmos a ele um conjunto de operações.

Use o comando _rm_ para deletar a base de dados e abra novamente. Vejamos agora como usamos o operador %>% para "emendar" tarefas:

```{r, include = F}
saques_amostra_201701 <- read_delim("https://raw.githubusercontent.com/leobarone/FLS6397/master/data/saques_amostra_201701.csv", delim = ";", col_names = T)
```

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  rename(uf = UF, 
         munic = `Nome Município`,
         cod_munic = `Código SIAFI Município`, 
         nome = `Nome Favorecido`,
         valor = `Valor Parcela`, 
         mes = `Mês Competência`, 
         data_saque =`Data do Saque`)  %>%
  select(uf, munic, cod_munic, nome, valor, mes, data_saque)
```

Em uma única sequência de operações, alteramos os nomes das variáveis e selecionamos as que permaneceriam no banco de dados. Esta forma de programa, tenha certeza, é bastante mais econômica e mais fácil de ler, para que possamos identificar erros mais facilmente.

Voltemos agora aos dados. Se observarmos as dimensões da nossa base dados, veremos que ela tem 10 mil linhas, mas apenas 7 colunas agora:

```{r}
dim(saques_amostra_201701)
```

## Transformando variáveis

Usaremos a função _mutate_ para operar transformações nas variáveis existentes e criar variáveis novas. Há inúmeras transformações possíveis e elas lembram bastante as funções de outros softwares, como MS Excel. Vamos ver algumas das mais importantes.

Um exemplo simples: vamor gerar uma nova variável com os nomes dos beneficiários em minúsculo usando a função _tolower_. Veja:

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% mutate(nome_min = tolower(nome))
```

ou, em uma forma alternativa,

```{r}
saques_amostra_201701 <-mutate(saques_amostra_201701, nome_min = tolower(nome))
```

Use o comando View para visualizar o resultado da coluna criada à direita do banco de dados. Simples, não? Basta inserimos dentro do 'verbo' _mutate_ a expressão da transformação que queremos.


Vamos a um exemplo um pouco mais difícil: A variável 'valor', apesar de conter números, foi lida como texto. Isso ocorre por que o R não entende o uso da vírgula como separador de milhar. Como resolver um problema desses? Precisamos substituir vírgula por vazio em um texto e, a seguir, indicar que o texto é, na verdade, um número. Em vez de criar uma nova variável "valor", vamos apenas alterar a variável já existente duas vezes. Com a função _gsub_, faremos a substituição da vírgula por vazio e com a função _as.numeric_ faremos a transformação texto-número.

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  mutate(valor = gsub(",", "", valor)) %>% 
  mutate(valor = as.numeric(valor))
```

A operação reversa a _as.numeric_, que transforma número em texto, é _as.character_. Vamos explorar as funções de texto e tranformação de variáveis em outro tutorial.

Precisamos usar _mutate_ duas vezes? Não. As duas formas abaixo são equivalentes à acima:

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  mutate(valor = as.numeric(gsub(",", "", valor)))
```

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  mutate(valor = gsub(",", "", valor), 
         valor = as.numeric(valor))
```

Vamos ver um novo exemplo. Faremos agora duas operações separadas, cada uma resultando em uma nova variável: dividiremos o valor por 3.8 para transformar o valor em dólares; e somaremos R$ 10 ao valor, pelo simples exercício de ver a transformação.

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  mutate(valor_dolar = valor_num / 3.8, 
         valor10 = valor_num + 10)
```

Use o comando _View_ para ver as novas variáveis no banco de dados.

As operações de soma, subtração, divisão, multiplicação, módulo entre mais de uma variável ou entre variáveis e valores são válidas e facilmente executadas como acima mostramos.

Nem todas as transformações de variáveis, porém, são operações matemáticas. Vamos transformar a variável valor em uma nova variável que indique se o valor sacado é "Alto" (acima de R\$ 300) ou "Baixo" (abaixo de R\$ 500) com o comando _cut_:

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  mutate(valor_categorico = cut(valor_num, 
                                c(0, 300, Inf), 
                                c("Baixo", "Alto")))
```

E se quisermos recodificar uma variável de texto? Por exemplo, vamos examinar a variável "mes". Ela contém o "Mês de Competência" do saque. Usemos a função _table_ para examiná-la:

```{r}
table(saques_amostra_201701$mes)
```

São 3 valores possíveis em nossa amostra: "11/2016", "12/2016" e "01/2017" em nossa amostra. Vamos gerar uma nova variável, ano, que indica apenas se a competência é 2016 ou 2017:

```{r}
saques_amostra_201701 <- saques_amostra_201701 %>% 
  mutate(ano = recode(mes, 
                      "11/2016" = "2016", 
                      "12/2016" = "2016", 
                      "01/2017" = "2017"))
```

Com as operações matemáticas, as transformações _as.numeric_ e _as.character_ e os comandos _cut_ e _recode_ podemos fazer praticamente qualquer recodifição de variáveis que envolva texto e números. A exceção, por enquanto, serão as variáveis da classe _factor_, que já vimos em tutorais anteriores. Para os interessados em expressões regulares, recomendo a leitura do arquivo "help" da família da função _gsub_, que inclui _grep_, _regexpre_ e outras.

## Exercício

Use os exemplos acima para gerar novas variáveis conforme instruções abaixo:

- Faça uma nova divisão da variável "valor" usando _cut_ a seu critério. Chame a nova variável de "valor\_categorico2".
- Cria uma variável "valor_euro", que é o valor calculado em Euros.
- Recodifique "valor\_categorico" chamando as categorias de "Abaixo de R\$300" e "Acima de R\$300". Chame a nova variável de "valor\_categorico3".
- Usando a função _recode_ recodifique "mes" em 3 novos valores: "Novembro", "Dezembro" e "Janeiro". Chame a nova variável de "mes\_novo".

## Filtrando linhas

Por vezes, queremos trabalhar apenas com um conjunto de linhas do nosso banco de dados. Por exemplo, se quisermos selecionar apenas os beneficiários do estado do Espírito Santo e salvarmos em um objeto chamado 'saques_amostra_ES':

```{r}
saques_amostra_ES <- saques_amostra_201701 %>% filter(uf == "ES")
```
ou 

```{r}
saques_amostra_ES <-filter(saques_amostra_201701, uf == "ES")
```

Exceto pelo uso do 'verbo' _filter_, não há nada de novo para nós. Nós já vimos condições como uf == "ES", que indica que apenas as linhas cuja variável _uf_ assumo valor igual a ES devem ser consideradas. Além da igualdade, poderíamos usar outros símbolos: maior (>). maior ou igual (>=), menor (<), menor ou igual (<=) e diferente (!=).  Para casos de _NA_, podemos usar a função is.na(), pois a igualdade '== NA' é inválida em R.

Também utilizamos aspas em "ES". Como estamos comparando os valores para cada linha a um texto, devemos usar as aspas.

Vamos supor agora que apenas os estados do Centro-Oeste nos interessam. Vamos criar um novo _data frame_, chamado saques_amostra_CO, que atenda a este critério:

```{r}
saques_amostra_CO <- saques_amostra_201701 %>% 
  filter(uf == "MT" | uf == "MS" | uf == "DF" | uf == "GO")
```

Note que, para dizer que queremos as quatro condições atendidas, utilizamos uma barra vertical. A barra é o símbolo "ou", e indica que todas as observações que atenderem a uma ou outra condição serão incluídas.

Vamos supor que queremos estabelecer agora condições para a seleção de linhas a partir de duas variáveis. Por exemplo, queremos incluir observações do Mato Grosso e que também tenham ano de competência (variável que criamos acima) igual a 2016. O símbolo da conjunção "e" é "&". Veja como utilizá-lo:

```{r}
saques_amostra_MT_2016 <- saques_amostra_201701 %>% 
  filter(uf == "MT" & ano == "2016")
```

Ao usar duas variáveis diferentes para filter e a conjunção "e", podemos escrever o comando separando as condições por vírgula e dispensar o operador "&":

```{r}
saques_amostra_MT_2016 <- saques_amostra_201701 %>% 
  filter(uf == "MT", ano == "2016")
```

Você pode combinar quantas condições precisar. Se houver ambiguidade quanto à ordem das condições, use parênteses das mesma forma que usamos com operações aritméticas.

## Exercício

- Crie um novo _data frame_ apenas com as observações cujo mês de competência é janeiro.
- Crie um novo _data frame_ apenas com as observações cujo valor é superior a R\$ 500.
- Crie um novo _data frame_ apenas com as observações cujo valor é superior a R\$ 500 e da região Sul.

## Resumos

Por enquanto, por mais que transformássemos as variáveis do banco de dados ou selecionássemos linhas, as unidades continuavam a ser os saques realizados por cada beneficiário. E se, no entanto, nos queremos gerar estatísticas resumidas? 

Por exemplo, se quisermos o total do valor de todas as transações em nosso banco de dados?

```{r}
saques_amostra_201701 %>% 
  summarize(Valor_total=sum(valor,na.rm=T))


```

E a média?

```{r}
saques_amostra_201701 %>% 
  summarize(Valor_media=mean(valor,na.rm=T))
```

Observe que o resultado de uma operação de _summarize_ é um valor único. Enquanto _mutate_ no máximo adiciona outra coluna ao nosso frame de dados e sempre retorna o mesmo número de linhas que o original, _summarize_ sempre *reduz* o número de linhas no resultado.

## Agrupando

Também podemos criar resumos para grupos específicos dentro de nossos dados. Conseguimos isso especificando a variável de agrupamento relevante com _group\_by_ em nosso fluxo de análise de dados. Por exemplo, para calcular o valor total de transações por estado:

```{r}
saques_amostra_201701 %>% 
  group_by(uf) %>%
  summarize(Valor_total=sum(valor,na.rm=T))
```

Também podemos usar a função _n()_ para simplesmente contar o número de linhas (neste caso, transações) em cada grupo (UF):

```{r}
saques_amostra_201701 %>% 
  group_by(uf) %>% 
  summarise(contagem = n())
```

Veja que usamos simultaneamente 2 funções, _group\_by_ e _summarise_. Eles tem significado literal: na primeira, inserimos as variáveis pelas quais agruparemos o banco de dados. Na segunda, as operações de "sumário", ou seja, de condensação, que faremos com o banco de dados e com as demais variáveis. No exemplo acima, apenas contamos, usando a função n(), quantas linhas pertencem a cada uf, que é a variável de grupo.

Vamos complicar um pouco mais. Suponhamos que, além da contagem, tenhamos interesse na soma, média, mediana, desvio padrão, mínimo, máximo dos valores no mesmo resultado. Neste caso, devemos inserir novas operações na função _summarize_, separadas por vírgula:

```{r}
valores_uf <- saques_amostra_201701 %>% 
  group_by(uf) %>% 
  summarise(contagem = n(),
            soma = sum(valor),
            media = mean(valor),
            mediana = median(valor),
            desvio = sd(valor),
            minimo = min(valor),
            maximo = max(valor))
```

Use _View_ para observar o resultado.

A sessão [_Useful Summary Functions_](http://r4ds.had.co.nz/transform.html#summarise-funs) do livro _R for Data Science_ traz uma relação mais completa de funçoes que podem ser usandas com _summarise_. O ["cheatsheet" da RStudio](https://github.com/rstudio/cheatsheets/raw/master/data-transformation.pdf) oferece uma lista para uso rápido.

## Exercício

Usando a variável "mes_novo", calcule a contagem, soma e média de valores para cada mês.

## Mais de um grupo

E se quisermos agrupar por mais de uma variável? Veja como fazer um agrupamento por "mes"" e "uf", reportando apenas a contagem de saques em cada combinação de grupos:

```{r}
contagem_uf_mes <- saques_amostra_201701 %>% 
  group_by(uf, mes) %>% 
  summarise(contagem = n())
```

Note que, agora, cada uf é repetida duas ou três vezes, uma para cada mês. Cada grupo gera uma nova coluna e as linhas representam exatamente a combinação de grupos de cada variável presente nos dados.

Finalmente, podemos utilizar múltiplas variáveis de grupo em conjunto e também gerar um sumário com diversas varáveis, como no exemplo a seguir, que combina parte dos dois anteriores:

```{r}
valores_uf_mes <- saques_amostra_201701 %>% 
  group_by(uf, mes) %>% 
  summarise(contagem = n(),
            soma = sum(valor),
            media = mean(valor),
            desvio = sd(valor))
```

## Ordenando a base de dados

Quando trabalhamos com bases de dados muito grandes, faz pouco sentido ordená-las. Entretanto, quando trabalhamos numa escala menor, com poucas linha, como nos exemplos acima, convém ordenar a tabela (veja que, neste ponto, faz pouco sentido diferenciar tabela de _data frame_, pois tornam-se sinônimos) por alguma variável de interesse.

Se quisermos ordenar, de forma crescente, a tabela de valores por uf pela soma de valores, basta usar o comando _arrange_:

```{r}
valores_uf <- valores_uf %>% arrange(soma)
```

Apenas para ilustrar, poderíamos ter usado o comando _arrange_ diretamente ao gerar a tabela:

```{r}
valores_uf <- saques_amostra_201701 %>% 
  group_by(uf) %>% 
  summarise(contagem = n(),
            soma = sum(valor),
            media = mean(valor),
            mediana = median(valor),
            desvio = sd(valor),
            minimo = min(valor),
            maximo = max(valor)) %>%
  arrange(soma)
```

Se quisermos rearranjar uma tabela, agora em ordem decrescente de média de valores, por exemplo, colocamos o negativo em frente da variável:

```{r}
valores_uf <- valores_uf %>% arrange(-soma)
```

Para usar mais de uma variável ao ordenar, basta colocá-las em ordem de prioridade e separá-las por vírgula. No exemplo abaixo ordenamos pela mediana (descendente) e depois pelo máximo:

```{r}
valores_uf <- valores_uf %>% arrange(-mediana, maximo)
```

