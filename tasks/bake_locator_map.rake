require 'simpler_tiles'

namespace :locator do
  task :load do
    Dir["#{PROJECT_ROOT}/data/locator/data/*/*.shp"].each do |f|
      layer = f.gsub(/^.*\//,"").gsub(/\.shp/,"")
      # p f, layer
      ltype = layer.match(/roads/) ? "MULTILINESTRING" : "MULTIPOLYGON"
      `ogr2ogr -f "PostgreSQL" PG:dbname=la_lrn -overwrite -nln #{layer} -nlt #{ltype} -geomfield the_geom #{f} -t_srs "EPSG:3857"`
    end
  end

  task :bake do
    def get_bounds_dims(statefp)
      out = {}
      fipstr = out[:fipstr] = statefp.map {|q| "'#{q}'"}.join(",")
      psql_out = `echo "select st_extent(st_expand(wkb_geometry, 20000)) from cb_2018_us_state_500k where geoid IN (#{fipstr})" | psql la_lrn -t`
      out["bounds"]    = psql_out.scan(/[\-\d\.]+/).map(&:to_f)
      llw = out["bounds"][2] - out["bounds"][0]
      llh = out["bounds"][3] - out["bounds"][1]
      out["dims_800"]  = {w: 800,  h: llh / (llw / 800) }
      out["dims_300"]  = {w: 300,  h: llh / (llw / 300)  }
      out["dims_150"]  = {w: 150,  h: llh / (llw / 150)  }
      p out
      out
    end

    pg = "PG:dbname=la_lrn host=localhost port=5432 user=propublica"
    statefp = ["22"]
    draw_fips = ["22"].map {|q| "'#{q}'"}.join(",")
    bvals  = get_bounds_dims(statefp)

    %w[150 300 800].each do |map_brk|
      map = SimplerTiles::Map.new do |m|
        puts "==== drawing #{map_brk}"
        m.width  = map_brk.to_i
        m.height = bvals["dims_#{map_brk}"][:h].to_i
        m.srs    = "EPSG:3857"
        m.set_bounds *bvals["bounds"]
        m.bgcolor = "#ffffff00"

        m.layer "#{pg}" do |l|
          l.query "select * from cb_2018_us_state_500k where geoid in (#{draw_fips})" do |q|
            q.styles 'stroke' => '#9e9e9e',
                'fill' => "#ffffff",
                'line-join' => 'round',
                'weight' => '0.8'
          end
        end

        m.layer "#{pg}" do |l|
          l.query "select * from place" do |q|
          q.styles 'stroke' => '#4444441A',
                'fill' => "#44444433",
                'line-join' => 'round',
                   'weight' => '0.3'
          end
        end

        m.layer "#{pg}" do |l|
          l.query "select * from areawater" do |q|
          q.styles 'stroke' => '#80b1c6',
                'fill' => "#80b1c6",
                'line-join' => 'round',
                   'weight' => '0.1'
          end
        end

      end
      File.open("#{PROJECT_ROOT}/data/locator/out/locator_#{map_brk}.png", 'wb') do |f| 
        f.write map.to_png
      end
    end
  end
end

