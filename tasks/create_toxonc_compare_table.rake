
task :create_toxconc_compare_table do
	fips = ["01","02","04","05","06","08","09","10","11","12","13","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50","51","53","54","55","56"]
	(1988).upto(2017).each do |year|
		fips.each { |state_fips| 
			puts state_fips 
			sql = <<-SQL
	      	INSERT INTO top50_blockgroups_per_state_year SELECT * FROM censusmicroblockgroup2017_#{year}_aggregated as bgs WHERE bgs.state_fips LIKE '#{state_fips}' ORDER BY toxconc DESC LIMIT 50;
		    SQL
		    `echo "#{sql}" | psql #{DB}`
		}
		puts "== added #{year}"
	end
end