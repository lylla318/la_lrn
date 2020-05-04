
task :parish_grid_lookup do
  require 'csv'
  require 'json'

  out = {}
  c = CSV.read("#{DATA_ROOT}/grid_xy_aoi_lookup.csv", :headers => true)
  geo = JSON.parse(File.open("#{DATA_ROOT}/seven_parish.geo.json").read)
  c_ary = c.to_a
  geo["features"].each_with_index do |f, i|
    props = f["properties"]
    walk = c_ary.select {|q| q[0] == props["x"].to_s && q[1] == props["y"].to_s }[0]
    if walk && walk.length > 0
      fips = walk[2]
      p fips
      out[fips] = (out[fips] || [])
      out[fips].push(i)
    end
  end
  File.open("#{DATA_ROOT}/aoi_grid_lookup_f.json", "w") do |f|
    f.write out.to_json
  end
end