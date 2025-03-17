library(corrplot)

#Preparing path and subjects

#Initial_path (where all the parceled files should be)
#final_path (where the final files of fingerprinting, iself and iothers will be saved)
#movie_example (reference to time windows calculation)

setwd("~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/PARCELATION_TESTE/")
  
initial_path = "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/PARCELATION_TESTE/"

final_path = "~/Desktop/Filmes - Atlases/export/Gordon/All_Movies/"

movie_example = read.csv("Subject001 - 500_Days_of_Summer - Atlas (333 ROIs) Gordon.csv", sep="") #movie_settings

##############################################
#Initial settings

#Window_size is the only variable you will set based on interest intervals
# In this code, we divide the window size in half and calculate the measures comparing halves
#Number of windows is window_size dependent

window_size = 240 #seconds

##############################################
#Initializing variables

duration = nrow(movie_example) #number of timepoints/rows

rois = ncol(movie_example) #number of regions/colums

number_of_windows = floor(duration/window_size)

start = 1

middle = floor(window_size/2)

end = window_size

fingerprinting = 0

list_of_files = list.files(initial_path, pattern = ".csv") #list only the .csv files from the participants

number_of_subjects = length(list_of_files) #number of subjects

first_half_list_of_FC_matrices = array(dim= c(rois,rois,number_of_subjects)) #array of matrices of all subjects from the first half of the window

second_half_list_of_FC_matrices = array(dim= c(rois,rois,number_of_subjects)) #array of matrices of all subjects from the second half of the window

vectorized_first_half_matrix = list() #list of all the vectorized FC matrices of first half of the window

vectorized_second_half_matrix = list() #list of all the vectorized FC matrices of second half of the window

header = list() #list of column names for each window calculation

id_matrix = matrix(nrow = number_of_subjects, ncol = number_of_subjects) #fingerprinting matrix

Iself = matrix(nrow = number_of_subjects, ncol = number_of_windows) #collect all the iself values for all the windows

Iothers = matrix(nrow = number_of_subjects, ncol = number_of_windows) #collect all the iothers values for all the windows

fingerprint_final = 1:number_of_windows

##############################################

#Generate the FC from the first and the second half for all subjects
#Sometimes files are saved with , ou space as separator
#If something goes wrong and subject have only 1 column, probably that happened

for (number_of_windows in 1:number_of_windows) {
  
  for(i in 1:number_of_subjects){
    
    subject = as.data.frame(read.csv(list_of_files[i], sep = ""))
    
    first_half_of_window = cor(scale(subject[start:middle, ]))
    
    second_half_of_window = cor(scale(subject[middle:end, ]))
    
    first_half_list_of_FC_matrices[,,i] = first_half_of_window
    
    second_half_list_of_FC_matrices[,,i] = second_half_of_window
    
  }
  
#Put all the FC matrices of the first half on the array
  
  for (i in 1:number_of_subjects) {
    
    first_half_matrix = first_half_list_of_FC_matrices[,,i]
    
    vectorized_first_half_matrix[[i]] = as.vector(first_half_matrix)
    
  }
  
#Put all the FC matrices of the second half on the array
  
  for (i in 1:number_of_subjects) {
    
    second_half_matrix = second_half_list_of_FC_matrices[,,i]
    
    vectorized_second_half_matrix[[i]] = as.vector(second_half_matrix)
    
  }
  
#Correlates all positions from the first list with the second list and generates a matrix with all those correlations
#Also already calculates the % of fingerprinting
  
  for (i in 1:number_of_subjects) {
    
    first = vectorized_first_half_matrix[[i]]
    
    for (j in 1:number_of_subjects){
      
      second = vectorized_second_half_matrix[[j]]
      
      id = cor(first, second)
      
      id_matrix[i,j] = id
    }
  }
  
  for(i in 1:number_of_subjects){
    
    if (max(id_matrix[i,]) == id_matrix[i,i]) {
      
      fingerprinting =  fingerprinting + 1
      
    }
    
    percentage_of_fingerprinting = (fingerprinting/number_of_subjects)*100
    
  }
  
  fingerprint_final[number_of_windows] = percentage_of_fingerprinting
  
##########################################################################
#Calculate Iself and Iothers for all subjects
  
  for (i in 1:number_of_subjects) {
    
    Iself[i,number_of_windows] = id_matrix[i,i]
    
  }
  
  
  for (i in 1:number_of_subjects) {
    
    row_without_iself = (sum(id_matrix[i,]) - id_matrix[i,i])
    column_without_iself = (sum(id_matrix[,i]) - id_matrix[i,i])
    
    Iothers[i,number_of_windows] = (row_without_iself + column_without_iself)/(2*length(id_matrix[3,])-2)
    
  }
  
  start = start + window_size
  
  middle = middle + window_size
  
  end = end + window_size
  
  fingerprinting = 0
  
#Plot the fingerprinting matrix for visualization and quality check of code and dataset  
  
  registro = paste("Window #", number_of_windows, " - Window Size: ", window_size, "seconds - Fingeprinting Percentage:", round(percentage_of_fingerprinting,3),"%")
  print(registro)
  corrplot(id_matrix, method = "shade",is.corr=FALSE, diag = TRUE,
           col = colorRampPalette(c("cyan", "white", "firebrick"))(200))
  
}

#########################
#Naming output files and saving in csv files

Iself = t(Iself) 

Iothers = t(Iothers)

Iself_csv = paste0(final_path,"Iself_DATASET_NAME_WINDOW_SIZE_", window_size, "_seconds_", number_of_subjects,"_SUBJECTS.csv")

Iothers_csv = paste0(final_path,"Iothers_DATASET_NAME_WINDOW_SIZE_", window_size, "_seconds_", number_of_subjects,"_SUBJECTS.csv")

Fingerprinting_csv = paste0(final_path,"Fingerprinting_DATASET_NAME_WINDOW_SIZE_", window_size, "_seconds_", number_of_subjects,"_SUBJECTS.csv")

write.table(Iself, file = Iself_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)

write.table(Iothers, file = Iothers_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)

write.table(fingerprint_final, file = Fingerprinting_csv, row.names = FALSE, dec = ".", sep = ",", quote = FALSE)

