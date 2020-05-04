task :three_parish_chem_json_for_rig do
  require 'csv'
  require 'json'

  geo = JSON.parse(File.open("#{DATA_ROOT}/st-john-stjames-st-charles.geojson").read)
  chemicals = CSV.read("#{DATA_ROOT}/three_parish_chem_rfc.csv", :headers => true)
  chemnames = chemicals.map {|q| q["chemical"] }
  chem_attrs = chemicals.map {|q| [q["rfcinhale"].to_f, q["rfcconf"], q["unitriskinhale"].to_f] }

  noncancer_ratio_min = 1
  cancer_ratio_min = 1e-6

  c = CSV.read("#{DATA_ROOT}/three_parish_conc_grid.csv", :headers => true)
  out = {
    "chemicals" => chemnames,
    "chem_attrs" => chem_attrs,
    "chems_above_thresh" => [],
    "grid" => []
  }
  out["chems_above_thresh"] = 0.upto(chemnames.length - 1).map {|q| 0 }
  c.each do |row|
    grid_square_idx = geo["features"].find_index do |q| 
      q["properties"]["x"] == row["x"].to_i && q["properties"]["y"] == row["y"].to_i
    end
    chem_idx = chemnames.index(row["chemical"])

    p grid_square_idx
    out["grid"][grid_square_idx] ||= []
    out["grid"][grid_square_idx][chem_idx] = row["conc"].to_f

    # non cancer
    if ((row["conc"].to_f / chem_attrs[chem_idx][0]) >= noncancer_ratio_min) || 
      # cancer
      ((row["conc"].to_f * (chem_attrs[chem_idx][2] / 1000)) >= cancer_ratio_min)
      out["chems_above_thresh"][chem_idx] = 1
    end
  end
  File.open("#{DATA_ROOT}/_threeparish_grid_chems_for_rig.json", "w") do |f|
    f.write out.to_json
  end
end