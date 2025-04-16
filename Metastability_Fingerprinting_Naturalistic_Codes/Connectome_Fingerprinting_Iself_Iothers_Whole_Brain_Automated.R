library(corrplot)

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

movie_number <- "1"  # Define the movie here
movie_name <- movie_names[[movie_number]]

# Path definition
setwd(paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/PARCELLATION_DATA_REORGANIZED/"))
initial_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/PARCELLATION_DATA_REORGANIZED/")
final_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/METASTABILITY/")

# Checks the value of ROIs and TR for each subject and sends the smallest one to the final code
#This step is important to avoid conflicts in the code in case there are files with different sizes

list_of_files = list.files(initial_path, pattern = ".csv")
number_of_subjects = length(list_of_files)

subjects_rows = numeric(number_of_subjects)
subjects_columns = numeric(number_of_subjects)

for (i in 1:number_of_subjects) {
  subject = as.data.frame(read.csv(list_of_files[i], sep = ""))
  subjects_rows[i] = nrow(subject)
  subjects_columns[i] = ncol(subject)
}

rois = min(subjects_columns)
duration = min(subjects_rows)

# List of window sizes to be tested
window_sizes = c(60, 120, 180, 240, 300, 360, 420, 480, 540, 600)

# Create directories if they do not exist
dir.create(file.path(final_path, "ISELF"), showWarnings = FALSE)
dir.create(file.path(final_path, "IOTHERS"), showWarnings = FALSE)
dir.create(file.path(final_path, "FINGERPRINTING"), showWarnings = FALSE)

#Starts the fingerprinting, iself and iothers calculation code, sliding window by window
for (window_size in window_sizes) {
  number_of_windows = floor(duration / window_size)
  
  start = 1
  middle = floor(window_size / 2)
  end = window_size
  fingerprinting = 0
  
  first_half_list_of_FC_matrices = array(dim = c(rois, rois, number_of_subjects))
  second_half_list_of_FC_matrices = array(dim = c(rois, rois, number_of_subjects))
  vectorized_first_half_matrix = vector("list", number_of_subjects)
  vectorized_second_half_matrix = vector("list", number_of_subjects)
  id_matrix = matrix(nrow = number_of_subjects, ncol = number_of_subjects)
  Iself = matrix(nrow = number_of_subjects, ncol = number_of_windows)
  Iothers = matrix(nrow = number_of_subjects, ncol = number_of_windows)
  fingerprint_final = numeric(number_of_windows)
  
  for (win in 1:number_of_windows) {
    for (i in 1:number_of_subjects) {
      subject = as.data.frame(read.csv(list_of_files[i], sep = ""))
      first_half_of_window = cor(scale(subject[start:middle, ]))
      second_half_of_window = cor(scale(subject[middle:end, ]))
      first_half_list_of_FC_matrices[,,i] = first_half_of_window
      second_half_list_of_FC_matrices[,,i] = second_half_of_window
    }
    
    for (i in 1:number_of_subjects) {
      vectorized_first_half_matrix[[i]] = as.vector(first_half_list_of_FC_matrices[,,i])
      vectorized_second_half_matrix[[i]] = as.vector(second_half_list_of_FC_matrices[,,i])
    }
    
    for (i in 1:number_of_subjects) {
      for (j in 1:number_of_subjects) {
        id_matrix[i, j] = cor(vectorized_first_half_matrix[[i]], vectorized_second_half_matrix[[j]])
      }
    }
    
    fingerprinting = sum(diag(id_matrix) == apply(id_matrix, 1, max))
    percentage_of_fingerprinting = (fingerprinting / number_of_subjects) * 100
    fingerprint_final[win] = percentage_of_fingerprinting
    
    for (i in 1:number_of_subjects) {
      Iself[i, win] = id_matrix[i, i]
      row_without_iself = sum(id_matrix[i,]) - id_matrix[i, i]
      column_without_iself = sum(id_matrix[, i]) - id_matrix[i, i]
      Iothers[i, win] = (row_without_iself + column_without_iself) / (2 * (number_of_subjects - 1))
    }
    
    start = start + window_size
    middle = middle + window_size
    end = end + window_size
    fingerprinting = 0
    
    #Plots the fingerprinting matrix.
    #Although not necessary, it is a great quality check if something is wrong with the code or data
    
    registro = paste("Window #", win, " - Window Size: ", window_size, " seconds - Fingerprinting Percentage:", round(percentage_of_fingerprinting, 3), "%")
    print(registro)
    corrplot(id_matrix, method = "shade", is.corr = FALSE, diag = TRUE,
             col = colorRampPalette(c("cyan", "white", "firebrick"))(200))
  }
  
  Iself = t(Iself)
  Iothers = t(Iothers)
  
  #Saves the files
  
  write.table(Iself, file = paste0(final_path, "ISELF/Iself_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
  write.table(Iothers, file = paste0(final_path, "IOTHERS/Iothers_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
  write.table(fingerprint_final, file = paste0(final_path, "FINGERPRINTING/Fingerprinting_", movie_name, "_WINDOW_SIZE_", window_size, "_seconds.csv"), row.names = FALSE, sep = ",", quote = FALSE)
}
