* PMA Core Household Member Data Checking file
**This .do file imports the Household Roster into Stata and cleans it

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
import delimited "$csvdir/`HHQcsv'-hh_rpt.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
save `CCPX'_HHQmember.dta, replace

*If a second version of the form was used, append it to the dataset with the first version
clear
capture import delimited "$csvdir/`HHQcsv2'-hh_rpt.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
if _rc==0 {
	tempfile tempHHQ
	save `tempHHQ', replace

	use `CCPX'_HHQmember.dta, clear
	append using `tempHHQ', force
	save, replace
	}


use `CCPX'_HHQmember.dta, clear

/* ---------------------------------------------------------
         SECTION 1: Drop columns
   --------------------------------------------------------- */
   
drop not_usual_warn
drop eligibility_screen_no
drop eligibility_screen_yes
drop more_hh_members_add
drop more_hh_members_donotadd


/* ---------------------------------------------------------
         SECTION 2: Rename
   --------------------------------------------------------- */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         SUBSECTION: Rename to original ODK names
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

rename nmfirstname_raw firstname_raw
rename nmfirstname firstname
rename nmrespondent_match respondent_match
rename mbrelationship relationship
rename mbhead_check head_check
rename mbhead_name head_name
rename mbgender gender
rename mbage age
rename msmarital_status marital_status
rename msusually_live usually_live
rename mslast_night last_night
rename frs_form_name FRS_form_name
rename ea_transfer EA_transfer
rename gps_transfer GPS_transfer

/* ---------------------------------------------------------
         SECTION 3: Destring
   --------------------------------------------------------- */
   
destring age, replace
destring respondent_match, replace
destring eligible, replace

/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */

label define gender_list 1 "male" 2 "female"
label define marital_status_list 1 "currently_married" 2 "currently_living_with_partner" 3 "divorced" 4 "widow" 5 "never_married" -99 "-99"
label define relationship_list 1 "head" 2 "spouse" 3 "child" 4 "child_in_law" 5 "grandchild" 6 "parent" 7 "parent_in_law" 8 "sibling" 9 "help" 96 "other" -88 "-88" -99 "-99"
label define yes_no_list 1 "yes" 0 "no"
label define yes_no_nr_list 1 "yes" 0 "no" -99 "-99"

encode relationship, gen(relationshipV2) lab(relationship_list)
order relationshipV2, after(relationship)
drop relationship
rename relationshipV2 relationship

encode gender, gen(genderV2) lab(gender_list)
order genderV2, after(gender)
drop gender
rename genderV2 gender

encode marital_status, gen(marital_statusV2) lab(marital_status_list)
order marital_statusV2, after(marital_status)
drop marital_status
rename marital_statusV2 marital_status

encode more_hh_members, gen(more_hh_membersV2) lab(yes_no_list)
order more_hh_membersV2, after(more_hh_members)
drop more_hh_members
rename more_hh_membersV2 more_hh_members

foreach var in usually_live last_night  {
	encode `var', gen(`var'V2) lab(yes_no_nr_list)
	order `var'V2, after(`var')
	drop `var'
	rename `var'V2 `var'
	}

label define yes_no_list 1 "Yes" 0 "No", replace
label define yes_no_nr_list 1 "Yes" 0 "No" -99 "No response", replace
label define relationship_list 1 "Head" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son/Daughter-in-law" 5 "Grandchild" 6 "Parent" 7 "Parent in law" 8 "Brother/Sister" 9 "House help" 96 "Other" -88 "Do not know" -99 "No response", replace
label define marital_status_list 1 "Married" 2 "Living with a partner" 3 "Divorced / separated" 4 "Widow / widower" 5 "Never married" -99 "No response", replace
label define gender_list 1 "Male" 2 "Female", replace

/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */


/* ---------------------------------------------------------
         SECTION 6: Label variable
   --------------------------------------------------------- */

label var firstname "Name of HH Member"
label var respondent_match "Is this person the respondent?"
label var relationship "What is NAME's relationship to the head of household?"
label var gender "Is NAME male or female?"
label var age "How old was NAME at their last birthday?"
label var marital_status "What is NAME's current marital status?"
label var usually_live "Does NAME usually live here?"
label var last_night "Did NAME stay here last night?"
label var eligible "Eligible for Female Questionnaire"
label var more_hh_members "Are there any other members of your household/people who slept in the house?"

/* ---------------------------------------------------------
         SECTION 7: Format Dates
   --------------------------------------------------------- */
   
/* ---------------------------------------------------------
         SECTION 8: Additional Cleaning
   --------------------------------------------------------- */
*Encode calculated variables
label val respondent_match yes_no_list
label val eligible yes_no_list

*Check for observations that are all duplicates
duplicates report
duplicates drop

*Prepare for merge
rename parent_key metainstanceID
rename key member_number 
duplicates drop member_number, force

rename link_transfer link
drop *_transfer*
rename link link_transfer
drop setofhh_rpt
drop firstname_raw

save `CCPX'_HHQmember_`date'.dta, replace

