
task :load_block_group_shapefiles do
  sql = <<-SQL
    create table censusmicroblockgroup_allyears_aggregated_usa as select * from censusmicroblockgroup2017_1988_aggregated;
    alter table censusmicroblockgroup_allyears_aggregated_usa add column data_year integer;
    update censusmicroblockgroup_allyears_aggregated_usa set data_year = 1988;
  SQL
  puts "== created new table, populated 1988"
  `echo "#{sql}" | psql #{DB}`
  (1989).upto(2017).each do |year|
    sql = <<-SQL
      insert into censusmicroblockgroup_allyears_aggregated_usa select *, #{year} as data_year from CensusMicroBlockGroup2017_#{year}_aggregated
    SQL
    `echo "#{sql}" | psql #{DB}`
    puts "== added #{year}"
  end
end



# $shp_folder = "/Users/lyllayounes/Documents/Volumes/lrn_louisiana/bg_data/shapefiles"
# task :load_test do
# 	`shp2pgsql -I -s 4326 "/Users/lyllayounes/Documents/Volumes/lrn_louisiana/bg_data/shapefiles/CensusMicroBlockGroup2017_1988_aggregated/CensusMicroBlockGroup2017_1988_aggregated.shp" census_bg_test | psql -U lyllayounes -d rsei_historical_tracts`
# 	Dir.foreach($shp_folder) do |fname|
# 	  	filename = $shp_folder + "/" + fname + "/" + fname + ".shp"
# 	  	puts "Processing... " + fname
# 	  	`shp2pgsql -I -s 4326 #{filename} #{fname} | psql -U lyllayounes -d rsei_historical_tracts`
# 	end
# end


