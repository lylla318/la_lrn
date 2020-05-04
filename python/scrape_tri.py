import os
import csv
import simplejson as json
import time
import urllib3
import requests
import collections
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options 
from selenium.common.exceptions import TimeoutException

class Scraper:

	def __init__(self, filename):

		self.csvwrite = filename
		self.driver = None
		self.scrape()
		



	# Search for the page corresponding to a given case number.
	def scrape(self):

		data_dict = collections.defaultdict(lambda: collections.defaultdict(lambda: collections.defaultdict(lambda: collections.defaultdict(str))))

		years   = [2003,2017]
		# "Ascension", "Assumption", "East Baton Rouge","East Feliciana",
		# parishes = ["Iberville", "Jefferson", "Lafourche", "Livingston", "Orleans", "Plaquemines", "Pointe Coupee", "St. Bernard", "St. Charles", "St. James", "St. John The Baptist", "St. Tammany", "Tangipahoa", "West Baton Rouge", "West Feliciana"]
		parishes = ["Pointe Coupee"]

		# Set up the driver.
		chrome_path = os.path.realpath('chromedriver')
		chrome_options = Options()
		chrome_options.add_experimental_option("detach", True)
		
		# page = self.driver.get( 'https://iaspub.epa.gov/triexplorer/tri_release.facility' )
		
		for parish in parishes:

			for year in range(2003,2017):

				print("Scraping " + str(year) + ", " + parish)
				self.driver = webdriver.Chrome(executable_path='/Users/lyllayounes/Documents/alaska_scraping/chromedriver', chrome_options=chrome_options)
				page = self.driver.get( 'https://iaspub.epa.gov/triexplorer/tri_release.facility' )
				rows = []
				self.check_exists_by_xpath()

				# Select year.
				dropdown = WebDriverWait(self.driver, 3).until(EC.presence_of_element_located((By.NAME, 'year')))
				time.sleep(1)
				el = self.driver.find_element_by_name('year')
				for option in el.find_elements_by_tag_name('option'):
				    if option.text == str(year):
				        option.click() 
				        break

				self.check_exists_by_xpath()

				# Select geographic location.
				el = self.driver.find_element_by_name('stateloc')
				for option in el.find_elements_by_tag_name('option'):
				    if option.text == 'Select a state or a county':
				        option.click() 
				        time.sleep(1)
				        break

				self.check_exists_by_xpath()

				# Select a state.
				el = self.driver.find_element_by_name('state')
				for option in el.find_elements_by_tag_name('option'):
				    if option.text == 'Louisiana':
				        option.click() 
				        break

				self.check_exists_by_xpath()

				# Click to select county.
				el = self.driver.find_element_by_xpath('//*[@id="form1"]/table/tbody/tr[2]/td[1]/a[3]')
				el.click()
				time.sleep(1)

				self.check_exists_by_xpath()

				# Select a parish.
				el = self.driver.find_element_by_name('county')
				for option in el.find_elements_by_tag_name('option'):
				    if option.text == parish:
				        option.click() 
				        break

				self.check_exists_by_xpath()

				# Include additional data columns. 
				radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[1]/td/input')
				radioBtn.click()
				radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[2]/td/input')
				radioBtn.click()
				radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[3]/td/input')
				radioBtn.click()
				radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[4]/td/input')
				radioBtn.click()
				try:
					radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[7]/td[2]/input')
					radioBtn.click()
					radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[8]/td[2]/input')
					radioBtn.click()
					radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[11]/td[2]/input')
					radioBtn.click()
					radioBtn = self.driver.find_element_by_xpath('//*[@id="main"]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[12]/td[2]/input')
					radioBtn.click()
				except:
					print("Radio button not found.")

				self.check_exists_by_xpath()

				# Generate report.
				submitBtn = self.driver.find_element_by_xpath('//*[@id="form1"]/table/tbody/tr[3]/td[1]/b/input')
				time.sleep(3)
				submitBtn.click()

				# Wait until data loads.
				table = WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="main"]/div[1]/table')))
				html = self.driver.page_source
				soup = BeautifulSoup(html, features="html.parser")
				# table = (soup.find("div", {"class":"ui-datatable-tablewrapper"})).find("table")
				tables = soup.findAll("table")
				table = None
				for i in range(len(tables)):
					if(i == 3):
						table = tables[i].find("tbody")
						break

				current = None
				for tr in table.findAll("tr"):

					cells = tr.findAll("td")
					tmp   = []
					# Facility row.
					try:
						if(cells[0].text.strip() != ""):
							current   = [cells[1].text.strip(), cells[2].text.strip(), cells[3].text.strip(), cells[4].text.strip(), cells[5].text.strip(), cells[6].text.strip()]
							tmp = [year, parish, ""]
							for i in range(1,len(cells)):
								tmp.append(cells[i].text.strip())
							rows.append(tmp)
						# Chemical row.
						else:
							tmp = [year, parish, cells[1].text.strip(), current[0], current[1], cells[3].text.strip(), cells[4].text.strip(), current[4], current[5]]
							for i in range(7, len(cells)):
								tmp.append(cells[i].text.strip())

						rows.append(tmp)
					except:
						print(cells)

				with open(self.csvwrite, mode='a') as csvfile:
				    csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
				    for row in rows:
				    	csvwriter.writerow(row)

				self.driver.close()
		
		

		print(data_dict)





	def check_exists_by_xpath(self):
		time.sleep(3)
		xpath = '//*[@id="acsMainInvite"]/a'
		try:
			self.driver.find_element_by_xpath(xpath)
			popup = self.driver.find_element_by_xpath('//*[@id="acsMainInvite"]/a')
			print("BLOCK POPUP")
			popup.click()
		except:
			return False
		return True


if __name__ == '__main__':

	# input_file  = "original_data/alaska_sex_crime_charges.csv"
	# output_file = "output_data/output.json"
	filename = "data/output_data/POINTE_COUPEE_2003_2017.csv"
	instance = Scraper(filename)









