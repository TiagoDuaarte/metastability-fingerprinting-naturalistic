Hello there!

This repository have the last updated versions of the codes that I use for run my analysis
of metastability and fingerprinting in naturalistic fMRI data.

Until now, it was only tested, written and setted to the Naturalistic Neuroimaging Database.
Future replication must be made and will be updated here.

If everything is right, we have 11 different codes that I separte into 4 steps:

ORGANIZING DATA PRE-CALCULATION
(The results were tested in other two atlases: Havard-Oxford and Glasser.
Gordon atlas was chosen as the main atlas for this analysis because of it well documented networks division ROIs.
For this reason, depending how or with what software you parcelated, will show some differences in the order of labels.
Attention must be paid in to using the right label file because networks are calculated based on this label.
I've uploaded the label file that I use based on CONN Toolbox and FSL outputs using Gordon atlas, but we suggest you to keep using the label files that you found with the atlas file.)

- Relabeling_Atlas_Files.R (Reupload the labels into the columns names if for some reason you lost them)
- Reorganizing_Atlas_Columns.R (Reorganized clustering similar names to faciliated the networks calcuation)
- Reorganzing_Atlas_Columns_Manually.R (Sometimes you only need to do it for one file, could be easier use this one)

CALCULATION OF MEASURES
(These code have as output: fingerprinting percentage, iself, iothers, spatial coherence and metastability.
Execpt spatial coherence, all other measures depend on you window size of interest.
The Naturalistic Neuroimaging Database have huge fMRI files (>90 minutes) so wider window size can be used.
Shorter files will be forced to work in smaller windows.
The Whole Brain and Network codes are basically the same, with the only difference is the initial and final rois.
For whole brain, it use all ROIs from the file. For networks, have to be manually setted for each network.
I intent to automatized this network part in the future so it will became way easier this part

UPDATES 04/17/25: Now it's improved, you only have to choose the movie/file number, how many windows do you want to run, and choose which networks do you want, the code should do all the rest.

- Connectome_Fingerprinting_Iself_Iothers_Whole_Brain.R
- Connectome_Fingerprinting_Iself_Iothers_Networks.R
- Spatial_Coherence_and_Metastability_Whole_Brain.R
- Spatial_Coherence_and_Metastability_Networks.R

ORGANIZING DATA AFTER CALCULATION
(Is just about putting the different measures into the same dataframe following the long format.
I've separated into Automatized for multiple files (Iothers, Iself and Metastability for mutiple window sizes) and Manually for single files (Iothers, Iself and Metastability for a single window size.
It also add the Subject, Window and Movies (optional) columns. More columns must be easy to add. Attention to number of windows, number of subjects, number of movies and other specificities of each dataset.)

UPDATES 04/17/25: Now it's improved, you only have to choose the movie/file number, which windows do you want to calculate and a reference file. The same for the networks.

- Organizing_Data_Format_Long_Whole_Brain.R
- Organizing_Data_Format_Long_Networks.R

BINDING DIFFERENT MOVIES
Now, if you wnat to bind different movies/files together to create a file with more than one movie, the codes below were made to glue them up together.

Bind_All_Movies_Organizing_Data.R
Bind_All_Movies_Organizing_Data_Networks.R

MIXED MODELS
(The codes are also almost the same, the only difference is one more column/predictor for different Movies.
If your dataset have more than one stimuli, the All_Movies code will be better and easier to use.
If your dataset have only one stimuli, use the Single_Movies code.
In both we are considering that you are using a long format file).

UPDATES 04/17/25: Now it's improved, you only have to choose the movie/file number and which predictor do you to plot (movie variable only avaiable in data with more than one movie). And now the code already provide a plot.

- Automated_GMM_Code_Naturalistic_with_plotting.R
- Automated_GMM_Code_Naturalistic_with_plotting_Networks.R

EXTRA PLOTTING

Also I uploaded a simple code to visualize the network data into a bar plot that maybe could help.

BarPlot_Networks.R
