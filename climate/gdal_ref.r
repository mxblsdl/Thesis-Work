
library(gdalUtils)
library(raster)
## For reprojecting and resampling a raster
# An example of using gdalwarp

# read in one of the UW rasters for reference information
UW_FCID <- raster("../../../CBI_Unshared_Work/CARBCAT Development/Data/UW Modeled Biomass Resource/Treatment Tiffs/Remove100Percent.tif")

# get desired crs projection
UW_crs <- as.character(crs(UW_FCID))

# get desired extent 
UW_ext <- bbox(extent(UW_FCID))

# get desired pixel cell size
tr <- c(30, 30)


# Reproject the FCCS raster using nearest neighbor (should preserve values).

gdalwarp(srcfile = "climate_adair.tif", # source raster
        dstfile = "climate.tif", # destination (what the new raster will be called and where to save it)
         tr = tr, # output resolution
         r = "near", # resampling method (this is nearest neighbor which preserves values
                    # 'bilinear' would produce a mean value)
         t_srs = UW_crs, # target spatial reference system
         te = c(UW_ext), # target extent
         overwrite=TRUE) # 


## note, I have definitely used this to upsample rasters to a higher resolution. I took 
## a 4km x 4km raster of CA up to 30m x 30m and it was a difference of 125kb to 4.5 gb