task :topojsonify do
  json_root = "/Users/ashaw/rails/louisiana_rsei_graphic/app/scripts/packs/rsei_map"
  files = [
    '/data/facility-data/rsei_facilities_sevenparish_filtered.geo.json',
    '/data/facility-data/new-facilities.geo.json',
    '/data/facility-data/pending-facilities.geo.json',
    '/data/facility-data/facility-shapes/major-industry-filtered.geo.json',
    "/data/facility-data/facility-shapes/fg_shape.geo.json",
    "/data/facility-data/facility-shapes/ergon_slm_shapes.geo.json",
    "/data/facility-data/facility-shapes/yci_shape.geo.json",
    "/data/st_gabriel_shape3857.geo.json",
    "/data/facility-data/facility-shapes/wolverine_petroplex.geo.json",
    '/data/sevenparish_shapes.geo.json'
  ]
  save_properties = [
    "FacilityNumber FacilityName",
    "MASTER_AI_ID MASTER_AI_NAME",
    "MASTER_AI_ID MASTER_AI_NAME",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
  ]

  files.each_with_index do |f,i|
    `geojson-pick #{save_properties[i]} < #{json_root}#{f} | geo2topo > #{json_root}#{f.gsub(/geo\.json/, "topo.json")}`
  end
end