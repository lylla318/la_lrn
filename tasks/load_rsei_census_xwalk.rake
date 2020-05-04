task :load_rsei_census_xwalk do
  `csvsql --db postgresql:///#{DB} --tables resi_census_xwalk --no-constraints --insert "/Volumes/AL\'S\ DRIVE/la_lrn/CensusBlock2010_ConUS_810m.csv"`
end