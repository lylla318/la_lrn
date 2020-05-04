import sqlalchemy as sa
from odo import odo
odo("../data/chemical_data_rsei_v237.csv", 'postgresql://localhost/la_lrn::rsei_chemicals')