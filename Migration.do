* PMA Core Migration Module Data Checking file
**This .do file imports the Migration Repeat into Stata and cleans it

clear matrix
clear
set more off
label drop _all

cd "$datadir" 

*Macros
local CCPX $CCPX
local FQcsv $FQcsv
local FQcsv2 $FQcsv2

local today=c(current_date)
local date=subinstr("`today'", " ", "", .)

*Import the migration csv file and save a dta as is
import delimited "$csvdir/`FQcsv'-residential_history_rpt.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
save `CCPX'_FQ_migration.dta, replace

*If a second version of the form was used, append it to the dataset with the first version
clear
capture import delimited "$csvdir/`FQcsv2'-residential_history_rpt.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
if _rc==0 {
	tempfile tempFQm
	save `tempFQm', replace

	use `CCPX'_FQ_migration.dta, clear
	append using `tempFQm', force
	save, replace
	}
	
use `CCPX'_FQ_migration.dta, clear

/* ---------------------------------------------------------
         SECTION 1: Drop columns
   --------------------------------------------------------- */
drop place_lived_note

/* ---------------------------------------------------------
         SECTION 3: Destring
   --------------------------------------------------------- */
destring age_came, replace

/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */
label define urban_rural_list 1 "urban" 2 "peri_urban" 3 "rural" -99 "-99"

encode urban_rural, gen(urban_ruralV2) lab(urban_rural_list)
order urban_ruralV2, after(urban_rural)
drop urban_rural
rename urban_ruralV2 urban_rural

label define urban_rural_list 1 "Urban" 2 "Peri-urban" 3 "Rural" -99 "No response", replace

/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */
label define o2s_binary_label 0 No 1 Yes

***** Begin split of "reason_came"
* Create padded variable
gen reason_cameV2 = " " + reason_came + " "

* Build binary variables for each choice
gen reason_came_worksearching = 0 if reason_came != ""
replace reason_came_worksearching = 1 if strpos(reason_cameV2, " work_searching ")
label var reason_came_worksearching "For what reason did you move to LOCATION? : Looking for a job"

gen reason_came_workseasonal = 0 if reason_came != ""
replace reason_came_workseasonal = 1 if strpos(reason_cameV2, " work_seasonal ")
label var reason_came_workseasonal "For what reason did you move to LOCATION? : Seasonal work"

gen reason_came_work = 0 if reason_came != ""
replace reason_came_work = 1 if strpos(reason_cameV2, " work ")
label var reason_came_work "For what reason did you move to LOCATION? : Work (non-seasonal)"

gen reason_came_workchange = 0 if reason_came != ""
replace reason_came_workchange = 1 if strpos(reason_cameV2, " work_change ")
label var reason_came_workchange "For what reason did you move to LOCATION? : Want to change jobs"

gen reason_came_conflict = 0 if reason_came != ""
replace reason_came_conflict = 1 if strpos(reason_cameV2, " conflict ")
label var reason_came_conflict "For what reason did you move to LOCATION? : Family or village conflict"

gen reason_came_schoolattend = 0 if reason_came != ""
replace reason_came_schoolattend = 1 if strpos(reason_cameV2, " school_attend ")
label var reason_came_schoolattend "For what reason did you move to LOCATION? : To attend school"

gen reason_came_schooldone = 0 if reason_came != ""
replace reason_came_schooldone = 1 if strpos(reason_cameV2, " school_done ")
label var reason_came_schooldone "For what reason did you move to LOCATION? : Move after completed school"

gen reason_came_postmarriage = 0 if reason_came != ""
replace reason_came_postmarriage = 1 if strpos(reason_cameV2, " post_marriage ")
label var reason_came_postmarriage "For what reason did you move to LOCATION? : Join spouse after marriage"

gen reason_came_cohabitate = 0 if reason_came != ""
replace reason_came_cohabitate = 1 if strpos(reason_cameV2, " cohabitate ")
label var reason_came_cohabitate "For what reason did you move to LOCATION? : Co-reside with boy/girlfriend"

gen reason_came_divorcewidow = 0 if reason_came != ""
replace reason_came_divorcewidow = 1 if strpos(reason_cameV2, " divorce_widow ")
label var reason_came_divorcewidow "For what reason did you move to LOCATION? : Divorce/widowhood"

gen reason_came_healthproblem = 0 if reason_came != ""
replace reason_came_healthproblem = 1 if strpos(reason_cameV2, " health_problem ")
label var reason_came_healthproblem "For what reason did you move to LOCATION? : Hospitalization/health problem"

gen reason_came_healthaccess = 0 if reason_came != ""
replace reason_came_healthaccess = 1 if strpos(reason_cameV2, " health_access ")
label var reason_came_healthaccess "For what reason did you move to LOCATION? : Better access to health service"

gen reason_came_sickrelative = 0 if reason_came != ""
replace reason_came_sickrelative = 1 if strpos(reason_cameV2, " sick_relative ")
label var reason_came_sickrelative "For what reason did you move to LOCATION? : Caring for sick relative"

gen reason_came_joinspousework = 0 if reason_came != ""
replace reason_came_joinspousework = 1 if strpos(reason_cameV2, " join_spouse_work ")
label var reason_came_joinspousework "For what reason did you move to LOCATION? : Followed spouse to job"

gen reason_came_farming = 0 if reason_came != ""
replace reason_came_farming = 1 if strpos(reason_cameV2, " farming ")
label var reason_came_farming "For what reason did you move to LOCATION? : Better land for farming"

gen reason_came_educationkids = 0 if reason_came != ""
replace reason_came_educationkids = 1 if strpos(reason_cameV2, " education_kids ")
label var reason_came_educationkids "For what reason did you move to LOCATION? : Better education for children"

gen reason_came_othersocial = 0 if reason_came != ""
replace reason_came_othersocial = 1 if strpos(reason_cameV2, " other_social ")
label var reason_came_othersocial "For what reason did you move to LOCATION? : Other social reasons"

gen reason_came_other = 0 if reason_came != ""
replace reason_came_other = 1 if strpos(reason_cameV2, " other ")
label var reason_came_other "For what reason did you move to LOCATION? : Other"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order reason_came_worksearching-reason_came_other, after(reason_came)
label values reason_came_worksearching-reason_came_other o2s_binary_label
drop reason_cameV2

/* ---------------------------------------------------------
         SECTION 6: Label variable
   --------------------------------------------------------- */

label var place_lived "What is the name of the place you lived before this place?"
label var country_lived "Is LOCATION located in THIS COUNTRY or in another country?"
label var district_lived "In which LEVEL1 is LOCATION?"
label var urban_rural "Was LOCATION a city, a town, or a rural area?"
label var age_came "How old were you when you moved to LOCATION?"
label var reason_came "For what reason did you move to LOCATION?"

/* ---------------------------------------------------------
         SECTION 8: Additional Cleaning
   --------------------------------------------------------- */
*Reshape the repeat group wide and merge with HHQFQ Combined
rename parent_key metainstanceID
rename key mig_key

capture assert _N>=1 
if _rc==0 {
	split mig_key, gen(key_) parse("/residential_history_rpt")
	drop key_1 
	rename key_2 position
	replace position=subinstr(position, "[", "",.)
	replace position=subinstr(position, "]", "",.)
	destring position, replace

	capture sum position 
	local max_mig = r(max)

	order metainstanceID, first

	unab mig_var : place_lived-setofresidential_history_rpt
	foreach var in `mig_var' {
		local `var'lab : variable label `var'
		}

	reshape wide place_lived-setofresidential_history_rpt, i(metainstanceID) j(position)

	foreach var in `mig_var' {
		forval y = 1/`max_mig' {
			label var `var'`y' "``var'lab'"
			}
		}
	}
save `CCPX'_FQ_Migration_`date'.dta, replace

*Merge
use `CCPX'_FQ_`date'.dta, clear
merge 1:m metainstanceID using `CCPX'_FQ_Migration_`date'.dta, gen(mig_merge)

*Clean variables outside of the repeat group
drop location_lived_note

rename setofresidential_history_rpt* residential_history_rpt*

destring locations_lived, replace

encode locations_lived_check, gen(locations_lived_checkV2) lab(yes_no_list)
order locations_lived_checkV2, after(locations_lived_check)
drop locations_lived_check
rename locations_lived_checkV2 locations_lived_check

label var locations_lived "Please tell me how many locations you have lived in for 6mo or more after age 15"
label var locations_lived_check "Respondent said she has lived in X locations, is that correct?"
label var residential_history_rpt "Residential history group"

save `CCPX'_FQ_`date'.dta, replace

