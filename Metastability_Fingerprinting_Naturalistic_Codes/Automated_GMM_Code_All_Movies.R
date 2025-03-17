library(nlme)
library(lme4)
library(performance)

# Set in which folder is all long format
# This code is set to a multiple movies files following variables below:
#subjects, iself, iothers, metastablity, windows, and movies
#different variables must me set manually
#This code works with just one file or multiple files in the same format
#The results presentation will follow the files order in the folder

setwd("~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/ORGANIZED_DATA/")
initial_path <- "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/ORGANIZED_DATA/"

####### Initiates variables

beta_iothers = c()
std_error_iothers = c()
p_value_iothers = c()

beta_iself = c()
std_error_iself = c()
p_value_iself = c()

beta_window = c()
std_error_window = c()
p_value_window = c()

beta_movie = c()
std_error_movie = c()
p_value_movie = c()

r_condicional = c()
r_marginal = c()
icc = c()
aic = c()

csv_files <- list.files(initial_path, pattern = "*.csv", full.names = TRUE)

number_of_files = length(csv_files)

i = 1

for (file in csv_files) {
  
  # Read the file
  movie_measures <- read.csv(file, sep = ",")
  
  # Define the variables based on it columns
  #This code assume that more than one movie in the data
  
  iself <- movie_measures$ISELF
  meta <- movie_measures$METASTABILITY
  iothers <- movie_measures$IOTHERS
  window <- movie_measures$WINDOW
  subject <- movie_measures$SUBJECT
  movie <- movie_measures$MOVIE
  
  # Runs the model based on the assumption that:
  # Subjects have a random effect (ICC > 5%)
  # Metastability follows a Gamma distribution
  # Here we use a log link function just to fit but it can make the interpretation trickier
  # Sometimes, running like a gaussian distribution, if significative, can help into interpretate the estimates
  
  #Model
  model = glmer(meta ~ iothers + iself + window + movie + (1|subject), data=movie_measures, family = Gamma(link=log))
  summary_model = summary(model)
  
  #Testing if Subjects variable must be considered as random effects
  random_effect = lmer(meta ~ 1 + (1|subject), data = movie_measures)
  
  #The numbers inside the [] expects that you are following the same order for predictors and the same predictors.
  #If changes in the order or in predictors were made, the numbers must be corrected.
  
  beta_iothers[i] = summary_model$coefficients[2]
  std_error_iothers[i] = summary_model$coefficients[7]
  p_value_iothers[i] = summary_model$coefficients[17]
  
  beta_iself[i] = summary_model$coefficients[3]
  std_error_iself[i] = summary_model$coefficients[8]
  p_value_iself[i] = summary_model$coefficients[18]
  
  beta_window[i] = summary_model$coefficients[4]
  std_error_window[i] = summary_model$coefficients[9]
  p_value_window[i] = summary_model$coefficients[19]
  
  beta_movie[i] = summary_model$coefficients[5]
  std_error_movie[i] = summary_model$coefficients[10]
  p_value_movie[i] = summary_model$coefficients[20]
  
  #Quality of the model information
  
  r2 = r2(model)
  r_condicional[i] = r2$R2_conditional
  r_marginal[i] = r2$R2_marginal
  
  icc_model = icc(random_effect)
  icc[i] = icc_model$ICC_adjusted
  
  aic[i] = summary_model$AICtab[1]
  
  i = i + 1
}

#Presentation of the results

cat("\n\n", "Beta - Iothers:", "\n", beta_iothers, "\n")
cat("\n\n", "Std Error - Iothers:", "\n", std_error_iothers, "\n")
cat("\n\n", "p-value - Iothers:", "\n", p_value_iothers, "\n")

cat("\n\n", "Beta - Iself:", "\n", beta_iself, "\n")
cat("\n\n", "Std Error - Iself:", "\n", std_error_iself, "\n")
cat("\n\n", "p-value - Iself:", "\n", p_value_iself, "\n")

cat("\n\n", "Beta - Window:", "\n", beta_window, "\n")
cat("\n\n", "Std Error - Window:", "\n", std_error_window, "\n")
cat("\n\n", "p-value - Window:", "\n", p_value_window, "\n")

cat("\n\n", "Beta - movie:", "\n", beta_movie, "\n")
cat("\n\n", "Std Error - movie:", "\n", std_error_movie, "\n")
cat("\n\n", "p-value - movie:", "\n", p_value_movie, "\n")

cat("\n\n", "R2 Condicional:", "\n", r_condicional, "\n")

cat("\n\n", "R2 Marginal:", "\n", r_marginal, "\n")

cat("\n\n", "Subjects ICCs:", "\n", icc, "\n")

cat("\n\n", "AIC:", "\n", aic, "\n")
