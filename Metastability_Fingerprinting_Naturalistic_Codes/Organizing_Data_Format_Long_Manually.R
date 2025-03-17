      setwd("~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/")
      
      initial_path = "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/"
      
      final_path = "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/"
      
      iself = read.csv("MEASURES_TESTE/Iself_TESTE_WINDOW_SIZE_240_seconds_20_SUBJECTS.csv")
      
      iother = read.csv("MEASURES_TESTE/Iothers_TESTE_WINDOW_SIZE_240_seconds_20_SUBJECTS.csv")
      
      metastability = read.csv("MEASURES_TESTE/Metastability_All_Movies_Teste_Gordon_240_Window_Size.csv")
      
      windows = 240
      
      new_row = ncol(iself)*nrow(iself)
      
      windows_number = rep(1:nrow(iself), times = ncol(iself))
      
      subject_number = rep(1:ncol(iself), each = nrow(iself))
      
      iself = t(t(iself))
      
      iother = t(t(iother))
      
      metastability = t(t(metastability))
      
      metastability = as.vector(metastability)
      
      new_sheet = matrix(nrow = new_row, ncol = 5) #5 columns for only one movie, 6 columns for more than one movie
      
      new_sheet[,1] = subject_number
      
      new_sheet[,2] = iself
      
      new_sheet[,3] = iother
      
      new_sheet[,4] = metastability
      
      new_sheet[,5] = windows_number
      
      #new_sheet[,6] = 
      
      #windows_number
      
      new_sheet = as.data.frame(new_sheet)
      new_sheet[is.na(new_sheet)] = 1
      
      colnames(new_sheet) <- c("SUBJECT", "ISELF", "IOTHERS", "METASTABILITY", "WINDOW")
      
      sheet_csv = paste0(final_path,"PD_VENTRAL_ATTN_GORDON_", windows, "_SECONDS_WINDOW.csv")
      
      write.table(new_sheet, file = sheet_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)
      
