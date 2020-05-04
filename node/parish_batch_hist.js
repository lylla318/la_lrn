var _  = require("lodash");
var d3 = require("d3");
var fs = require("fs");
var chemData = require('../data/_sevenparish_conc_grid_filtered_rounded_f.json');
var geoData = require('../data/seven_parish.geo.json');
var censusLookup = require('../data/grid_xy_countyfp_lookup.json');
var fips = ['22095', '22089', '22093', '22033', '22121', '22047', '22005'];

/*
  fpHists = [
    {
      fp: FIPS,
      histData : [
        // bucket 1
        {chem1: GRIDCT, chem2: GRIDCT},
        // bucket 2
        {chem1: GRIDCT, chem2: GRIDCT}
          ...
      ]
    }
  ]
*/

for (var i = 0; i < geoData.features.length; i++) {
  var cur = geoData.features[i];
  var filtered = _.filter(censusLookup, function(it) {
    return it["x"] === (cur.properties.x + '') && it['y'] === (cur.properties.y + '');
  });
  if (filtered.length > 0) {
    cur.properties.fp = filtered[0].countyfp;
  }
}

console.log(geoData.features[0])

// noncancer
var scale = d3.scaleLog().clamp(true).domain([0.8, 500]).range([0,5])

var bucket = function(it) {
  return +scale(400).toFixed(0);
}

var fpHists = [];

for (var f = 0; f < fips.length; f++) {
  var hist = {};
  hist.fp = f;
  histData = [];
  var gridData = geoData.features.map(function(it) { return it.properties.fp === f });
}



