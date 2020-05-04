var fs = require('fs');
var topojson = require('topojson');
var chemData = require('../data/_sevenparish_conc_grid_filtered_rounded_f.json');
var geoData = require('../data/seven_parish.geo.json');

for (var i = 0; i < geoData.features.length; i++) {
  geoData.features[i].properties.chems = [];
  for (var j = 0; j < chemData.chemicals.length; j++) {
    var curChem = chemData.chemicals[j];
    var val = chemData.grid[i][j];
    // noncancer val, cancer val
    res = [val / chemData.chem_attrs[j][0], val * (chemData.chem_attrs[j][2] / 1000)]
    geoData.features[i].properties.chems[chemData.chemicals.indexOf(curChem)] = res;
  }
}

var topology = topojson.topology({g: geoData});

fs.writeFileSync('../data/sevenparish_geo+chems_precomputed.topojson', JSON.stringify(topology));

