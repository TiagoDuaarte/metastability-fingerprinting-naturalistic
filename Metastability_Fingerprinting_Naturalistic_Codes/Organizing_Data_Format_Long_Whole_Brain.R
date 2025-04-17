

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
movie_number <- "3"  # Change this number to switch the movie
movie_name <- movie_names[[movie_number]]

# Set every measure into a different and specific folder

setwd(paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/PARCELATTION_DATA_REORGANIZED/"))

iself_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/ISELF/")
iothers_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/IOTHERS/")
metastability_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/METASTABILITY/")
final_path <- paste0("~/Desktop/Filmes - Atlases/export/Gordon/", movie_name, "/ORGANIZED_DATA/")
reference_file = read.csv("Subject082 - 12_Years_A_Slave - Atlas (333 ROIs) Gordon.csv")

number_of_subjects = ncol(reference_file)

# Set the windows that mus be considered
windows <- c("60","120","180","240", "300", "360", "420", "480", "540", "600")

#Organize data for all windows
for (w in windows) {
  
  # Set name files based on window size
  iself_file <- paste0(iself_path, "Iself_", movie_name, "_WINDOW_SIZE_", w, "_seconds.csv")
  iothers_file <- paste0(iothers_path, "Iothers_", movie_name, "_WINDOW_SIZE_", w, "_seconds.csv")
  metastability_file <- paste0(metastability_path, "Metastability_", movie_name,"_Gordon_", w, "_Window_Size.csv")
  
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
  sheet_csv <- paste0(final_path, movie_name, w, "_SECONDS_WINDOW.csv")
  
  # Save a csv file
  write.table(long_format_data, file = sheet_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)
}

