task :stjohn_chem_json do
  require 'csv'
  require 'json'

  chemicals = CSV.read("#{DATA_ROOT}/three_parish_chem_rfc.csv", :headers => true)
  chemnames = chemicals.map {|q| q["chemical"] }
  chem_attrs = chemicals.map {|q| [q["rfcinhale"].to_f, q["rfcconf"], q["unitriskinhale"].to_f] }

  noncancer_ratio_min = 1
  cancer_ratio_min = 1e-6

  c = CSV.read("/Users/lyllayounes/Documents/Volumes/nola_graphic/three_parish_conc_grid.csv", :headers => true)
  out = {
    "chemicals" => chemnames,
    "chem_attrs" => chem_attrs,
    "chems_above_thresh" => [],
    "grid" => {
      "22095" => {},
      "22089" => {},
      "22093" => {},
      "22033" => {}, 
      "22121" => {},
      "22047" => {}, 
      "22005" => {} 
    }
  }
  out["chems_above_thresh"] = 0.upto(chemnames.length - 1).map {|q| 0 }
  c.each do |row|
    out["grid"][row["fips"]]["#{row["x"]}_#{row["y"]}"] = out["grid"][row["fips"]]["#{row["x"]}_#{row["y"]}"] ? out["grid"][row["fips"]]["#{row["x"]}_#{row["y"]}"] : []
    out["grid"][row["fips"]]["#{row["x"]}_#{row["y"]}"][chemnames.index(row["chemical"])] = row["conc"].to_f

    chem_idx = chemnames.index(row["chemical"])
    # non cancer
    if ((row["conc"].to_f / chem_attrs[chem_idx][0]) >= noncancer_ratio_min) || 
      # cancer
      ((row["conc"].to_f * (chem_attrs[chem_idx][2] / 1000)) >= cancer_ratio_min)
      out["chems_above_thresh"][chem_idx] = 1
    end
  end
  File.open("#{DATA_ROOT}/_threeparish_grid_chems.json", "w") do |f|
    f.write out.to_json
  end
end



