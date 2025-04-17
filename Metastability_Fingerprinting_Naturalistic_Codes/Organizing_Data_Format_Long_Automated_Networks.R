
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

# Choose the movie number
movie_number <- "10"  # Change this number to switch the movie
movie_name <- movie_names[[movie_number]]

# Set the windows that mus be considered
windows <- c("60", "120", "180", "240", "300", "360", "420", "480", "540", "600")

networks_to_run <- c("DMN", "MOTOR", "VISUAL", "FPN", "AUDITORY", "AMN", "VENTRAL_ATTN", "DORSAL_ATTN")

for(network_name in networks_to_run){
  
  base_path = paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/NETWORKS/", network_name, "/")
  setwd(base_path)
  
  
  iself_path <- paste0(base_path)
  iothers_path <- paste0(base_path)
  metastability_path <- paste0(base_path)
  dir.create(file.path(dirname(base_path), "ORGANIZED_DATA"), showWarnings = FALSE)
  final_path <- paste0(dirname(base_path),"/ORGANIZED_DATA/")
  
  cat("Network running:", network_name, "\n")

#Organize data for all windows
for (w in windows) {
  
  # Set name files based on window size
  iself_file <- paste0(iself_path, "_Iself_", network_name, "_", movie_name, "_WINDOW_SIZE_", w, "_seconds.csv")
  iothers_file <- paste0(iothers_path, "_Iothers_", network_name, "_", movie_name, "_WINDOW_SIZE_", w, "_seconds.csv")
  metastability_file <- paste0(metastability_path, "Metastability_", movie_name, "_", network_name, "_", w, "_Window_Size.csv")
  
  # Read the csv. files
  iself <- read.csv(iself_file)
  iother <- read.csv(iothers_file)
  metastability <- read.csv(metastability_file)
  iself[is.na(iself)] = 0
  iother[is.na(iother)] = 0
  metastability[is.na(metastability)] = 0
  
  # Get the number of subjects and windows
  num_subjects <- nrow(iself)
  num_windows <- ncol(iself)
  
  # Create subject and windows columns
  # Also, if make sense to your data, a movie category column
  new_row <- num_subjects * num_windows
  subject_number <- rep(1:num_subjects, each = num_windows)
  windows_number <- rep(1:num_windows, times = num_subjects)
  
  #In this dataset, I had 10 movies with different sample sizes
  movie <- c(rep(movie_number, times = num_windows*num_subjects))
  
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
    MOVIE = movie
  )
  length(iself)
  length(iother)
  length(metastability)
  length(windows_number)
  length(movie)
  
  # Define output name
  sheet_csv <- paste0(final_path, network_name, "_", movie_name, "_", w, "_SECONDS_WINDOW.csv")
  
  # Save a csv file
  write.table(long_format_data, file = sheet_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)

}
  }

