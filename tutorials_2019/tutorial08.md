
# Visualização de Dados

Para este tutorial vamos usar novamente dados de Fakeland, como fizemos no tutorial 6. Em vez de apenas 30 observações, agora trabalharemos com um conjunto maior de cidadãos (200) e menos variáveis, para facilitar nosso trabalho.

Antes de abrir os dados, vamos começar abrindo o _tidyverse_ que contêm a biblioteca para a produção de gráficos, _ggplot2_:

```{r}
library(tidyverse)
```

A seguir, carregue os dados, que estão no repositório do curso:

```{r}
url_fake_data <- "https://raw.githubusercontent.com/leobarone/cebrap_lab_programacao_r/master/data/fake_data_2.csv"
fake <- read_delim(url_fake_data, delim = ";", col_names = T)
```

## ggplot2: uma Gramática de Dados

Em conjunto com a gramática de manipulação de dados do _dplyr_, a gramática de gráficos _ggplot2_ é um dos destaques da linguagem R. Além de flexível e aplicável a diversas classes de objetos (data frames, objetos de mapa e redes, por exemplo), a qualidade dos gráficos é excepcionalmente boa.

Existe uma forte ligação entre a gramática de _dplyr_ e a gramática de _ggplot2_: toda a informação para o nosso gráfico vem de um data.frame; cada linha em nosso data.frame é uma 'unidade' a ser exibida no gráfico, e cada coluna em nosso data.frame é uma variável que determina um aspecto visual específico do gráfico, incluindo posição, cor, tamanho e forma.

Neste tutorial vamos priorizar a compreensão da estrutura do código para produzir gráficos com _ggplot2_ a partir de alguns exemplos simples e propositalmente não cobriremos todas as (inúmeras) possibilidades de visualização.

Você verá, depois de um punhado de gráficos, que a estrutura pouco muda de um tipo de gráfico a outro. Quando precisar de um "tipo" novo de gráfico, ou, como denominaremos a partir de agora, de uma nova "geometria", bastará aprender mais uma linha de código a ser adicionada ao final de um código já conhecido.

Vamos logo a um primeiro exemplo para esclarecer o assunto.

## Um primeiro exemplo de gráficos com uma variável discreta

Queremos conhecer a distribuição de preferências de candidato à presidência na amostra de cidadãos de Fakeland. Veja como apresentar essa informação com o pacote _ggplot2_:

```{r}
fake %>% 
  ggplot() +
  geom_bar(aes(x = candidato))
```

Bastante estranho, não? Vamos olhar cada uma de suas partes.

Comecemos pela primeira linha. A principal função do código é, como era de se esperar, _ggplot_ (sem o 2 mesmo). Note que não estamos fazendo uma atribuição, por enquanto, pois queremos apenas "imprimir" o gráfico, e não guardá-lo como objeto.

O argumento da função _ggplot_ é "data", ou seja, o objeto que contém os dados a serem visualizados. No nosso caso, é o data frame _fake_. Podemos colocar os dados no início do nosso código como 'pipe' (%>%) para não precisar inserí-lo dentro da função _ggplot_. Você verá que isso será bem útil num futuro breve.

Ao usar _ggplot_ iniciamos um gráfico sem conteúdo, por enquanto.

Agora, para adicionarmos uma geometria, colocamos um símbolo de "+" após fecharmos o parêntesis da função _ggplot_. Cada "+" nos permite adicionar mais uma camada em nosso gráfico. Mas qual camada? Nós definimos um gráfico por sua _geometria_ - o tipo de representação visual dos nossos dados que queremos. _geom\_bar_ indica que queremos uma geometria de barras, como um 'bar chart' em editores de planilha.

A escolha da geometria depende do tipo de dados que você deseja visualizar de seu dados.frame. Aqui, analisamos a distribuição de preferências de candidato à presidência, que é uma variável discreta (_character_ ou _factor_), então usamos uma geometria que corresponda com dados discretos. A lógica de um gráfico de barras é representar a contagem de frequência de cada categoria discreta, então faz sentido usar a geometria _geom\_bar_. Vamos ver exemplos de outras geometrias que corespondam a outros dados abaixo.

Na linha de código da geometria, as 3 letrinhas "aes" causam estranheza. "aes" é a abreviação de "aesthetics". Aqui definiremos quais variáveis de nosso _data.frame_ farão parte do gráfico. Estamos trabalhando por enquanto com apenas uma variável, representada no eixo horizontal, ou eixo "x". Por esta razão preenchemos o parâmetro "x" da "aesthetics" e nada mais.

## Gráficos com uma variável contínua - Gráficos de histogramas

Vamos trocar rapidamente para uma variável contínua, renda, alterando o valor de "x" dentro de "aesthetics".

```{r}
fake %>% 
  ggplot() + 
  geom_bar(aes(x = renda))
```

Este gráfico está em branco, por quê? Tentamos representar uma variável contínua com uma geometria construído para variáveis discretas. Como cada valor de renda é único, existe uma barra (minúscula) para cada indivíduo e o gráfico não faz sentido. Precisamos mudar o geometria - o equivalente de um gráfico de barras para variáveis contínuas é um histograma, então usamos _geom\_histogram_.

```{r}
fake %>% 
  ggplot() + 
  geom_histogram(aes(x = renda))
```

Faz mais sentido? Espero que sim. Compare os dois códigos dos gráficos acima com calma e compreenda as diferenças. Note que o tipo de variável que demanda a geometria a ser escolhida, e não contrário.

### Exercício

Use o banco de dados de Fakeland para criar um gráfico que mostre o nível de apoio para cada partido, e outro que gráfico que mostre a distribuição da idade (trate idade como uma variável contínua). 

### Parâmetros fixos 

As geometrias, cada uma com sua utilidade, também têm parâmetros que podem ser alterados. Por exemplo, as barras do histograma que acabamos de produzir são muito "fininhas". Vamos aumentar sua largura, ou seja, vamos representar mais valores do eixo "x" em cada barra do histograma:

```{r}
fake %>% 
  ggplot() + 
  geom_histogram(aes(x = renda), 
                 binwidth = 4000)
```

Uma observação importante aqui: o _binwidth_ é especificado _fora_ do _aes()_. Por que? Porque existe uma regra importante no _ggplot2_: parâmetros que dependem de nossos dados devem ficar dentro de _aes()_; parâmetros fixos que não dependem de nossos dados devem ficar fora do _aes()_. Então, em nosso código, temos dentro de _aes()_ uma variável, renda, e fora de _aes()_ um número que independe dos dados, 4000. 

O gráfico está muito cinza. Se quisemos mudar algumas cores, onde vamos especificar novos parâmetros de cores? Como as cores são fixas para todo o gráfico e não depende de nossos dados, inserimos o parâmetro fora de _aes()_.

```{r}
fake %>% 
  ggplot() + 
  geom_histogram(aes(x = renda), 
                 binwidth = 4000, 
                 color = "red", 
                 fill = "green")
```

Melhor, não? Certamente não! Mas note que podemos trocar as contornos das barras e seu preenchimento. Em geral, os argumentos "color" e "fill" servem a várias geometrias.

Curiosidade: R aceita as duas grafias em inglês para a palavra cor, "colour" (britânico) e "color" (americano).

# Gráficos com uma variável contínua - Gráficos de densidade

Histogramas são normalmente bastante adequados para variáveis numéricas com valores bastante espaçados, como é o caso de variáveis discretas numéricas (valores inteiros apenas, como acontece com anos inteiros ou número de televisores em um residência).

Uma alternativa mais elegante ao histograma, e convencionalmente utilizada para variáveis verdadeiramente contínuas, são os gráficos de densidade. Vamos, assim, apenas alterar a geometria para a mesma variável, renda, e observar novamente sua distribuição. A lição é que, embora a geometria deva corresponder ao tipo de dados, existem várias geometrias que podem funcionar para um tipo de dado específico (histogram ou densidade, por exemplo).

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda))
```

Lindo, mas ainda cinza demais. Vamos adicionar cor à borda:

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda), 
               color="blue")
```

Melhor (melhor?), mas ainda muito branco. Vamos adicionar cor ao interior da curva:

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda), 
               color="blue", 
               fill="blue")
```

Muito pior. E se deixássemos a curva mais "transparente"?

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda), 
               color="blue", 
               fill="blue",
               alpha=0.2)
```

Agora sim melhorou. Mas nos falta uma referência para facilitar a leitura do gráfico. Por exemplo, seria legal adicionar uma linha vertical que indicasse onde está a média da distribuição. Vamos calcular a média da renda:

```{r}
media_renda <- mean(fake$renda)
```

Mas estamos tratando de curvas de densidade, não estamos? Nessa geometria não há possibilidade de representar valores com uma linha vertical. Vamos, então, adicionar uma nova geometria, com uma "aesthetics" própria, com novos dados (no caso, um valor único), ao gráfico que já havíamos construído:

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda), 
               color="blue", 
               fill="blue",
               alpha=0.2) +
  geom_vline(aes(xintercept = media_renda))
```

Veja que, com _ggplot2_ podemos adicionar novas geometrias e dados sempre que precisarmos. Agora, temos duas camadas e duas geometrias. É por esta razão que a estrutura do código deste pacote difere tanto da estrutura para gráficos no pacote base. A flexibilidade para adicionar geometrias (usando ou não os dados inicialmente apontados) é uma das vantagens do _ggplot2_ 

Para tornarmos o gráfico mais interessante, vamos alterar a forma e a cor da linha adicionada no gráfico anterior:

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda), 
               color="blue", 
               fill="blue",
               alpha=0.2) +
  geom_vline(aes(xintercept = media_renda),
             linetype="dashed",
             color="red")
```

"linetype" é outro parâmetro comum a diversas geometrias (obviamente, as geometrias de linhas).

### Exercício

Crie um gráfico de densidade de idade e adicione uma linha vertical que indica as pessoas com mais de 21 anos de idade. Ajuste a formatação para usar as mesmas cores do design do site do NIC.

## Gráficos com uma variável contínua e uma variável discreta

Vamos dar alguns passos para traz e retornar aos histogramas. E se quisermos comparar as distribuições de renda por sexo, por exemplo? Precisamos filtrar os dados e fazer um gráfico para cada categoria de sexo?

Poderíamos. Mas mais interessante é comparar as distribuições em um mesmo gráfico. Para fazer isso, precisamos saber como visualizar duas variáveis do nosso data frame ao mesmo tempo. Como estamos separando uma distribuição de uma variável contínua (renda) em duas, a partir de uma segunda variável discreta (sexo), precisamos adicionar essa nova variável à "aesthetics". Veja como:

```{r}
fake %>% 
  ggplot() + 
  geom_histogram(aes(x = renda,
                     fill = sexo), 
                 binwidth = 4000)
```

Observe que adicionamos o parâmetro "fill" à "aesthetics" (dentro do _aes()_ porque ele depende de nossos dados). Isso significa que a variável sexo separará as distribuições de renda em cores de preenchimento diferentes. Conseguem ver as duas distribuições, uma atrás da outra? Note que agora temos uma legenda.

A sobreposição dos dois histogramas dificulta a visualização de todos os dados. Podemos ajustar como os dois conjuntos de dados são exibidos um em cima do outro com o argumento 'position'. Por exemplo, com _position="dodge"_ podemos organizar os dados lado a lado:

```{r}
fake %>% 
  ggplot() + 
  geom_histogram(aes(x = renda, 
                     fill = sexo), 
                 binwidth = 4000, 
                 position = "dodge")
```

Um pouco melhor?

Vamos tentar algo semelhante com as curvas de densidade. Em vez de "fill", vamos usar a variável sexo em "color" na "aesthetics" (dentro da 'aes', desta vez) e separar as distribuições por cores de borda:

```{r}
fake %>% ggplot() + 
  geom_density(aes(x = renda, 
                   color = sexo))
```

Agora sim está melhor. Vamos adicionar o mesmo com "fill":

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda,
                   fill = sexo))
```

Não ficou muito bom. Mas pode melhorar. Com o parâmetro "alpha", que já usamos no passado, podemos deixar as distribuições mais "transparentes" e observar as áreas nas quais se sobrepôe:

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda, 
                   fill = sexo), 
               alpha=0.5)
```

Finalmente, podemos usar "fill" e "color" juntos na "aesthetics"

```{r}
fake %>% 
  ggplot() + 
  geom_density(aes(x = renda, 
                   fill = sexo, 
                   color = sexo), 
               alpha = 0.5)
```

Que belezura de gráfico! A comparação de distribuições de uma variável contínua por uma variável discreta (aqui binária  - duas categorias) é uma das mais úteis em ciência, pois é exatamente a forma gráfica de testes de hipóteses clássico. Qual grupo tem, na média, mais renda em Fakeland? Com os gráficos fica fácil responder.

### Exercício

As pessoas mais ricas do Fakeland estão mais propensas a serem membros do partido "Conservative Party"? Crie um gráfico claro para mostrar a relação entre essas variáveis.

## Gráficos com uma variável contínua e uma variável discreta - Gráficos de boxplot

Vamos repetir o gráfico acima, mas, em vez de separarmos as distribuições por sexo, vamos separar por uma variável com mais categorias: 'educ', que representa nível educacional mais alto obtido pelo indivíduo em Fakeland.

```{r}
fake %>% ggplot() + 
  geom_density(aes(x = renda, 
                   fill = educ, 
                   color = educ), 
               alpha = 0.5)
```

Dá par comparar as distribuições de idade por grupo? Certamente não. Podemos ter alguma ideia de que não há muita diferença, mas o gráfico é poluído demais.

Uma alternativa sintética para representar distribuições de variáveis numéricas é utilizar boxplot. Vamos ver um exemplo que serve de alternativa ao gráfico anterior.

Nota: na nova "aesthetics" temos agora "x", eixo horizontal, e "y", eixo vertical.

```{r}
fake %>% 
  ggplot() + 
  geom_boxplot(aes(x = educ, 
                   y = renda))
```

Importante: se você não tem familiaridade com boxplots, peça uma rápida explicação.

Ainda que com perda de informação, conseguimos compara as distribuições de renda por nível educacional de forma bastante rápida. A média renda das pessoas com "college degree" é maior que os outros, e a variação na renda para aqueles com "High school degree" é grande. Para colocar um pouco de cor nos boxplots, podemos usar "fill" novamente:

```{r}
fake %>% 
  ggplot() + 
  geom_boxplot(aes(x = educ, 
                   y = renda, 
                   fill = educ))
```

Gráfico de barras, para variáveis categóricas, e histogramas, curvas de densidade e boxplot são os melhores gráficos para explorarmos a distribuição de variáveis quando queremos conhecer os dados que recém coletamos ou obtemos.

## Gráficos de duas variáveis contínuas

Até agora trabalhamos com distribuições de uma única variável ou com a distribuição conjunta de uma variável contínua por outra discreta (em outras palavras, separados a distribuição de uma variável em várias a partir de um variável categórica).

Vamos ver agora como relacionar graficamente duas variáveis contínuas. O padrão é usarmos a geometria de gráfico de dispersão, que presenta cada par de informações como uma coordenada no espaço bidimensional. Vamos ver um exemplo com idade (eixo horizontal) e renda (eixo vertical) usando a geometria _geom\_point_:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade,
                 y = renda))
```

Você consegue ler este gráfico? Cada ponto representa um indivíduo, ou seja, posiciona no espaço o par (idade, renda) daquele indivíduo.

Note que há uma certa tendência nos dados: quanto mais velha a pessoa, maior sua renda. Podemos representar essa relação com modelos lineares e não lineares. A geometria _geom\_smooth_ cumpre esse papel.

Para utilizá-la, precisamos definir qual é o método (parâmetro "method") para modelar os dados. O mais convencional é representar a relação entre as variáveis como reta: um 'linear model' que é representado por 'lm'. Veja o exemplo (ignore o parâmetro "se" por enquanto):

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda)) +
  geom_smooth(aes(x = idade, 
                  y = renda), 
              method = "lm", 
              se = FALSE)
```

Legal, não? Se retirarmos o parâmetro "se", ou voltarmos seu valor para o padrão "TRUE", obteremos também o intervalo de confiança (95\%) da reta que inserimos.

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda)) +
  geom_smooth(aes(x = idade, 
                  y = renda), 
              method = "lm")
```

Modelos de regressão, linear ou não, estão bastante fora do escopo deste curso. Tente apenas interpretar o resultado gráfico.

A alternativa não linear para representar a relação ao dados mais utilizada com essa geometria é o método "loess" (local weighted regression). Veja o resultado:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda)) +
  geom_smooth(aes(x = idade, 
                  y = renda), 
              method = "loess")
```

## Gráficos de três ou mais variáveis

Em geral, estamos limitados por papel e telas bidimensionais para exibir apenas geometrias de duas variáveis. Mas existe um truque que podemos usar para mostrar mais informações: incluir os outros parâmetros de uma geometria, tais como cores, tamanhos e formas, dentro de _aes_ segundo uma variável terceira variável em seu data.frame. 

Se, por exemplo, queremos representar uma terceira variável numérica, podemos colocá-la como o tamanho dos pontos (raio do círculo). Por exemplo, o número de filhos, variável que vai de 1 a 10 nos nossos dados, poderia ser adicionada da seguinte forma:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 size = filhos))
```

Se em vez de alterar o tamanho dos pontos por uma variável numérica quisermos alterar sua cor ou forma dos pontos com base em uma variável categória (sexo, por exemplo), fazemos, respectivamente:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo))
```

Ou:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 shape = sexo))
```

Nota: cada símbolo é representado por um número e você encontra facilmente no [Cheat Sheet do ggplot2](https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf). 

Alterando simultaneamente cor e forma:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo, 
                 shape = sexo))
```

Adicionando uma reta de regressão para cada categoria de sexo:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo, 
                 shape = sexo)) +
  geom_smooth(aes(x = idade, 
                  y = renda, 
                  color = sexo, 
                  shape = sexo), 
              method = "lm", 
              se = F)
```

Lindo, não?

Existe mais um outro jeito de mostrar mais de duas variáveis - podemos criar vários gráficos organizados em uma grade sem ter que repetir nosso código toda vez. Como fazer isso? Com _facet\_wrap_. Veja um exemplo:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda)) +
  facet_wrap(~sexo)
```

### Exercício

Vamos usar o banco de dados menor de Fakeland para investigar a relação entre renda, poupança e número de crianças. Começando com o código abaixo, crie um gráfico de dispersão entre renda (income) e poupança (savings), e ajuste o tamanho de cada ponto dependendo do número de crianças (kids). 

```{r}
fake_menor <- read_delim(file1 <- "https://raw.githubusercontent.com/leobarone/ifch_intro_r/master/data/fake_data.csv", delim = ";", col_names = T)
```

## Aspectos não relacionados à geometria

Finalmente, podemos alterar diversos aspectos não relacionados aos dados, geometria e "aesthetics". O procedimento para adicionar alterações em título, eixos, legenda, etc, é o mesmo que para adicionar novas geometrias/camadas.

Em primeiro lugar, vamos adicionar um título ao gráfico:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo)) +
  ggtitle("Renda por idade, separado por sexo")
```

A seguir, vamos modificar os nomes dos rótulos dos eixos:

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo)) +
  ggtitle("Renda por idade, separado por sexo") +
  xlab("Idade (em anos inteiros)") +
  ylab("FM$ (Fake Money)")
```

O _ggplot_ nos permite modificar basicamente todos os elementos de estilo do nosso gráfico, mas isso é muitos detalhes. Para alterar o estilo do nosso gráfico, é mais fácil usar um tema ( _theme_ ) pré-definido. Por exemplo, podemos usar _theme\_classic_ para tirar o preenchimento e a grade do fundo. 

```{r}
fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo)) +
  ggtitle("Renda por idade, separado por sexo") +
  xlab("Idade (em anos inteiros)") +
  ylab("FM$ (Fake Money)") +
  theme_classic()
```

Os temas também podem ser usados para replicar estilos de outras fontes profissionais, por exemplo usando o pacote _ggthemes_. Debaixo criamos um gráfico usando o estilo da revista "The Economist" em uma linha só de código.

```{r}
#install.packages("ggthemes")
library(ggthemes)

fake %>% 
  ggplot() + 
  geom_point(aes(x = idade, 
                 y = renda, 
                 color = sexo)) +
  ggtitle("Renda por idade, separado por sexo") +
  xlab("Idade (em anos inteiros)") +
  ylab("FM$ (Fake Money)") +
  theme_economist()
```

### Exercício

Melhore seu gráfico do exercício anterior especificando um título, títulos de eixos e um tema de sua preferência.
