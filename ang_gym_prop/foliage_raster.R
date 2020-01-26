# ---
# title: "foliage raster"
# author: "Max Blasdel"
# date: "March 2, 2019"
# output: html_document
# ---

# purpose 
# Create foliage raster with climate modifier
# This will mimic the cwd/fwd workflows

library(raster)
library(tidyverse)

# set temp directory which will be emptied periodically
dir.create("E:/tempdir")
rasterOptions(tmpdir = "E:/tempdir")

# Read in ang/gym rasters and decay values

rast <- dir(path = "ang_gym_proportions", pattern = ".tif", full.names = T)

dat <- read.csv("data/mean.species.k.csv") %>% 
  dplyr::select(classification, k_foliage) %>% 
  distinct()

# Read in climate raster
cli <- raster("climate_mod/climate_V2.tif")

# Variation on climate raster function
# rast <- c("Angiosperm.tif", "Gymnosperm.tif")
  # load raster
  r <- raster(rast[1])
  # extract species info
  ras <- gsub(".*/","",rast[1])
  # note the global <<- which will be used for naming conventions later on
  ras <- tools::file_path_sans_ext(ras)
  val <- dat[dat$classification == "Angiosperm", 'k_foliage']

  # reclass and multiply by climate raster
  r_class <- raster::reclassify(r, cbind(0,1,val))
  
  r_class_1 <- r_class * cli

  writeRaster(r_class_1, "E:/rasterSpecies/temp_rast_fol/ang.tif", overwrite=T)

# Repeat for gymnosperm

# load raster
  r <- raster(rast[2])
# extract species info
  ras <- gsub(".*/","",rast[2])
  # note the global <<- which will be used for naming conventions later on
  ras <- tools::file_path_sans_ext(ras)
  val <- dat[dat$classification == "Gymnosperm", 'k_foliage']

  # reclass and multiply by climate raster
  r_class <- raster::reclassify(r, cbind(0,1,val))
  
  r_class_1 <- r_class * cli
  
  writeRaster(r_class_1, "E:/rasterSpecies/temp_rast_fol/gym.tif", overwrite=T)


# Load rasters, multiply by proportions and sum together.
decayRasts <- dir("E:/rasterSpecies/temp_rast_fol", pattern = ".tif", full.names = T) 
proportions <- dir("ang_gym_proportions", pattern = ".tif", full.names = T)

rast_list <- list()
for (i in 1:2) {
  r <- raster(decayRasts[i])
  rt <- raster(proportions[i])
  spe <- r * rt
  rast_list[[i]] <- spe
}

rast_list <- stack(rast_list)

rast_fol <- calc(rast_list, sum, na.rm = T)

writeRaster(rast_fol, "E:/rasterSpecies/Fol/foliage.tif")

# Some weirdness has been occuring with the addition. Went into Q and did the intermediate step of decay rate times proportion. Going to change NA values to 0 then add together.


# # load the weighted rasters made in Qgis
# ang <- raster("qgis/ang.tif")
# gyn <- raster("qgis/gym.tif")
# 
# # sum with removing NA values
# fol <- sum(ang, gyn, na.rm = T)
# 
# 
# writeRaster(fol, "C:/Users/Max Blasdel/Desktop/ang_gym_proportions/foliage.tif")





