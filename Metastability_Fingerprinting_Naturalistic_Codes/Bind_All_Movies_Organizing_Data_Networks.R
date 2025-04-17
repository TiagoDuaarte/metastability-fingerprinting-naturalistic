# List the folder paths for each movie
folders <- c(
  "~/Desktop/Filmes - Atlases/export/Gordon/500_Days_of_Summer/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Citizenfour/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Usual_Suspects/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Pulp_Fiction/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/The_Shawshank_Redemption/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/The_Prestige/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Back_to_the_Future/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Split/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/Little_Miss_Sunshine/NETWORKS/ORGANIZED_DATA",
  "~/Desktop/Filmes - Atlases/export/Gordon/12_Years_A_Slave/NETWORKS/ORGANIZED_DATA"
)

# List of networks to process
networks_to_run <- c("DMN", "MOTOR", "VISUAL", "FPN", "AUDITORY", "AMN", "VENTRAL_ATTN", "DORSAL_ATTN")

# Create the destination folder (with subfolders if necessary)
final_path <- "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/NETWORKS/ORGANIZED_DATA_NETWORKS/"
dir.create(final_path, recursive = TRUE, showWarnings = FALSE)

# Max number of files to process per folder
num_files <- 100  # Adjust if needed

# Loop through each network
for (network_name in networks_to_run) {
  
  # Loop through each file index
  for (i in 1:num_files) {
    
    data_list <- list()
    file_name_to_use <- NULL
    
    for (folder in folders) {
      
      # Only get .csv files that match the current network
      pattern_name <- paste0(network_name, ".*\\.csv$")
      files <- list.files(folder, pattern = pattern_name, full.names = TRUE)
      
      if (length(files) >= i) {
        file_to_read <- files[i]
        
        df <- read.csv(file_to_read, sep = ",")
        
        # Get the movie title from the folder structure
        df$MOVIE_TITLE <- gsub("_", " ", basename(dirname(dirname(folder))))
        
        data_list[[length(data_list) + 1]] <- df
        
        if (is.null(file_name_to_use)) {
          file_name_to_use <- basename(file_to_read)
        }
      }
    }
    
    # Skip this index if no files were found
    if (length(data_list) == 0) next
    
    # Get all unique column names across dataframes
    all_columns <- unique(unlist(lapply(data_list, names)))
    
    # Function to fill missing columns with NA
    pad_columns <- function(df, all_cols) {
      missing_cols <- setdiff(all_cols, names(df))
      for (col in missing_cols) {
        df[[col]] <- NA
      }
      df <- df[, all_cols]
      return(df)
    }
    
    # Standardize all dataframes
    data_list_standardized <- lapply(data_list, pad_columns, all_cols = all_columns)
    
    # Combine all dataframes into one
    final_data <- do.call(rbind, data_list_standardized)
    
    # Renumber SUBJECT globally while preserving the original order
    unique_combinations <- unique(paste(final_data$MOVIE_TITLE, final_data$SUBJECT, sep = "_"))
    new_ids <- seq_along(unique_combinations)
    names(new_ids) <- unique_combinations
    
    final_data$SUBJECT <- new_ids[paste(final_data$MOVIE_TITLE, final_data$SUBJECT, sep = "_")]
    
    # Move MOVIE_TITLE to the last column
    cols <- colnames(final_data)
    cols <- c(setdiff(cols, "MOVIE_TITLE"), "MOVIE_TITLE")
    final_data <- final_data[, cols]
    
    # Generate new file name by replacing the movie name with "ALL_MOVIES"
    new_file_name <- sub(basename(dirname(dirname(folder))), "ALL_MOVIES\\1", basename(files[1]))
    
    # Save the final CSV
    write.csv(final_data,
              file = paste0(final_path, new_file_name),
              row.names = FALSE)
    
    print(paste("File", new_file_name, "saved."))
  }
}
