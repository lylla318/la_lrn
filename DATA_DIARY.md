# Data Diary Part 1: Identification and Analysis of Toxic Air

1. Load grid bottom -> rsei_grid_bottom using Odo (load_rsei.rake)
2. Load census xwalk -> rsei_census_xwalk using Odo (load_rsei_census_xwalk.py)
3. Manually fix column names that have garbage characters in them (e.g. gridid)
4. Add countyfp fields
        
        alter table rsei_census_xwalk add column countyfp varchar(255)
        update rsei_census_xwalk set countyfp = substring(BlockID00::text, 1, 5)

5. Create parishes.csv table with FIPS codes for Parishes we want (by hand)
6. Trim grid table for just the Parishes we want ([Parish FIPS codes](http://www.laworks.net/Downloads/OWC/parishcodes.pdf))

        create table rsei_louisiana as (select
          distinct on(c.x, c.y)
          row_number() over (order by null) as autoid,
          c.gridID as gridid, c.x as x, c.y as y, c.blockid00 as blockid00, c.countyfp as countyfp, grid.wkb_geometry as wkb_geometry
          from rsei_census_xwalk as c, rsei_grid_bottom as grid
          where c.countyfp IN ('22005','22007','22033','22037','22047','22051','22057','22063','22071','22075','22077','22087','22089','22093','22095','22103','22105','22121','22125')
          and c.x = grid.cellx and c.y = grid.celly
          group by gridid,x,y,blockid00,countyfp,wkb_geometry
        );

7. Trim down microdata to just the grid squares we want, using awk:

        cat micro2017_2017.csv | awk -F, '$2 > 337 && $2 < 934 && $3 > 815 && $3 < 1235' > micro2017_louisiana.csv

8. Load Louisiana microdata -> micro_2017_louisiana using Odo (load_rsei_micro2017.py)
9. Cache rsei scores on the grid table ([microdata data dictionary](https://www.epa.gov/rsei/rsei-data-dictionary-disaggregated-microdata))

        alter table rsei_louisiana add column score double precision;
        alter table rsei_louisiana add column scorecancer double precision;
        alter table rsei_louisiana add column scorenoncancer double precision;
        alter table rsei_louisiana add column pop double precision;

        update rsei_louisiana set score = t.score from (
          select "1","2",sum("9") as score from micro_2017_louisiana group by "1","2"
        ) t
        where x = t."1" and y = t."2";

        update rsei_louisiana set scorecancer = t.scorecancer from (
          select "1","2",sum("10") as scorecancer from micro_2017_louisiana group by "1","2"
        ) t
        where x = t."1" and y = t."2";

        update rsei_louisiana set scorenoncancer = t.scorenoncancer from (
          select "1","2",sum("11") as scorenoncancer from micro_2017_louisiana group by "1","2"
        ) t
        where x = t."1" and y = t."2";

        update rsei_louisiana set pop = t.pop from (
          select "1","2",sum("12") as pop from micro_2017_louisiana group by "1","2"
        ) t
        where x = t."1" and y = t."2";

10. Add indexes

        create index on micro_2017_louisiana ("1");
        create index on micro_2017_louisiana ("2");
        create index on rsei_louisiana ("x");
        create index on rsei_louisiana ("y");

11. Add chemical data using Odo (load_chemicals.py)

12. Load census data for basemap generation: rake download_census and rake load_census

13. How to get stats for number of grid cells above cancer/noncancer risk thresholds:

    where `noncancer_risk` is > 1 or `cancer_risk` is either over 1e-4 or 1e-6 depending on which threshold we're using.
    
        select count(*),fips,chemical from 
        (select chemicals.chemical, micro."4" as chem, micro."7" as conc,
          grid.x,grid.y,
          chemicals.rfcinhale,
          chemicals.unitriskinhale,
          (micro."7" * (chemicals.unitriskinhale / 1000)) as cancer_risk,
          (micro."7" / rfcinhale) as noncancer_risk,
          substring(grid.blockid00::varchar,1,5) as fips
              from micro_2017_louisiana as micro, rsei_louisiana as grid, rsei_chemicals as chemicals
              where (
               grid.blockid00::varchar like '22047%' 
               or grid.blockid00::varchar like '22121%' 
               or grid.blockid00::varchar like '22033%' 
               or grid.blockid00::varchar like '22005%' 
               or grid.blockid00::varchar like '22093%' 
               or grid.blockid00::varchar like '22095%' 
               or grid.blockid00::varchar like '22089%') and grid.x = micro."1" and grid.y = micro."2" and micro."4" = chemicals.chemicalnumber
              and chemicals.chemical IN ('Benzene', 'Ethylene oxide', 'Chloroprene', 'Formaldehyde')
              and chemicals.rfcinhale is not null
              and micro."8" > 0
            order by chemicals.chemical,x,y) sub
         where sub.cancer_risk > 1e-4
         group by fips,chemical 
         order by fips,chemical




# Data Diary Part 2: Generating Data For the Interactive

The interactive relies on 3 JSON files: a file that stores all the chem concentrations for every grid cell and the chem benchmarks (`_threeparish_grid_chems.json`), a geojson file of all the facilities (`stjohn-stcharles-stjames-facilities.geojson`) and a geojson file of the raw grid cell geometries (`st-john-stjames-st-charles.geojson`)

## Chemical Concentration JSON

The chemical file combines the raw chemical concentrations and the chem benchmarks to output normalized values relative to cancer/noncancer effects. It doesn't output any raw chemical concentration data. To do this, you'll need to run two SQL queries.

To generate the raw concentration file for St. John, St. James and St. Charles, run this (or sub in FIPS codes for other parishes to expand or contract the query)

    select chemicals.chemical, micro."4" as chem, sum(micro."7") as conc,grid.x,grid.y,substring(grid.blockid00::varchar,1,5) as fips
    from micro_2017_louisiana as micro, rsei_louisiana as grid, rsei_chemicals as chemicals
    where (grid.blockid00::varchar like '22095%' or grid.blockid00::varchar like '22089%' or grid.blockid00::varchar like '22093%') and grid.x = micro."1" and grid.y = micro."2" and micro."4" = chemicals.chemicalnumber
    and chemicals.rfcinhale is not null
    and micro."8" > 0
    group by chemicals.chemical,chem,grid.x,grid.y,grid.blockid00

Save the result of that query as `three_parish_conc_grid.csv` in the data directory

Then generate the chemical benchmark data for the same set of FIPS codes:

    select distinct on (chemicals.chemical) chemicals.chemical,chemicals.rfcinhale,chemicals.rfcconf,chemicals.unitriskinhale
    from micro_2017_louisiana as micro, rsei_louisiana as grid, rsei_chemicals as chemicals
    where (grid.blockid00::varchar like '22095%' or grid.blockid00::varchar like '22089%' or grid.blockid00::varchar like '22093%') and grid.x = micro."1" and grid.y = micro."2" and micro."4" = chemicals.chemicalnumber
    and micro."8" > 0
    and rfcinhale is not null
    group by chemicals.chemical,chemicals.rfcinhale,chemicals.rfcconf,chemicals.unitriskinhale

That will get you the RFC, UnitRiskInhale, and RFCConfs. Save the result of that query as `three_parish_chem_rfc.csv` in the data directory.

Then edit `tasks/stjohn_chem_json.rake` starting at line 18 to add the FIPS codes of the Parishes you want to the JSON output. Then run that file with `rake stjohn_chem_json`. That should get you a new file `data/_threeparish_grid_chems.json` which can be used in the interactive.

## Facility GeoJSON

To get facilities within the parishes you want, run this spatial query, subbing in the FIPS for those parishes:

    select facilitynumber, facilityname, modelednaics, st_asgeojson(st_transform(st_setsrid(st_makepoint(longitude, latitude), 4326), 3857)) as wkb_geometry from rsei_facilities where fips in ('22095', '22089', '22093')

Save the output of that query as `data/stjohn-stcharles-stjames-facilities.csv` (we may want to make these file names more abstract when expanding number of parishes.. or alter the rake tasks to accept different files based on geographic scope)

Then run `rake rsei_facility_json`. That will get you a GeoJSON file `stjohn-stcharles-stjames-facilities.geojson` which can be dropped into the interactive.

## Grid Cell geometries GeoJSON

Use ogr2ogr to grab the raw grid cell geometries from the database and convert it to GeoJSON for the parishes you want -- the example below is for the 7 parishes:

    ogr2ogr -f "GeoJSON" -sql "select ogc_fid,x,y,wkb_geometry from rsei_louisiana where blockid00::varchar like '22047%' or blockid00::varchar like '22121%' or blockid00::varchar like '22033%' or blockid00::varchar like '22005%' or blockid00::varchar like '22093%' or blockid00::varchar like '22095%' or blockid00::varchar like '22089%'" seven_parish.geojson PG:dbname=la_lrn

That will get you a file called `st-john-stjames-st-charles.geojson` which can be dropped right into the interactive.

## Generating Overall Toxonc file

    select round(SUM(micro."8")::numeric, 8) as toxconc,grid.x,grid.y,substring(grid.blockid00::varchar,1,5) as fips
    from micro_2017_louisiana as micro, rsei_louisiana as grid
        where (grid.blockid00::varchar like '22033%' 
            or grid.blockid00::varchar like '22121%' 
            or grid.blockid00::varchar like '22047%' 
            or grid.blockid00::varchar like '22005%' 
            or grid.blockid00::varchar like '22089%' 
            or grid.blockid00::varchar like '22093%' 
            or grid.blockid00::varchar like '22095%') 
            and grid.x = micro."1" and grid.y = micro."2" 
            and micro."8" > 0
            group by grid.x,grid.y,grid.blockid00;

## Generating Cancer Summations / Aggregate Toxconc File

First run this query to get raw conc values for all chemicals in the 7 parishes. 

    -- GET RAW CONC VALUES FOR ALL CHEMS IN 7 PARISHES
    select chemicals.chemical, micro."4" as chem, round(SUM(micro."7")::numeric, 8)
    as conc,grid.x,grid.y,substring(grid.blockid00::varchar,1,5) as fips
        from micro_2017_louisiana as micro, rsei_louisiana as grid, rsei_chemicals as chemicals
            where (grid.blockid00::varchar like '22033%' 
                or grid.blockid00::varchar like '22121%' 
                or grid.blockid00::varchar like '22047%' 
                or grid.blockid00::varchar like '22005%' 
                or grid.blockid00::varchar like '22089%' 
                or grid.blockid00::varchar like '22093%' 
                or grid.blockid00::varchar like '22095%') 
                and grid.x = micro."1" and grid.y = micro."2" and micro."4" = chemicals.chemicalnumber
                and chemicals.rfcinhale is not null
                and micro."8" > 0
                group by chemicals.chemical,chem,grid.x,grid.y,grid.blockid00;

Save the result as `sevenparish_conc_grid_all_chem.csv`. Then export the rsei chemicals file, as `rsei_chemicals.csv`. You can grab that file here: `https://www.epa.gov/rsei/rsei-data-dictionary-chemical-data`. Then run the script in `generate_conc_summations.py` in the python folder. That will output the file `_sevenparish_aggregated_grid_for_rig`. The output will have a grid with 3 valus for each cell: aggregate toxconc, cancer_sum, and noncancer_sum. 


## Researcher Deliverable Data Work

First load the data into postgres, running csvsql insert for both files:

    csvsql --db postgresql:///rsei_louisiana --tables mike_deliverable_1 --insert --create-if-not-exists path/to/PropublicOutputP1_0800219.csv

    csvsql --db postgresql:///rsei_louisiana --tables mike_deliverable_1 --insert --create-if-not-exists /Users/lyllayounes/Documents/lrn_github/louisiana_lrn/data/mike_deliverable/PropublicOutputP2_0800219.csv

The first file should give you 1347599 rows, and with the second I have 2519395 rows. Check the row numbers in the command line with `cat FILE_NAME  | wc -l` to make sure everything made it into the database.

Now generate the overall toxonc file with Mike's data:

    select round(SUM(micro."ToxConc")::numeric, 8) as toxconc,grid.x,grid.y,substring(grid.blockid00::varchar,1,5) as fips from mike_deliverable_1 as micro, rsei_louisiana as grid
            where (grid.blockid00::varchar like '22033%' 
                or grid.blockid00::varchar like '22121%' 
                or grid.blockid00::varchar like '22047%' 
                or grid.blockid00::varchar like '22005%' 
                or grid.blockid00::varchar like '22089%' 
                or grid.blockid00::varchar like '22093%' 
                or grid.blockid00::varchar like '22095%') 
                and grid.x = micro."CELLX" and grid.y = micro."CELLY" 
                and micro."ToxConc" > 0
                group by grid.x, grid.y, grid.blockid00;

Save the output as `sevenparish_toxconc_grid_mike_1.csv`. With that done, we first want to generate a new cancer summation file for Mike's data. This is largely a duplicate of the previous section:

    select chemicals.chemical, micro."Chemical" as chem, round(SUM(micro."Conc")::numeric, 8) as conc, grid.x, grid.y, substring(grid.blockid00::varchar,1,5) as fips
    from mike_deliverable_1 as micro, rsei_louisiana as grid, rsei_chemicals as chemicals
        where (grid.blockid00::varchar like '22033%' 
            or grid.blockid00::varchar like '22121%' 
            or grid.blockid00::varchar like '22047%' 
            or grid.blockid00::varchar like '22005%' 
            or grid.blockid00::varchar like '22089%' 
            or grid.blockid00::varchar like '22093%' 
            or grid.blockid00::varchar like '22095%') 
            and grid.x = micro."CELLX" and grid.y = micro."CELLY" and micro."Chemical" = chemicals.chemical
            and chemicals.rfcinhale is not null
            and micro."ToxConc" > 0
            group by chemicals.chemical, chem, grid.x, grid.y, grid.blockid00;

Save the result as `sevenparish_conc_grid_mike_1.csv`.   

Use those two files to run generate_conc_summations.py, which will give you the data for the interactive. 





















            

