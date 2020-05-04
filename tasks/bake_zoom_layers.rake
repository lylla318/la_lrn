task :bake_zoom_layers do
  require 'simpler_tiles'

  pg = "PG:dbname=la_lrn"

  aois = {
    "st_james_92019" => {
      :bounds => [-10127773.299,3497768.244,-10090682.742,3519535.303],
      :dims => [10000, 5868.62]
    },
    # "ascension_iberville_92019" => {
    #   :bounds => [-10161968.8,3520564.6,-10119864.7,3551576.7],
    #   :dims => [10000, 7365.57]
    #},
    # "union_carbide_92019" => {
    #   :bounds => [-10095413.6,3480534.7,-10046612.2,3525377.4],
    #   :dims => [10000,9188.81]
    # }
  }

  statefps = ["22"]
  countyfps = ["22047", "22121", "22033", "22005", "22093", "22095", "22089"],

  def get_h(bounds, width)
    llw = bounds[2] - bounds[0]
    llh = bounds[3] - bounds[1]
    # w, h
    wh = [width,  (llh / (llw / width))]
    p wh
    wh[1]
  end

  aois.each do |slug, o|
    roads = SimplerTiles::Map.new do |m|
      m.width  = o[:dims][0]
      m.height = o[:dims][1]
      m.srs    = "EPSG:3857"
      m.set_bounds *o[:bounds]
      m.bgcolor = "#FFFFFF00"


      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from roads where mtfcc = 'S1100' " do |q|
          q.styles 'stroke' => '#444',
                    'fill' => '#444',
                'line-join' => 'round',
                   'weight' => '10'
        end
      end

      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from roads where mtfcc = 'S1200' " do |q|
          q.styles 'stroke' => '#444',
                    'fill' => '#444',
                'line-join' => 'round',
                   'weight' => '5'
        end
      end
    end

    places = SimplerTiles::Map.new do |m|
      m.width  = o[:dims][0]
      m.height = o[:dims][1]
      m.srs    = "EPSG:3857"
      m.set_bounds *o[:bounds]
      m.bgcolor = "#FFFFFF00"


      # m.layer "#{pg}" do |l|
      #   l.query "select wkb_geometry from place" do |q|
      #     q.styles 'stroke' => '#4444441A',
      #           'fill' => "#d6d6d626",
      #           'line-join' => 'round',
      #              'weight' => '0.3'
      #   end
      # end

      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from ms_buildings " do |q|
          q.styles 'stroke' => '#999',
                'fill' => '#999',
                'line-join' => 'round',
                   'weight' => '0.2'
        end
      end
    end

    waters = SimplerTiles::Map.new do |m|
      m.width  = o[:dims][0]
      m.height = o[:dims][1]
      m.srs    = "EPSG:3857"
      m.set_bounds *o[:bounds]
      m.bgcolor = "#FFFFFF00"


      m.layer "#{pg}" do |l|
        l.query "select * from areawater" do |q|
        q.styles 'stroke' => '#999',
                'fill' => '#999',
                'line-join' => 'round',
                   'weight' => '2'
        end
      end
    end

    outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_roads.png"
    p outf
    File.open(outf, 'wb') {|f| f.write roads.to_png }

    outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_places.png"
    p outf
    File.open(outf, 'wb') {|f| f.write places.to_png }

    outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_waters.png"
    p outf
    File.open(outf, 'wb') {|f| f.write waters.to_png }

    # yci and wanhua
    # if slug == 'st_james'

    #   new_facilities = SimplerTiles::Map.new do |m|
    #     m.width  = o[:dims][0]
    #     m.height = o[:dims][1]
    #     m.srs    = "EPSG:3857"
    #     m.set_bounds *o[:bounds]
    #     m.bgcolor = "#FFFFFF00"


    #     m.layer "#{PROJECT_ROOT}/data/facility_images/trace_shp/yci.shp" do |l|
    #       l.query "select * from yci" do |q|
    #         q.styles 'stroke' => '#999',
    #               'line-join' => 'round',
    #                  'weight' => '3'
    #       end
    #     end

    #     m.layer "#{PROJECT_ROOT}/data/facility_images/trace_shp/wanhua.shp" do |l|
    #     l.query "select * from wanhua" do |q|
    #       q.styles 'stroke' => '#999',
    #             'line-join' => 'round',
    #                'weight' => '3'
    #       end
    #     end

    #     m.layer "#{pg}" do |l|
    #       l.query "select st_union(wkb_geometry) from stjames_tax_parcels where taxpayer = 'FG LA LLC' OR taxpayer = 'F.G. LA LLC'" do |q|
    #         q.styles 'stroke' => '#999',
    #               'line-join' => 'round',
    #                  'weight' => '3'
    #         end
    #       end
    #     end
  
    #     outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_new_facility_parcels.png"
    #     p outf
    #     File.open(outf, 'wb') {|f| f.write new_facilities.to_png }

    # end
  end
end