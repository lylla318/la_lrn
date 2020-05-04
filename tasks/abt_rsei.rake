task :abt_rsei_download do
  def shp_url(year)
    "http://abt-rsei.s3.amazonaws.com/microdata2017/shapefiles/CensusMicroBlockGroup2017_#{year}_aggregated.zip"
  end

  def csv_url(year)
    "http://abt-rsei.s3.amazonaws.com/microdata2017/census_full/CensusMicroBlockGroup2017_#{year}.zip"
  end

  (1988).upto(2017).each do |year|
    `cd "/Volumes/AL\'S\ DRIVE/la_lrn/abt" && curl -O #{shp_url(year)} && curl -O #{csv_url(year)}` 
  end
end

task :abt_rsei_load do
  (1988).upto(2017).each do |year|
    `cd "/Volumes/AL\'S\ DRIVE/la_lrn/abt" && \
      unzip CensusMicroBlockGroup2017_#{year}_aggregated.zip && \
      ogr2ogr -f "PostgreSQL" PG:dbname=#{DB} -lco precision=NO -overwrite -nlt POLYGON -nln CensusMicroBlockGroup2017_#{year}_aggregated CensusMicroBlockGroup2017_#{year}_aggregated.shp -t_srs "EPSG:3857"`
  end
end

task :abt_rsei_combine_blockgroups do
  sql = <<-SQL
    create table censusmicroblockgroup_allyears_aggregated_louisiana as select * from censusmicroblockgroup2017_1988_aggregated where geoid like '22%';
    alter table censusmicroblockgroup_allyears_aggregated_louisiana add column data_year integer;
    update censusmicroblockgroup_allyears_aggregated_louisiana set data_year = 1988;
  SQL
  puts "== created new table, populated 1988"
  `echo "#{sql}" | psql #{DB}`
  (1989).upto(2017).each do |year|
    sql = <<-SQL
      insert into censusmicroblockgroup_allyears_aggregated_louisiana select *, #{year} as data_year from CensusMicroBlockGroup2017_#{year}_aggregated where geoid like '22%'
    SQL
    `echo "#{sql}" | psql #{DB}`
    puts "== added #{year}"
  end
end