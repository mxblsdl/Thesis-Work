
# title: "Create climate modified decay"
# author: "Max Blasdel"
# date: "February 13, 2019"
# output: html_document

# Script to convert proportional rasters to decay values

library(raster)
library(magrittr)
library(dplyr)

#Read in all species proportional values from deratified GNN data
raster_files <- "E:/rasterSpecies/indiv_rasts_UW/"
raster_loc <- as.list(dir(raster_files, pattern = ".tif$", full.names = T))

#Read in CWD, FWD, and species values 
dat <- read.csv("data/speciesCode_kValues.csv", row.names = 'X', stringsAsFactors = F)

# Load climate modifier
# Values are the scalar of how climate effects decomposition
cli <- raster("climate_mod/climate_V2.tif") 

climatizeRaster <- function(raster_loc, kval, sizeClass, climateRaster) {
 
  # load raster
  r <- raster(raster_loc)
  
  # extract species info
  ras <- gsub(".*/","",raster_loc)
  
  # note the global <<- which will be used for naming conventions later on
  ras <- tools::file_path_sans_ext(ras)
  name <<- ras
  
  val <- kval[kval$Species == ras, sizeClass]
  
  # reclass and multiply by climate raster
  r_class <- raster::reclassify(r, cbind(0,Inf,val))
  
  r_class <- r_class * climateRaster
  
  return(r_class) # result will need to be added together
}

# Loop through function saving outputs 
# outputs need to be saved as an intermediary step due to memory limitations
# otputs will be added together later on

#location <- "E:/rasterSpecies/temp_rast_cwd/"

# test location for one raster
location <- "E:/rasterSpecies/temp_rast_cwd/"


lapply(raster_loc, function(x) {
  
  # create temp folder for temp rasters
  dir.create(file.path("E:/tempdir"), showWarnings = T)
  rasterOptions(tmpdir = file.path("E:/tempdir"))
  
  # run reclass function for CWD
  r <- climatizeRaster(raster_loc = x, kval = dat, sizeClass = "CWD", climateRaster = cli)
  
  writeRaster(r, filename = paste0(location, name, ".tif"), overwrite=T)
  
  # unlink to remove temp files
  unlink("E:/tempdir", recursive = T)
})


# repeat steps for FWD
location <- "E:/rasterSpecies/temp_rast_fwd/" 

lapply(raster_loc, function(x) {
  
  dir.create(file.path("E:/tempdir"), showWarnings = T)
  rasterOptions(tmpdir = file.path("E:/tempdir"))
  
  r <- climatizeRaster(raster_loc = x, kval = dat, sizeClass = "FWD", climateRaster = cli)
  
  writeRaster(r, filename = paste0(location, name, ".tif"), overwrite=T)
  
  unlink("E:/tempdir", recursive = T)

})





