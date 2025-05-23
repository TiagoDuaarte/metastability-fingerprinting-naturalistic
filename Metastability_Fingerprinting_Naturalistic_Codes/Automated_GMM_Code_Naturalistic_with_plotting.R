library(nlme)
library(lme4)
library(performance)
library(ggplot2)

# Define which predictor to plot: "iothers", "iself", "window", or "movie"
# Movie predictor only if the data contains this variable

predictor_to_plot = "iothers"

# Movie names
movie_names <- list(
  "1" = "500_Days_of_Summer",
  "2" = "Citizenfour",
  "3" = "Usual_Suspects",
  "4" = "Pulp_Fiction",
  "5" = "The_Shawshank_Redemption",
  "6" = "The_Prestige",
  "7" = "Back_to_the_Future",
  "8" = "Split",
  "9" = "Little_Miss_Sunshine",
  "10" = "12_Years_A_Slave",
  "11" = "All_Movies"
)

movie_number <- "11"
movie_name <- movie_names[[movie_number]]

setwd(paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/ORGANIZED_DATA"))
initial_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/ORGANIZED_DATA")

# Vectors to store model results
beta_iothers <- c()
std_error_iothers <- c()
p_value_iothers <- c()

beta_iself <- c()
std_error_iself <- c()
p_value_iself <- c()

beta_window <- c()
std_error_window <- c()
p_value_window <- c()

beta_movie <- c()
std_error_movie <- c()
p_value_movie <- c()

r_conditional <- c()
r_marginal <- c()
aic <- c()
icc_value = c()
anova_test = c()

# Read all CSV files
csv_files <- list.files(initial_path, pattern = "*.csv", full.names = TRUE)

i <- 1

for (file in csv_files) {
  
  movie_measures <- read.csv(file, sep = ",")
  
  iself <- movie_measures$ISELF
  meta <- movie_measures$METASTABILITY
  iothers <- movie_measures$IOTHERS
  window <- movie_measures$WINDOW
  subject <- movie_measures$SUBJECT
  if ("MOVIE" %in% colnames(movie_measures)) {
    movie <- movie_measures$MOVIE
  }
  
  if ("MOVIE_TITLE" %in% colnames(movie_measures)) {
    movie <- movie_measures$MOVIE
    
    # Run model with MOVIE as predictor if available
    model = glmer(meta ~ iothers + iself + window + movie + (1|subject), 
                  data = movie_measures, family = Gamma(link = identity))
    
    summary_model = summary(model)
    
    beta_iothers[i] <- summary_model$coefficients[2]
    std_error_iothers[i] <- summary_model$coefficients[7]
    p_value_iothers[i] <- summary_model$coefficients[17]
    
    beta_iself[i] <- summary_model$coefficients[3]
    std_error_iself[i] <- summary_model$coefficients[8]
    p_value_iself[i] <- summary_model$coefficients[18]
    
    beta_window[i] <- summary_model$coefficients[4]
    std_error_window[i] <- summary_model$coefficients[9]
    p_value_window[i] <- summary_model$coefficients[19]
    
    beta_movie[i] <- summary_model$coefficients[5]
    std_error_movie[i] <- summary_model$coefficients[10]
    p_value_movie[i] <- summary_model$coefficients[20]
    
  } else {
    # Run model without MOVIE as predictor
    model <- glmer(meta ~ iothers + iself + window + (1|subject), 
                   data=movie_measures, family = Gamma(link = identity))
    
    summary_model = summary(model)
    
    beta_iothers[i] <- summary_model$coefficients[2]
    std_error_iothers[i] <- summary_model$coefficients[6]
    p_value_iothers[i] <- summary_model$coefficients[14]
    
    beta_iself[i] <- summary_model$coefficients[3]
    std_error_iself[i] <- summary_model$coefficients[7]
    p_value_iself[i] <- summary_model$coefficients[15]
    
    beta_window[i] <- summary_model$coefficients[4]
    std_error_window[i] <- summary_model$coefficients[8]
    p_value_window[i] <- summary_model$coefficients[16]
    
  }
  
  summary_model <- summary(model)
  
  #Model fit indices
  
  #Code can get stuck in that part if have few subjects.
  #If so, suggest to comment until from r2 until icc_value
  #aic runs ok
  
  r2 <- r2(model)
  r_conditional[i] <- r2$R2_conditional
  r_marginal[i] <- r2$R2_marginal
  
  icc_number = icc(model)
  icc_value[i] = icc_number$ICC_unadjusted
  
  aic[i] <- AIC(model)
  
  i = i + 1
}

# Create dataframe for plotting
if (predictor_to_plot == "iothers") {
  results <- data.frame(
    Beta = beta_iothers,
    Std_Error = std_error_iothers,
    P_Value = p_value_iothers
  )
  plot_name <- paste0(gsub("_", " ", movie_name), " - Iothers (beta)")
  
  cat("\n\n", "Beta - Iothers:", "\n", beta_iothers, "\n")
  cat("\n\n", "Std Error - Iothers:", "\n", std_error_iothers, "\n")
  cat("\n\n", "P_value - Iothers:", "\n", p_value_iothers, "\n")
  
} else if (predictor_to_plot == "iself") {
  results <- data.frame(
    Beta = beta_iself,
    Std_Error = std_error_iself,
    P_Value = p_value_iself
  )
  plot_name <- paste0(gsub("_", " ", movie_name), " - Iself (beta)")
  
} else if (predictor_to_plot == "window") {
  results <- data.frame(
    Beta = beta_window,
    Std_Error = std_error_window,
    P_Value = p_value_window
  )
  plot_name <- paste0(gsub("_", " ", movie_name), " - Window (beta)")
  
} else if(predictor_to_plot == "movie") {
  results <- data.frame(
    Beta = beta_movie,
    Std_Error = std_error_movie,
    P_Value = p_value_movie
  )
  plot_name <- paste0(gsub("_", " ", movie_name), " - Movies (beta)")
  
} else {
  stop("Choose a valid value for predictor_to_plot: 'iothers', 'iself', or 'window'")
}

# Extract file names (e.g., window size)
results$FileName <- gsub(".*_(\\d+)_.*", "\\1", basename(csv_files))
results$FileName <- factor(results$FileName, levels = results$FileName)

# Final plot
ggplot(results, aes(x = FileName, y = Beta, group = 1)) +
  geom_ribbon(aes(ymin = Beta - Std_Error, ymax = Beta + Std_Error), fill = "lightblue", alpha = 0.5) +
  geom_line(color = "black", size = 1) +
  geom_point(aes(color = P_Value > 0.05), size = 3) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "gray")) +
  labs(title = plot_name,
       x = "Window Size",
       y = "Beta Estimate") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1, color = "black"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.position = "none"
  )

# Print values and stop if any predictor is selected
if (predictor_to_plot == "iothers") {
  cat("\n\n", "Beta - Iothers:", "\n", beta_iothers, "\n")
  cat("\n\n", "Std Error - Iothers:", "\n", std_error_iothers, "\n")
  cat("\n\n", "P_value - Iothers:", "\n", p_value_iothers, "\n")
  stop("Code stopped after printing values of interest.")
}

if (predictor_to_plot == "iself") {
  cat("\n\n", "Beta - Iself:", "\n", beta_iself, "\n")
  cat("\n\n", "Std Error - Iself:", "\n", std_error_iself, "\n")
  cat("\n\n", "P_value - Iself:", "\n", p_value_iself, "\n")
  stop("Code stopped after printing values of interest.")  
}

if (predictor_to_plot == "window") {
  cat("\n\n", "Beta - Window:", "\n", beta_window, "\n")
  cat("\n\n", "Std Error - Window:", "\n", std_error_window, "\n")
  cat("\n\n", "P_value - Window:", "\n", p_value_window, "\n")
  stop("Code stopped after printing values of interest.")  
}

if (predictor_to_plot == "movies") {
  cat("\n\n", "Beta - Movies:", "\n", beta_movie, "\n")
  cat("\n\n", "Std Error - Movies:", "\n", std_error_movie, "\n")
  cat("\n\n", "P_value - Movies:", "\n", p_value_movie, "\n")
  stop("Code stopped after printing values of interest.")  
}

# Additional information

cat("\n\n", "R2 Conditional:", "\n", r_conditional, "\n")
cat("\n\n", "R2 Marginal:", "\n", r_marginal, "\n")
cat("\n\n", "AIC:", "\n", aic, "\n")
cat("\n\n", "ICC:", "\n", icc_value, "\n")
range(icc_value)
