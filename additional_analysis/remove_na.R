# To remove 0 values from decay rasters
# Outputed rasters have lots of 0 values where there is no data, this makes the distribution hard to look at.
library(raster)

cwd <- raster("../output/cwd_cm.tif")

# Change all 0 values to NA
cwd_na <- reclassify(cwd, cbind(-Inf, 0, NA))

# write out for later use
#writeRaster(cwd_na , "../output/rast_cwd.tif")

# Repeat for fwd and foliage
fwd <- raster("../output/fwd_cm.tif")
fwd_na <- reclassify(fwd, cbind(-Inf, 0, NA))

writeRaster(fwd_na, "../output/fwd_cm_NA.tif")

fol <- raster("../output/foliage_cm.tif")
fol_na <- reclassify(fol, cbind(-Inf, 0, NA))

writeRaster(fol_na, "../output/fol_cm_NA.tif")



