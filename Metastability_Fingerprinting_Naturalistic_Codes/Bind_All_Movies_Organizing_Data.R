# List of folder paths
folders <- c(
  "~/Desktop/Filmes - Atlases/export/Gordon/500_Days_of_Summer/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Citizenfour/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Usual_Suspects/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Pulp_Fiction/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/The_Shawshank_Redemption/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/The_Prestige/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Back_to_the_Future/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Split/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Little_Miss_Sunshine/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/12_Years_A_Slave/ORGANIZED_DATA"
)

# Maximum number of files to process per folder
num_files <- 100  # Adjust if needed

# Create the final folder if it doesn't exist
dir.create("~/Desktop/Filmes - Atlases/export/Gordon/All_Movies", showWarnings = FALSE)

# Loop through file positions (1st, 2nd, 3rd, etc.)
for (i in 1:num_files) {
  
  data_list <- list()
  file_name_to_use <- NULL
  
  for (folder in folders) {
    
    files <- list.files(folder, pattern = "*.csv", full.names = TRUE)
    
    if (length(files) >= i) {
      file_to_read <- files[i]
      
      df <- read.csv(file_to_read, sep = ",")
      
      # Extract movie title from folder name and replace underscores with spaces
      df$MOVIE_TITLE <- gsub("_", " ", basename(dirname(folder)))
      
      data_list[[length(data_list) + 1]] <- df
      
      if (is.null(file_name_to_use)) {
        file_name_to_use <- basename(file_to_read)
      }
    }
  }
  
  # Skip if no files were found in any folder for this index
  if (length(data_list) == 0) next
  
  # Find the complete set of column names across all dataframes
  all_columns <- unique(unlist(lapply(data_list, names)))
  
  # Function to pad missing columns with NA
  pad_columns <- function(df, all_cols) {
    missing_cols <- setdiff(all_cols, names(df))
    for (col in missing_cols) {
      df[[col]] <- NA
    }
    df <- df[, all_cols]
    return(df)
  }
  
  # Standardize column structure across dataframes
  data_list_padded <- lapply(data_list, pad_columns, all_cols = all_columns)
  
  # Combine all dataframes into one
  final_data <- do.call(rbind, data_list_padded)
  
  # Renumber SUBJECT IDs globally while preserving original order
  unique_combinations <- unique(paste(final_data$MOVIE_TITLE, final_data$SUBJECT, sep = "_"))
  new_ids <- seq_along(unique_combinations)
  names(new_ids) <- unique_combinations
  
  final_data$SUBJECT <- new_ids[paste(final_data$MOVIE_TITLE, final_data$SUBJECT, sep = "_")]
  
  # Move MOVIE_TITLE to the last column
  cols <- colnames(final_data)
  cols <- c(setdiff(cols, "MOVIE_TITLE"), "MOVIE_TITLE")
  final_data <- final_data[, cols]
  
  # Generate new file name
  new_file_name <- sub(".*(_GORDON_.*)", "ALL_MOVIES\\1", file_name_to_use)
  
  # Save the final combined file
  write.csv(final_data,
            file = paste0("~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/", new_file_name),
            row.names = FALSE)
  
  print(paste("File", new_file_name, "saved."))
}
