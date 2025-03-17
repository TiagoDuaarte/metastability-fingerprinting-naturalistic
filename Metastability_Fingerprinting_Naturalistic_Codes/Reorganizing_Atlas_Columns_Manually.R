# Load necessary library
library(readr)  # For reading CSV files

setwd("~/Desktop/PD_fingerprinting/Data/Control/Gordon/")

# Define input and output file paths
input_file <- "PARCELATION_LABELED/Subject002 - _Control_ - Atlas (333 ROIs) Gordon.csv"  
output_folder <- "PARCELATION_REORGANIZED"

# Ensure output directory exists
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Extract filename and define output file path
file_name <- basename(input_file)  # Get only the filename
output_file <- file.path(output_folder, file_name)  # Combine folder with filename

# Read the file
data <- read.table(input_file, header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)


# Get unique column names
unique_cols <- unique(colnames(data))

# Create a new list to store grouped columns
grouped_data <- list()

# Group columns by name
for (col_name in unique_cols) {
  cols_with_same_name <- data[, colnames(data) == col_name, drop = FALSE]  # Select matching columns
  grouped_data[[col_name]] <- do.call(cbind, cols_with_same_name)  # Combine into one data frame
}

# Convert list to a final data frame
final_data <- do.call(cbind, grouped_data)

# Save output file with the same name as the input
write.table(final_data, file = output_file, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)

cat("Reorganization completed! File saved at:", output_file, "\n")
