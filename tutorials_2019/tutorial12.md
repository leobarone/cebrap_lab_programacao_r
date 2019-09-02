# Tópicos adicionais com ggplot2

Este breve tutorial fornece um guia para alguns recursos adicionais do ggplot2. Também exploramos como preparar nossos dados com _dplyr_ para facilitar o trabalho com _ggplot2_. 

## Mais geometrias

Existe uma variedade de geometrias que podemos usar como camadas para visualizar os nossos dados. Vamos continuar com o nosso analise de dados de Fakeland. 

```{r}
library(tidyverse)
url_fake_data <- "https://raw.githubusercontent.com/leobarone/cebrap_lab_programacao_r/master/data/fake_data_2.csv"
fake <- read_delim(url_fake_data, delim = ";", col_names = T)
```

Uma geometria muito útil é _geom\_text_, que coloca como formas geométricas os textos mesmos. Por exemplo, nós podemos especificar um gráfico de dispersão onde os pontos refletem o nome de candidato em que as pessoas votaram, usando o parâmetro 'label'.

```{r}
fake %>% 
  ggplot() +
  geom_text(aes(x=idade,
                y=renda,
                label=candidato))
```

Outra geometria útil é _geom\_tile_ que tem uma forte conexão com mapas "raster". Especificamos variáveis x e y, e também uma variável de 'fill' que se aplica a cada célula de interseção de x e y.

```{r}
fake %>% 
  ggplot() +
  geom_tile(aes(x=idade,
                y=educ, 
                fill=renda))
```

## Pipes e Gráficos de linha

Gráficos de linha exigem, em geral, um pouco mais de preparação de nossos dados. A variável x pode ser discreta ou contínua, mas precisa ser _ordenada_ para que as linhas façam sentido. Precisamos organizar o data frame fora do _ggplot2_ e colocá-lo antes do pipe. Por exemplo, podemos visualizar apenas os dados para as mulheres.

```{r}
fake %>% 
  filter(sexo == "Female") %>%
  ggplot() +
  geom_point(aes(x = idade,
                 y = renda))
```

Note uma coisa chata: existem dois símbolos conetando as nossas ações agora: um pipe ( _%>%_ ) e um "+". Usamos o pipe com data.frames, e o "+" com camadas de gráficos depois da linha _ggplot()_. 

Para criar um gráfico de linha vamos usar 'idade' como nossa variável ordenada e, portanto, precisamos resumir os dados por idade. Vamos analisar a renda média por idade

```{r}
fake %>% 
  group_by(idade) %>%
  summarize(renda_media = mean(renda, na.rm=T))
```

Temos um tabela como novos tamanho e formato para analisar. Podemos usar as novas variáveis em nosso gráfico.

```{r}
fake %>% 
  group_by(idade) %>%
  summarize(renda_media = mean(renda, na.rm=T)) %>%
  ggplot() +
  geom_line(aes(x = idade, 
                y = renda_media))
```

E se quisermos ter duas linhas, uma para cada sexo? Precisamos reorganizar nossos dados para criar médias separadas para cada sexo, e incluir um parâmetro 'group' em nossa chamada para _ggplot2_. Isso é essencial para que o _ggplot2_ saiba como desenhar as linhas. 

```{r}
fake %>% 
  group_by(idade, sexo) %>%
  summarize(renda_media = mean(renda, na.rm = T)) %>%
  ggplot() +
  geom_line(aes(x = idade, 
                y = renda_media, 
                group = sexo))
```

Claro que precisamos distinguir a cor das linhas também.

```{r}
fake %>% 
  group_by(idade, sexo) %>%
  summarize(renda_media = mean(renda, na.rm = T)) %>%
  ggplot() +
  geom_line(aes(x = idade, 
                y = renda_media, 
                group = sexo, 
                color = sexo))
```

### Exercício

Accesse o banco de dados _flights_ no pacote _nycflights13_. Transforme os dados e crie um gráfico de linha com meses no eixo horixontal, o atraso média de partida ( _dep\_delay_) no eixo vertical, e linhas separadas para cada aeroporto de origem.

## Controlando cores com 'scales'

O ggplot2 usa cores padrões para mapear variáveis para cores. Claro que podemos controlar as cores usando mais um elemento da gramática dos gráficos, 'scales'. Adicionamos mais uma linha de código no final para controlar quais cores o ggplot2 deve usar. Infelizmente, precisamos tomar muito cuidado com o tipo de scale, que precisa corresponder ao tipo de nossos dados e também se estamos colorindo um ponto/linha ('colour') ou preenchendo uma área ('fill'). Use o tabela debaixo como uma guia:

Tipo de dados | Color (ponto, linha) | Fill (área)
------------- | --------------------|---------
Continuo      | scale_color_gradient(low="cor1",high="cor2") | scale_fill_gradient(low="cor1",high="cor2")
Discreto      | scale_color_brewer(palette="pre-definido")     | scale_fill_brewer(palette="pre-definido")
  
Para as cores e paletas, podemos usar vários tipos de referências: nomes, rgb, hex etc. Mas é difícil escolher boas cores - é melhor usar um site, por exemplo http://colorbrewer2.org

Vamos modificar as cores de nosso gráfico de linha. A nosso variável distinguida pela cor é o sexo, que é discreta, e nós queremos colorir as linhas, não as áreas, então precisamos usar _scale\_color\_brewer_. Eu gosto de uma escala/palette que se chama 'Accent' então adicionamos uma nova linha no código para utilizá-la:

```{r}
fake %>% 
  group_by(idade, sexo) %>%
  summarize(renda_media = mean(renda, na.rm = T)) %>%
  ggplot() +
  geom_line(aes(x = idade, 
                y = renda_media, 
                group = sexo, 
                colour = sexo)) +
  scale_color_brewer(palette="Accent")
```

Para ilustrar o uso de uma escala contínua e de área, voltamos para o gráfico de _geom\_tile_. Agora, precisamos usar _scale\_fill\_gradient_ e especificar a cor de valores baixos e a cor de valores altos.

```{r}
ggplot(fake) +
  geom_tile(aes(x = idade,
                y = educ, 
                fill = renda)) +
  scale_fill_gradient(low = "yellow",
                      high = "red")
```

### Exercício

Com o banco de dados _flights_, filtrar os dados para vôos partindo do aeroporto LGA no dia 20 de maio ('day' e 'month'). Depois, crie um gráfico de dispersão/texto que compara a hora de partida com distância, que coloca os nomes de destinos no gráfico, e, usando um 'scale', para que o cor de cada texto reflita o atraso de partido desse vôo.

## Gráficos interativos e animações

Se você estiver trabalhando com um site online (e não um PDF), talvez queira tornar seu gráfico interativo para que os usuários possam explorar cada ponto de dados. Isso é fácil com o pacote _plotly_ e o comando _ggplotly_. Gravamos nosso gráfico na mesma sintaxe de _ggplot2_ como um objeto e, em seguida, usamos _ggplotly_.

```{r}
#install.packages("plotly")
library(plotly)

graf_1 <- fake %>% 
  group_by(idade,sexo) %>%
  summarize(renda_media = mean(renda, na.rm = T)) %>%
  ggplot() +
  geom_line(aes(x = idade, 
                y = renda_media, 
                group = sexo, 
                colour = sexo)) 

graf_1 %>%
  ggplotly()
```

Este pacote também ajuda a transformar gráficos em animações. Podemos usar o mesmo fluxo de trabalho acima, e só precisamos especificar o parâmetro 'frame' em _ggplot2_ para que a variável que queremos a mudar com cada slide da animação. Para ilustrar, vamos analisar um gráfico de dispersão simples, que muda a cada slide para filtrar os dados por número de filhos. Toque 'play' no gráfico produzido pelo código debaixo para ver a animação.

```{r}
graf_2 <- fake %>%
  ggplot() +
  geom_point(aes(x = idade, 
                 y = renda, 
                 frame = filhos))

graf_2 %>%
  ggplotly()
```

## Gráficos para Regressões

Os resultados de uma simples regressão podem ser complicados e confusos. Exibir gráficos de resultados pode ajudar a comunicar nossas análises ao nosso público. Por exemplo, imagine que queremos mostrar os resultados da regressão de renda sobre idade e número de filhos.

```{r}
fake %>% 
  lm(renda ~ idade + filhos, data =.) 
```

Para visualizar, nossa primeira tarefa é extrair os coeficientes e erros padrão de nossa regressão linear, o que é facilitado pela função _tidy () _ no pacote _broom_. Isso produz um data.frame com o qual somos especialistas em trabalhar.

```{r}
library(broom)

fake %>% 
  lm(renda ~ idade + filhos, data =.) %>% 
  tidy()
```

Depois, podemos tirar o intercepto que normalmente não nos interessa muito usando _filter_, e calcular os intervalos de confiança de 95\% usando _mutate_.

```{r}
fake %>% 
  lm(renda ~ idade + filhos, data =.) %>% 
  tidy() %>% 
  filter(term != "(Intercept)") %>% 
  mutate(Conf.lo = estimate - 1.96 * std.error,
         Conf.hi = estimate + 1.96 * std.error)
```

Finalmente, vamos construir um gráfico de efeitos marginais, que mostra as nossas estimativas dos coeficientes com um ponto (uma camada) para a estimativa média e uma linha (outra camada) para o intervalo de confiança de 95\%. Observe que combinamos toda a preparação de dados e gráficos em uma única linha de código. 

```{r}
fake %>% 
  lm(renda ~ idade + filhos, data =.) %>% 
  tidy() %>% 
  filter(term != "(Intercept)") %>% 
  mutate(Conf.lo = estimate - 1.96 * std.error,
         Conf.hi = estimate + 1.96 * std.error) %>% 
  ggplot() + 
  geom_point(aes(x = term,
                 y = estimate)) +
  geom_segment(aes(x = term,
                   xend = term,
                   y = Conf.lo,
                   yend = Conf.hi))
```

Finalmente, adicionamos uma linha horizontal para indicar onde o zero está no gráfico, nós rotulamos os eixos, adicione um título e mude o tema.

```{r}
fake %>% 
  lm(renda ~ idade + filhos, data =.) %>% 
  tidy() %>% 
  filter(term != "(Intercept)") %>% 
  mutate(Conf.lo = estimate - 1.96 * std.error,
         Conf.hi = estimate + 1.96 * std.error) %>% 
  ggplot() + 
  geom_point(aes(x = term,
                 y = estimate)) +
  geom_segment(aes(x = term,
                   xend = term,
                   y = Conf.lo,
                   yend = Conf.hi)) +
  geom_hline(yintercept = 0,
             linetype = "dotted") +
  theme_classic() +
  ggtitle("Efeitos Marginais Estimados da Idade e do Número de Filhos sobre Renda") + 
  ylab("Coefficiente") +
  xlab("Variável")
```

### Exercício

Criar um gráfico de efeitos marginais para o efeito de educação e candidato sobre renda.