# FG
# ogr2ogr -f "ESRI Shapefile" fg.shp PG:dbname=la_lrn -sql "select * from stjames_tax_parcels where taxpayer LIKE '%F.G.%' or taxpayer LIKE '%FG%'"

task :bake_vector_geojson do
  features = [
    
  ]
end