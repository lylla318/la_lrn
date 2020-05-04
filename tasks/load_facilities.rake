task :load_facilities do
  `csvsql --db postgresql:///#{DB} --tables rsei_facilities --insert "#{DATA_ROOT}/facility_data_rsei_v237_0.csv"`
end