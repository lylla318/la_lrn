import sqlalchemy as sa
from odo import odo
odo("/Volumes/AL\'S DRIVE/la_lrn/CensusBlock2010_ConUS_810m.csv", 'postgresql://localhost/la_lrn::rsei_census_xwalk')

# alter table rsei_census_xwalk add column countyfp varchar(255)
# update rsei_census_xwalk set countyfp = substring(BlockID00::text, 1, 5)

# create table rsei_louisiana as (select
#   distinct on(c.x, c.y)
#   row_number() over (order by null) as autoid,
#   c.gridID as gridid, c.x as x, c.y as y, c.blockid00 as blockid00, c.countyfp as countyfp, grid.wkb_geometry as wkb_geometry
#   from rsei_census_xwalk as c, rsei_grid_bottom as grid
#   where c.countyfp IN ('22005','22007','22033','22037','22047','22051','22057','22063','22071','22075','22077','22087','22089','22093','22095','22103','22105','22121','22125')
#   and c.x = grid.cellx and c.y = grid.celly
#   group by gridid,x,y,blockid00,countyfp,wkb_geometry
# )
