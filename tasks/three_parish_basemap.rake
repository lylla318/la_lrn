task :three_parish_basemap do
  require 'simpler_tiles'

  pg = "PG:dbname=la_lrn"
  bounds = [-10129774.7, 3461209.3, -10033859.1, 3544638]

  statefps = ["22"]
  countyfps = ["22095", "22089", "22093"]

  def get_h(bounds, width)
    llw = bounds[2] - bounds[0]
    llh = bounds[3] - bounds[1]
    # w, h
    wh = [width,  (llh / (llw / width))]
    p wh
    wh[1]
  end

  base_map = SimplerTiles::Map.new do |m|
    m.width  = 2000
    m.height = get_h(bounds, m.width)
    m.srs    = "EPSG:3857"
    m.set_bounds *bounds
    m.bgcolor = "#FFFFFF00"


    m.layer "#{pg}" do |l|
      l.query "select * from arealm where mtfcc LIKE '%K218%'" do |q|
        q.styles "fill" => "#E4ECD5",
             'seamless' => 'true'
      end
    end
    m.layer "#{pg}" do |l|
      l.query "select wkb_geometry from place" do |q|
        q.styles 'stroke' => '#4444441A',
              'fill' => "#d6d6d626",
              'line-join' => 'round',
                 'weight' => '0.3'
      end
    end

    m.layer "#{pg}" do |l|
      l.query "select wkb_geometry from ms_buildings " do |q|
        q.styles 'stroke' => '#222',
              'fill' => '#222',
              'line-join' => 'round',
                 'weight' => '0.2'
      end
    end

    m.layer "#{pg}" do |l|
      l.query "select wkb_geometry from roads where mtfcc = 'S1100' " do |q|
        q.styles 'stroke' => '#9e9e9e',
              'line-join' => 'round',
                 'weight' => '0.2'
      end
    end

    m.layer "#{pg}" do |l|
      l.query "select wkb_geometry from roads where mtfcc = 'S1200' " do |q|
        q.styles 'stroke' => '#9e9e9e',
              'line-join' => 'round',
                 'weight' => '0.2'
      end
    end

    m.layer "#{pg}" do |l|
      l.query "select wkb_geometry from areawater" do |q|
        q.styles 'fill' => '#cfdade',
                  'stroke' => '#cfdade',
                  'weight' => '0.4',
                  'seamless' => 'true'
      end
    end
  end

  File.open("#{PROJECT_ROOT}/data/out_basemap.png", 'wb') {|f| f.write base_map.to_png }

end