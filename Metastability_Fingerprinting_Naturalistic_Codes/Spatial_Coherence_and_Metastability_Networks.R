    library(corrplot)
    
    #Initial_path (where all the parceled files should be)
    #final_path (where the final files of coherence and metastability)
    #movie_example (reference to time windows calculation)
    
    setwd("~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/PARCELATION_TESTE/")
    
    initial_path = "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/PARCELATION_TESTE/"
    
    final_path = "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/"
    
    movie_example = read.csv("Subject001 - 500_Days_of_Summer - Atlas (333 ROIs) Gordon.csv", sep="") #movie_settings
    
    ##############################################
    
    #Window_size must be set based on interest intervals
    #After using the Reorganizing_Atlas_Columns.R code in github you can use the numbers below for reference
    #In future I will automatize this, I promise
    
    ####### SET FOR NETWORKS IN GORDON ATLAS
    ###### 
    
    #Default Mode (41 ROIs) 1:41
    #Mot (46 ROIs) 42:87
    #Vis (39 ROIs) 88:126
    #FrontoParietal (24 ROIs) 127:150
    #Audit (24 ROIs) 151:174
    #CinguloOperc (40 ROIs) 235:274
    #Ventrl Attentional (23 ROIs) 275:297
    #Dorsl Attentional (32 ROIs) 302:333
    
    ####### MANUAL INPUT
    
    metastability_window_size = c(240)
    
    initial_roi = 302
    
    final_roi = 333
    
    final_name = "Metastability_DATASET_NAME"
    
    coherence_csv = paste0(final_path,"Coherence_DATASET_NAME.csv")
    
    ##############################################
    #Initializing variables
    
    duration = nrow(movie_example)
    
    rois = (final_roi - initial_roi)+1
    
    number_of_windows = floor(duration/metastability_window_size)
    
    start = 1
    
    end = metastability_window_size
    
    list_of_files = list.files(initial_path, pattern = ".csv") #list only the .csv files from the participants
    
    number_of_subjects = length(list_of_files) #number of subjects
    
    diff_fmri = matrix(nrow = duration, ncol = rois)
    
    V_matrix = matrix(nrow = duration, ncol = number_of_subjects)
    
    metastability = matrix(nrow = number_of_windows, ncol = number_of_subjects)
    
    mean_fmri = c()
    
    V = c()
    
    subject_counter = 1
    
    ################# SPATIAL COHERENCE
    
    #Sometimes files are saved with , ou space as separator
    #If something goes wrong and subject have only 1 column, probably that happened
    
    for(k in 1:number_of_subjects){
      
      subject = as.data.frame(scale(read.csv(list_of_files[k], sep = "")))
      
      subject = subject[ , initial_roi:final_roi] #Calculate only in network intervals
      
      #Calculate the mean value of the first row (first TR)
      
      for (m in 1:duration) {
        
        mean_fmri[m] = mean(as.numeric(subject[m,]))
        
      }
      
      #Calculate the absolute value 
      for (i in 1:duration) {
        for(j in 1:rois){
          
          diff_fmri[i,j] = abs(subject[i,j] - mean_fmri[i])
          
        }
        
        V[i] = sum(diff_fmri[i,])
        
      }
      
      
      V = V/rois
      
      V_matrix[,k] = V
      
      
      registro = paste0("Coherence_Subject_", k, "_completed - Last Value for reference (must be lower and positive): ", round(V_matrix[k,k],2))
      
      print(registro)
      
      subject_counter = subject_counter + 1
      
    }
    
    write.table(V_matrix, file = coherence_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)
    
    ############## METASTABILITY  
    
    
    final_size = length(metastability_window_size)
    

    for (s in 1:final_size) {
      
      final_size = length(metastability_window_size)

      window_size = metastability_window_size[s]
      
      number_of_windows = floor(duration / window_size)
      
      metastability = matrix(NA, nrow = number_of_windows, ncol = number_of_subjects)
      
      for (v in 1:number_of_subjects) {
        
        start = 1
        end = window_size
        
        for (t in 1:number_of_windows) {
          
          metastability[t, v] = sd(V_matrix[start:end, v])
          
          start = start + window_size
          end = end + window_size
        }
      }
      
      metastability_csv = paste0(final_path, final_name, window_size, "_Window_Size.csv")
      
      write.table(metastability, file = metastability_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)
    }
    
