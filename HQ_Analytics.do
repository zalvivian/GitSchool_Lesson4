*PMA HQ Analytics
**This file generates the Analytics report for the Household Questionnaire
**Analytics measures the active time spent per screen in an ODK form

*****************************************************************************************
* SET MACROS: UPDATE THIS SECTION FOR EACH PHASE OF DATA COLLECTION
*****************************************************************************************
clear

*Country-Phase macros
local country KE
local phase 1
local CCPX KEP1

*Geo ID variables
local Geo_ID level1 level2 level3 level4

*Where the ODK files are saved for this survey
global odkdir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1\Data"

*Change odk file names here
global HQodk KEP1-Household-Questionnaire-v3-jef

*Where the Analytics .csv files are saved
global analyticsdir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1\Data"

*Change analytic csv file names here
global HQanalytics1 KEP1_Household_Questionnaire_v3_Analytics.csv

*If there is 2nd version of analytics, use the older version below and add csv names
global HQanalytics2 

*Where the outputs from this .do file should be saved
global datadir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1"

*Datadate of the ECRecode dataset
global datadate 14Oct2019

**For the following macros the section name can be whatever you want it to be
**The firstvar is usually the note that begins the section in the ODK
**The lastvar is usually the note that begins the following section in the ODK

*Section 1 macros
local sec1_name roster
local sec1_firstvar sect_hh_roster
local sec1_lastvar sect_hh_characteristics_note

*Section 2 macros
local sec2_name characteristics
local sec2_firstvar sect_hh_characteristics_note
local sec2_lastvar sect_hh_observation_note

*Section 3 macros
local sec3_name observations
local sec3_firstvar sect_hh_observation_note
local sec3_lastvar sect_wash_note

*Section 4 macros
local sec4_name WASH
local sec4_firstvar sect_wash_note
local sec4_lastvar sect_end

*Number of sections in the survey
local n_sections 4

*Should there be more sections, copy the format of the other section macros and add them, and update the n_sections macro

*****************************************************************************************
 			******* Stop Updating Macros Here *******
*****************************************************************************************
cd "$datadir"

local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

********************************************************************************
* First Step is to Generate a List of Separate Screens in ODK by var name
********************************************************************************
import excel "$odkdir/$HQodk", sheet("survey") firstrow

*drop completely missing vars
foreach var of varlist _all {
	capture assert mi(`var')
		if !_rc {
		drop `var'
		}
	}

*extract all questions
gen type_clean="select_one" if strpos(type, "select_one")>0
replace type_clean="select_multiple" if strpos(type, "select_multiple")>0
replace type_clean=type if (type=="date"|type=="dateTime"|type=="decimal"|type=="geopoint"| ///
type=="image"|type=="integer"|type=="text")


***************This code deal with screens, not questions
*For ODK groups where multiple questions are displayed on the same screen at the same time, keep only one variable per screen/group
gen screen="select_one" if strpos(type, "select_one")>0
replace screen="select_multiple" if strpos(type, "select_multiple")>0
replace screen=type if (type=="date"|type=="dateTime"|type=="decimal"|type=="geopoint"| ///
type=="image"|type=="integer"|type=="text"|type=="note")

*Generage tag for those within the group
gen tempvar=1 if type=="begin group" & appearance=="field-list"
replace tempvar=2 if type=="end group"
carryforward tempvar, gen(fieldlist_tag)
drop tempvar
order fieldlist_tag, after(type)
order appearance, after(type)

*For the series of questions in the group, drop begin, end, note and check
drop if ((type=="begin group"|strpos(type,"note")>0|type=="calculate") & fieldlist_tag==1)
drop if ((type=="select_one blank_list") & fieldlist_tag==1)

*Only keep one for the entire group
recode fieldlist_tag 2=.
gen fieldlist_duptag=1 if fieldlist_tag==1 & fieldlist_tag[_n-1]==.
keep if ((fieldlist_duptag==1 & fieldlist_tag==1)|(fieldlist_duptag==.&fieldlist_tag==.))

drop fieldlist_duptag screen
drop if type=="calculate"
drop if type=="start"|type=="end"|type=="deviceid"|type=="simserial"|type=="phonenumber" ///
	|type=="hidden string"|type=="hidden geopoint"|type=="hidden"|type=="hidden int" | type=="hidden binary"

drop if fieldlist_tag==. & (type=="end group" | type=="begin group")
drop fieldlist_tag

***************
*Make into lower cases
replace name=lower(name)

*Only keep variable names and make the list of variable names into a macro
keep name
sxpose, clear firstnames

*Drop the space in the original ODK, otherwise it'll generate a random variable
capture drop _var*

*For modules drop the repeat prompt since it's not in analytics
capture drop *_rpt

*Generate a macro that holds all ODK screen variables
local all_hhvar 
foreach var of varlist _all {
	local all_hhvar "`all_hhvar' `var'"
	}

********************************************************************************
*                            HHQ Analytics 
********************************************************************************

*open HHQ dataset and keep necessary information to be added to analytics
use "$datadir/`CCPX'_Combined_ECRecode_$datadate.dta", clear
egen HHtag=tag(metainstanceID)
keep if HHtag==1
keep metainstanceID RE structure household num_HH_members assets water_main_drinking_select sanitation_main HHQ_result
tempfile combined
save `combined', replace

*merge info from HQ data and analytic data
clear
capture noisily insheet using "$analyticsdir/$HQanalytics1", clear

save "`CCPX'_Household_Questionnaire_Analytics_$date.dta", replace	

capture noisily insheet using "$analyticsdir/$HQanalytics2", comma case clear
if _rc==0 {
	tempfile HQana
	save `HQana', replace
	
	use "`CCPX'_Household_Questionnaire_Analytics_$date.dta", clear
	append using `HQana', force
	save "`CCPX'_Household_Questionnaire_Analytics_$date.dta", replace
	}

use "`CCPX'_Household_Questionnaire_Analytics_$date.dta", clear
	
*Rename/recode vars in analytics file to match with ECRecode
rename dir_uuid metainstanceID
replace metainstanceID=subinstr(metainstanceID,"uuid","uuid:",.)
gen RE=your_name
tostring RE,replace
tostring name_typed, replace
replace RE=name_typed if missing(your_name)
save "`CCPX'_Household_Questionnaire_Analytics_$date.dta", replace

**Merge analytics dataset and partial core dataset
merge 1:1 metainstanceID using `combined', nogen force

*Name cleaning of csv
order RE, after(your_name)
drop your_name name_typed
capture rename ea EA
sort RE

if "`country'"=="RJ" | "`country'"=="Rajasthan" {
	replace RE="re"+RE if substr(RE,1,2)=="10"
	}

egen GeoID_SH=concat(`Geo_ID' EA structure household), punct(-)
egen GeoID=concat(`Geo_ID' EA), punct(-)
		
*Time by section
order *_t, after(HHQ_result)
order *_b, after(hhq_result_t)
order *_v, after(hhq_result_b)
order *_c, after(hhq_result_v)
order *_d, after(hhq_result_c)


*Create time measuring active and short break time
rename *_t *_a
foreach var in `all_hhvar' {
	egen `var'_t=rowtotal(`var'_a `var'_b)
	}
order *_t, after(hhq_result_d)

*Section time calculations
forval x = 1/`n_sections' {
	capture drop HQ`sec`x'_name'_time
	egen HQ`sec`x'_name'_time=rowtotal(`sec`x'_firstvar'_t-`sec`x'_lastvar'_t)
	replace HQ`sec`x'_name'_time=(HQ`sec`x'_name'_time-`sec`x'_lastvar'_t)/60/1000
	local section_time "`section_time' HQ`sec`x'_name'_time"
	}	

*Flag those with total active time <10min
gen HQinterview=resumed+short_break
gen HQinterview_min=(resumed+short_break)/1000/60
gen HQtime_flag=1 if HQinterview_min<10
format HQinterview_min %12.2f


****Generate interview speed in v8
foreach var in `all_hhvar' {
	capture gen `var'_u=.
	capture replace `var'_u=1 if `var'_v!=.
	}

order *_u, after(hhq_result_t)

egen unique_visit_total=rowtotal(your_name_check_u - hhq_result_u)
drop your_name_check_u-hhq_result_u

*generate macro names for _t _v _c _d
local all_hhvar_t
foreach var in `all_hhvar' {
	local all_hhvar_t "`all_hhvar_t' `var'_t"
	}

local all_hhvar_v
foreach var in `all_hhvar' {
	local all_hhvar_v "`all_hhvar_v' `var'_v"
	}

local all_hhvar_c
foreach var in `all_hhvar' {
	local all_hhvar_c "`all_hhvar_c' `var'_c"
	}

local all_hhvar_d
foreach var in `all_hhvar' {
	local all_hhvar_d "`all_hhvar_d' `var'_d"
	}

**generate a variable speed=sum(each question time)/unique screen. unit is seconds per screen
egen HQ_t_total=rowtotal(`all_hhvar_t')
gen HQspeed_second=(HQ_t_total/unique_visit_total)/1000


****************************************************************Analysis Section

*export histogram to show interview time distribution
*generate statistics for overall time distribution
preserve
capture graph drop first
drop if HQinterview_min>10000
drop if HQinterview_min==0
sum HQinterview_min, detail
return list
histogram HQinterview_min if HHQ_result==1, width(10)  start(0) percent addlabels title("`CCPX' HHQ Completed Interview Time Distribution $date") ///
   xtitle("Interview Time in Minute") ytitle("Percent Among All Completed Forms") xtick(0(10)120) bcolor(blue) ///
   xscale(range(0 (10) 60)) ///
   text(40 70 "N=`r(N)'", placement(se)) ///
   text(36 70 "Minimum=`r(min)'", placement(se)) ///
   text(32 70 "Median=`r(p50)'", placement(se)) ///
   text(28 70 "Max=`r(max)'", placement(se)) ///
   text(24 70 "SD=`r(sd)'", placement(se)) name(first)
capture graph export "HHQ_interview_time_distribution_$date.png", replace
restore

save "`CCPX'_Household_Questionnaire_Analytics_$date.dta", replace

***Summary of HQ interview
	preserve
	keep if HQinterview_min<10
	drop if HQinterview_min<1
	keep if HHQ_result==1

capture noisily export excel RE metainstanceID GeoID_SH num_HH_members HQinterview_min HQspeed_second ///
	`section_time' using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(HQoverview<10min) replace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO COMPLETED HOUSEHOLD INTERVIEWS LESS OR EQUAL TO 10 MINUTES"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(HQoverview<10min) replace
	restore
	}
	
	
***Specific questions within HQ
*asset question tab
preserve
keep if HHQ_result==1
replace assets_t=assets_t/1000
keep if assets_t<=10 & assets_t>0

capture noisily export excel RE metainstanceID GeoID_SH assets assets_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(HQasset<=10s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO ASSET QUESTION LESS THAN 10 SECONDS"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(HQasset<=10s) sheetreplace
	restore
	}

*WASH question series tab
egen WASH_series_t=rowtotal(water_main_drinking_select_t sanitation_main_t)
replace WASH_series_t=WASH_series_t/1000

preserve
keep if HHQ_result==1
keep if WASH_series_t<=5 & WASH_series_t>0

capture noisily export excel RE metainstanceID GeoID_SH water_main_drinking_select sanitation_main WASH_series_t  ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(HQWASH<=5s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO WASH SECTION LESS THAN 5 SECONDS"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(HQWASH<=5s) sheetreplace
	restore
	}


*generate flag for short questions
gen assets_time_flag=1 if assets_t<=10 & HHQ_result==1
gen WASH_time_flag=1 if WASH_series_t<=5 & HHQ_result==1

gen HH_key_time_flag=1 if assets_time_flag==1 | WASH_time_flag==1 
   
***Breakdown by each RE, include time summary, CC, screen visit, rs
***Age heaping issue
preserve
keep if HHQ_result==1

collapse (count) HHQ_completed=HHQ_result (min) HQinterview_minimum=HQinterview_min ///
	(p50) HQinterview_median=HQinterview_min (max) HQinterview_maximum=HQinterview_min ///
	(mean) mean_HQinterview_speed=HQspeed_second ///
	(count) num_interview_less_10min=HQtime_flag ///
	(count) num_short_key_question=HH_key_time_flag ///
	(sum) age_change=rs, by(RE)
	
label var HHQ_completed "Total HH Forms Completed"
label var HQinterview_minimum "Minimum HQ time in minutes"
label var HQinterview_median "Median HQ time in minutes"
label var HQinterview_maximum "Maximum HQ time in minutes"
label var mean_HQinterview_speed "Average seconds per ODK Screen"
label var num_interview_less_10min "Number of HQ interviews under 10 min"
label var num_short_key_question "Number of HQ interviews with short key questions"
label var age_change "Number of age changes in HQ forms"

capture noisily export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(varlabels) sh(HQbyRE) sheetmodify
restore

save "`CCPX'_Household_Questionnaire_Analytics_$date.dta", replace


