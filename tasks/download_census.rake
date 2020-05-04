task :download_census do
  `cd #{DATA_ROOT}/TIGER && wget https://www2.census.gov/geo/tiger/TIGER2018/STATE/tl_2018_us_state.zip`
  `cd #{DATA_ROOT}/TIGER && wget https://www2.census.gov/geo/tiger/TIGER2018/COUNTY/tl_2018_us_county.zip`
  states = ["22"]
  states.each do |s|
    `cd #{DATA_ROOT}/TIGER && wget https://www2.census.gov/geo/tiger/TIGER2018/AREALM/tl_2018_#{s}_arealm.zip`
    `cd #{DATA_ROOT}/TIGER && wget https://www2.census.gov/geo/tiger/TIGER2018/PLACE/tl_2018_#{s}_place.zip`
  end

  counties = %w[
    001
    003
    005
    007
    009
    011
    013
    015
    017
    019
    021
    023
    025
    027
    029
    031
    033
    035
    037
    039
    041
    043
    045
    047
    049
    051
    053
    055
    057
    059
    061
    063
    065
    067
    069
    071
    073
    075
    077
    079
    081
    083
    085
    087
    089
    091
    093
    095
    097
    099
    101
    103
    105
    107
    109
  ].map {|q| "22#{q}"}

  counties.each do |c|
    `cd #{DATA_ROOT}/TIGER && wget https://www2.census.gov/geo/tiger/TIGER2018/AREAWATER/tl_2018_#{c}_areawater.zip`
    `cd #{DATA_ROOT}/TIGER && wget https://www2.census.gov/geo/tiger/TIGER2018/ROADS/tl_2018_#{c}_roads.zip`
  end
  `cd #{DATA_ROOT}/MSBUILDINGS && wget https://usbuildingdata.blob.core.windows.net/usbuildings-v1-1/Louisiana.zip`

  `cd #{DATA_ROOT}/TIGER && unzip "*.zip"`
  `cd #{DATA_ROOT}/MSBUILDINGS && unzip "*.zip"`
end
