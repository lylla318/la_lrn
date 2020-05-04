task :bake_st_james_acs do
  require 'simpler_tiles'

  aois = {
    "st_james_92019" => {
      :bounds => [-10127773.299,3497768.244,-10090682.742,3519535.303],
      :dims => [10000, 5868.62]
    }
  }

  def get_h(bounds, width)
    llw = bounds[2] - bounds[0]
    llh = bounds[3] - bounds[1]
    # w, h
    wh = [width,  (llh / (llw / width))]
    p wh
    wh[1]
  end

  aois.each do |slug, o|
    acsout = SimplerTiles::Map.new do |m|
      m.width  = o[:dims][0]
      m.height = o[:dims][1]
      m.srs    = "EPSG:3857"
      m.set_bounds *o[:bounds]
      m.bgcolor = "#FFFFFF00"

      brks = [
        [[0,    0.4],   "#ffffff"],
        [[0.4,  9.6],   "#f7fbff"],
        [[9.6,  22.5],  "#deebf7"],
        [[22.5, 35.4],  "#c6dbef"],
        [[35.4, 49.0],  "#9ecae1"],
        [[49.0, 61.2],  "#6baed6"],
        [[61.2, 74.2],  "#4292c6"],
        [[74.2, 86.9],  "#2171b5"],
        [[86.9, 100],   "#084594"],
      ]

      m.layer "#{DATA_ROOT}/sevenparish_tracts_acs.geo.json" do |l|
        brks.each do |brk|
          l.query "select * from sevenparish_tracts_acs where sevenparish_acs_black_alone_percent_black_num >= #{brk[0][0]} and sevenparish_acs_black_alone_percent_black_num < #{brk[0][1]}" do |q|
            q.styles 'stroke' => "#{brk[1]}",
                      'fill' => "#{brk[1]}",
                  'line-join' => 'round',
                     'weight' => '10'
          end
        end
      end
    end

    outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_acs.png"
    p outf
    File.open(outf, 'wb') {|f| f.write acsout.to_png }
  end
end

task :bake_st_james_district5_3 do
  require 'simpler_tiles'

  aois = {
    "st_james_92019" => {
      :bounds => [-10127773.299,3497768.244,-10090682.742,3519535.303],
      :dims => [10000, 5868.62]
    }
  }
  pg = "PG:dbname=la_lrn"
  
  def get_h(bounds, width)
    llw = bounds[2] - bounds[0]
    llh = bounds[3] - bounds[1]
    # w, h
    wh = [width,  (llh / (llw / width))]
    p wh
    wh[1]
  end

  aois.each do |slug, o|

    out_district_5 = SimplerTiles::Map.new do |m|
      m.width  = o[:dims][0]
      m.height = o[:dims][1]
      m.srs    = "EPSG:3857"
      m.set_bounds *o[:bounds]
      m.bgcolor = "#FFFFFF00"


      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from cousub where statefp = '22' and countyfp = '093' and namelsad = 'District 5' " do |q|
          q.styles 'stroke' => '#000',
                'line-join' => 'round',
                   'weight' => '8'
        end
      end
    end

    out_district_3 = SimplerTiles::Map.new do |m|
      m.width  = o[:dims][0]
      m.height = o[:dims][1]
      m.srs    = "EPSG:3857"
      m.set_bounds *o[:bounds]
      m.bgcolor = "#FFFFFF00"


      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from cousub where statefp = '22' and countyfp = '093' and namelsad = 'District 3' " do |q|
          q.styles 'stroke' => '#000',
                'line-join' => 'round',
                   'weight' => '8'
        end
      end
    end

    File.open("#{PROJECT_ROOT}/data/_carto/#{slug}_district5.png", 'wb') {|f| f.write out_district_5.to_png }
    p "#{PROJECT_ROOT}/data/_carto/#{slug}_district5.png"
    File.open("#{PROJECT_ROOT}/data/_carto/#{slug}_district3.png", 'wb') {|f| f.write out_district_3.to_png }
    p "#{PROJECT_ROOT}/data/_carto/#{slug}_district3.png"
  end

end