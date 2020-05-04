import os
import csv
import simplejson as json
import time
import urllib3
import requests
import collections


class Analyzer:


	def __init__(self, echo, tri):

		self.echo_datafile = echo
		self.tri_datafile  = tri
		self.tri_trifd = collections.defaultdict()
		self.echo_data = []
		self.tri_data  = []
		self.echo_dict = collections.defaultdict()
		self.tri_dict  = collections.defaultdict()

		self.read_data()


	def filter_data(self):

		la_rows = []
		with open(self.echo_datafile) as csvfile:
			reader = csv.DictReader(csvfile)
			x = 0
			for row in reader:
				if(x % 1000 == 0):
					print("Completed " + str(x) + " rows")
				if(row["FAC_STATE"] == "LA" and row["TRI_IDS"] != ""):
					la_rows.append(row)
				x += 1

		with open("tmp.txt", "w") as jsonfile:
			json.dump(la_rows, jsonfile)


	def read_data(self):

		with open(self.tri_datafile) as csvfile:
			reader = csv.DictReader(csvfile)
			for row in reader:
				self.tri_data.append(row)

		with open(self.echo_datafile) as jsonfile:
			self.echo_data = json.load(jsonfile)

		for row in self.tri_data:
			self.tri_dict[row["TRIF ID"]] = row

		for row in self.echo_data:
			self.echo_dict[row["TRI_IDS"]] = row

		exists = 0
		merged_data = []
		for trifid in self.tri_dict.keys():
			if(trifid in self.echo_dict.keys()):
				merged = self.merge_dicts(self.echo_dict[trifid], self.tri_dict[trifid])
				merged_data.append(merged)
				exists += 1
			
		# print("NUMBER OF ECHO ROWS: ", len(self.echo_dict.keys()))
		# print("NUMBER OF TRI ROWS: ", len(self.tri_dict.keys()))
		# print("NUMBER OF JOINABLE ROWS: ", exists)

		# with open("echo_la_filtered.txt", "w") as jsonfile:
		# 	json.dump(self.echo_data, jsonfile)


	
	def merge_dicts(self, x, y):
	    z = x.copy()
	    z.update(y)
	    return z
		







if __name__ == '__main__':

	# echo_datafile = "data/ECHO_Exporter/ECHO_Exporter.csv"
	tri_datafile  = "data/TRI/TRI_LA/tri_louisiana_2017_all_chemicals.csv"
	echo_datafile = "data/ECHO_Exporter/louisiana_w_triids.json"
	Analyzer(echo_datafile, tri_datafile)

