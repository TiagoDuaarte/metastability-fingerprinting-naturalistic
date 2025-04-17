# Generate a CSV file with the following structure:
# Beta #Std_Error #P_Value #FileName (network names) #Condition 
# Read this file below

results = read.csv("~/Desktop/Filmes - Atlases/export/Gordon/BarPlot_csv_networks_all_movies_240.csv")

# Add a title for the bar plot
plot_name = "Predicting Metastability with Iothers in Networks"

# Here you can reorder the bars based on one of the conditions
# Just check which position this condition starts and ends

results$FileName <- reorder(results$FileName[1:9], results$Beta[1:9], FUN = min)

# Arrange the desired order of the conditions
results$Condition <- factor(results$Condition, levels = c("All Movies", "Citizenfour", "500 Days of Summer"))

# Grouped bar plot with error bars and color by significance, now using ordered "Condition"
ggplot(results, aes(x = FileName, y = Beta, fill = Condition)) +
  geom_col(position = position_dodge(width = 0.8), color = "black", width = 0.7) +
  geom_errorbar(
    aes(ymin = Beta - Std_Error, ymax = Beta + Std_Error),
    position = position_dodge(width = 0.8),
    width = 0.2, color = "black"
  ) +
  geom_point(
    aes(color = P_Value > 0.05, group = Condition),
    position = position_dodge(width = 0.8),
    size = 2
  ) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "gray"), guide = "none") +
  scale_fill_manual(values = c(
    "Citizenfour" = "#00BFC4", 
    "500 Days of Summer" = "#F8766D", 
    "All Movies" = "grey"
  )) +
  scale_y_reverse() +  # Keeps the Y-axis reversed
  scale_x_discrete(labels = c(
    "MOTOR" = "Motor",
    "AMN" = "AMN",
    "DMN" = "DMN",
    "FPN" = "FPN",
    "AUDITORY" = "Auditory",
    "VENTRAL" = "Ventral Attn",
    "VISUAL" = "Visual",
    "DORSAL" = "Dorsal Attn",
    "WHOLE-BRAIN" = "Whole-Brain"
  )) +
  labs(title = plot_name,
       x = "",
       y = "Beta Estimate",
       fill = "") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 10),
    axis.text.x = element_text(angle = 30, hjust = 1, color = "black"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.position = c(0.8, 1.0),       # position inside the plot
    legend.justification = c(1, 1),
    legend.direction = "horizontal", # anchor in the top-right corner of the legend box
    legend.background = element_rect(fill = "NA", color = "NA"),  # legend box
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8)
  )
