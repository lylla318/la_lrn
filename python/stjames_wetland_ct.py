# generate stjames-nlcd.tif by cropping nlcd .img file to st james county boundary:
#   ogr2ogr -f "ESRI Shapefile" stjames.shp PG:"dbname=la_lrn" -sql "select * from county where statefp = '22' and countyfp = '093'"
#   gdalwarp -cutline stjames.shp -crop_to_cutline -dstalpha NLCD_2016_Land_Cover_L48_20190424/NLCD_2016_Land_Cover_L48.img stjames-nlcd.tif
import sys
import numpy as np
import rasterio

f = rasterio.open("../data/stjames-nlcd.tif")
b1 = f.read(1)
allpx = 0
woodywetlands = 0
emergentwetlands = 0

for row in range(f.height):
  for col in range(f.width):
    allpx += 1
    if b1[row, col] == 90:
      woodywetlands += 1
    elif b1[row,col] == 95:
      emergentwetlands += 1

print(allpx, woodywetlands, emergentwetlands, ((woodywetlands + emergentwetlands) / allpx))
# result: 1048567 392559 38798 0.41137762298451125