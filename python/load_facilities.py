import sqlalchemy as sa
from odo import odo
odo("../data/facility_data_rsei_v237_0.csv", 'postgresql://localhost/la_lrn::rsei_facilities')
