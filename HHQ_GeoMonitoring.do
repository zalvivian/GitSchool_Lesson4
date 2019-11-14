** GPS checks for HHQ survey 
** Authors Ann Rogers - Sally Ann Safi - Beth Larson - Julien Nobili
** Requirements: None
** version 2.0  (August 2019)

**********************Set directory**************************************

local datadir 		$datadir
local dofiles       $dofiledir
local csv_results   $datadir
local Geo_ID 		$Geo_ID
local CCPX			$CCPX
 

*****************Creation of EA Mean Centers from HHQ file*************************

* Use cleaned HHQ dataset from PARENT
clear
use "`datadir'/`CCPX'_HHQ_$date.dta" 

destring locationlatitude, replace
destring locationlongitude, replace
destring locationaccuracy, replace

preserve
* Generate XY average per EA (EA centroids creation)
bysort EA: egen centro_latt=mean(locationlatitude) if locationlatitude!=0
bysort EA: egen centro_long=mean(locationlongitude) if locationlongitude!=0

* Save one observation per EA with average geo-coordinates
egen tag=tag(EA)
keep if tag==1
keep EA centro_latt centro_long

* Save as temp_HHQ_centro
tempfile temp_HHQ_centroids
save `temp_HHQ_centroids.dta', replace

restore

**********************Preparation of the HHQ file for review ****************
preserve 

* Keep useful vars
keep RE `Geo_ID' EA locationlatitude locationlongitude locationaccuracy metainstanceID

******* Merge: temp_HHQ_centroids + HHQ file**************

merge m:1 EA using `temp_HHQ_centroids.dta', gen(centroid_merge)
drop centroid_merge

************* Gen distances vars (distance from HH to Centroid) ***********

gen distance_2_cent=(((locationlatitude-centro_latt)^2+(locationlongitude-centro_long)^2)^(1/2))*111295

*********** Generate mean and standard-dev using var distance_cent *************
bysort EA: egen mean_distance_cent=mean(distance_2_cent)
bysort EA: egen sd_distance_cent=sd(distance_2_cent)

************************ Genarate Issues vars **********************************
gen missing_coordinates=1 if  locationlatitude==. | locationlongitude==. 
gen poor_accuracy=1 if locationaccuracy>6 & !missing(locationaccuracy)
gen EA_size_issue=1 if mean_distance_cent<sd_distance_cent
gen HH_suspect_location=1 if ((distance_2_cent-mean_distance_cent)/sd_distance_cent)>=2 & missing_coordinates!=1

********* Keep useful vars and save output files (for GIS monitoring) **************
keep RE `Geo_ID' EA locationlatitude locationlongitude locationaccuracy metainstanceID missing_coordinates poor_accuracy EA_size_issue HH_suspect_location
save `CCPX'_HHQ_GISFullcheck_$date.dta, replace 

export delimited using `CCPX'_HHQ_GISFullcheck_$date.csv, replace

************* Output spreadsheet (errors by RE) Errors.xls *********************
collapse(count) missing_coordinates poor_accuracy EA_size_issue HH_suspect_location, by(RE)
export excel RE missing_coordinates poor_accuracy EA_size_issue HH_suspect_location using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(GPS_check_by_RE) sheetreplace

********************************* Voilà! ****************************************
restore 


