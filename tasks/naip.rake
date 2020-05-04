task :stitch_naip_stjames_92019 do
  slug = "st_james_92019"
  orders = %w[1021332 1025950 1032577 1041482]
  tifs = orders.map {|q| Dir["#{PROJECT_ROOT}/data/NAIP/#{q}/NAIP/*/*.tif"] }.flatten

  system(<<-SH
    gdalwarp -t_srs "EPSG:3857" #{tifs.join(" ")} #{PROJECT_ROOT}/data/NAIP/out/#{slug}.tif
  SH
    )
  puts "done -> #{PROJECT_ROOT}/data/NAIP/out/#{slug}.tif"
end

task :crop_naip_st_james_92019 do
  bounds = [-10127773.299,3497768.244,-10090682.742,3519535.303]
  system(<<-SH
    gdalwarp -te #{bounds.join(" ")} #{PROJECT_ROOT}/data/NAIP/out/st_james_92019.tif #{PROJECT_ROOT}/data/NAIP/out/st_james_92019_crop.tif
  SH
  )
end


task :stitch_naip_ascension_iberville_92019 do
  orders = %w[1021320 1021330 1024633 1040569 st-gabriel-gaps]
  tifs = orders.map {|q| Dir["#{PROJECT_ROOT}/data/NAIP/#{q}/NAIP/*/*.tif"] }.flatten
  system(<<-SH
    gdalwarp -t_srs "EPSG:3857" '#{tifs.join("' '")}' #{PROJECT_ROOT}/data/NAIP/out/ascension_iberville_92019.tif
  SH
    )
end

task :crop_naip_ascension_iberville_92019 do
  bounds = [-10161968.8,3520564.6,-10119864.7,3551576.7]
  system(<<-SH
    gdalwarp -te #{bounds.join(" ")} #{PROJECT_ROOT}/data/NAIP/out/ascension_iberville_92019.tif #{PROJECT_ROOT}/data/NAIP/out/ascension_iberville_92019_crop.tif
  SH
  )
end

task :stitch_naip_union_carbide_92019 do
  slug = "union_carbide_92019"
  orders = ["1040575"]
  tifs = orders.map {|q| Dir["#{PROJECT_ROOT}/data/NAIP/#{q}/NAIP/*/*.tif"] }.flatten
  system(<<-SH
    gdalwarp -t_srs "EPSG:3857" '#{tifs.join("' '")}' #{PROJECT_ROOT}/data/NAIP/out/#{slug}.tif
  SH
    )
end

task :crop_naip_union_carbide_92019 do
  bounds = [-10095413.6,3480534.7,-10046612.2,3525377.4]
  system(<<-SH
    gdalwarp -te #{bounds.join(" ")} #{PROJECT_ROOT}/data/NAIP/out/union_carbide_92019.tif #{PROJECT_ROOT}/data/NAIP/out/union_carbide_92019_crop.tif
  SH
  )
end