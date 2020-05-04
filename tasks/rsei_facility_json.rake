task :rsei_facility_json do
  require 'csv'
  require 'json'

  c = CSV.read("#{DATA_ROOT}/stjohn-stcharles-stjames-facilities.csv", :headers => true)
  out = {
    "type" => "FeatureCollection",
    "features" => []
  }
  c.each do |row|
    o = {
      "type" => "Feature",
      "properties" => {},
      "geometry" => JSON.parse(row["wkb_geometry"])
    }
    (c.headers - ["wkb_geometry"]).each do |h|
      o["properties"][h] = row[h]
    end
    out["features"] << o
  end
  File.open("#{DATA_ROOT}/stjohn-stcharles-stjames-facilities.geojson", "w") do |f|
    f.write out.to_json
  end
end