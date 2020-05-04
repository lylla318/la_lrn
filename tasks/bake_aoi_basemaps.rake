task :aoi_basemaps do
  require 'simpler_tiles'

  pg = "PG:dbname=la_lrn"

  aois = {
    "7_parish": {"bounds": [-10219366,3460719.38,-10024699.38,3599677], "dims": [11201, 7996]},
    "3_parish": {"bounds": [-10129774.7,3461209.3,-10033859.1,3544638], "dims": [10000, 6439]}
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

  aois.each do |slug, opts|
    p slug, opts
    roads = SimplerTiles::Map.new do |m|
      m.width  = opts[:dims][0]
      m.height = opts[:dims][1] # get_h(bounds, m.width)
      m.srs    = "EPSG:3857"
      m.set_bounds *opts[:bounds]
      m.bgcolor = "#FFFFFF00"


      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from roads where mtfcc = 'S1100' " do |q|
          q.styles 'stroke' => '#444',
                'line-join' => 'round',
                   'weight' => '2'
        end
      end

      m.layer "#{pg}" do |l|
        l.query "select wkb_geometry from roads where mtfcc = 'S1200' " do |q|
          q.styles 'stroke' => '#444',
                'line-join' => 'round',
                   'weight' => '1'
        end
      end
    end

    places = SimplerTiles::Map.new do |m|
      m.width  = opts[:dims][0]
      m.height = opts[:dims][1] # get_h(bounds, m.width)
      m.srs    = "EPSG:3857"
      m.set_bounds *opts[:bounds]
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

    outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_roads.png"
    p outf
    File.open(outf, 'wb') {|f| f.write roads.to_png }

    outf = "#{PROJECT_ROOT}/data/_carto/#{slug}_places.png"
    p outf
    File.open(outf, 'wb') {|f| f.write places.to_png }
  end
end