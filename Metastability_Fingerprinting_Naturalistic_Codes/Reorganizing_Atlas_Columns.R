# Load necessary library
library(readr)  # For reading CSV files

# Definir diretórios de entrada e saída
input_folder <- "~/Desktop/PD_fingerprinting/Data/PD/Gordon/PARCELATION_LABELED/"
output_folder <- "~/Desktop/PD_fingerprinting/Data/PD/Gordon/PARCELATION_REORGANIZED/"

# Criar diretório de saída se não existir
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Listar todos os arquivos CSV na pasta de entrada
csv_files <- list.files(input_folder, pattern = "\\.csv$", full.names = TRUE)

# Função para processar cada arquivo
process_csv <- function(input_file) {
  # Extrair nome do arquivo
  file_name <- basename(input_file)
  output_file <- file.path(output_folder, file_name)
  
  # Ler o arquivo sem modificar os nomes das colunas
  data <- read.table(input_file, header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
  
  # Obter nomes únicos das colunas
  unique_cols <- unique(colnames(data))
  
  # Criar uma lista para armazenar os grupos de colunas
  grouped_data <- list()
  
  # Agrupar colunas por nome
  for (col_name in unique_cols) {
    cols_with_same_name <- data[, colnames(data) == col_name, drop = FALSE]  # Seleciona colunas correspondentes
    grouped_data[[col_name]] <- do.call(cbind, cols_with_same_name)  # Combina em um único data frame
  }
  
  # Converter lista para um data frame final
  final_data <- do.call(cbind, grouped_data)
  
  # Salvar o arquivo reorganizado
  write.table(final_data, file = output_file, row.names = FALSE, dec = ".", sep = ",", quote = FALSE, col.names = TRUE)
  
  cat("Reorganization completed! File saved at:", output_file, "\n")
}

# Processar todos os arquivos CSV encontrados
lapply(csv_files, process_csv)

cat("All files have been processed and saved in:", output_folder, "\n
