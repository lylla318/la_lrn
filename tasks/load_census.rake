desc "load census"
task :load_census do
  # `echo "drop table us_state; drop table county; drop table arealm; drop table place; drop table areawater; drop table roads;" | psql #{DB}`
  # Dir["#{DATA_ROOT}/TIGER/*.shp"].each do |f|
  #   layer = f.gsub(/^.*\//,"").gsub(/\.shp/,"")
  #   # p f, layer
  #   l_nofips = layer.gsub(/^.*_/,"")
  #   ltype = layer.match(/roads/) ? "MULTILINESTRING" : "MULTIPOLYGON"
  #   `ogr2ogr -f "PostgreSQL" PG:dbname=#{DB} -append -nln #{l_nofips} -nlt #{ltype} -geomfield the_geom #{f} -t_srs "EPSG:3857"`
  # end
  # `ogr2ogr -f "PostgreSQL" PG:dbname=#{DB} -append -nln us_state -nlt POLYGON -geomfield the_geom #{DATA_ROOT}/TIGER/tl_2018_us_state.shp -t_srs "EPSG:3857"`
  # MS Buildings
  `ogr2ogr -f "PostgreSQL" PG:dbname=#{DB} -append -nln ms_buildings -nlt POLYGON -geomfield the_geom #{DATA_ROOT}/MSBUILDINGS/Louisiana.geojson -t_srs "EPSG:3857"`
end