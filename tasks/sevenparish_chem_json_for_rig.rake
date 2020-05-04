task :sevenparish_chem_json_for_rig do
  require 'csv'
  require 'json'

  geo = JSON.parse(File.open("#{DATA_ROOT}/seven_parish.geojson").read) 
  chemicals   = CSV.read("#{DATA_ROOT}/sevenparish_top20_chem_benchmark.csv" , :headers => true)  
  chemnames   = chemicals.map {|q| q["chemical"] }
  chem_attrs  = chemicals.map {|q| [q["rfcinhale"].to_f, q["rfcconf"], q["unitriskinhale"].to_f] }

  c = CSV.read("#{DATA_ROOT}/sevenparish_conc_grid_top20.csv", :headers => true)
  
  out = {
    "chemicals" => chemnames,
    "chem_attrs" => chem_attrs,
    "grid" => []
  }

  c.each do |row|
    grid_square_idx = geo["features"].find_index do |q| 
      	q["properties"]["x"] == row["x"].to_i && q["properties"]["y"] == row["y"].to_i
    end
    chem_idx = chemnames.index(row["chemical"])

    p grid_square_idx
    out["grid"][grid_square_idx] ||= []
    out["grid"][grid_square_idx][chem_idx] = row["conc"].to_f

  end

  File.open("#{DATA_ROOT}/_sevenparish_test.json", "w") do |f|
    f.write out.to_json
  end

end


task :sevenparish_aggregated_grid_for_rig do
	require 'csv'
	require 'json'

  	geo = JSON.parse(File.open("#{DATA_ROOT}/seven_parish.geojson").read) 
  	c = CSV.read("#{DATA_ROOT}/sevenparish_aggregated_grid_data.csv", :headers => true)
  
  	out = {
	    "grid" => []
  	}

  	c.each do |row|
    	grid_square_idx = geo["features"].find_index do |q| 
    		q["properties"]["x"].to_i == row["x"].to_i && q["properties"]["y"].to_i == row["y"].to_i
    	end
    	p grid_square_idx

    	out["grid"][grid_square_idx] ||= []
    	out["grid"][grid_square_idx] = [row["toxconc"].to_f, row["cancer_sum"].to_f, row["noncancer_sum"].to_f]
  	end

  	File.open("#{DATA_ROOT}/_sevenparish_aggregated_grid_for_rig", "w") do |f|
    	f.write out.to_json
  	end

end

task :entergy_chems_grid_for_rig do
  require 'csv'
  require 'json'

  geo = JSON.parse(File.open("#{DATA_ROOT}/seven_parish.geojson").read) 
  chemicals   = CSV.read("#{DATA_ROOT}/sevenparish_top20_chem_benchmark.csv" , :headers => true)  
  chemnames   = chemicals.map {|q| q["chemical"] }
  chem_attrs  = chemicals.map {|q| [q["rfcinhale"].to_f, q["rfcconf"], q["unitriskinhale"].to_f] }

  c = CSV.read("#{DATA_ROOT}/sevenparish_conc_grid_top20.csv", :headers => true)
  
  out = {
    "chemicals" => chemnames,
    "chem_attrs" => chem_attrs,
    "grid" => []
  }

  c.each do |row|
    grid_square_idx = geo["features"].find_index do |q| 
        q["properties"]["x"] == row["x"].to_i && q["properties"]["y"] == row["y"].to_i
    end
    chem_idx = chemnames.index(row["chemical"])

    p grid_square_idx
    out["grid"][grid_square_idx] ||= []
    out["grid"][grid_square_idx][chem_idx] = row["conc"].to_f

  end

  File.open("#{DATA_ROOT}/_sevenparish_test.json", "w") do |f|
    f.write out.to_json
  end

end

task :mike_formosa_ilcr_for_rig do
  require 'csv'
  require 'json'

    geo = JSON.parse(File.open("#{DATA_ROOT}/seven_parish.geo.json").read) 
    c = CSV.read("#{DATA_ROOT}/mike_formosa_for_rig_update.csv", :headers => true)
  
    out = {
      "grid" => []
    }

    c.each do |row|
      grid_square_idx = geo["features"].find_index do |q| 
        q["properties"]["x"].to_i == row["x"].to_i && q["properties"]["y"].to_i == row["y"].to_i
      end
      p grid_square_idx

      out["grid"][grid_square_idx] ||= []
      out["grid"][grid_square_idx] = [row["toxconc"].to_f, row["cancer_sum"].to_f, row["noncancer_sum"].to_f]
    end

    File.open("#{DATA_ROOT}/_mike_formosa_for_rig_update_rake.json", "w") do |f|
      f.write out.to_json
    end 
end

task :mike_formosa_plusagg_for_rig do
  require 'csv'
  require 'json'

    agg     = JSON.parse(File.open("#{DATA_ROOT}/_sevenparish_aggregated_grid_for_rig.json").read)
    formosa = JSON.parse(File.open("#{DATA_ROOT}/_mike_formosa_for_rig_update_rake.json").read)

    out = {
      "grid" => []
    }

    agg["grid"].each_with_index do |square, idx|
      puts idx
      if formosa["grid"][idx]
        puts "combining formosa"
        out["grid"][idx] = [
          (agg["grid"][idx][0] + formosa["grid"][idx][0]),
          (agg["grid"][idx][1] + formosa["grid"][idx][1]),
          (agg["grid"][idx][2] + formosa["grid"][idx][2])
        ]
      else 
        out["grid"][idx] = agg["grid"][idx]
      end
    end

    File.open("#{DATA_ROOT}/_mike_formosa_update_plus_agg_rake.json", "w") do |f|
      f.write out.to_json
    end 

end























