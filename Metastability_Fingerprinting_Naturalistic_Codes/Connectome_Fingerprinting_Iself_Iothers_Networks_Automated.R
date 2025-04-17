library(corrplot)

# Mapping movie numbers to names
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

# Defining networks by ROI index ranges
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

movie_number <- "10"  # Define the movie here
movie_name <- movie_names[[movie_number]]

# Define which networks you want to process:
networks_to_run <- c("DMN", "MOTOR", "VISUAL", "FPN", "AUDITORY", "AMN", "VENTRAL_ATTN", "DORSAL_ATTN")

# Base paths
base_path <- "~/Desktop/Filmes - Atlases/export/Gordon/"
initial_path <- paste0(base_path, movie_name, "/PARCELLATION_DATA_REORGANIZED/")
final_path <- paste0(base_path, movie_name, "/NETWORKS/")
setwd(initial_path)

# Create folders for each network (if not already created)
dir.create(file.path(final_path, "DMN"), showWarnings = FALSE)
dir.create(file.path(final_path, "MOTOR"), showWarnings = FALSE)
dir.create(file.path(final_path, "VISUAL"), showWarnings = FALSE)
dir.create(file.path(final_path, "FPN"), showWarnings = FALSE)
dir.create(file.path(final_path, "AUDITORY"), showWarnings = FALSE)
dir.create(file.path(final_path, "AMN"), showWarnings = FALSE)
dir.create(file.path(final_path, "VENTRAL_ATTN"), showWarnings = FALSE)
dir.create(file.path(final_path, "DORSAL_ATTN"), showWarnings = FALSE)

# Define window size(s) for analysis (in TRs)
window_sizes <- c(240)

list_of_files <- list.files(initial_path, pattern = ".csv")
number_of_subjects <- length(list_of_files)

# Loop to run analysis for each network
for (network_name in networks_to_run) {
  
  cat("Running network:", network_name, "\n")
  
  initial_roi <- networks[[network_name]][1]
  final_roi <- networks[[network_name]][2]
  
  subjects_rows <- numeric(number_of_subjects)
  subjects_columns <- numeric(number_of_subjects)
  
  network_path <- paste0(final_path, network_name, "/")
  
  for (i in 1:number_of_subjects) {
    subject <- read.csv(list_of_files[i], sep = "")
    subject <- subject[, initial_roi:final_roi]  # Extract only network-specific ROIs
    subjects_rows[i] <- nrow(subject)
    subjects_columns[i] <- ncol(subject)
  }
  
  rois <- min(subjects_columns)
  duration <- min(subjects_rows)
  
  # Create subfolders for storing results
  dir.create(file.path(network_path, "ISELF"), showWarnings = FALSE)
  dir.create(file.path(network_path, "IOTHERS"), showWarnings = FALSE)
  dir.create(file.path(network_path, "OURSELVES"), showWarnings = FALSE)
  dir.create(file.path(network_path, "FINGERPRINTING"), showWarnings = FALSE)
  
  for (window_size in window_sizes) {
    
    number_of_windows <- floor(duration / window_size)
    start <- 1
    middle <- floor(window_size / 2)
    end <- window_size
    fingerprint_final <- numeric(number_of_windows)
    
    first_half_list_of_FC_matrices = array(dim = c(rois, rois, number_of_subjects))
    second_half_list_of_FC_matrices = array(dim = c(rois, rois, number_of_subjects))
    vectorized_first_half_matrix = vector("list", number_of_subjects)
    vectorized_second_half_matrix = vector("list", number_of_subjects)
    id_matrix = matrix(nrow = number_of_subjects, ncol = number_of_subjects)
    Iself <- matrix(nrow = number_of_subjects, ncol = number_of_windows)
    Iothers <- matrix(nrow = number_of_subjects, ncol = number_of_windows)
    Ourselves <- matrix(nrow = number_of_subjects, ncol = number_of_windows)
    
    for (win in 1:number_of_windows) {
      for (i in 1:number_of_subjects) {
        subject = as.data.frame(read.csv(list_of_files[i], sep = ""))
        subject = subject[ ,initial_roi:final_roi]
        first_half_of_window = cor(scale(subject[start:middle, ]))
        second_half_of_window = cor(scale(subject[middle:end, ]))
        first_half_list_of_FC_matrices[,,i] = first_half_of_window
        second_half_list_of_FC_matrices[,,i] = second_half_of_window
      }
      
      # Vectorize FC matrices to compare similarity
      for (i in 1:number_of_subjects) {
        vectorized_first_half_matrix[[i]] = as.vector(first_half_list_of_FC_matrices[,,i])
        vectorized_second_half_matrix[[i]] = as.vector(second_half_list_of_FC_matrices[,,i])
      }
      
      # Compute the identification matrix
      for (i in 1:number_of_subjects) {
        for (j in 1:number_of_subjects) {
          id_matrix[i, j] = cor(vectorized_first_half_matrix[[i]], vectorized_second_half_matrix[[j]])
        }
      }
      
      # Calculate fingerprinting: % of subjects best matched to themselves
      fingerprinting = sum(diag(id_matrix) == apply(id_matrix, 1, max))
      percentage_of_fingerprinting = (fingerprinting / number_of_subjects) * 100
      fingerprint_final[win] = percentage_of_fingerprinting
      
      # Compute self-similarity (Iself), other-similarity (Iothers), and combined (Ourselves)
      for (i in 1:number_of_subjects) {
        Iself[i, win] = id_matrix[i, i]
        row_without_iself = sum(id_matrix[i,]) - id_matrix[i, i]
        column_without_iself = sum(id_matrix[, i]) - id_matrix[i, i]
        Iothers[i, win] = (row_without_iself + column_without_iself) / (2 * (number_of_subjects - 1))
        Ourselves[i, win] = (sum(id_matrix[i,]) + sum(id_matrix[, i]) - id_matrix[i, i]) / (2 * number_of_subjects - 1)
      }
      
      # Update window positions
      start = start + window_size
      middle = middle + window_size
      end = end + window_size
      fingerprinting = 0
      
      # Log current window result
      registro = paste("Window #", win, " - Window Size: ", window_size, " seconds - Fingerprinting Percentage:", round(percentage_of_fingerprinting, 3), "%")
      print(registro)
      
      # Optional: visual representation of identification matrix
      corrplot(id_matrix, method = "shade", is.corr = FALSE, diag = TRUE,
               col = colorRampPalette(c("cyan", "white", "firebrick"))(200))
    }
  }
  
  # Save results to .csv files
  write.table(Iself, file = paste0(final_path, "ISELF/Iself_", network_name, "_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
  write.table(Iothers, file = paste0(final_path, "IOTHERS/Iothers_", network_name, "_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
  write.table(Ourselves, file = paste0(final_path, "OURSELVES/Ourselves_", network_name, "_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
  write.table(fingerprint_final, file = paste0(final_path, "FINGERPRINTING/Fingerprinting_", network_name, "_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
  
}
