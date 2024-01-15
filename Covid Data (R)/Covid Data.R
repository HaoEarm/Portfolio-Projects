# import data
rm(list=ls())
# install.packages("Hmisc")

library(Hmisc)
data <- read.csv("COVID19_line_list_data.csv")
#Source Kaggle
#https://www.kaggle.com/datasets/sudalairajkumar/novel-corona-virus-2019-dataset/versions/25


describe(data)
summary(data)

# Cleaning up Data in $Death
# 14 Distinct values in $death
# Deaths are recorded as (0,1),  but some rows have the date recorded instead

#Cleaned up death col.
data$death_new <- as.integer(data$death != 0)

# Calculating Deathrate
sum(data$death_new) / nrow(data)

# Testing a possible claim
# Claim: Older people are more likely to die from Covid
dead = subset(data, death_new == 1)
alive = subset(data,death_new == 0)
# Calculating mean age to support claim,NA exists in age col
mean(dead$age, na.rm = TRUE)
mean(alive$age, na.rm = TRUE)

# 68.58621 and 48.07229
# Is this statistically significant to support the claim?
# Using t.test , two-sided, and a confidence level of 0.95
t.test(alive$age, dead$age, alternative='two.sided', conf.level = 0.95)

# From Student's t-test
# p-value < 2.2e-16
# If p < 0.05, null hypothesis is rejected
# with this p-value close to 0, we can reject the null hypothesis
# and conclude that the claim is statistically significant

# Testing another possible claim
# Gender has no effect on deaths from covid
men = subset(data, gender == "male")
women = subset(data,gender == "female")

# Calculating mean age to support claim , NA exists in age col
mean(men$death_new, na.rm = TRUE)
mean(women$death_new, na.rm = TRUE)

# 0.08461538 and 0.03664921
# Is this statistically significant to support the claim?
# Using t.test , two-sided, and a confidence level of 0.95
t.test(men$death_new, women$death_new, alternative='two.sided', conf.level = 0.95)
# p-value of 0.002105,< 0.05 at 95% confidence level
# reject null hypothesis,  
# Men have higher death rates than compared to women for covid in this dataset
# is statistically significant 


