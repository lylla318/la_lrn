task :load_stjames_tax_parcels do
  `cd data && ogr2ogr -f "PostgreSQL" PG:dbname=#{DB} -lco precision=NO -overwrite -nlt POLYGON -nln stjames_tax_parcels st_james_tax_parcels/st_james_tax_parcels.shp -t_srs "EPSG:3857"`
end