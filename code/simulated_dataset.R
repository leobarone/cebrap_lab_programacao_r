rm(list=ls())
set.seed(3697560)

sex_levels <- c("Male", "Female")
educ_levels <- c("No High School Degree", "High School Degree", "College Incomplete", "College Degree or more") 
yes_no <- c("Yes", "No")
kids_levels <- c('0', '1', '2', '3 or more')
party_levels <- c("Conservative Party", "Socialist Party", "Independent")
opinion_scale <- c("Very good", "Good", "About average", "Bad", "Very Bad", "Don't Know")
candidate_levels <- c("Trampi", "Rilari", "Other", "None")
vote_history_levels <- c('0', '1', '2', '3', '4')

n_amostra = 200
fake_data <- data.frame(
  age = as.integer(rnorm(n = n_amostra, mean = 35, sd = 5)),
  sex = sample(x = sex_levels, size = n_amostra, prob = c(0.4, 0.5), replace = T),
  educ = sample(x = educ_levels, size = n_amostra, prob = c(0.1, 0.4, 0.2, 0.3), replace = T),
  income = rpois(n = n_amostra, lambda = 1) * 2000 + rnorm(n = n_amostra, mean = 500, sd = 300),
  savings = rpois(n = n_amostra, lambda = 1) * 10000 + rnorm(n = n_amostra, mean = 5000, sd = 300),
  marriage = sample(x = yes_no, size = n_amostra, prob = c(0.5, 0.5), replace = T),
  kids = sample(x = kids_levels, size = n_amostra, prob = c(0.5, 0.25, 0.2, 0.05), replace = T),
  party = sample(x = party_levels, size = n_amostra, prob = c(0.2, 0.2, 0.6), replace = T),
  turnout = sample(x = yes_no, size = n_amostra, prob = c(0.5, 0.5), replace = T),
  vote_history = sample(x = vote_history_levels, size = n_amostra, prob = c(0.3, 0.1, 0.1, 0.2, 0.3), replace = T),
  economy = sample(x = opinion_scale, size = n_amostra, prob = c(0.05, 0.15, 0.3, 0.3, 0.15, 0.05), replace = T),
  incumbent = sample(x = opinion_scale, size = n_amostra, prob = c(0.2, 0.2, 0.2, 0.2, 0.15, 0.05), replace = T),
  candidate = sample(x = candidate_levels, size = n_amostra, prob = c(0.4, 0.4, 0.1, 0.1), replace = T)
)
  
write.table(fake_data, "fake_data.csv", sep = ";", row.names = F)

View(fake_data)

counts <- table(c(rep("Male", 45), rep("Female", 55)))/100
barplot(counts, xlab="Sex") 

table(fake_data$sex)/30
table(fake_data$educ)/30
table(fake_data$marriage)/30
table(fake_data$kids)/30
table(fake_data$party)/30

table(fake_data$sex, fake_data$party)/30

fake_data$income

hist(fake_data$income)
plot(density(fake_data$income), main = "")
