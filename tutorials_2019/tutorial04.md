---
title: 'Tutorial 4'
output: html_document
---

```{r setup, include=F}
knitr::opts_chunk$set(echo = TRUE, eval=F, include=T)
```

# Abrindo dados no R

Neste tutorial vamos cobrir uma série de métodos disponíveis para abrirmos arquivos de texto, editores de planilhas e de outros softwares de análise de dados no R. Vamos dar atenção aos argumentos das funções de forma a solucionar dificuldades de abertura de dados com diferentes características ou em sistemas operacionais variados.

## Pacotes no R

Antes de avançarmos à tarefa principal, vamos aprender um pouco mais sobre pacotes. Já foi destacado diversas vezes que uma das vantagens do R é a existência de uma comunidade produtiva e que desenvolve continuamente novas funcionalidades, tudo em código aberto.

Para instalarmos um novo pacote de R que esteja disponível no CRAN -- "The Comprehensive R Archive Network" -- utilizamos a função _install.packages_. Veja o exemplo com o pacote _beepr_:

```{r, eval = F}
install.packages("beepr")
```

Note que o nome do pacote deve estar em parêntese e aspas. Além disso, é possível que você tenha sido perguntada sobre de qual servidor do CRAN você quer baixar o pacote. A escolha em nada muda o resultado, exceto o tempo de duração do download.

Uma vez que um pacote foi instalado, ele está disponível em seu computador, mas não ainda para uso neste script e sessão R. Apenas depois de executarmos a função _library_ é que teremos o pacote em nossa "biblioteca" de funções.

```{r}
library(beepr)
```

Você pode dispensar as aspas ao usar a função _library_, pois é opcional.

Se você quiser usar rapidamente apenas uma função de um pacote sem carregá-lo, você pode utilizar a função precedidade por ":" duas vezes e o nome do pacote. Veja o exemplo:


```{r}
beepr::beep()
```

## Caminhos no R

Cada opção para importar dados para R depende de informar a R onde procurar no seu disco pelo arquivo. R sempre começa a procurar no 'diretório de trabalho'. Você pode verificar em qual diretório está trabalhando executando o seguinte comando:

```{r, eval = F}
getwd()
```

E como eu altero o "wd" (_working directory_)?

```{r, eval = F}
setwd("C:\\User\\Documents")
```

Simples e muito útil para evitar escrevermos "labirintos de pastas" cada vez que queremos importar dados. Agora só precisamos nos referir ao nome do arquivo (e não a sua pasta) para abrí-lo. É uma boa prática manter todos os arquivos, scripts e saídas importados em uma pasta de projeto bem organizada.

Um detalhe fundamental para quem usa Windows: os caminhos devem ser escritos com duas barras no lugar de uma, como no exemplo acima. É uma chatice e a melhor solução é mudar definitivamente para Linux e nunca mais pagar por software proprietário.

## Readr

Existem muitas funções para abrir arquivos de dados, mas para simplificar neste curso, vamos nos concentrar em um conjunto de funções do pacote _Readr_. O pacote _readr_, parte do _tidyverse_ (conjunto de pacotes com o qual vamos trabalhar), contém funções para abertura de dados 'retangulares' (.csv, .tsv, .txt). 

A maneira mais fácil de acessar as funções do _Readr_ é abrir a biblioteca do _tidyverse_ (instale-a primeira, se necessário).

```{r}
library(tidyverse)
```

Provavelmente a função mais usada no _Readr_ é _read\_csv_, que abre arquivos .csv. Em vez de abrir arquivos do nosso computador, também podemos abrir links e, para simplificar, disponibilizamos vários arquivos em nosso repositório do github. Você pode colar o url de cada arquivo no navegador para ver o seu formato antes de executar o código.

```{r}
file1 <- "https://raw.githubusercontent.com/leobarone/ifch_intro_r/master/data/bf_amostra_hv.csv"
dados <- read_csv(file1)
```

_dados_ deve aperecer como um objeto em seu 'Environment'. A função _read\_delim_ nos dá mais flexibilidade para lidar com tipos incomuns de arquivos. Por exemplo, podemos especificar o caractere usado para separar as colunas (por padrão, esta é a vírgula em read_csv):

```{r}
dados <- read_delim(file1, 
                    delim = ",")

file_semi_colon <- "https://raw.githubusercontent.com/leobarone/ifch_intro_r/master/data/bf_amostra_hp.csv"
dados <- read_delim(file_semi_colon, 
                    delim = ";")

file_tab <- "https://raw.githubusercontent.com/leobarone/ifch_intro_r/master/data/bf_amostra_ht.csv"
dados <- read_delim(file_tab, 
                    delim = "\t")
```

O padrão de _read\_delim_ (e _read\_csv_) é importar a primeira linha como nome das variáveis. Se nossos dados não tiverem um _header_ (cabeçalho, ou seja, nomes das variáveis na primeira linhas), a primeira linha de dados se torna equivocadamente o nome das variáveis (inclusive os números, que aparecem antecedidos por um "X"). Para corrigir o problema utilizamos o argumento "col_names", que deve ser igual a "FALSE" para os dados armezenados sem nomes de colunas, por exemplo:

```{r}
file_sem_header <- "https://raw.githubusercontent.com/leobarone/ifch_intro_r/master/data/bf_amostra_nv.csv"
dados <- read_delim(file_sem_header, 
                    col_names = F, 
                    delim = ",")
```

Além dos valores lógicos, "col_names" também aceita um vetor com novos nomes para as colunas como argumento:

```{r}
dados <- read_delim(file_sem_header, 
                    col_names = c("estado", "municipio_cod", "municipio_nome",
                                  "NIS", "transferido"),
                    delim = ",")
```

Por vezes, é interessante definir as classes das variáveis a serem importadas, para evitar novas transformações quando os dados forem importados. O argumento _col\_types_ deve ser uma sequência de caracteres onde "c" = "character", "d" = "double", "l" = "logical" e "i" = "integer". Por exemplo:

```{r}
dados <- read_delim(file1, 
                    delim = ",", 
                    col_types = "cicid")
```

Perceba que quando abrimos os dados sem especificar o tipo da coluna, a função _read\_csv_ tenta identificá-los. 

Uma complexidade de abertura de dados brasileiros é o uso da vírgula como separador decimal e o ponto para indicar milhares. Temos que especificar no argumento _locale_ essas diferenças. 

```{r}
dados <- read_delim(file1, 
                    delim = ",", 
                    locale = locale(decimal_mark=",",grouping_mark="."))
```

Também podemos usar _locale_ para especificar o formato da hora, o formato da data e o encoding do arquivo que estamos lendo.

Finalmente, é comum termos problemas para abrir arquivos que contenham caracteres especiais, pois há diferentes formas do computador transformar 0 e 1 em vogais acentuadas, cecedilha, etc. O "encoding" de cada arquivo varia de acordo com o sistema operacional e aplicativo no qual foi gerado.

```{r}
dados <- read_delim(file1, 
                    delim = ",", 
                    locale = locale(encoding='latin1'))
```

Para resolver este problema, informamos ao R o parâmetro _encoding_ dentro do _locale_, que indica qual é o "encoding" esperado do arquivo. Infelizmente não há formas automáticas infalíveis de descobrir o "encoding" de um arquivo e é preciso conhecer como foi gerado -- seja por que você produziu o arquivo ou por que você teve acesso à documentação -- ou partir para tentativa e erro. Alguns "encodings" comuns são "latin1", "latin2" e "utf8", mas há diversos outros. Como arquivo com o qual estamos trabalhando não contém caracteres especiais, não é preciso fazer nada.

## Tibbles

Se inspecionarmos o objeto criado por qualquer uma das operações acima, _dados_ parecem um pouco diferentes do que vimos antes. _dados_ é um data.frame, mas também tem alguns característicos adicionais que facilitam o nosso trabalho. Ele se chama um _tibble_ (um objeto pode ser de mais de uma clase). Observe que não utilizamos _head_ para imprimir as primeiras linhas. Essa é uma característica de _tibbles_: o output contém uma fração do banco, a informação sobre número de linhas e colunas, e os tipos de cada variável abaixo dos nomes das colunas. Você pode ler mais sobre _tibbles_ [aqui](https://cran.r-project.org/web/packages/tibble/vignettes/tibble.html).

## Dados em arquivos editores de planilhas

Editores de planilha são, em geral, a primeira ferramenta de análise de dados que aprendemos. Diversas organizações disponibilizam (infelizmente) seus dados em formato .xls ou .xlsx e muitos pesquisadores utilizam editores de planilha para construir bases de dados.

Vamos ver como obter dados em formato .xls ou .xlsx diretamente, sem precisar abrir os arquivos e exportá-los para um formato de texto.

Há dois bons pacotes com funções para dados em editores de planilha: _readxl_ e _gdata_. Vamos trabalhar apenas com o primeiro, mas convém conhecer o segundo se você for trabalhar constantemente com planilhas e quiser editá-las, e não só salvá-las. _readxl_ também é parte do _tidyverse_ mas temos que abri a biblioteca direitamente. Importe o pacote:

```{r}
library(readxl)
```


### Um pouco sobre donwload e manipulação de arquivos

Nosso exemplo será a Pesquisa Perfil dos Municípios Brasileiros de 2005, produzida pelo IBGE e apelidade de MUNIC. Diferentemente das demais funções deste tutorial, precisamos baixar o arquivo para o computador e acessá-lo localmente. Faça o download diretamente do [site do IBGE](ftp://ftp.ibge.gov.br/Perfil_Municipios/2005/base_MUNIC_2005.zip) e descompacte. Ou, mais interessante ainda, vamos automatizar o download e descompactação do arquivo (aviso: pode dar erro no Windows e tentaremos corrigir na hora -- use Linux!).

Em primeiro lugar, vamos guardar o endereço url do arquivo em um objeto e fazer o download. Note que na função _download.file_ o primeiro argumento é o url e o segundo é o nome do arquivo que será salvo.

```{r}
url_arquivo <- "ftp://ftp.ibge.gov.br/Perfil_Municipios/2005/base_MUNIC_2005.zip"
download.file(url_arquivo, "temp.zip", quiet = F)
```

O argumento "quiet = F" serve para não imprimirmos no console "os números" do download (pois o tutorial ficaria poluído), mas você pode retirá-lo ou alterá-lo caso queira ver o que acontece.

Com _unzip_, vamos extrair o conteúdo da pasta:

```{r}
unzip("temp.zip")
```

Use _list.files_ para ver todos os arquivos que estão na sua pasta caso você não saiba o nome do arquivo baixado. No nosso caso utilizaremos o arquivo "Base 2005.xls"

```{r, eval = F}
list.files()
```

Vamos aproveitar e excluir nosso arquivo .zip temporário: 

```{r}
file.remove("temp.zip")
```

## Voltando às planilhas

Para não repetir o nome do arquivo diversas vezes, vamos criar o objeto "arquivo" que contém o endereço do arquivo no seu computador (ou só o nome do arquivo entre aspas se você tivê-lo no seu wd):

```{r}
arquivo <- "Base 2005.xls"
```
Com _excel\_sheets_ examinamos quais são as planilhas existentes do arquivo:

```{r, results = 'hide'}
excel_sheets(arquivo)
```

No caso, temos 11 planilhas diferentes (e um bocado de mensagens de erro estranhas). O dicionário, para quem já trabalhou alguma vez com a MUNIC, não é uma base de dados, apenas textos espalhados entre células. As demais, no entanto, têm formato adequado para _data frame_.

Vamos importar os dados da planilha "Variáveis externas". As duas maneiras abaixo se equivalem:

```{r, results = 'hide'}
# 1
transporte <- read_excel(arquivo, "Variáveis externas")

# 2
transporte <- read_excel(arquivo, 11)
```

A função _read\_excel_ aceita os argumentos "col_names" e "col_types" tal como as funções de importação do pacote _readr_.

```{r, include = F}
file.remove("Base 2005.xls")
```

## Dados de SPSS, Stata e SAS

R é bastante flexível quanto à importação de dados de outros softwares estatísticos. Para este fim também há um pacote _haven_, que é, advinhe só, parte do _tidyverse_. 

```{r}
library(haven)
```

Basicamente, há cinco funções de importação de dados em _haven_: _read\_sas_, para dados em SAS; _read\_stata_ e _read\_dta_, idênticas, para dados em formato .dta gerados em Stata; e _read\_sav_ e _read\_por_, uma para cada formato de dados em SPSS. O uso, como era de se esperar, é bastante similar ao que vimos no tutorial todo.

Vamos usar como exemplo o [Latinobarômetro 2015](http://www.latinobarometro.org/latContents.jsp), que está disponível para SAS, Stata, SPSS e R. Como os arquivos são grandes demais e o portal do Latinobarômetro é "cheio de javascript" (dá mais trabalho pegar dados de um portal com funcionalidades construídas nesta linguagem), vamos fazer o processo manual de baixar os dados da página 'data bank', descompactar os arquivos de 2015 e abrí-los. Vamos ignorar SAS por razões que não interessam agora e por não ser uma linguagem popular nas ciências sociais, mas se você tiver interesse em saber mais, me procure.

## Abrindo os dados com haven

Vejamos o uso das funções em arquivos de diferentes formatos:

```{r}
# SPSS
latino_barometro_spss <- read_spss("Latinobarometro_2015_Eng.sav")
latino_barometro_spss

# Stata
latino_barometro_stata <- read_stata("Latinobarometro_2015_Eng.dta")
latino_barometro_stata
```

Simples assim.

Há critérios de conversão de variáveis categóricas, rótulos e etc, adotados pelo R ao importar arquivos de outras linguagens, mas você pode descobrí-los testando sozinha.

## Arquivos .RData

Faça download do arquivo do Latinobarômetro 2015 para formato R. Você verá que o arquivo tem a extensão .RData. Este é o formato de dados do R? Sim e não.

Começando pelo "não": um arquivo .RData não é um arquivo de base de dados em R, ou seja, não contém um _data frame_. Ele contém um workspace ('Environment') inteiro! Ou seja, se você salvar o seu workspace agora usando o "botão de disquete" do RStudio que está na aba "Enviroment" (provavelmente no canto superior à direita), você salvará todos os objetos que ali estão -- _data frames_, vetores, funções, gráficos, etc -- e não apenas um único _data frame_.

Em um tutorial futuro veremos como exportar arquivos de texto com as famílias de funções "write", primas das funções "read", dos mesmos pacotes que usamos neste tutorial.

Para abrir um arquivo .RData, por exemplo, o do Latinobarômetro ou o que você acabou de salvar, use a função _load_:

```{r}
# Latinobarometro
load("Latinobarometro_2015_Eng.rdata")
```



