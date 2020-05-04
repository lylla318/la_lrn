import os
import csv
import simplejson as json
import collections



def generate_conc_summations(conc_grid_file, toxconc_grid_file, benchmark_file, writefile):
	
	toxconc_grid  = collections.defaultdict(list)
	conc_grid     = collections.defaultdict(lambda: collections.defaultdict(float))
	benchmarks    = collections.defaultdict(dict)

	# Read benchmark data.
	with open(benchmark_file) as csvfile:
		reader = csv.DictReader(csvfile)
		for row in reader:
			benchmarks[row["Chemical"]] = row

	# Read conc grid data.
	with open(conc_grid_file) as csvfile:
		reader = csv.DictReader(csvfile)
		ctr = 0
		for row in reader:
			if(ctr % 10000 == 0):
				print("Processed " + str(ctr) + " rows...")
			ctr += 1
			uri = benchmarks[row["chemical"]]["unitriskinhale"]
			rfc = benchmarks[row["chemical"]]["RfCInhale"]
			if(uri):
				conc_grid[row["x"]+"-"+row["y"]]["cancer_sum"] += (float(row["conc"]) * (float(uri))/1000)
			if(rfc):
				conc_grid[row["x"]+"-"+row["y"]]["noncancer_sum"] += (float(row["conc"]) * (1/float(rfc)))
	
	# Read toxconc data.
	with open(toxconc_grid_file) as csvfile:
		reader = csv.reader(csvfile)
		next(reader, None)
		for row in reader:
			toxconc_grid[row[1]+"-"+row[2]] = row

	# Add summations to toxconc aggregate file.
	for grid_xy in conc_grid.keys():
		toxconc_grid[grid_xy].append(conc_grid[grid_xy]["cancer_sum"])
		toxconc_grid[grid_xy].append(conc_grid[grid_xy]["noncancer_sum"])

	# Write output.
	with open(writefile, mode='w') as csvfile:
	    csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
	    csvwriter.writerow(["toxconc","x","y","fips", "cancer_sum", "noncancer_sum"])
	    for grid_xy in toxconc_grid.keys():
	    	csvwriter.writerow(toxconc_grid[grid_xy])



if __name__ == '__main__':

	conc_grid    = "../data/mike_deliverable/sevenparish_conc_grid_mike_1.csv"
	toxconc_grid = "../data/mike_deliverable/sevenparish_toxconc_grid_mike_1.csv"
	benchmarks   = "../data/rsei_chemicals.csv"
	writefile    = "../data/mike_deliverable/sevenparish_aggregated_grid_mike_1.csv"
	generate_conc_summations(conc_grid, toxconc_grid, benchmarks, writefile)



# conc_grid    = "../data/sevenparish_conc_grid_all_chem.csv"
# toxconc_grid = "../data/sevenparish_toxconc_grid.csv"
# benchmarks   = "../data/rsei_chemicals.csv"
# writefile    = "../data/sevenparish_aggregated_grid_data.csv"