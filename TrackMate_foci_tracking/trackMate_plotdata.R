#2024 tracking script

library(tidyverse)
import_trackmate <- function(file_path) {
  # Get the headers from second row as character strings
  headers <- read_csv(file_path, 
                      skip = 1,
                      n_max = 1,
                      col_names = FALSE,
                      col_types = cols(.default = "c")) %>%
    unlist()
  
  # Read data skipping header rows 
  tracks <- read_csv(file_path, 
                     skip = 4,
                     col_names = FALSE,
                     show_col_types = FALSE)
  
  # Apply headers and clean names
  colnames(tracks) <- headers
  tracks <- tracks %>%
    rename_all(~str_replace_all(., " ", "_")) %>%
    rename_all(~str_replace_all(., "[^[:alnum:]_]", ""))
  
  return(tracks)
}

spots <- import_trackmate("/media/DATA/Maarten/OneDrive/Data2/241011_Timelapse_mSG-R51/MAX/MAX_001_IB10_mSG+_B3/nuclei_unfiltered_spots.csv")

foci <- import_trackmate("/media/DATA/Maarten/OneDrive/Data2/241011_Timelapse_mSG-R51/MAX/MAX_004_IB10_mSG+_B3/foci_unfiltered_spots.csv")
foci %>% 
  mutate(T_h=T/3600)%>%
  group_by(T_h) %>%  # Using Frame instead of T since T is time point
  summarize(n = n()) %>%
  ggplot(aes(x = T_h, y = n)) +
  geom_line() +
  geom_point() +
  labs(x = "Time (s)", 
       y = "Number of foci",
       title = "Foci count over time") +
  theme_minimal()


spots %>% 
  group_by(Frame) %>%  # Using Frame instead of T since T is time point
  summarize(n = n()) %>%
  ggplot(aes(x = Frame, y = n)) +
  geom_line() +
  geom_point() +
  labs(x = "Time (frames)", 
       y = "Number of foci",
       title = "Foci count over time") +
  theme_minimal()

#What I need to add is a function to allow for filtering of nuclei spots and also foci spots; this can be a generic function that makes it easy t
# Later on, but not now should work on importing tracks; link to spots and do analysis on 
