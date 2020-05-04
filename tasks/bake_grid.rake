task :bake_grids do
  require 'json'
  require 'simpler_tiles'
  pg = "PG:dbname=la_lrn"
  bounds = [-10219366,3460702,-10024682,3599677]


  def get_h(bounds, width)
    llw = bounds[2] - bounds[0]
    llh = bounds[3] - bounds[1]
    # w, h
    wh = [width,  (llh / (llw / width))]
    p wh
    wh[1]
  end

  aois = [
    [-10219366,3460702,-10024682,3599677]
  ]

  chems = ["Chloroprene", "Ethylene oxide", "Benzene"]

  color_lookup_out = "#{PROJECT_ROOT}/tmp/tmp_grid_colors.json"
  
  system("node #{PROJECT_ROOT}/node/colors_for_static_grid #{color_lookup_out} '#{chems.join("' '")}'")

  o = JSON.parse(File.open(color_lookup_out).read)

  # width  = 11202
  width = 2000
  height = get_h(bounds, width)

  st_map = SimplerTiles::Map.new do |m|
    m.width  = width
    m.height = height
    m.srs    = "EPSG:3857"
    m.set_bounds *bounds
    m.bgcolor = "#FFFFFF00"

    m.layer pg do |l|
      o.each do |chem|
        chem.each do |color, autoids|
          l.query "select * from rsei_louisiana where autoid IN ('#{autoids.join("','")}')" do |q|
            q.styles 'fill' => color
          end
        end
      end
    end
  end

  out_basename = "out_7parish_#{chems.map {|q| q.gsub(/ /,"_") }.join("-")}_#{width}x#{height}"
  p "#{PROJECT_ROOT}/data/_st_out/#{out_basename}.png"
  File.open("#{PROJECT_ROOT}/data/_st_out/#{out_basename}.png", 'wb') {|f| f.write st_map.to_png }
end