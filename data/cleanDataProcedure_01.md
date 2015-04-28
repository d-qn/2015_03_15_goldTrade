## Clean & format 1982+bis+2013_E.xlsx


[source](http://www.ezv.admin.ch/themen/04096/04101/05233/05672/index.html?lang=en&download=NHzLpZeg7t,lnp6I0NTU042l2Z6ln1ad1IZn4Z2qZpnO2Yuq2Z6gpJCDfYF5gmym162epYbg2c_JjKbNoKSn6A--)


### In excel

1. Duplicate that excel. In the first sheet
2. Delete header 4 first rows and empty 8th row
3. Delete columns:
    * D - O
    * sdaf     
    * columns to keep
    	* 7107.10 - Gold and gold alloys in bulk, bars, powder, etc. -> P -S 
    	* 7108.1200 - Gold, incl. gold plated with platinum, in unwrought forms, for non-monetary purposes (excl. gold in powder form)  -> T - W
        * until 1987: 7107.10 From 1988: 7108.1200 
1. Copy the 4 columns of 7107.10 until 1997 in 7108.1200 -> merged column of **7108.1200 - Gold, incl. gold plated with platinum, in unwrought forms, for non-monetary purposes (excl. gold in powder form) & 7107.10 - Gold and gold alloys in bulk, bars, powder, etc.** 
2. Rename column
3. Save as CSV (a second column will be added to be deleted)
4. Ensure the header is just one row (delete export and import)


### Google refine
1. Character encoding: UTF-8
2. Transpose wide to long [as done here](http://blogs.worldbank.org/opendata/unpivoting-data-excel-open-refine-and-python)
3. save 


## Get 2014 gold data swiss-impex.ch

#### In https://www.swiss-impex.admin.ch
2. Data 'annuel' 2014 until 2014
3. Importation & exportation
4. Type of goods: Gold [in special trade since 2014] & total trade
5. Partners: "Add the whole selection" and remove 'total trade'
6. Options -> key figures -> uncheck %change
7. copy/paste in excel (export to excell doesn't work!)


#### In Excel
1. **remove all "," in excel!**
2. rename columns and delete to get as header

		Year	|Partner	|Import kg	|Import CHF	|Export kg| Export CHF
3. save

##### Google refine		






 
   