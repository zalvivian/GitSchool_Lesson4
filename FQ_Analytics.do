*PMA FQ Analytics
**This file generates the Analytics report for the Female Questionnaire

clear matrix
clear
set more off
set maxvar 30000

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
global FQodk KEP1-Female-Questionnaire-v3-jef

*Where the Analytics .csv files are saved
global analyticsdir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1\Data"

*Change analytic csv file names here
global FQanalytics1 KEP1_Female_Questionnaire_v3_Analytics.csv

*If there is 2nd version of analytics, use the older version below and add csv names
global FQanalytics2 

*Where the outputs from this .do file should be saved
global datadir "C:\Users\annro\PMA\Data_Not_Shared\Kenya\Test_KEP1"

*Datadate of the ECRecode dataset
global datadate 14Oct2019

**For the following macros the section name can be whatever you want it to be
**The firstvar is usually the note that begins the section in the ODK
**The lastvar is usually the note that begins the following section in the ODK

*Section 1 macros
local sec1_name background
local sec1_firstvar sect_background
local sec1_lastvar nights_husb_away_12mo

*Section 2 macros
local sec2_name migration
local sec2_firstvar nights_husb_away_12mo
local sec2_lastvar work_yn_7days

*Section 3 macros
local sec3_name economics_finance
local sec3_firstvar work_yn_7days
local sec3_lastvar sect_reproductive_health

*Section 4 macros
local sec4_name reproductive
local sec4_firstvar sect_reproductive_health
local sec4_lastvar sect_contraception

*Section 5 macros
local sec5_name contraception
local sec5_firstvar sect_contraception
local sec5_lastvar sect_sexual_activity

*Section 6 macros
local sec6_name sexual_activity
local sec6_firstvar sect_sexual_activity
local sec6_lastvar sect_wge

*Section 7 macros
local sec7_name wge
local sec7_firstvar sect_wge
local sec7_lastvar sect_flw

*Section 8 macros
local sec8_name follow_up
local sec8_firstvar sect_flw
local sec8_lastvar sect_end

*Number of sections in the survey
local n_sections 8

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
import excel "$odkdir/$FQodk", sheet("survey") firstrow

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
|type=="hidden string"|type=="hidden geopoint"|type=="hidden"|type=="hidden int"

drop if fieldlist_tag==. & (type=="end group" | type=="begin group")
drop fieldlist_tag
***************
*make into lower cases
replace name=lower(name)

*only keep variable names and make it into a country-specific macro
keep name
sxpose, clear firstnames

*drop the space in the original ODK, otherwise it'll generate a random variable
capture drop _var*

*for modules like children diarrhea, drop the repeat prompt since it's not in analytics
capture drop *_rpt

*generate a macro that holds all ODK screen variables
local all_frsvar 
foreach var of varlist _all {
	local all_frsvar "`all_frsvar' `var'"
	}

********************************************************************************
*                                  FQ Analytics
********************************************************************************

*open HHQ dataset and keep necessary information to be added to analytics
use "$datadir/`CCPX'_Combined_ECRecode_$datadate.dta", clear

keep if FQmetainstanceID!=""
keep FQmetainstanceID RE structure household FRS_form_name FQ_age FQmarital_status current_user fp_ever_used ///
	current_method why_not_using fp_provider_rw_known fp_provider_rw_nr fp_obtain_desired_whynot birthdate recent_birth age_at_first_use FRS_result 

duplicates drop FQmetainstanceID, force
tempfile combined1
save `combined1', replace

*merge info from FQ data and analytic data
clear
capture noisily insheet using "$analyticsdir/$FQanalytics1", clear

save "`CCPX'_Female_Questionnaire_Analytics_$date.dta", replace	

capture noisily insheet using "$analyticsdir/$FQanalytics2", comma case clear
if _rc==0 {
    tempfile FQana
    save `FQana', replace	
	
	use "`CCPX'_Female_Questionnaire_Analytics_$date.dta", clear
	append using `FQana', force
	save "`CCPX'_Female_Questionnaire_Analytics_$date.dta", replace	
	}

use "`CCPX'_Female_Questionnaire_Analytics_$date.dta", clear

*housekeeping of analytics files
rename dir_uuid FQmetainstanceID
replace FQmetainstanceID=subinstr(FQmetainstanceID,"uuid","uuid:",.)
gen RE=your_name
tostring RE,replace
tostring name_typed, replace
replace RE=name_typed if missing(your_name)

*save a copy of raw FQ analytics csv
merge 1:1 FQmetainstanceID using `combined1', nogen force
save "`CCPX'_Female_Questionnaire_Analytics_$date.dta", replace

*Get variable number for variable names that are too long
preserve
keep FQmetainstanceID-age_at_first_use_children_warnin 
global age_1stuse_children_warn_t = c(k) +1
global age_1stuse_children_warn_v = c(k) +2
global age_1stuse_children_warn_d = c(k) +3
global age_1stuse_children_warn_b = c(k) +4
restore

preserve
keep FQmetainstanceID-cc_year1_col2_note_b
global cc1_year1_col2_note_c = c(k)+1
global cc1_year1_col2_note_t = c(k)+2
global cc1_year1_col2_note_v = c(k)+3
global cc1_year1_col2_note_d = c(k)+4
global cc1_year1_col2_note_b = c(k)+5
restore
	
capture confirm var rb_m_t 
if _rc==0 {
	preserve
	keep FQmetainstanceID-rbq_b
	global rb1_note_c = c(k)+1
	global rb1_note_t = c(k)+2
	global rb1_note_v = c(k)+3
	global rb1_note_d = c(k)+4
	global rb1_note_b = c(k)+5
	restore
	}

*name cleaning of csv
order RE, after(your_name)
capture drop your_name name_typed
capture rename ea* EA*
sort RE

if "`country'"=="RJ" | "`country'"=="Rajasthan" {
	replace RE="re"+RE if substr(RE,1,2)=="10"
	}

egen GeoID_SH=concat(`Geo_ID' EA structure household), punct(-)
egen GeoID=concat(`Geo_ID' EA), punct(-)

*rename vars that are too long
rename age_at_first_use_children_warnin age_1stuse_children_warn_c 
rename v$age_1stuse_children_warn_t age_1stuse_children_warn_t
rename v$age_1stuse_children_warn_v age_1stuse_children_warn_v
rename v$age_1stuse_children_warn_d age_1stuse_children_warn_d
rename v$age_1stuse_children_warn_b age_1stuse_children_warn_b

rename v$cc1_year1_col2_note_c cc1_year1_col2_note_c
rename v$cc1_year1_col2_note_t cc1_year1_col2_note_t
rename v$cc1_year1_col2_note_v cc1_year1_col2_note_v
rename v$cc1_year1_col2_note_b cc1_year1_col2_note_b
rename v$cc1_year1_col2_note_d cc1_year1_col2_note_d

capture confirm var rb_m_t 
if _rc==0 {
	rename v$rb1_note_c rb1_note_c
	rename v$rb1_note_t rb1_note_t
	rename v$rb1_note_v rb1_note_v
	rename v$rb1_note_b rb1_note_b
	rename v$rb1_note_d rb1_note_d
	}
	
*Time by section
order *_t, after(FRS_result)
order *_b, after(frs_result_t)
order *_v, after(frs_result_b)
order *_c, after(frs_result_v)
order *_d, after(frs_result_c)

*Create time measuring active and short break time
rename *_t *_a

foreach var in `all_frsvar' {
	egen `var'_t=rowtotal(`var'_a `var'_b)
	}

*Section time calculations
forval x = 1/`n_sections' {
	capture drop FQ`sec`x'_name'_time
	egen FQ`sec`x'_name'_time=rowtotal(`sec`x'_firstvar'_t-`sec`x'_lastvar'_t)
	replace FQ`sec`x'_name'_time=(FQ`sec`x'_name'_time-`sec`x'_lastvar'_t)/60/1000
	local section_time "`section_time' FQ`sec`x'_name'_time"
	}	

*flag if interview <10min
gen FQinterview=resumed+short_break
gen FQinterview_min=(resumed+short_break)/60000
gen FQtime_flag=1 if FQinterview_min<10
format FQinterview_min %12.2f

****Generate interview speed in v8
foreach var in `all_frsvar'{
	capture gen `var'_u=.
	capture replace `var'_u=1 if `var'_v!=.
	}

order *_u, after(frs_result_t)

egen unique_visit_total=rowtotal(ok_continue_u - frs_result_u)
drop ok_continue_u-frs_result_u

local all_frsvar_t
foreach var in `all_frsvar' {
	local all_frsvar_t "`all_frsvar_t' `var'_t"
	}

local all_frsvar_v
foreach var in `all_frsvar'{
	local all_frsvar_v "`all_frsvar_v' `var'_v"
	}

local all_frsvar_c
foreach var in `all_frsvar'{
	local all_frsvar_c "`all_frsvar_c' `var'_c"
	}

local all_frsvar_d
foreach var in `all_frsvar' {
	local all_frsvar_d "`all_frsvar_d' `var'_d"
	}

**generate a variable speed=sum(each question time)/unique screen. unit is seconds per screen 
egen FQ_t_total=rowtotal(`all_frsvar_t')
gen FQspeed_second=(FQ_t_total/unique_visit_total)/1000


********************************************************************************
* Error sheet
********************************************************************************

*export histogram to show interview time distribution
*generate statistics for overall time distribution
preserve
capture graph drop second
drop if FQinterview_min>10000
drop if FQinterview_min==0
quietly sum FQinterview_min, detail
return list
histogram FQinterview_min if FRS_result==1, width(10) start(0) percent addlabels title("`CCPX' FQ Completed Interview Time Distribution $date") ///
   xtitle("Interview Time in Minute") ytitle("Percent Among All Completed Forms") xtick(0(10)120) bcolor(pink) ///
   text(40 70 "N=`r(N)'", placement(se)) ///
   text(36 70 "Minimum=`r(min)'", placement(se)) ///
   text(32 70 "Median=`r(p50)'", placement(se)) ///
   text(28 70 "Max=`r(max)'", placement(se)) ///
   text(24 70 "SD=`r(sd)'", placement(se)) name(second)
capture graph export "FQ_interview_time_distribution_$date.png", replace
restore

save "`CCPX'_Female_Questionnaire_Analytics_$date.dta", replace

*FQ overall time	
preserve
keep if FRS_result==1
drop if FQinterview_min<1
keep if FQinterview_min<10

capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age FQmarital_status current_user ///
	current_method FQinterview_min FQspeed_second ///
	`section_time' using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQoverview<10min) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO COMPLETED FEMALE INTERVIEWS LESS OR EQUAL TO 10 MINUTES"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQoverview<10min) sheetreplace
	restore
	}


***FQ specific questions
*Birthdate
preserve
keep if FRS_result==1
replace birthdate_m_t=birthdate_m_t/1000
keep if birthdate_m_t<=5 & birthdate_m_t>0
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age birthdate birthdate_m_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(birthdate<=5s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO BIRTHDATE QUESTION LESS THAN 5S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(birthdate<=5s) sheetreplace
	restore
	}


*Recent Birth
preserve
keep if FRS_result==1
keep if recent_birth!=""
replace rb_m_t=rb_m_t/1000
keep if rb_m_t<=5 & rb_m_t>0
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age recent_birth rb_m_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(recent_birth<=5s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO RECENT BIRTH QUESTION LESS THAN 5S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(recent_birth<=5s) sheetreplace
	restore
	}

* current method	
replace current_method_t=current_method_t/1000

preserve
keep if FRS_result==1
keep if current_user==1
keep if current_method_t<=3 & current_method_t>0
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age FQmarital_status current_user current_method current_method_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQcurrent_method<=3s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO CURRENT METHOD QUESTION LESS THAN 3S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQcurrent_method<=3s) sheetreplace
	restore
	}

*Age at first use
preserve
keep if FRS_result==1
keep if fp_ever_used==1
replace age_at_first_use_t=age_at_first_use_t/1000
keep if age_at_first_use_t<=5 & age_at_first_use_t>0
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age age_at_first_use age_at_first_use_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(age_first_use<=5s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO AGE FIRST USE QUESTION LESS THAN 5S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(age_first_use<=5s) sheetreplace
	restore
	}

*why not using
preserve
keep if FRS_result==1
keep if current_user==0
drop if (FQmarital_status==5 | FQmarital_status==6) & why_not_using=="not_married"
replace why_not_using_t=why_not_using_t/1000
keep if why_not_using_t<=5 & why_not_using_t>0
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age FQmarital_status current_user why_not_using why_not_using_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQwhy_not_use<=5s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO WHY NOT USE QUESTION LESS THAN 5S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQwhy_not_use<=5s) sheetreplace
	restore
	}

*fp provider
rename fp_provider_rw_known_t fp_provider_rw_t
replace fp_provider_rw_t=fp_provider_rw_t/1000

preserve
keep if FRS_result==1
keep if current_user==1 
keep if fp_provider_rw_t<=3 & fp_provider_rw_t>0
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age FQmarital_status current_method fp_provider_rw_known fp_provider_rw_nr fp_provider_rw_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQprovider<=3s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO FP PROVIDER QUESTION LESS THAN 3S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQprovider<=3s) sheetreplace
	restore
	}

*fp obtained desired why not
preserve
keep if FRS_result==1
keep if !missing(fp_provider_rw_known) & !missing(fp_provider_rw_nr)
replace fp_obtain_desired_whynot_t=fp_obtain_desired_whynot_t/1000
keep if fp_obtain_desired_whynot_t<=5 
capture noisily export excel RE FQmetainstanceID GeoID_SH FQ_age FQmarital_status current_user fp_obtain_desired_whynot fp_obtain_desired_whynot_t ///
	using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQfp_obtain_desired_whynot<=5s) sheetreplace
if _rc!=198{
	restore
	}
else{
	clear 
	set obs 1
	gen x="NO WHY NOT GETTING DESIRED METHOD QUESTION LESS THAN 5S"
	export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(variables) sh(FQfp_obtain_desired_whynot<=5s) sheetreplace
	restore
	}

*generate flag for short key questions
foreach var in current_method fp_provider_rw {
	gen `var'_time_flag=1 if (`var'_t<=3 & `var'_t!=0 & FRS_result==1)
	}
	
foreach var in birthdate_m age_at_first_use why_not_using {
	gen `var'_time_flag=1 if (`var'_t<=5000 & `var'_t!=0 & FRS_result==1)
	}
	
gen FQ_key_time_flag=1 if current_method_time_flag==1 | fp_provider_rw_time_flag==1 | ///
	age_at_first_use_time_flag==1 | why_not_using_time_flag==1 | birthdate_m_time_flag==1 

***Breakdown by each RE, include time summary, screen visit, rs
preserve
keep if FRS_result==1

collapse (count) FRS_completed=FRS_result (min) FQinterview_minimum=FQinterview_min ///
(p50) FQinterview_median=FQinterview_min (max) FQinterview_maximum=FQinterview_min ///
(mean) mean_FQinterview_speed=FQspeed_second ///
(count) num_interview_less_10min=FQtime_flag ///
(count) num_short_key_question=FQ_key_time_flag, by(RE)

label var FRS_completed "Total Female Forms Completed"
label var FQinterview_minimum "Minimum FQ time in minutes"
label var FQinterview_median "Median FQ time in minutes"
label var FQinterview_maximum "Maximum FQ time in minutes"
label var mean_FQinterview_speed "Average seconds per ODK Screen"
label var num_interview_less_10min "Number of FQ interviews under 10 min"
label var num_short_key_question "Number of FQ interviews with short key questions"


export excel using `CCPX'_HQFQ_Analytics_Error_Report_$date.xls, firstrow(varlabels) sh(FQbyRE) sheetreplace
restore

save "`CCPX'_Female_Questionnaire_Analytics_$date.dta", replace

