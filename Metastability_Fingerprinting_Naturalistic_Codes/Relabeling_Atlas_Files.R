# Definir caminhos

setwd("~/Desktop/")

input_data <- "PD_fingerprinting/Data/PD/Gordon/PARCELATION_UNLABELED/"
output_data <- "PD_fingerprinting/Data/PD/Gordon/PARCELATION_LABELED/"
labels <- "Filmes - Atlases/export/Gordon/500_Days_of_Summer/labels.csv"

# Ler os novos nomes das colunas
new_labels <- read.csv(labels, header = FALSE)
new_labels <- as.vector(new_labels)  # Convertendo para vetor
new_labels = t(new_labels)
# Obter a lista de arquivos .csv na pasta


all_csv_files <- list.files(input_data, pattern = "\\.csv$", full.names = TRUE)

i = 1
counter_wrongs = 0

# Processar cada arquivo
while (i <= length(all_csv_files)) {
  # Ler a planilha
  csv_file <- read.csv(all_csv_files[i], sep = " ", stringsAsFactors = FALSE)
  
  if (ncol(csv_file) != length(new_labels)) {
    cat(paste("\n Label and CSV file have different number of columns in: \n", basename(all_csv_files[i])))
    i = i + 1
    counter_wrongs = counter_wrongs + 1
  }
    
  colnames(csv_file) <- new_labels
  
  # Criar nome do arquivo de saída
  output_name_file <- file.path(output_data, basename(all_csv_files[i]))
  
  # Salvar a planilha com os novos nomes de colunas
  write.csv(csv_file, output_name_file, row.names = FALSE)
  
  cat("\n \n Full processed file:", basename(all_csv_files[i]), "\n")
  
  i = i + 1
}

cat("Relabeling concluded!! \n ", ((i-1) - counter_wrongs), " Concluded \n", counter_wrongs, " Errors")
