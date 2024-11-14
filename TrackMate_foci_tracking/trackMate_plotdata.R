#2024 tracking script
#This script is used to import tracking data from TrackMate and plot the data.
#version 2024.11.01
# Maarten Paul 
# TO DO
# Include the labelmask tiff to pick up foci from the segmented nuclei only

library(tidyverse)
import_trackmate <- function(file_path) {
  # Read everything as character first
  headers <- read_csv(file_path, 
                      skip = 1,
                      n_max = 1,
                      col_names = FALSE,
                      col_types = cols(.default = "c")) %>%
    unlist()
  
  data <- read_csv(file_path, 
                   skip = 4,
                   col_names = FALSE,
                   col_types = cols(.default = "c"))
  
  # Apply headers
  colnames(data) <- headers
  
  # Clean names
  data <- data %>%
    rename_all(~str_replace_all(., " ", "_")) %>%
    rename_all(~str_replace_all(., "[^[:alnum:]_]", ""))
  
  # Convert all columns except Label to numeric
  data <- data %>%
    mutate(across(!contains("Label"), as.numeric))
  
  return(data)
}
# Generic filtering function
filter_spots <- function(data, filter_conditions) {
  filtered_data <- data
  for(condition in names(filter_conditions)) {
    if(condition %in% colnames(data)) {
      filtered_data <- filtered_data %>%
        filter(!!sym(condition) >= filter_conditions[[condition]][1] & 
                 !!sym(condition) <= filter_conditions[[condition]][2])
    }
  }
  return(filtered_data)
}

# Function to extract metadata from folder name
parse_folder_name <- function(folder_name) {
  parts <- str_split(folder_name, "_")[[1]]
  metadata <- list(
    movie = parts[2],
    cell_line = parts[3],
    marker = parts[4],
    clone = parts[5],
    condition = if(length(parts) > 5) parts[6] else NA
  )
  return(metadata)
}


process_folders <- function(root_folder) {
  # Find all folders containing the required files
  folders <- list.dirs(root_folder, recursive = TRUE)
  folders <- folders[file.exists(file.path(folders, "foci_unfiltered_spots.csv")) & 
                       file.exists(file.path(folders, "nuclei_unfiltered_spots.csv"))]
  
  # Process foci data
  foci_data <- map_df(folders, function(folder) {
    folder_name <- basename(folder)
    metadata <- parse_folder_name(folder_name)
    
    import_trackmate(file.path(folder, "foci_unfiltered_spots.csv")) %>%
      mutate(
        movie = metadata$movie,
        cell_line = metadata$cell_line,
        marker = metadata$marker,
        clone = metadata$clone,
        condition = metadata$condition,
        T_h = T/3600
      )
  })
  
  # Process nuclei data
  nuclei_data <- map_df(folders, function(folder) {
    folder_name <- basename(folder)
    metadata <- parse_folder_name(folder_name)
    
    import_trackmate(file.path(folder, "nuclei_unfiltered_spots.csv")) %>%
      mutate(
        movie = metadata$movie,
        cell_line = metadata$cell_line,
        marker = metadata$marker,
        clone = metadata$clone,
        condition = metadata$condition,
        T_h = T/3600
      )
  })
  
  return(list(foci = foci_data, nuclei = nuclei_data))
}

# Process all files
root_folder <- "C:/Users/maart/OneDrive/Data2/241011_Timelapse_mSG-R51/MAX"
tracking_data <- process_folders(root_folder)

plot_tracking_metric <- function(data, metric_col, y_label, plot_title) {
  data %>%
    group_by(Frame, movie, cell_line, marker, clone, condition) %>%
    summarize(metric = mean(!!sym(metric_col)), .groups = 'keep') %>%
    group_by(Frame, cell_line, clone, condition) %>%
    summarize(metric = mean(metric), .groups = 'keep') %>%
    ggplot(aes(x = Frame, y = metric, color = cell_line)) +
    geom_line() +
    geom_point() +
    facet_wrap(clone~condition) +
    labs(x = "Time (frames)", 
         y = y_label,
         title = plot_title) +
    theme_minimal()
}

# Calculate and plot foci per nucleus
p1 <- tracking_data$foci %>%
  group_by(Frame, movie, cell_line, marker, clone, condition) %>%
  summarize(foci_count = n(), .groups = 'keep') %>%
  left_join(
    tracking_data$nuclei %>%
      group_by(Frame, movie, cell_line, marker, clone, condition) %>%
      summarize(nuclei_count = n(), .groups = 'keep')
  ) %>%
  mutate(foci_per_nucleus = foci_count/nuclei_count) %>%
  group_by(Frame, cell_line, clone, condition) %>%
  summarize(metric = mean(foci_per_nucleus), .groups = 'keep') %>%
  ggplot(aes(x = Frame, y = metric, color = cell_line)) +
  geom_line() +
  geom_point() +
  facet_wrap(clone~condition) +
  labs(x = "Time (frames)", 
       y = "Foci per nucleus",
       title = "Foci per nucleus over time") +
  theme_minimal()

# Plot mean area
p2 <- plot_tracking_metric(tracking_data$foci, 
                           "Area", 
                           "Average focus area (pixels²)",
                           "Focus size over time")

# Plot mean intensity
p3 <- plot_tracking_metric(tracking_data$foci, 
                           "Sum_intensity_ch1", 
                           "Average total intensity (a.u.)",
                           "Focus intensity over time")

# Display plots
p1
p2
p3

