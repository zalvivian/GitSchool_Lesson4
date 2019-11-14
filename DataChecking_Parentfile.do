/****PMA Data Quality Checks****

**First do file in series
This do file is designed to clean and check data.  Information from Briefcase will need to be downloaded and exported as csv.
 The do file will then (by country):

Step 1
a. Append all different versions of the Household Questionnaire into one version and destrings variables as appropriate, codes, and labels each questionnaire
b. Append all different versions of the Household Roster into one version and destrings variables as appropriate, codes, and labels each questionnaire
c. Append all different versions of the Female Questionnaire into one version and destrings variables as appropriate, codes, and labels each questionnaire

*All duplicates are tagged and dropped if they are complete duplicates

Step 2
a. Merge the Household Questionnaire, the Household Roster, and the Female Questionnaire into one file
*Also identifies any female questionnaires that exist but do not merge with a household form and all
*female quesitonnaires that are identified by an HHRoster but that do not have a FQ

Step 3
Run checks on the dataset, checking for data quality issues by RE/EA
**********************************************************************************/

clear matrix
clear
set more off
set maxvar 30000

*******************************************************************************
* SET MACROS: UPDATE THIS SECTION FOR EACH COUNTRY/PHASE
*******************************************************************************
*BEFORE USE THE FOLLOWING NEED TO BE UPDATED:
*Country/Round/Abbreviations
global Country KE	 
global Phase Phase1
global phase 1
global CCPX KEP1

*Year of the Survey
local SurveyYear 2018 
local SYShort 18 

*First and last years asked about in the contraceptive calendar
global year1 2017
global year3 2019

******CSV FILE NAMES ****
*HHQ CSV File name 
global HHQcsv KEP1_Household_Questionnaire_v3
*FQ CSV File name
global FQcsv KEP1_Female_Questionnaire_v3

***If the REs used a second version of the form, update these 
*If they did not use a second version, DONT UPDATE 
global HHQcsv2 
global FQcsv2 

**Module .do file names
***If modules included besides standard core mini-modules, list their names here
***If more modules included than listed in parentfile, add a macro here and add code 
*	at end of the Parentfile to run the new .do file
local module1
local module2
local module3

**** GEOGRAPHIC IDENTIFIERS ****
global GeoID "level1 level2 level3 level4 EA"

*Geographic Identifier lower than EA to household
global GeoID_SH "structure household"

*Rename level1 variable to the geographic highest level, level2 second level
*done in the final data cleaning before dropping other geographic identifiers
global level1name county
global level2name district
global level3name zone
global level4name location

*Number of households selected per EA
global EAtake=35

**** DIRECTORIES****

**Global directory for the dropbox where the csv files are originally stored
global csvdir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1"

**Create a global data directory - NEVER DROPBOX
global datadir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1"

**Create a global do file directory
**Should be your GitKraken working directory for the HHQFQ_Cleaning-Monitoring Repository
global dofiledir "C:\Users\annro\PMA\GitKraken\PMA-DM\HHQFQ_Cleaning-Monitoring"

*******************************************************************************************
 			******* Stop Updating Macros Here *******
******************************************************************************************* 			
*Locals (Dont need to Update)
local Country "$Country"
local Phase "$Phase"
local CCPX "$CCPX"

/*Define locals for dates.  The current date will automatically update to the day you are running the do
file and save a version with that day's date*/
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

*******************************************************************************************
 			******* Stop Updating Macros Here *******
******************************************************************************************* 			
cd "$datadir"

**The following commands should be run after the first time you run the data. These commands
*archive all the old versions of the datasets so that data is not deleted and if it somehow is,
*we will have backups of all old datasets.  The shell command accesses the terminal in the background 
*(outside of Stata) but only works for Mac.  It is not necessary to use shell when using Windows but the commands are different
*The command zipfile should work for both Mac and Windows, however shell command only works for Mac.  
*The following commands will zip old datasets and then remove them so that only the newest version is available
*Make sure you are in the directory where you will save the data


/* Zip all of the old versions of the datasets and the excel spreadsheets.  
*Replaces the archive, does not save into it so create a new archive every date you run the file
capture zipfile `CCPX'*, saving (Archived_Data/ArchivedHHQFQData_$date.zip, replace)

capture shell erase `CCPX'*
*/
**Start log
capture log close
log using `CCPX'_DataCleaningQuality_$date.log, replace

*********************************************************************************************************
								******* Start the cleaning *******
*********************************************************************************************************			

*Step 1.a.  Running the following do-file command imports all of the versions of the forms
*tags duplicates, renames variables, labels, encodes and formats the non-country/phase specific variables

**Dataset is named `CCPX'_HHQ_$date.dta
run "$dofiledir/HHQ_DataChecking.do"

duplicates drop metainstanceID, force
save, replace

*********************************************************************************************************
* Step 1.b. Household Roster Information - Repeats the same steps for the Household Roster 

** Generates data file `CCPX'_HHQmember_$date.dta

run "$dofiledir/HHQMember_DataChecking.do"

*********************************************************************************************************
**Merges the household and the household roster together
use `CCPX'_HHQ_$date.dta
merge 1:m metainstanceID using `CCPX'_HHQmember_$date, gen (HHmemb)
save `CCPX'_HHQCombined_$date, replace

*********************************************************************************************************
******************************HOUSEHOLD FORM CLEANING SECTION********************************************
*********************************************************************************************************
******After you initially combine the household and household memeber, you will need to correct duplicate submissions.
*  You will correct those errors here and in the section below so that the next time you run the files, the dataset will
* be cleaned and only errors that remain unresolved are generated.  

**Write your corrections into the do file named "/Whatever/your/path/name/is/CCP#_CleaningByREHHQ.do

run "$dofiledir/CleaningByRE_HHQ.do"
capture drop dupHHtag
egen GeoID=concat($GeoID), punc(-)
egen GeoID_SH=concat($GeoID structure household), punc(-)

save, replace

*********************************************************************************************************
* Step 1.c. Female Questionnaire Information - Repeats the same steps for the Female Questionnaire 

** Generates data file `CCPX'_FQ_$date.dta

run "$dofiledir/FQ_DataChecking.do"
egen FQGeoID=concat($GeoID), punc(-)
egen FQGeoID_SH=concat($GeoID structure household), punc(-)
save, replace

*Run Migration .do file if mini-module is included
capture confirm var locations_lived
if _rc==0 {
	run "$dofiledir/Migration.do"
	}

*This exports a list of female forms that are duplicated.  Use this to track if any REs seem to be having trouble uploading forms
*dont need to make changes based on this list other than dropping exact duplicates and making sure REs are being patient and not hitting send
*multiple times

preserve
keep if dupFQ!=0
sort metainstanceName

capture noisily export excel metainstanceID RE FQGeoID_SH firstname FQ_age metainstanceName using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DuplicateFemale) replace
if _rc!=198 {
	restore
	}
else { 
	set obs 1
	gen x="NO DUPLICATE FEMALE FORMS"
	export excel x using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DuplicateFemale) replace
	restore
	}
	
duplicates drop metainstanceID, force
save, replace

*********************************************************************************************************
******************************FEMALE FORM CLEANING SECTION***********************************************
*********************************************************************************************************
******After running the dataset each time, the excel file will generate a list of errors.  You will correct those errors
*here and in the section below so that the next time you run the files, the dataset will be cleaned and only errors that remain
*unfinished are generated.  *This is where you will clean the female forms for duplicates 
*If you find multiple female forms submitted for the same person, or if the names do not exactly match, 
*you will correct those errors here.  


**Write your corrections into the do file named "/Whatever/your/path/name/is/`CCRX'_CleaningByRE_FEMALE.do

run "$dofiledir/CleaningByRE_FEMALE.do"

*********************************************************************************************************
							******* Step 2: Merge the Datasets *******
*********************************************************************************************************	
*Prepare FQ data for the merge by renaming variables that have the same name in both datasets
clear

use `CCPX'_FQ_$date.dta

foreach var of varlist SubmissionDate times_visited system_date manual_date $GeoID structure household ///
		start startSIF end endSIF today todaySIF acquainted-firstname marital_status locationlatitude-locationaccuracy survey_language {
	rename `var' FQ`var'
	}

duplicates list metainstanceName RE 
duplicates drop metainstanceID, force

duplicates report RE metainstanceName
sort RE metainstanceName

rename FQEA EA
replace EA=unlinkedEA if unlinked=="1"


***Check for duplicate links in dataset, since link is the variable used to merge the datasets
drop duplink
duplicates tag link, gen(duplink)
		
preserve
keep if duplink!=0
capture noisily export excel metainstanceID RE FQGeoID FQstructure FQhousehold metainstanceName ///
	link FQfirstname FQ_age FQSubmissionDate FRS_result FQstart FQend unlinkedEA  using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(Duplicate_Link_in_FQ) sheetreplace
if _rc!=198{
	restore
	}
if _rc==198 { 
	clear
	set obs 1
	gen x="NO DUPLICATE LINK ID IN FRQ DATASET"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(Duplicate_Link_in_FQ) sheetreplace
	restore
	} 		
		
rename metainstanceName FRS_form_name
rename metainstanceID FQmetainstanceID
rename available FQavailable
rename key FQKEY

**This lists remaining duplicate female form links that have not already been cleaned  
*You cannot merge with duplicate female forms
*Must update the CleaningByRE_FEMALE .do file above or drop duplicates
*To merge, must drop all remaining by duplicates

*BUT BEFORE FINAL CLEANING YOU MUST IDENTIFY WHICH OF THE FEMALE FORMS IS THE CORRECT ONE!!!!
gen linktag=1 if link=="" & unlinked=="1"
gen linkn=_n if linktag==1
tostring linkn, replace
replace link=linkn if linktag==1

duplicates drop link, force
save, replace


******************* Merge in Female Questionnaire ********************************

use `CCPX'_HHQCombined_$date

**Above code drops duplicate link from FQ but also need to make sure that there are no duplicates in the household
*Identify any duplicate links in the household.  Make sure the households are also not duplicated
* and drop any remaining duplicated female and household forms before merging
*Write the instances to drop in the CleaningByRE files

duplicates tag link_transfer if link_transfer!="", gen(duplink)
tab duplink

preserve
keep if duplink!=0 & duplink!=.
sort FRS_form_name
capture noisily export excel metainstanceID member_number RE GeoID_SH names FRS_form_name link_transfer using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(Duplicate_Link_in_Household) sheetreplace
if _rc!=198{
	restore
	}
else {
	clear
	set obs 1
	gen x="NO DUPLICATE LINKS IN HOUSEHOLD"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(Duplicate_Link_in_Household) sheetreplace
	restore
	}

save, replace

preserve
keep if eligible==1
rename link_transfer link
merge m:1 link using `CCPX'_FQ_$date.dta, gen(FQresp)
tempfile FRStemp
save `FRStemp', replace

restore 
drop if eligible==1
append using `FRStemp'
sort metainstanceID member_number
egen metatag=tag(metainstanceID)

replace link="" if linktag==1
drop linktag
save `CCPX'_Combined_$date.dta, replace

*********************************************************************************************************
			*******************Step 3: Clean and Check Merged Data********************
*********************************************************************************************************

**Now you will clean the household file of duplicate households or misnumbered houses.  Save these changes in this do file
**Use cleaning file to drop problems that have been cleaned already (update this file as problems are resolved)
capture drop dupHHtag

**Complete duplicates have already been exported out.  Those that have been resolved already will be cleaned using the 
*previous do file.  If the observations have not been cleaned yet, the data will be exported out below

*This information exports out variables that have duplicate structures and households from forms submitted multiple times
**Establish which form is correct (check based on visit number, submission date, start date and end date and work with 
*supervisor and RE to identify which form is correct and which should be deleted

preserve
keep if metatag!=0
duplicates tag GeoID_SH, gen(dupHHtag)

keep if dupHHtag!=0 
sort GeoID_SH RE hh_duplicate_check

capture noisily export excel metainstanceID RE GeoID_SH names times_visited hh_duplicate_check resubmit_reasons HHQ_result system_date end SubmissionDate using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DuplicateEAStructureHH) sheetreplace
if _rc!=198{
	restore
	}
else {
	clear
	set obs 1
	gen x="NO DUPLICATE GeoID"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DuplicateEAStructureHH) sheetreplace
	restore
	}

save, replace


**This line of code identifies households and structures that have the same number but in which there are more than one group of people
*Identify if the people are actually one household and the RE created more than one form OR if they are two different households
*and the RE accidentally labeled them with the same number
*Export out one observation per household/name combination for each household that has more than one group of people

preserve
keep if metatag==1
egen HHtag=tag(RE EA GeoID_SH names)

*Checking to see if there are duplicate households and structure that do NOT have the same people listed
*Tags each unique RE EA structure household and name combination

*Totals the number of groups in a household (should only ever be 1)
bysort RE EA GeoID_SH: egen totalHHgroups=total(HHtag)

keep if HHtag==1 & totalHHgroups>1 & metatag==1

capture noisily export excel metainstanceID RE GeoID_SH names hh_duplicate_check using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DuplicateHH_DifferentNames) sheetreplace
if _rc!=198 {
	restore
	}
else {
	clear 
	set obs 1
	gen x="NO DUPLICATE HOUSEHOLDS WITH DIFFERENT NAMES"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DuplicateHH_DifferentNames) sheetreplace
	restore
	}

/*IF THERE ARE ANY FEMALE FORMS THAT DO NOT MERGE or eligible females that do not have
a form merged to them, these will be flagged and exported for followup */

gen error=1 if FQresp==2
replace error=1 if FQresp==1 & eligible==1
save, replace
preserve
keep if error==1
gsort FQresp -unlinked RE

capture noisily  export excel RE metainstanceID GeoID_SH link FRS_form_name  firstname ///
FQmetainstanceID FQfirstname unlinked SubmissionDate FQSubmissionDate using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FRQmergeerror) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO FEMALE QUESTIONNAIRE MERGE ERRORS"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FRQmergeerror) sheetreplace
	restore
	}

/* This line of code will identify if there are duplicate observations in the household.  Sometimes the entire
roster duplicates itself.  This will check for duplicate name, age, and relationships in the household*/

duplicates tag metainstanceID firstname age relationship if metainstanceID!="", gen(HHmemberdup)
preserve
drop if FQresp==2 
keep if HHmemberdup!=0
sort RE
capture noisily export excel RE metainstanceID member_number GeoID_SH firstname age relationship  using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DupHHmember) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="No duplicated records of household members"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DupHHmember) sheetreplace
	restore
	}		

**Flag forms where the number of household members listed in the dataset is not equal to the number calculated by ODK
gen numberpeopletag=1 if key!=""
bysort metainstanceID: egen numberpeoplelisted=total(numberpeopletag)

drop numberpeopletag
gen numberpeopletag =1 if numberpeoplelisted!=num_HH_members
save, replace

preserve
keep if numberpeopletag==1 & metatag==1 & (HHQ_result==1 | HHQ_result==5)
sort RE
capture noisily export excel metainstanceID RE GeoID_SH names numberpeoplelisted num_HH_members /// 
		using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(Number_HH_member)
if _rc!=198{
	restore
	}
if _rc==198 { 
	clear
	set obs 1
	gen x="NUMBER OF HOUSEHOLD MEMBERS IN ODK AND IN DATASET IS CONSISTENT IN ALL FORMS"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(Number_HH_member) sheetreplace
	restore
	} 
	
**Check for short HHQ and FQ interviews
gen totalint=minutes(endSIF-startSIF)
gen FQtotalint=minutes(FQendSIF-FQstartSIF)
save, replace

preserve 
keep if metatag==1
keep if HHQ_result==1
drop if totalint<0
keep if totalint<=10
sort RE
capture noisily export excel RE metainstanceID GeoID_SH names totalint assets num_HH_members water_main_drinking_select sanitation_main using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(HQInterview10min) 
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO COMPLETE HOUSEHOLD INTERVIEWS LESS THAN 10 MINUTES"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(HQInterview10min) 
	restore
	}

preserve
keep if FRS_result==1 & HHQ_result==1
drop if FQtotalint<0
keep if FQtotalint<=10
sort RE

capture noisily export excel RE FQmetainstanceID FQGeoID_SH FRS_form_name FQtotalint FQ_age FQmarital_status current_user using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FQInterview10min) 
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO COMPLETE FEMALE INTERVIEWS LESS THAN 10 MINUTES"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FQInterview10min) 
	restore
	}
	
**Add GPS checks for anything over 6m (or missing)
destring locationaccuracy, replace
gen GPSmore6=1 if locationaccuracy>6 | locationaccuracy==.
egen tag=tag(RE $GeoID structure household)
save, replace 

preserve
keep if GPSmore6==1 & metatag==1
sort RE
capture noisily export excel RE metainstanceID GeoID_SH names locationaccuracy using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(HHGPSmore6m)
if _rc!=198 {
	restore
	}
else {
	clear 
	set obs 1
	gen x="NO HH GPS MISSING OR MORE THAN 6M"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(HHGPSmore6m)
	restore
	}
	
**Repeat for Female Accuracy
capture destring FQlocationaccuracy, replace
gen FQGPSmore6=1 if (FQlocationaccuracy>6 | FQlocationaccuracy==.) & FRS_result!=.
save, replace

preserve
keep if FQGPSmore6==1 & FRS_result!=.
capture noisily export excel RE metainstanceID GeoID_SH FRS_form_name FQlocationaccuracy using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FQGPSmore6m)
if _rc!=198 {
	restore
	}
else {
	clear 
	set obs 1
	gen x="NO FQ GPS MISSING OR MORE THAN 6M"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FQGPSmore6m)
	restore
	}
		
**GPS Spatial data error-checks - By RE & Full list   
preserve
run "$dofiledir/HHQ_GeoMonitoring.do"
restore


***Checking data quality for FQ integer variables
*Identify if there are any FQ integer variables with a value of 77, 88, or 99 indicating a potential mistype on the part of the RE or in the Cleaning file
preserve 
keep FQavailable-FQresp RE
sort FQGeoID_SH RE

**Checking if numeric variables have the values
gen mistype=.
gen mistype_var=""
foreach var of varlist _all {
	capture confirm numeric var `var'
	if _rc==0 {
		replace mistype=mistype+1 if (`var'==77 | `var'==88 | `var'==99) 
		replace mistype_var=mistype_var+" "+"`var'" if `var'==77 | `var'==88 | `var'==99
		}
	}
replace mistype_var=strtrim(mistype_var)

*Keep all variables that have been mistyped
levelsof mistype_var, local(typo) clean
keep if mistype!=. 
keep FQmetainstanceID RE FQGeoID_SH `typo'
order FQmetainstanceID RE FQGeoID_SH, first

capture noisily export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FQ_Potential_Typos) sheetreplace
if _rc!=198 {
	restore
	}
else {
	clear 
	set obs 1
	gen x="NO NUMERIC VARIABLES WITH A VALUE OF 77, 88, OR 99"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(FQ_Potential_Typos) sheetreplace
	restore
	}

**Export out forms and total the number of forms where the date is entered incorrectly
gen datetag=.
foreach var in system_date start end {
	split `var', gen (`var'_)
	capture confirm var `var'_3
	if _rc!=0{
		drop `var'_*
		split `var', gen(`var'_) parse(/ " ")
		}
	replace datetag=1 if `var'_3!="`SurveyYear'" & `var'_3!="`SYshort'"
	drop `var'_*
	}
save, replace

preserve

keep if datetag==1 & metatag==1
sort RE
capture noisily export excel metainstanceID RE GeoID_SH names system_date start end datetag using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(PhoneDateFlag)
if _rc!=198{
	restore
	}
if _rc==198 { 
	clear
	set obs 1
	gen x="NO FORMS WITH AN INCORRECT DATE"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(PhoneDateFlag) sheetreplace
	restore
	} 

**Flag any forms where at least one observation for household member info is missing

egen missingroster=rowmiss(gender age relationship  usually last_night) if HHQ_result==1
replace missingroster=missingroster+1 if marital_status==. & age>=10

egen noresponseroster=anycount(gender age  relationship usually last_night) if HHQ_result==1, values(-99 -88)
replace noresponseroster=noresponseroster+1 if marital_status==-99 & age>=10 & HHQ_result==1

gen missinginfo_roster=missingroster+noresponseroster
save, replace

preserve
keep if missinginfo_roster>0 & missinginfo_roster!=. 
sort RE
capture noisily export excel metainstanceID RE GeoID_SH firstname-last_night missinginfo_roster /// 
		using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(MissingRosterInfo)
 if _rc!=198{
	restore
	}
if _rc==198 { 
	clear
	set obs 1
	gen x="NO OBSERVATIONS HAVE MISSING/NONRESPONSE INFORMATION IN THE ROSTER"
	export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(MissingRosterInfo) sheetreplace
	restore
	} 
	
*********************************************************************************************************
						*****Generate Progress Report and associated checks*****
*********************************************************************************************************
capture drop HHtag
**Check: Number of files uploaded by RE

/*Count the total number of surveys,  the total number of surveys by version uploaded, and the total number
 of completions and refusals by RE and EA (since in some cases, REs may go to more than one EA).  Also 
 calculate the mean number of hhmembers per household*/

preserve
keep if metatag==1

forval x = 1/9 {
	gen HHQ_result_`x'=1 if HHQ_result==`x'
	}

collapse (count) HHQ_result_* HHQ_result, by (RE $GeoID)

rename HHQ_result HQtotalup
rename HHQ_result_1 HQcomplete
rename HHQ_result_2 HQnothome
rename HHQ_result_4 HQrefusal
rename HHQ_result_8 HQnotfound
gen HQresultother=HHQ_result_5 + HHQ_result_6 + HHQ_result_3 + HHQ_result_7 + HHQ_result_9
	
save `CCPX'_ProgressReport_$date, replace

restore

/*Number of eligible women identified and average number of eligible women per household*/
*Counting total number of eligible women identified in EA based only on COMPLETED FORMS

preserve
collapse (sum) eligible if HHQ_result==1, by(RE $GeoID)

rename eligible totaleligible
label var totaleligible	"Total eligible women identified in EA - COMPLETED HH FORMS ONLY"
tempfile collapse
save `collapse', replace
use `CCPX'_ProgressReport_$date
merge 1:1 RE $GeoID using `collapse', nogen

save, replace

restore

**Number of female surveys uploaded, number of female surveys that do not link (error)

preserve
collapse (count) FQresp if FQresp!=1, by (RE $GeoID)

rename FQresp FQtotalup
label var FQtotalup 	"Total Female Questionnaires Uploaded (including errors)"
save `collapse', replace
use `CCPX'_ProgressReport_$date
merge 1:1 RE $GeoID using `collapse', nogen
save, replace
restore

*Number of female questionnaires that are in the FQ database but do not link to a household
preserve
capture collapse (count) FQresp if FQresp==2, by (RE $GeoID)
if _rc!=2000{
	rename FQresp FQerror
	label var FQerror		"Female Questionnaires that do not match Household"

	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
restore

*Number of eligible women who are missing a female questionnaire (this should always be zero!)
preserve
capture collapse (count) FQresp if eligible==1 & FQresp==1, by (RE $GeoID)
if _rc!=2000{
	rename FQresp FQmiss
	label var FQmiss		"Eligible women missing female questionnaires"

	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
restore

**Completion and refusal rates for female questionnaire
preserve

forval x = 1/6 {
	gen FRS_result_`x'=1 if FRS_result==`x'
	}

collapse (count) FRS_result_* FRS_result if FRS_result!=., by (RE $GeoID)

*Count the number of surveys with each completion code 
rename FRS_result_1 FQcomplete
rename FRS_result_4 FQrefusal
rename FRS_result_2 FRS_resultothome
gen FQresultother = FRS_result_3 + FRS_result_5 + FRS_result_6
save `collapse', replace

use `CCPX'_ProgressReport_$date
merge 1:1 RE $GeoID using `collapse', nogen
save, replace

restore

*Count the number of HH surveys under 10 min long 
preserve 
keep if metatag==1
keep if HHQ_result==1
drop if totalint<0
keep if totalint<10
capture collapse (count) totalint , by(RE $GeoID)
if _rc!=2000{
	rename totalint HHQintless10
	tempfile collapse
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	use `CCPX'_ProgressReport_$date , clear
	gen HHQintless10=0
	save, replace
	}
restore

*Count the number of FQ surveys under 10 min long 
preserve 
keep if FRS_result==1 & HHQ_result==1
drop if FQtotalint<0
keep if FQtotalint<10
capture collapse (count) FQtotalint , by(RE $GeoID)
if _rc!=2000{
	rename FQtotalint FQintless10
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	use `CCPX'_ProgressReport_$date, clear
	gen FQintless10=0
	save, replace
	}
restore

*Count the number of HH surveys with GPSaccuracy>6m 
preserve 
keep if metatag==1
sort RE
capture collapse (count) GPSmore6, by(RE $GeoID)
if _rc!=2000{
	rename GPSmore6 HHQGPSAccuracymore6
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	clear
	use `CCPX'_ProgressReport_$date
	gen HHQGPSAccuracymore6=0
	save, replace
	}
restore

*Count the number of FQ surveys with GPSaccuracy>6m 
preserve
keep if FRS_result==1
capture collapse (count) FQGPSmore6 if FRS_result!=., by(RE $GeoID)
	if _rc!=2000{
	rename FQGPSmore6 FQGPSAccuracymore6
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	clear
	use `CCPX'_ProgressReport_$date
	gen FQGPSAccuracymore6=0
	save, replace
	}
restore

***** Creating 14/15 and 49/50 Age ratios for Females by RE/EA 
preserve

foreach y in 14 15 49 50{
	gen age`y'=1 if age==`y' & gender==2
	}

capture collapse (sum) age14 age15 age49 age50, by(RE $GeoID)
if _rc!=2000 {
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
}
restore

*Count the number of HH surveys with mismatching numbers of household members 
preserve
collapse (sum) numberpeopletag if metatag==1 & (HHQ_result==1 | HHQ_result==5), by (RE $GeoID)
if _rc!=2000{
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	use `CCPX'_ProgressReport_$date
	gen numberpeopletag==.
	save, replace
	}
restore

*Count the number of HH surveys missing HH roster information
preserve
gen missinginfotag=1 if missinginfo_roster!=0 & missinginfo_roster!=.
collapse (sum) missinginfotag if metatag==1, by (RE $GeoID)
if _rc!=2000{
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	use `CCPX'_ProgressReport_$date
	gen missinginfotag==.
	save, replace
	}
restore

*Count the number of HH surveys with incorrect phone dates
preserve
collapse (sum) datetag if metatag==1, by (RE $GeoID)
if _rc!=2000{
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	use `CCPX'_ProgressReport_$date
	gen datetag==.
	save, replace
	}
restore

**Total the number of DNK for first marriage year, recent marriage year, age at first birth, age at first sex by RE

gen DNKfirstmarriage=1 if year(husband_cohabit_start_firstSIF)==2030
gen DNKcurrentmarriage=1 if year(husband_cohabit_start_recentSIF)==2030
gen DNKfirstbirth=1 if year(first_birthSIF)==2030
gen DNKrecentbirth=1 if year(recent_birthSIF)==2030
gen DNKNRfirstsex=1 if age_at_first_sex==-88 | age_at_first_sex==-99
gen DNKNRlastsex=1 if last_time_sex==-88 | last_time_sex==-99

preserve
keep if FQmetainstanceID!=""
collapse (sum) DNK* , by (RE $GeoID)

if _rc!=2000{
	egen DNKNRtotal=rowtotal(DNK*)
	save `collapse', replace
	use `CCPX'_ProgressReport_$date
	merge 1:1 RE $GeoID using `collapse', nogen
	save, replace
	}
else {
	use `CCPX'_ProgressReport_$date
	gen DNK==.
	save, replace
	}
restore

***Export out checks from the Progress Report	
use `CCPX'_ProgressReport_$date, clear
drop FRS_result_*
save, replace

*Supervisor Checks
preserve
order EA HQtotalup HQcomplete HQrefusal HQnothome HQnotfound HQresultother totaleligible FQtotalup FQcomplete FQrefusal FRS_resultothome FQresultother, last
collapse (sum) HQtotalup-FQresultother (min) HHQGPS* FQGPS* HHQintless10 FQintless10, by(RE $GeoID)
export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(SupervisorChecks) sheetreplace
restore

*Additional Cleaning
preserve
collapse (min) age14 age15 age49 age50 (sum) numberpeopletag datetag missinginfotag, by(RE $GeoID)
export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(AdditionalCleaning) sheetreplace
restore

*DNK_NR_Count
export excel RE $GeoID DNK* using `CCPX'_HHQFQErrors_$date.xls, firstrow(variables) sh(DNK_NR_Count) sheetreplace 

***Overall counts
preserve
collapse (sum) HQtotalup HQcomplete-HHQ_result_5 totaleligible FQtotalup FQcomplete
label var HQtotalup "Total HH uploaded"
label var HQcomplete "Total HH complete"
gen HHresponse=HQcomplete/(HQcomplete + HQnothome + HHQ_result_3+ HQrefusal + HHQ_result_5)
label var HHresponse "Household response rate"
label var FQtotalup "Total FQ uploaded"
label var FQcomplete "Total FQ completed"
gen FQresponse=FQcomplete/FQtotalup
label var FQresponse "Female response rate"
tempfile temp
save `temp', replace
restore

clear
use `CCPX'_Combined_$date.dta
preserve
gen male=1 if gender==1
gen female=1 if gender==2
egen EAtag=tag($GeoID)
bysort $GeoID: egen EAtotal=total(metatag)
gen EAcomplete=1 if EAtotal==$EAtake & EAtag==1
collapse (sum) male female EAtag EAcomplete

gen sexratio=male/female
label var sexratio "Sex ratio - male:female"
label var EAtag "Number of EAs with any data submitted"
label var EAcomplete "Number of EAs with $EAtake HH forms submitted"
tempfile temp2
save `temp2'

use `temp'
append using `temp2'
keep HQtotalup HQcomplete HHresponse FQtotalup FQcomplete FQresponse sexratio EAtag EAcomplete

export excel using `CCPX'_HHQFQErrors_$date.xls, firstrow(varlabels) sh(OverallTotals) sheetreplace
restore
clear


*********************************************************************************************************
********************************* Country and Round Specific Cleaning ***********************************
*********************************************************************************************************
use `CCPX'_Combined_$date.dta, clear
capture noisily run "$dofiledir/`module1'"
capture noisily run "$dofiledir/`module2'"
capture noisily run "$dofiledir/`module3'"
capture noisily run "$dofiledir/`module4'"

save `CCPX'_Combined_$date.dta, replace

run "$dofiledir/CountrySpecific_CleanWeight.do"

************************************************************************************

translate `CCPX'_DataCleaningQuality_$date.log `CCPX'_DataCleaningQuality_$date.pdf, replace
