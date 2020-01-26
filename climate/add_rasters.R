
# title: "Combine Rasters"
# author: "Max Blasdel"
# date: "February 27, 2019"
# output: html_document

# Combine species rasters from the decay workflow

# Rasters have been previously prepared and just need to be stacked together

library(raster)

# Read in all raster files
coarseDecay <- dir("E:/rasterSpecies/temp_rast_cwd", pattern = ".tif$", full.names = T)

fineDecay <- dir("E:/rasterSpecies/temp_rast_fwd", pattern = ".tif$", full.names = T)

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
writeRaster(rast_cwd, "E:/rasterSpecies/CWD/rast_cwd.tif")


# repeat for fine

# create temp dir 
dir.create("E:/tempdir")
rasterOptions(tmpdir = "E:/tempdir")

rast_list <- list()
for (i in 1:length(fineDecay)) {
  
  r <- raster(fineDecay[i])
  rast_list[[i]] <- spe

}

rast_list <- stack(rast_list)
rast_fwd <- calc(rast_list, sum, na.rm = T)

writeRaster(rast_fwd, "E:/rasterSpecies/FWD/rast_fwd.tif")


