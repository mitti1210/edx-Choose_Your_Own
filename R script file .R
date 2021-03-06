# library
library(tidyverse)
library(caret)
library(randomForest)
library(ggridges)
library(rpart)
library(partykit)

#describes the adult dataset 
#create adult dataset
adult <- read_csv("https://github.com/mitti1210/edx-Choose_Your_Own/blob/master/adult.csv?raw=true")

adult %>% 
  select_if(is.character) %>% 
  map(., ~ levels(factor(.x)))

#String processing was performed because "?", "NA", and "-" were used. I changed income to 0,1.

adult <-  
  adult %>% 
  mutate_if(is_character, funs(str_replace_all(., pattern = "\\-", "_"))) %>% 
  mutate_if(is_character, funs(str_replace_all(., pattern = "\\&", "_"))) %>% 
  mutate_if(is_character, funs(str_replace_all(., pattern = "\\?", "NA"))) %>% 
  mutate_if(is_character, as.factor) %>% 
  mutate(income = as.factor(ifelse(income %in% ">50K", "1", "0")))

head(adult)

### Data exploration and visualization
#### Exploration
str(adult)

#### Visualization
##### Bar chart and density chart for each attribute
bar_workclass <-
  adult %>% 
  group_by(workclass, income) %>% 
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(workclass,per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_workclass

bar_education <- 
  adult %>% 
  group_by(education, income) %>% 
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(education,per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_education

bar_marital.status <- 
  adult %>% 
  group_by(marital.status, income) %>% 
  summarize(n = n()) %>%
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(marital.status, per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_marital.status

bar_occupation <- 
  adult %>% 
  group_by(occupation, income) %>% 
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(occupation, per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_occupation

bar_relationship <- 
  adult %>% 
  group_by(relationship, income) %>% 
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(relationship, per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_relationship

bar_race <- 
  adult %>% 
  group_by(race, income) %>% 
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(race, per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_race

bar_sex <- 
  adult %>% 
  group_by(sex, income) %>% 
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=reorder(sex, per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_sex

bar_native.country <- 
  adult %>% 
  group_by(native.country, income) %>%
  summarize(n = n()) %>% 
  spread(income,n) %>% 
  mutate(per = ifelse(is.na(`1`), 0, `1` / (`0` + `1`))) %>% 
  gather(key = income, value = n, 2:3) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>% 
  ggplot(aes(x=fct_reorder(native.country,per), y=n, fill=income))+
  geom_bar(stat = "identity", position = "fill")+
  coord_flip()
bar_native.country

adult %>% 
  ggplot(aes(x = age, y = income, fill = income)) +
  geom_density_ridges(alpha = 0.7)

adult %>% 
  ggplot(aes(x = fnlwgt, y = income, fill = income)) +
  geom_density_ridges(alpha = 0.7) +
  scale_x_sqrt()

adult %>% 
  ggplot(aes(x = education.num, y = income, fill = income)) +
  geom_density_ridges(bandwidth = 0.3, alpha = 0.7)

adult %>% 
  ggplot(aes(x = capital.gain, y = income, fill = income)) +
  geom_density_ridges(alpha = 0.7) +
  scale_x_sqrt()

adult %>% 
  ggplot(aes(x = capital.loss, y = income, fill = income)) +
  geom_density_ridges(alpha = 0.7)+
  scale_x_sqrt()

adult %>% 
  ggplot(aes(x = hours.per.week, y = income, fill = income)) +
  geom_density_ridges(bandwidth = 2, alpha = 0.7)

##### Create scatter plots of the relationship between education and education num.

adult%>% 
  group_by(education, education.num, income) %>% 
  summarize(n=n()) %>% 
  arrange(education.num) %>% 
  ggplot(aes(x = education.num, y = reorder(education, education.num), color = income))+
  geom_point(aes(size = n))


# Generate the train set and the test set
# Education was excluded from variables.
adult <- 
  adult %>% 
  select(-education)

# Test set will be 10% of adult data.
set.seed(1)
test_index <- createDataPartition(y = adult$income, times = 1, p = 0.1, list = FALSE)
train <- adult[-test_index,]
test <- adult[test_index,]

# Comparison of CART and Random Forests
# CART

set.seed(1)
fit_rpart <- rpart(income ~ ., data = train)
plot(as.party(fit_rpart))

yhat_rpart = factor(predict(fit_rpart, test, type = "class"), levels = levels(test$income))

confusionMatrix(yhat_rpart,test$income)  


# Random Forests

set.seed(1)
fit_rf <- randomForest(income ~ ., data = train)
fit_rf
varImpPlot(fit_rf)

yhat_rf = factor(predict(fit_rf, test), levels = levels(test$income))

confusionMatrix(yhat_rf, test$income)

# About Accuracy, Sensitivity, and Specificity

con_rpart <- confusionMatrix(yhat_rpart,test$income)
con_rf <- confusionMatrix(yhat_rf, test$income)

tibble(method = c("CART", "Random Forests"),
       accuracy = c(con_rpart[["overall"]][["Accuracy"]], con_rf[["overall"]][["Accuracy"]]),
       Sensitivity = c(con_rpart[["byClass"]][["Sensitivity"]],con_rf[["byClass"]][["Sensitivity"]]),
       Specificity = c(con_rpart[["byClass"]][["Specificity"]],con_rf[["byClass"]][["Specificity"]])) %>% 
  knitr::kable()
