task :load_rsei do
  `cd data && ogr2ogr -f "PostgreSQL" PG:dbname=#{DB} -lco precision=NO -overwrite -nlt POLYGON -nln rsei_grid_bottom poly_gc14_conus_810m_bottom.shp -t_srs "EPSG:3857"`
end