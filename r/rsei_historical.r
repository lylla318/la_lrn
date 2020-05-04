library(dplyr)
library(sf)
library(ggplot2)
library(tidyverse)
library(classInt)
library(viridis) 

# Set the year scale.
years <- 1988:2017

# Read the river parish geoid data.
river_parish_geoids <- read.csv("/Users/lyllayounes/Documents/Volumes/lrn_louisiana/river_parishes.csv")

# Read the river parish shapefile data.
river_parish_shapes <- st_read(
  paste0("/Users/lyllayounes/Documents/LRN\ Docs/Times\ Picayune/mapping/river_parish_shapes/river_parish_shapes.shp")
)

# FUNCTION  to read and filter shapefile data. # 
## INPUT - year ##
## OUTPUT - shapefile data, trimmed to river parishes ##
read_shapefiles <- function(year) {
  
  rsei_la <- st_read(
    paste0("/Users/lyllayounes/Documents/Volumes/lrn_louisiana/bg_data/shapefiles/CensusMicroBlockGroup2017_", year, "_aggregated/CensusMicroBlockGroup2017_", year, "_aggregated.shp")
  )
  
  # Cut to river parishes.
  rsei_la <- rsei_la %>% filter(substr(GEOID,1,2)=="22")
  rsei_rp <- subset(rsei_la, GEOID %in% river_parish_geoids$GEOID)
  rsei_la <- rsei_rp  %>%
    mutate(
      year=year
    )
  
  return(rsei_la)
  
}

# Get all shapefile data in one object.
shapefile_data <- years %>% map(read_shapefiles) 

# Put all the TOXCONC data in a single array.
allTOXCONC <- shapefile_data %>% map(function(x) pull(x,TOXCONC)) %>% unlist()

# Generate jenks classes for all TOXCONC data.
classes <- classIntervals(allTOXCONC, n = 9, style = "jenks")

# FUNCTION  to draw maps from shapefile data. # 
## INPUT - none. ##
## OUTPUT - downloaded plots. ##
draw_maps <- function() {
  
  year <- 1988
  for (rsei_la in shapefile_data) {
    
    rsei_la <- rsei_la %>%
      mutate(toxconc_class = cut(rsei_la$TOXCONC, classes$brks, include.lowest = T))
    
    # Plot the result
    ggplot() +
      geom_sf(data=rsei_la, aes(fill = toxconc_class), alpha = 1.0, colour = "white", size = 0.1) +
      geom_sf(data=river_parish_shapes,  fill=NA, alpha = 0.7, size = 0.4) +
      scale_fill_brewer(palette = "PuBu", name = "Toxicity Concentration Levels") +
      theme_void() +
      theme(panel.grid.major = element_line(colour = 'transparent')) +
      coord_sf() 
      
    ggsave(paste0("plot", year, ".jpg"), plot=last_plot(), path="/Users/lyllayounes/Documents/LRN\ Docs/Times\ Picayune/ggplots")
    year <- year + 1
  
    }
  
}

draw_maps()













###################### TEST CODE: Generate One Map ########################
options(scipen=999)

# Load the shapefile data
rsei_1989 <- st_read( 
  "/Users/lyllayounes/Documents/Volumes/lrn_louisiana/bg_data/shapefiles/CensusMicroBlockGroup2017_1989_aggregated/CensusMicroBlockGroup2017_1989_aggregated.shp")

river_parish_shapes <- st_read(
  "/Users/lyllayounes/Documents/LRN\ Docs/Times\ Picayune/mapping/river_parish_shapes/river_parish_shapes.shp"
)

# Cut to river parishes
river_parish_geoids <- read.csv("/Users/lyllayounes/Documents/Volumes/lrn_louisiana/river_parishes.csv")
rsei_1989_la <- rsei_1989 %>% filter(substr(GEOID,1,2)=="22")
rsei_1989_rp <- subset(rsei_1989_la, GEOID %in% river_parish_geoids$GEOID)
rsei_1989_la <- rsei_1989_rp

# Take a look
glimpse(rsei_1989_la)
st_geometry(rsei_1989_la)

# Generate classes for TOXCONC var
classes <- classIntervals(rsei_1989_la$TOXCONC, n = 9, style = "jenks")

rsei_1989_la <- rsei_1989_la %>%
  mutate(toxconc_class = cut(rsei_1989_la$TOXCONC, classes$brks, include.lowest = T))

# Plot the result
ggplot(rsei_1989_la) +
  geom_sf(aes(fill = toxconc_class), alpha = 0.8, colour = "white", size = 0.3) +
  scale_fill_brewer(palette = "PuBu", name = "Toxicity Concentration Levels") +
  theme_void() +
  theme(panel.grid.major = element_line(colour = 'transparent')) +
  coord_sf()

