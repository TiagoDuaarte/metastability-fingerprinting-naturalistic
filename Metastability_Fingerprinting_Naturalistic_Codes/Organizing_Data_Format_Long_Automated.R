# Set every measure into a different and specific folder

iself_path <- "~/Desktop/PD_fingerprinting/Data/Control/Gordon/ISELF/"
iothers_path <- "~/Desktop/PD_fingerprinting/Data/Control/Gordon/IOTHERS/"
metastability_path <- "~/Desktop/PD_fingerprinting/Data/Control/Gordon/METASTABILITY/"
final_path <- "~/Desktop/PD_fingerprinting/Data/Control/Gordon/ORGANIZED_DATA/"
reference_file = read.csv("Control/Gordon/ISELF/Iself_Control_WINDOW_SIZE_10_seconds_20_SUBJECTS.csv")

number_of_subjects = ncol(reference_file)

# Set the windows that mus be considered
windows <- c("10","20","30","40", "50", "60")

#Organize data for all windows
for (w in windows) {
  
  # Set name files based on window size
  iself_file <- paste0(iself_path, "Iself_Control_WINDOW_SIZE_", w, "_seconds_20_SUBJECTS.csv")
  iothers_file <- paste0(iothers_path, "Iothers_Control_WINDOW_SIZE_", w, "_seconds_20_SUBJECTS.csv")
  metastability_file <- paste0(metastability_path, "Metastability_Control_Gordon_", w, "_Window_Size.csv")
  
  # Read the csv. files
  iself <- read.csv(iself_file)
  iother <- read.csv(iothers_file)
  metastability <- read.csv(metastability_file)
  iself[is.na(iself)] = 0
  iother[is.na(iother)] = 0
  metastability[is.na(metastability)] = 0
  
  # Get the number of subjects and windows
  num_subjects <- ncol(iself)
  num_windows <- nrow(iself)
  
  # Create subject and windows columns
  # Also, if make sense to your data, a movie category column
  new_row <- num_subjects * num_windows
  subject_number <- rep(1:num_subjects, each = num_windows)
  windows_number <- rep(1:num_windows, times = num_subjects)
  
  #In this dataset, I had 10 movies with different sample sizes
  #movie <- c(rep(1, times = num_windows*X),
  #           rep(2, times = num_windows*X),
  #           rep(3, times = num_windows*X),
  #           rep(4, times = num_windows*X),
  #           rep(5, times = num_windows*X),
  #           rep(6, times = num_windows*X),
  #           rep(7, times = num_windows*X),
  #           rep(8, times = num_windows*X),
  #           rep(9, times = num_windows*X),
  #           rep(10, times = num_windows*X))

  # Transform into vectors
  iself <- as.vector(t(iself))
  iother <- as.vector(t(iother))
  metastability <- as.vector(t(metastability))
  
  # Create the long format dataframe
  long_format_data <- data.frame(
    SUBJECT = subject_number,
    ISELF = iself,
    IOTHERS = iother,
    METASTABILITY = metastability,
    WINDOW = windows_number,
    #MOVIE = movie
  )
  length(iself)
  length(iother)
  length(metastability)
  length(windows_number)
  #length(movie)
  # Define o nome do arquivo de saída
  sheet_csv <- paste0(final_path, "_DATASET_NAME_", w, "_SECONDS_WINDOW.csv")
  
  # Salva o arquivo CSV
  write.table(long_format_data, file = sheet_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)
}

