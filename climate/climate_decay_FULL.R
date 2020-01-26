# title: "Create climate modified decay & final rasters"
# author: "Max Blasdel"
# date: "June 28, 2019"
# output: html_document

# Script to convert proportional rasters to decay values
# Represent a V3 and complete script which will create CWD, FWD, and Foliage in one script.
# This will take a couple days to run in full

library(raster)
library(magrittr)
library(dplyr)


################################ Create individual rasters

#Read in all species proportional values from deratified GNN data
raster_files <- "E:/rasterSpecies/indiv_rasts_UW/"
raster_loc <- as.list(dir(raster_files, pattern = ".tif$", full.names = T))

#Read in CWD, FWD, and species values 
dat <- read.csv("data/speciesCode_kValues.csv", row.names = 'X', stringsAsFactors = F)

# Load climate modifier
# Values are the scalar of how climate effects decomposition
cli <- raster("climate_mod/climate_V3.tif") # version 3 

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
location <- "E:/rasterSpecies/temp_rast_cwd_V3/"


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
location <- "E:/rasterSpecies/temp_rast_fwd_V3/" 

lapply(raster_loc, function(x) {
  
  dir.create(file.path("E:/tempdir"), showWarnings = T)
  rasterOptions(tmpdir = file.path("E:/tempdir"))
  
  r <- climatizeRaster(raster_loc = x, kval = dat, sizeClass = "FWD", climateRaster = cli)
  
  writeRaster(r, filename = paste0(location, name, ".tif"), overwrite=T)
  
  unlink("E:/tempdir", recursive = T)
  
})

#################################### Add Rasters

# Read in all raster files
coarseDecay <- dir("E:/rasterSpecies/temp_rast_cwd_V3", pattern = ".tif$", full.names = T)

fineDecay <- dir("E:/rasterSpecies/temp_rast_fwd_V3", pattern = ".tif$", full.names = T)

proportions <- dir("E:/rasterSpecies/indiv_rasts_UW", pattern = ".tif$", full.names = T)

# set temp directory which will be emptied periodically
dir.create("E:/tempdir")
rasterOptions(tmpdir = "E:/tempdir")

# get all rasters in a list
# needs to be altered to accomodate multiply by proportions

rast_list <- list()
for (i in 1:length(coarseDecay)) {
  
  r <- raster(coarseDecay[i])
  
  prop <- raster(proportions[i])
  
  proportional_r <- r * prop
  
  rast_list[[i]] <- proportional_r
}

# stack raster together
rast_list <- stack(rast_list)

# calculate the sum of all rasters
rast_cwd <- calc(rast_list, sum, na.rm = T)

# write out as final decay raster
writeRaster(rast_cwd, "E:/rasterSpecies/CWD/rast_cwd_V3.tif")

# unlink to remove temp files
unlink("E:/tempdir", recursive = T)

# repeat for fine

# create temp dir 
dir.create("E:/tempdir")
rasterOptions(tmpdir = "E:/tempdir")

rast_list <- list()
for (i in 1:length(fineDecay)) {
  
  r <- raster(fineDecay[i])
  
  prop <- raster(proportions[i])
  
  proportional_r <- r * prop
  
  rast_list[[i]] <- proportional_r
  
}

rast_list <- stack(rast_list)
rast_fwd <- calc(rast_list, sum, na.rm = T)

writeRaster(rast_fwd, "E:/rasterSpecies/FWD/rast_fwd_V3.tif")

# unlink to remove temp files
unlink("E:/tempdir", recursive = T)

################################## Fol

# set temp directory which will be emptied periodically
dir.create("E:/tempdir")
rasterOptions(tmpdir = "E:/tempdir")

# Read in ang/gym rasters and decay values

rast <- dir(path = "ang_gym_proportions", pattern = ".tif", full.names = T)

dat <- read.csv("data/mean.species.k.csv") %>% 
  dplyr::select(classification, k_foliage) %>% 
  distinct()


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

writeRaster(r_class_1, "E:/rasterSpecies/temp_rast_fol_V3/ang.tif", overwrite=T)

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

writeRaster(r_class_1, "E:/rasterSpecies/temp_rast_fol_V3/gym.tif", overwrite=T)


# Load rasters, multiply by proportions and sum together.
decayRasts <- dir("E:/rasterSpecies/temp_rast_fol_V3", pattern = ".tif", full.names = T) 
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

writeRaster(rast_fol, "E:/rasterSpecies/Fol/foliage_V3.tif")

# unlink to remove temp files
unlink("E:/tempdir", recursive = T)
