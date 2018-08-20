rm(list=ls())
set.seed(3697560)

sex_levels <- c("Male", "Female")
educ_levels <- c("No High School Degree", "High School Degree", "College Incomplete", "College Degree or more") 
party_levels <- c("Conservative Party", "Socialist Party", "Independent")
candidate_levels <- c("Trampi", "Rilari", "Other", "None")
kids_levels <- 0:10
kids_prob <- c(5, 10, 7, 3, 1, 0.5, 0.4, 0.3, 0.2, 0.1, 0.05)
kids_prob <- kids_prob/sum(kids_prob)

n_amostra = 200
sex = as.factor(sample(x = sex_levels, size = n_amostra, 
             prob = c(0.4, 0.5), replace = T))
educ = factor(sample(x = educ_levels, size = n_amostra, 
              prob = c(0.1, 0.4, 0.2, 0.3), replace = T), 
              ordered = T,
              levels = educ_levels)
party = as.factor(sample(x = party_levels, size = n_amostra, 
               prob = c(0.2, 0.2, 0.6), replace = T))
candidate = as.factor(sample(x = candidate_levels, size = n_amostra, 
                   prob = c(0.4, 0.4, 0.1, 0.1), replace = T))
kids = (sample(x = kids_levels, size = n_amostra, 
                             prob = kids_prob, replace = T))
age = as.integer(rnorm(n = n_amostra, mean = 35, sd = 5)) +
  as.numeric(sex) * 3 
income = rnorm(n = n_amostra, mean = 0, sd = 1) * 1000 + 
  age/5 * rnorm(n = n_amostra, mean = 500, sd = 300) +
  as.numeric(sex) * rnorm(n_amostra, mean = 1000, sd = 400) +
  as.numeric(sex) * age/5 * rnorm(n_amostra, mean = 1000, sd = 500) +
  kids * 300

fake <- data.frame(idade = age, 
                   sexo = sex, 
                   educ, 
                   partido = party, 
                   candidato = candidate, 
                   renda = income,
                   filhos = kids)

rm(age, sex, educ, party, candidate, income, kids)
write.table(fake, "fake_data_2.csv", sep = ";", row.names = F)
