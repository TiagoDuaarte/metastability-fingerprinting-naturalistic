library(corrplot)

# List of movie names linked to numbers
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
  "10" = "12_Years_A_Slave"
)


# Define ROI ranges for each brain network
networks <- list(
  "DMN" = c(1, 41),
  "MOTOR" = c(42, 87),
  "VISUAL" = c(88, 126),
  "FPN" = c(127, 150),
  "AUDITORY" = c(151, 174),
  "AMN" = c(235, 274),
  "VENTRAL_ATTN" = c(275, 297),
  "DORSAL_ATTN" = c(302, 333),
  "WHOLE_BRAIN" = c(1, 333)
)

# Choose the movie number
movie_number <- "10"  # Change this number to switch the movie
movie_name <- movie_names[[movie_number]]

# Which networks to run
networks_to_run <- c("DMN", "MOTOR", "VISUAL", "FPN", "AUDITORY", "AMN", "VENTRAL_ATTN", "DORSAL_ATTN")


# Paths are built automatically based on the movie name
setwd(paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/PARCELLATION_DATA_REORGANIZED/"))

initial_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/PARCELLATION_DATA_REORGANIZED/")
final_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/NETWORKS/")

subjects_rows <- c()
subjects_columns <- c()
list_of_files <- list.files(initial_path, pattern = ".csv")
number_of_subjects <- length(list_of_files)

i <- 1

# Parameters
metastability_window_size <- c(60, 120, 180, 240, 300, 360, 420, 480, 540, 600)

subject_counter <- 1

# Loop through all selected networks
for (network_name in networks_to_run) {
  
  cat("Rodando rede:", network_name, "\n")
  
  initial_roi <- networks[[network_name]][1]
  final_roi <- networks[[network_name]][2]
  
  subjects_rows <- numeric(number_of_subjects)
  subjects_columns <- numeric(number_of_subjects)
  
  network_path <- paste0(final_path, network_name, "/")
  
  for (i in 1:number_of_subjects) {
    subject <- as.data.frame(read.csv(list_of_files[i], sep = ""))
    subject <- subject[, initial_roi:final_roi]
    subjects_rows[i] <- nrow(subject)
    subjects_columns[i] <- ncol(subject)
  }
  
  rois <- min(subjects_columns)
  duration <- min(subjects_rows)
  
  number_of_windows <- floor(duration / metastability_window_size)
  V_matrix <- matrix(nrow = duration, ncol = number_of_subjects)
  metastability <- matrix(nrow = number_of_windows, ncol = number_of_subjects)
  mean_fmri <- c()
  V <- c()
  diff_fmri <- matrix(nrow = duration, ncol = rois)

  # Spatial Coherence Calculation
for (k in 1:number_of_subjects) {
  subject <- as.data.frame(scale(read.csv(list_of_files[k], sep = "")))
  subject <- subject[, initial_roi:final_roi]
  
  for (m in 1:duration) {
    mean_fmri[m] <- mean(as.numeric(subject[m,]))
  }
  
  for (i in 1:duration) {
    for (j in 1:rois) {
      diff_fmri[i, j] <- abs(subject[i, j] - mean_fmri[i])
    }
    V[i] <- sum(diff_fmri[i, ])
  }
  
  V <- V / rois
  V_matrix[, k] <- V
  registro <- paste0("Coherence_Subject_", k, "_completed - Last Value for reference (must be lower and positive): ", round(V_matrix[k, k], 2))
  print(registro)
  subject_counter <- subject_counter + 1
}
  
coherence_csv <- paste0(network_path, "Coherence_", movie_name,"_", network_name,"_.csv")

write.table(V_matrix, file = coherence_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)

# Metastability Calculation
final_size <- length(metastability_window_size)

for (s in 1:final_size) {
  window_size <- metastability_window_size[s]
  number_of_windows <- floor(duration / window_size)
  metastability <- matrix(NA, nrow = number_of_windows, ncol = number_of_subjects)
  
  for (v in 1:number_of_subjects) {
    start <- 1
    end <- window_size
    for (t in 1:number_of_windows) {
      metastability[t, v] <- sd(V_matrix[start:end, v])
      start <- start + window_size
      end <- end + window_size
    }
  }
  
  final_name <- paste0("Metastability_", movie_name, "_", network_name, "_")
    metastability_csv <- paste0(network_path, final_name, window_size, "_Window_Size.csv")
  write.table(metastability, file = metastability_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)
}
}
