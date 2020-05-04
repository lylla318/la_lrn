var fs = require("fs");
var d3 = require('d3');
var chemData = require('../data/_sevenparish_conc_grid_filtered_rounded_f.json');
var geoData = require('../data/seven_parish+autoid.geo.json');

d3.round = function(x, n) {
  return n == null ? Math.round(x) : Math.round(x * (n = Math.pow(10, n))) / n;
}

// hardcoded
var cancer_noncancer = 'cancer';

const rawChemColors = [[228, 26, 28], 
                      [55, 126, 184], 
                      [77, 175, 74], 
                      [152, 78, 163], 
                      [255, 127, 0], 
                      [255, 255, 51], 
                      [166, 86, 40], 
                      [247, 129, 191], 
                      [153, 153, 153]];

const genFillColors = function() {
  let noncancer_colors = []
  let cancer_colors   = []
  let rgbs = rawChemColors;

  for (let rgbi = 0; rgbi < rgbs.length; rgbi++) {
    let currgb = rgbs[rgbi]

    cancer_colors[rgbi]     = d3.scaleLog().clamp(true);
    noncancer_colors[rgbi]  = d3.scaleLog().clamp(true);

    cancer_colors[rgbi]     = cancer_colors[rgbi].domain([1e-7, 1e-2])
    noncancer_colors[rgbi]  = noncancer_colors[rgbi].domain([1.2, 500])

    cancer_colors[rgbi].range(
      [`rgba(${currgb[0]},${currgb[1]},${currgb[2]},0)`, 
       `rgba(${currgb[0]},${currgb[1]},${currgb[2]},0.9)`])
    noncancer_colors[rgbi].range(
      [`rgba(${currgb[0]},${currgb[1]},${currgb[2]},0)`, 
       `rgba(${currgb[0]},${currgb[1]},${currgb[2]},0.9)`])
  }
  return {
    noncancer : noncancer_colors,
    cancer : cancer_colors
  }
}
const colors = genFillColors();

const alphaHex = function(i) {
  i = Math.round(i * 100) / 100;
  const alpha = Math.round(i * 255);
  const alpha = i * 255;
  const hex = (alpha + 0x10000).toString(16).substr(-2);
  return hex
}

const hex8 = function(rgba) {
  var color = d3.color(rgba);
  var hex = color.hex();
  hex += alphaHex(color.opacity);
  return hex;
};

const genFill = function(val, cAIdx, curIdx, cancer_noncancer) {
  if (cancer_noncancer === "noncancer") {
    val = val / chemData.chem_attrs[cAIdx][0];
  } else {
    val = val * (chemData.chem_attrs[cAIdx][2] / 1000);
  }
  return colors[cancer_noncancer][curIdx](val);
};

const args = process.argv.slice(2);
const outFile = args[0] // "$ROOT/tmp/tmp_grid_colors.json"
console.log('outFile', outFile)
const chems  = args.slice(1) // // ["Chloroprene", "Ethylene oxide", "Benzene"]

let lookup = [];
for (var i = 0; i < chems.length; i++) {
  lookup[i] = {};
}

console.log("generating color grid ---->", chems)

for (var c = 0; c < chems.length; c++) {
  let cAIdx = chemData.chemicals.indexOf(chems[c]);
  for (var g = 0; g < geoData.features.length; g++) {
    var feat = geoData.features[g];
    let val = chemData.grid[g][cAIdx];
    let fill = genFill(val, cAIdx, c, cancer_noncancer);
    // let rgba = fill.match(/[\d\.]+/g).map(function(it) { 
    //   return d3.round(parseFloat(it, 10), 2) 
    // })
    // let roundFill = "rgba(" + rgba[0] + "," + rgba[1] + "," + rgba[2] + "," + rgba[3] + ")";
    let hex = hex8(fill);
    lookup[c][hex] = (lookup[c][hex]) || [];
    lookup[c][hex].push(feat.properties.autoid);
  }
}

let lookupJson = JSON.stringify(lookup);

fs.writeFile(outFile, lookupJson, function(err) {
    if (err) {
      return console.log(err);
    }
})

