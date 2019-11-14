* PMA Core Household Questionnaire Data Checking file
**This .do file imports the Household Questionnaire (without roster) into Stata and cleans it

clear matrix
clear
set more off
label drop _all

cd "$datadir" 

*Macros
local CCPX $CCPX
local HHQcsv $HHQcsv
local HHQcsv2 $HHQcsv2

local today=c(current_date)
local date=subinstr("`today'", " ", "", .)

*Import the HQ csv file and save a dta as is
import delimited "$csvdir/`HHQcsv'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
save `CCPX'_HHQ.dta, replace

*If a second version of the form was used, append it to the dataset with the first version
clear
capture import delimited "$csvdir/`HHQcsv2'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
if _rc==0 {
	tempfile tempHHQ
	save `tempHHQ', replace

	use `CCPX'_HHQ.dta, clear
	append using `tempHHQ', force
	save, replace
	}
	
use `CCPX'_HHQ.dta, clear

/* ---------------------------------------------------------
         SECTION 1: Drop columns
   --------------------------------------------------------- */

drop duplicate_warning
drop duplicate_warning_hhmember
drop consent_start
capture drop consent_warning
drop sect_hh_roster
drop error_noheads
drop error_extraheads
drop no_respondent_in_roster
drop multiple_respondent_in_roster
drop sect_hh_characteristics_note
drop lvolivestock_owned_prompt
drop sect_hh_observation_note
drop sect_wash_note
drop thankyou
drop sect_end
drop metalogging

/* ---------------------------------------------------------
         SECTION 2: Rename
   --------------------------------------------------------- */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         SUBSECTION: Rename to original ODK names
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
rename dsystem_date system_date
rename dsystem_date_check system_date_check
rename ea EA
capture rename pssign sign
capture rename pscheckbox checkbox
rename setofhh_rpt hh_rpt
rename num_hh_members num_HH_members
rename asgassets assets
rename asgassets_check assets_check
rename lvo*_owned *_owned
rename hhq_result HHQ_result
rename metainstanceid metainstanceID

/* ---------------------------------------------------------
         SECTION 3: Destring
   --------------------------------------------------------- */

destring structure, replace
destring household, replace
destring *_owned, replace
destring num_HH_members, replace

/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */

label define blank_list 1 "1"
label define hhr_result_list 1 "completed" 2 "not_at_home" 3 "postponed" 4 "refused" 5 "partly_completed" 6 "vacant" 7 "destroyed" 8 "not_found" 9 "absent_extended_period"
label define sanitation_list 1 "flush_sewer" 2 "flush_septic" 3 "flushpit" 4 "flush_elsewhere" 5 "flush_unknown" 6 "vip" 7 "pit_with_slab" 8 "pit_no_slab" 9 "composting" 10 "bucket" 11 "hanging" 12 "other" 13 "bush" -99 "-99"
label define visits_list 1 "1" 2 "2" 3 "3"
label define water_source_list 1 "piped_indoor" 2 "piped_yard" 3 "piped_public" 4 "tubewell" 5 "protected_dug_well" 6 "unprotected_dug_well" 7 "protected_spring" 8 "unprotected_spring" 9 "rainwater" 10 "tanker" 11 "cart" 12 "surface_water" 13 "bottled" 14 "sachet" -99 "-99"
label define yes_no_list 1 "yes" 0 "no"
label define yes_no_nr_list 1 "yes" 0 "no" -99 "-99"

encode water_main_drinking_select, gen(water_main_drinking_selectV2) lab(water_source_list)
order water_main_drinking_selectV2, after(water_main_drinking_select)
drop water_main_drinking_select
rename water_main_drinking_selectV2 water_main_drinking_select

encode sanitation_main, gen(sanitation_mainV2) lab(sanitation_list)
order sanitation_mainV2, after(sanitation_main)
drop sanitation_main
rename sanitation_mainV2 sanitation_main

encode times_visited, gen(times_visitedV2) lab(visits_list)
order times_visitedV2, after(times_visited)
drop times_visited
rename times_visitedV2 times_visited

encode HHQ_result, gen(HHQ_resultV2) lab(hhr_result_list)
order HHQ_resultV2, after(HHQ_result)
drop HHQ_result
rename HHQ_resultV2 HHQ_result


foreach var in your_name_check system_date_check hh_duplicate_check available begin_interview roster_complete {
	encode `var', gen(`var'V2) lab(yes_no_list)
	order `var'V2, after(`var')
	drop `var'
	rename `var'V2 `var'
	}

foreach var in checkbox witness_auto assets_check  {
	encode `var', gen(`var'V2) lab(blank_list)
	order `var'V2, after(`var')
	drop `var'
	rename `var'V2 `var'
	}

encode livestock_owned_ask, gen(livestock_owned_askV2) lab(yes_no_nr_list)
order livestock_owned_askV2, after(livestock_owned_ask)
drop livestock_owned_ask
rename livestock_owned_askV2 livestock_owned_ask


label define blank_list 1 "", replace
label define hhr_result_list 1 "Completed" 2 "No household member at home or no competent respondent at home at time of visit" 3 "Postponed" 4 "Refused" 5 "Partly completed" 6 "Dwelling vacant or address not a dwelling" 7 "Dwelling destroyed" 8 "Dwelling not found" 9 "Entire household absent for extended period", replace
label define sanitation_list 1 "Flush/pour flush toilets connected to: Piped sewer system" 2 "Flush/pour flush toilets connected to: Septic tank" 3 "Flush/pour flush toilets connected to: Pit Latrine" 4 "Flush/pour flush toilets connected to: Elsewhere" 5 "Flush/pour flush toilets connected to: Unknown / Not sure / Do not know" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab  / open pit" 9 "Composting toilet" 10 "Bucket" 11 "Hanging toilet /Hanging latrine" 12 "Other" 13 "No facility / bush / field" -99 "No response", replace
label define visits_list 1 "1st time" 2 "2nd time" 3 "3rd time", replace
label define water_source_list 1 "Piped Water: Piped into dwelling/indoor" 2 "Piped Water: Pipe to yard/plot" 3 "Piped Water: Public tap/standpipe" 4 "Tube well or borehole" 5 "Dug Well: Protected Well" 6 "Dug Well: Unprotected Well" 7 "Water from Spring: Protected Spring" 8 "Water from Spring: Unprotected Spring" 9 "Rainwater" 10 "Tanker Truck" 11 "Cart with Small Tank" 12 "Surface water" 13 "Bottled Water" 14 "Sachet Water" -99 "No response", replace
label define yes_no_list 1 "Yes" 0 "No", replace
label define yes_no_nr_list 1 "Yes" 0 "No" -99 "No response", replace

/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */

label define o2s_binary_label 0 No 1 Yes


***** Begin split of "resubmit_reasons"
* Create padded variable
gen resubmit_reasonsV2 = " " + resubmit_reasons + " "

* Build binary variables for each choice
gen resubmit_reasons_newmembers = 0 if resubmit_reasons != ""
replace resubmit_reasons_newmembers = 1 if strpos(resubmit_reasonsV2, " new_members ")
label var resubmit_reasons_newmembers "CHECK: Why are you resending this : There are new household members on this form"

gen resubmit_reasons_correction = 0 if resubmit_reasons != ""
replace resubmit_reasons_correction = 1 if strpos(resubmit_reasonsV2, " correction ")
label var resubmit_reasons_correction "CHECK: Why are you resending : I am correcting a mistake made on a previous form"

gen resubmit_reasons_dissappeared = 0 if resubmit_reasons != ""
replace resubmit_reasons_dissappeared = 1 if strpos(resubmit_reasonsV2, " dissappeared ")
label var resubmit_reasons_dissappeared "CHECK: Why are  : The previous form disappeared from my phone without being sent"

gen resubmit_reasons_notreceived = 0 if resubmit_reasons != ""
replace resubmit_reasons_notreceived = 1 if strpos(resubmit_reasonsV2, " not_received ")
label var resubmit_reasons_notreceived "CHECK: Why are you resending this fo : I submitted the previous form and my supervisor told me that it was not received"

gen resubmit_reasons_other = 0 if resubmit_reasons != ""
replace resubmit_reasons_other = 1 if strpos(resubmit_reasonsV2, " other ")
label var resubmit_reasons_other "CHECK: Why are you resending this form? : Other reason(s)"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order resubmit_reasons_newmembers-resubmit_reasons_other, after(resubmit_reasons)
label values resubmit_reasons_newmembers-resubmit_reasons_other o2s_binary_label
drop resubmit_reasonsV2

/* ---------------------------------------------------------
         SECTION 6: Label variable
   --------------------------------------------------------- */

label var your_name_check "Is this your name?"
label var name_typed "Enter your name below."
label var system_date "Current date and time."
label var system_date_check "Is this date and time correct?"
label var manual_date "Record the correct date and time."
label var today "Date of interview"
label var EA "Enumeration area"
label var structure "Structure number"
label var household "Household number"
label var hh_duplicate_check "CHECK: Have you already sent a form for this structure and household?"
label var resubmit_reasons "CHECK: Why are you resending this form?"
label var available "Is a member of the household and competent respondent present and available?"
label var begin_interview "May I begin the interview now?"
label var sign "Respondent's signature"
label var checkbox "Checkbox"
label var witness_auto "Interviewer's name"
label var witness_manual "Interviewer's name as witness"
label var hh_rpt "Household member"
label var roster_complete "Is this a complete list of the household members?"
label var assets_check "Check here to acknowledge you considered all options."
label var livestock_owned_ask "Does this household own any livestock, herds, other farm animals, or poultry?"
label var water_main_drinking_select "What is the main source of drinking water for members of your household?"
label var sanitation_main "What is the main toilet facility used by members of your household?"
label var locationlatitude "Latitude"
label var locationlongitude "Longitude"
label var locationaltitude "Altitude"
label var locationaccuracy "Location accuracy"
label var times_visited "How many times have you visited this household?"
label var HHQ_result "Questionnaire Result"
label var start "Start time of interview"
label var end "End time of interview"
label var assets "Does your household have:"
label var floor "Main material of the floor"
label var walls "Main material of the walls"
label var roof "Main material of the roof"
label var survey_language "In what language was this interview conducted?"

/* ---------------------------------------------------------
         SECTION 7: Format Dates
   --------------------------------------------------------- */
**Change date variable of upload from scalar to stata time (SIF)
*Drop the day of the week of the interview and the UST
foreach var in submissiondate system_date manual_date start end {
	gen double `var'SIF=clock(`var', "MDYhms")
	format `var'SIF %tc
	local `var'_lab : variable label `var'
	label var `var'SIF "``var'_lab' SIF"
	order `var'SIF, after(`var')
	} 

gen double todaySIF=date(today, "YMD")
format todaySIF %td
label var todaySIF "Today's date SIF"
order todaySIF, after(today)


/* ---------------------------------------------------------
         SECTION 8: Additional Cleaning
   --------------------------------------------------------- */
rename submissiondate* SubmissionDate*

rename your_name RE
replace RE=name_typed if your_name_check==0 | your_name_check==.
label var RE "RE"

**Check any complete duplicates, duplicates of metainstanceid, and duplicates of structure and household numbers
duplicates report
duplicates report metainstanceID
duplicates tag metainstanceID, gen (dupmeta)

save `CCPX'_HHQ_`date'.dta, replace

