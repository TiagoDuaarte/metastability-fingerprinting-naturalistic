library(nlme)
library(lme4)
library(performance)
library(ggplot2)

# Define which predictor you want to plot: "iothers", "iself", "window", or "movies"
# "Movies" predictor only if the data includes this variable

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

movie_number <- "3"
movie_name <- movie_names[[movie_number]]

setwd(paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name,"/NETWORKS/ORGANIZED_DATA"))
initial_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/NETWORKS/ORGANIZED_DATA")

# Initialize result vectors
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

r_condicional <- c()
r_marginal <- c()
aic <- c()

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
    model <- glmer(meta ~ iothers + iself + window + movie + (1|subject), 
                   data=movie_measures, family = Gamma(link = identity))
    
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
  
  r2 <- r2(model)
  r_condicional[i] <- r2$R2_conditional
  r_marginal[i] <- r2$R2_marginal
  
  aic[i] <- summary_model$AICtab[1]
  
  i <- i + 1
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
  
} else if(predictor_to_plot == "movies") {
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
results$FileName <- sub("_.*", "", basename(csv_files))
results$FileName <- factor(results$FileName, levels = results$FileName[order(results$Beta)])

# Final plot
ggplot(results, aes(x = FileName, y = Beta)) +
  geom_col(position = position_dodge(width = 0.8), color = "black", width = 0.7) +
  geom_errorbar(
    aes(ymin = Beta - Std_Error, ymax = Beta + Std_Error),
    position = position_dodge(width = 0.8),
    width = 0.2, color = "black"
  ) +
  geom_point(
    aes(color = P_Value > 0.05, group = 1),
    position = position_dodge(width = 0.8),
    size = 2
  ) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "gray"), guide = "none") +
  scale_y_reverse() +  # Keep the Y-axis reversed
  scale_x_discrete(labels = c(
    "MOTOR" = "Motor",
    "AMN" = "AMN",
    "DMN" = "DMN",
    "FPN" = "FPN",
    "AUDITORY" = "Auditory",
    "VENTRAL" = "Ventral Attn",
    "VISUAL" = "Visual",
    "DORSAL" = "Dorsal Attn",
    "WHOLE-BRAIN" = "Whole-Brain"
  )) +
  labs(title = plot_name,
       x = "",
       y = "Beta Estimate",
       fill = "") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 10),
    axis.text.x = element_text(angle = 30, hjust = 1, color = "black"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.position = c(0.8, 1.0),       # position inside the plot
    legend.justification = c(1, 1),
    legend.direction = "horizontal", # anchor in the top-right corner of the legend box
    legend.background = element_rect(fill = "NA", color = "NA"),  # legend box
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8)
  )

# Print and stop based on the selected predictor
if (predictor_to_plot == "iothers") {
  cat("\n\n", "Beta - Iothers:", "\n", beta_iothers, "\n")
  cat("\n\n", "Std Error - Iothers:", "\n", std_error_iothers, "\n")
  cat("\n\n", "P_value - Iothers:", "\n", p_value_iothers, "\n")
  stop("Code interrupted after printing the values of interest.")
}

if (predictor_to_plot == "iself") {
  cat("\n\n", "Beta - Iself:", "\n", beta_iself, "\n")
  cat("\n\n", "Std Error - Iself:", "\n", std_error_iself, "\n")
  cat("\n\n", "P_value - Iself:", "\n", p_value_iself, "\n")
  stop("Code interrupted after printing the values of interest.")  
}

if (predictor_to_plot == "window") {
  cat("\n\n", "Beta - Window:", "\n", beta_window, "\n")
  cat("\n\n", "Std Error - Window:", "\n", std_error_window, "\n")
  cat("\n\n", "P_value - Window:", "\n", p_value_window, "\n")
  stop("Code interrupted after printing the values of interest.")  
}

if (predictor_to_plot == "movies") {
  cat("\n\n", "Beta - Movies:", "\n", beta_movie, "\n")
  cat("\n\n", "Std Error - Movies:", "\n", std_error_movie, "\n")
  cat("\n\n", "P_value - Movies:", "\n", p_value_movie, "\n")
  stop("Code interrupted after printing the values of interest.")  
}

# Additional information

#cat("\n\n", "Conditional R2:", "\n", r_condicional, "\n")
#cat("\n\n", "Marginal R2:", "\n", r_marginal, "\n")
cat("\n\n", "AIC:", "\n", aic, "\n")
