data("mtcars")
head(mtcars)
table(mtcars$gear)

# Indice
mtcars$id_num <- 1:32
head(mtcars)

# selecao de linha
mtcars_reduzido <- mtcars[mtcars$gear >= 4,]
mtcars[1:12,]

# selecao de coluna
mtcars[,c('mpg', 'cyl')]
mtcars[,c(1,2)]
mtcars[,substr(names(mtcars), 1, 1) == 'c']

# cyl por gear
mtcars$tipo <- "carro passeio"
mtcars$tipo[mtcars$gear >= 4] <- "trator" 

# como seria o mesmo codigo usando "if"
mtcars$tipo <- "carro passeio"
for (i in 1:32){
  if (mtcars$gear[i] >=4){
    mtcars$tipo[i] <- 'trator'
  }
}

# carro grande
mtcars$volume_motor <- NA
mtcars$volume_motor[mtcars$gear < 4] <- mtcars$cyl[mtcars$gear < 4] * 2
mtcars$volume_motor[mtcars$gear >= 4] <- mtcars$cyl[mtcars$gear < 4] * 3

### DPLYR
rm(mtcars)
data(mtcars)
library(dplyr)

mtcars$tipo <- "carro passeio"
mtcars <- mutate(mtcars, tipo = "carro passeio")
mtcars <- filter(mtcars, cyl > 6)
mtcars <- arrange(mtcars, mpg)

mtcars <- mtcars %>%
  renamte(motores = gear)
  mutate(tipo = "carro paseeio") %>%
  filter(cyl > 6) %>%
  arrange(mpg)

%>%
