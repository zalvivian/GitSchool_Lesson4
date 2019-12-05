****PMA Data Quality Checks****
***This file cleans country specific variables, applies country specific weights, recodes current method, and drops unnecessary and identifying variables

set more off

local CCPX $CCPX

******************************
use `CCPX'_Combined_$date.dta, clear

*Check if there are any remaining duplicates
duplicates report member_number 
duplicates report FQmetainstanceID
capture drop dupFQmeta
duplicates tag FQmetainstanceID, gen(dupFQmeta)
duplicates drop FQmetainstanceID if FQmetainstanceID!="", force
save, replace
 
 
********************************************************************************************************************
******************************All country specific variables need to be encoded here********************

*Household
**Update corrected date of interview if phone had incorrect settings. Update to year/month of data collection
**Geographic Variables
**Assets
**Floor
**Roof
**Walls
**Survey language
**Religion
**Ethnicity

*Female
**Update corrected date of interview if phone had incorrect settings. Update to year/month of data collection
**Geographic Variables (Including Migration Variables)
**School
**FP Provider
**Insurance
**Survey Language

*************************************************************
*************************  Household ************************

*HH Geographic Variables
local level1 $level1name
local level2 $level2name
local level3 $level3name
local level4 $level4name

forval y = 1/4 {
	capture confirm var level`y'
	if _rc==0 {
		rename level`y' `level`y''
		label var `level`y'' "`level`y''"
		}
	}

*Household DOI
capture drop doi*

gen doi=system_date
replace doi=manual_date if manual_date!="." & manual_date!=""

split doi, gen(doisplit_)
capture drop wrongdate
*If survey spans across 2 years add | doisplit_3!=year2
gen wrongdate=1 if doisplit_3!="2020"
replace wrongdate=1 if doisplit_1!="Mar" & doisplit_1!="Apr" & doisplit_1!="May" & doisplit_1!=""

gen doi_corrected=doi
replace doi_corrected=SubmissionDate if wrongdate==1 & SubmissionDate!=""
drop doisplit*

*Assets
replace assets=" "+assets+" "
foreach var in electricity radio tv mobile landline refrigerator tv_antenna cabel_subscription wash_mach gas_elect_stov imp_stov DVD_CD air_con computer internet wall_clock charruees bicycle motorcycle cart_animal canoe tractor car boatmotor {
	gen `var'=0 if assets!=""
	replace `var'=1 if strpos(assets, " `var' ")
	label val `var' o2s_binary_label
	label var `var' "`var' Owned"
	}
replace assets=strtrim(assets)

*Roof/Wall/Floor
**Numeric codes come from country specific DHS questionnaire 
label define floor_list 11 soil_sand 12 cow_dung 21 wood_boards 22 palm_bamboo 31 parquet 32 vinyl_asphal 33 tile 34 cement 35 carpet 96 other -99 "-99"
encode floor, gen(floorv2) lab(floor_list)

label define roof_list 11 no_roof 12 thatch_palm 13 earth_mottes 21 mat 22 palm_bamboo 23 wood_planks 24 cardboard 31 sheet_metal 32 wood 33 zinc_fiber 34 tile 35 cement 36 shingles 96 other -99 "-99"
encode roof, gen(roofv2) lab(roof_list)	

label define walls_list 11 no_wall 12 bamboo_palm 13 earth 21 bamboo_mud 22 stones_mud 23 adobe_uncovered 24 plywood 25 cardboard 26 recovered_wood 31 cement 32 stones_cement 33 bricks 34 cement_blocks 35 adobe_covered 36 board_shingles 96 other -99 "-99"
encode walls, gen(wallsv2) lab(walls_list)

*Livestock
foreach x in cow_bulls horses goats sheep pigs fowl other {
	capture rename owned_`x'* `x'_owned
	capture label var `x'_owned "Total number of `x' owned"
	destring `x'_owned, replace
	}

*Language 
label define language_list 1 english 2 french 3 arabic 4 baoule 5 senoufo 6 yacouba 7 agni 8 attie 9 guere 10 bete 11 dioula 12 abbey 13 mahou 14 wobe 15 lobi 96 other, replace
encode survey_language, gen(survey_languagev2) lab(language_list)
label var survey_languagev2 "Language of household interview"

*Religion
capture confirm var religion
if _rc==0 {
	label define religion_list 1 muslim 2 catholic 3 methodist 4 evangelical 5 other_christian 6 animist 96 other -77 "-77" -99 "-99"		
	encode religion, gen(religionv2) lab(religion_list)
	sort metainstanceID religionv2 
	bysort metainstanceID: replace religionv2 =religionv2[_n-1] if religionv2==.
	label var religionv2 "Religion of household head"
	}

*Ethnicity
capture confirm var ethnicity
if _rc==0 {
	label define ethnicity_list 1 akan 2 mande_du_sud 3 mande_du_nord 4 gur 5 krou 6 other_ic 7 other_non_ic -99 "-99"
	encode ethnicity, gen(ethnicityv2) lab(ethnicity_list)
	sort metainstanceID ethnicityv2 
	bysort metainstanceID: replace ethnicityv2=ethnicityv2[_n-1] if ethnicityv2==.
	label var ethnicityv2 "Ethnicity of household head"
	}

*************************************************************
***************************  Female  ************************

**Country specific female questionnaire changes
*Year and month of data collection.  

*If survey spans across 2 years add | thisyear!=year2
gen FQwrongdate=1 if thisyear!="2020" & thisyear!=""
replace FQwrongdate=1 if thismonth!="3" & thismonth!="4" & thismonth!="5" & thismonth!=""

gen FQdoi=FQsystem_date
replace FQdoi = FQmanual_date if FQmanual_date!="." & FQmanual_date!=""

gen FQdoi_corrected=FQdoi
replace FQdoi_corrected=FQSubmissionDate if FQwrongdate==1 & FQSubmissionDate!=""

*Migration Variables
capture confirm var country_lived
if _rc==0 {
	label define country_lived_list 1 "cotedivoire" 
	encode country_lived, gen(country_livedv2) lab(country_lived_list)
	}
	
capture confirm var district_lived 
if _rc==0 {
	label define level1_list 1 "level1"
	encode district_lived, gen(district_livedv2) lab(level1_list)
	}

*Education Categories
label def school_list 0 never 1 primary 2 secondary 3 tertiary -99 "-99", replace
encode school, gen(schoolv2) lab(school_list)

*Methods lists
**If asked about injectables 1 and 3 month, change 5 to "injectables 3mo" and "Injectables 3 month" respectively
label define methods_list 1 "female_sterilization" 2 "male_sterilization" 3 "implants" 4 "IUD" 5 "injectables" ///
	6 "injectables_1mo" 7 "pill" 8 "emergency" 9 "male_condoms" 10 "female_condoms" 11 "diaphragm" 12 "foam" 13 "beads" 14 "LAM" 15 "N_tablet" ///
	16 "injectables_sc" 30 "rhythm" 31 "withdrawal" 39 "other_traditional" -99 "-99"

foreach var in ppp_current_method_label fp_start_which last_time_sex_fp_method current_method_most_effective {
	encode `var', gen(`var'v2) lab(methods_list)
	}
	
label define methods_list 1 "Female sterilization" 2 "Male sterilization" 3 "Implant" 4 "IUD" 5 "Injectables" 6 "Injectables 1 month" 7 "Pill" ///
	8 "Emergency Contraception" 9 "Male condom" 10 "Female condom" 11 "Diaphragm" 12 "Foam/Jelly" 13 "Standard Days/Cycle beads" 14 "LAM" 15 "N tablet" ///
	16 "Injectables SC" 30 "Rhythm method" 31 "Withdrawal" 39 "Other traditional method" -99 "No response", replace

*Drop variables not included in country
*In variable list on the foreach line, include any variables NOT asked about in country (should always include EITHER injectables or injectables1 and injectables3)
foreach var of varlist injectables3 injectables1 N_tablet {
	sum `var'
	if r(min)==0 & r(max)==0 {
		drop `var'
		}
	}	

*Provider list 
label define providers_list 11 govt_hosp 12 govt_health_center 13 FP_clinic 14 mobile_clinic_public 15 fieldworker_public ///
	21 private_hospital 22 pharmacy 23 chemist 24 private_doctor 25 mobile_clinic_private 26 fieldworker_private ///
	31 shop 32 church 33 friend_relative 34 NGO 35 market /// 
	96 other -88 "-88" -99 "-99"
	
foreach var in fp_needs_where fp_provider_rw_known fp_provider_rw_nr {
	encode `var', gen(`var'v2) lab(providers_list)
	}
		
*Insurance
**Add list of choices from ODK to the foreach line
replace insurance_type=" "+insurance_type+" "
foreach type in {
	gen insurance_`type'=0
	replace insurance_`type'=1 if strpos(insurance_type, " `type' ")
	label var insurance_`type' "Has `type' insurance"
	label val insurance_`type' o2s_binary_label
	order insurance_`type', after(insurance_type)
	}
replace insurance_type=strtrim(insurance_type)	

*FQ Language
capture label define language_list 1 english 2 hausa 3 igbo 4 yoruba 5 pidgin 96 other
encode FQsurvey_language, gen(FQsurvey_languagev2) lab(language_list)
label var FQsurvey_language "Language of Female interview"
	

unab vars: *v2
local stubs: subinstr local vars "v2" "", all
foreach var in `stubs'{
	rename `var' `var'QZ
	order `var'v2, after(`var'QZ)
	}
rename *v2 *
drop *QZ	

	
***************************************************************************************************
********************************* COUNTRY SPECIFIC WEIGHT GENERATION ******************************
***************************************************************************************************

**Import sampling fraction probabilities and urban/rural
**NEED TO UPDATE PER COUNTRY
/*
merge m:1 EA using "C:/Users/Shulin/Dropbox (Gates Institute)/PMADataManagement_Uganda/Round5/WeightGeneration/UGR5_EASelectionProbabilities_20170717_lz.dta", gen(weightmerge)
drop region subcounty district
tab weightmerge

**Need to double check the weight merge accuracy
capture drop if weightmerge!=3
label define urbanrural 1 "URBAN" 2 "RURAL"
label val URCODE urbanrural
rename URCODE ur

capture rename EASelectionProbabiltiy EASelectionProbability
gen HHProbabilityofselection=EASelectionProbability * ($EAtake/HHTotalListed)
replace HHProbabilityofselection=EASelectionProbability if HHTotalListed<$EAtake
generate completedhh=1 if (HHQ_result==1) & metatag==1

*Denominator is any household that was found (NOT dwelling destroyed, vacant, entire household absent, or not found)
generate hhden=1 if HHQ_result<6 & metatag==1

*Count completed and total households in EA
bysort ur: egen HHnumtotal=total(completedhh)
bysort ur: egen HHdentotal=total(hhden)

*HHweight is1/ HHprobability * Missing weight
gen HHweight=(1/HHProbability)*(1/(HHnumtotal/HHdentotal)) if HHQ_result==1

**Generate Female weight based off of Household Weight
**total eligible women in the EA
gen eligible1=1 if eligible==1 & (last_night==1)
bysort ur: egen Wtotal=total(eligible1) 

**Count FQforms up and replace denominator of eligible women with forms uploaded
*if there are more female forms than estimated eligible women
gen FQup=1 if FQmetainstanceID!=""
gen FQup1=1 if FQup==1 & (last_night==1)
bysort ur: egen totalFQup=total(FQup1) 
drop FQup1

replace Wtotal=totalFQup if totalFQup>Wtotal & Wtotal!=. & totalFQup!=.

**Count the number of completed or partly completed forms (numerator)
gen completedw=1 if (FRS_result==1 ) & (last_night==1) //completed, or partly completed
bysort ur: egen Wcompleted=total(completedw)

*Gen FQweight as HHweight * missing weight
gen FQweight=HHweight*(1/(Wcompleted/Wtotal)) if eligible1==1 & FRS_result==1 & last_night==1
gen HHweightorig=HHweight
gen FQweightorig=FQweight
**Normalize the HHweight by dividing the HHweight by the mean HHweight (at the household leve, not the member level)
preserve
keep if metatag==1
su HHweight
replace HHweight=HHweight/r(mean)
sum HHweight
tempfile temp
keep metainstanceID HHweight
save `temp', replace
restore
drop HHweight
merge m:1 metainstanceID using `temp', nogen

**Normalize the FQweight
sum FQweight
replace FQweight=FQweight/r(mean)
sum FQweight


drop weightmerge HHProbabilityofselection completedhh-HHdentotal eligible1-Wcompleted

rename REGIONCODEUR strata
*/

***********************************************************************************************
********************************* GENERIC DONT NEED TO UPDATE *********************************

*1. Drop unneccessary variables
drop FQconsent *warning* heads ///
	roster_complete  ///
	deviceid simserial phonenumber *transfer *label* ///
	witness_manual witness_manual FQwitness_manual *check* *warn* FQKEY *unlinked* ///
	more_hh_members* *GeoID* dupFQ FQresp error ///
	HHmemberdup waitchild cc_start_date cc_start_date_lab close_exit ///
	ok_continue hh_confirmation location_confirmation birthdate_lab ///
	birthdate_y hcf_y hcf_y_lab husband_cohabit_start_first_lab ///
	hcs_y hcs_y_lab husband_cohabit_start_recent_lab fb_y fb_y_lab ///
	first_birth_lab rb_y rb_y_lab recent_birth_lab ob_y ob_y_lab other_birth_lab ///
	ab_y ab_y_lab pregnancy_end_lab rec_birth_date today_ym menstrual_period_lab ///
	fp_start_lab rec_husband_date bus_y bus_y_lab begin_using_full_lab ///
	last_time_sex_lab verify_cc* HHQ_GPS delete_form numberpeoplelisted numberpeopletag ///
	GPSmore6 tag FQGPSmore6 datetag missingroster noresponseroster missinginfo_roster dupFQmeta 
	
capture drop sign
capture drop FQsign
capture drop implant_duration_lab
capture drop mig_merge mig_key*
 
sort metainstanceID member_number


/***************** RECODE CURRENT METHOD **********************************
1. Generate recent users from contraceptive calendar
2. Recent EC users recoded to current users
3. LAM Users who are not using LAM recoded
4. Female sterilization users who do not report using sterilization are recoded
5. SP users recoded to SP
********************************************************************/
*Generate recent_users and recent methods
local year3 $year3
local year2=$year3-1
destring thismonth, replace

*Generate recoded calendar variables for current and most recent year
rename cc_col*_*_0* cc_col*_*_*
forval y = 1/12 {
	gen method_`year2'_`y'=cc_col1_`year2'_`y'
	recode  method_`year2'_`y' 0 40 41 42 = . 
	gen stop_using_`year2'_`y'=cc_col2_`year2'_`y'
	
	gen method_`year3'_`y'= cc_col1_`year3'_`y'
	recode  method_`year3'_`y' 0 40 41 42 = . 
	gen stop_using_`year3'_`y'=cc_col2_`year3'_`y'
	}

*Create most effective recent method used in last 12 months for non-current users 
egen most_effective_recent=rowmin(method_`year3'*) if current_user!=1
gen stop_using_why=.
gen stop_using=""
forval y = 12(-1)1 {
	replace stop_using_why=stop_using_`year3'_`y' if method_`year3'_`y'==most_effective_recent & stop_using_why==.
	replace stop_using="`year3'-`y'" if method_`year3'_`y'==most_effective_recent & stop_using=="" & stop_using_`year3'_`y'!=.

	replace most_effective_recent=method_`year2'_`y' if thismonth<`y' & method_`year2'_`y'<most_effective_recent & current_user!=1
	replace stop_using_why=stop_using_`year2'_`y' if thismonth<`y' & method_`year2'_`y'<most_effective_recent & stop_using_why==.
	replace stop_using="`year2'-`y'" if thismonth<`y' & method_`year2'_`y'<most_effective_recent & stop_using=="" & stop_using_`year2'_`y'!=.
	}
	
label val most_effective_recent methods_list
label var most_effective_recent "Most effective method used in the last 12 mo : non-current users"

label val stop_using_why cc_option2_list
label var stop_using_why "Why stop using most effective method used in last 12 mo"

label var stop_using "When did you stop using recent method"

gen double stop_usingSIF=date(stop_using, "YM")
format stop_usingSIF %td
label var stop_usingSIF "When did you stop using recent method SIF"

drop method_`year2'* method_`year3'* stop_using_`year2'* stop_using_`year3'*

*Generate recent user variable
gen recent_user=0 if current_user!=1 & !missing(FQmetainstanceID)
replace recent_user=1 if !missing(most_effective_recent)
label val recent_user o2s_binary_label
label var recent_user "Used contraception in the last 12 months : non current users"

*Combine current and recent most effective methods to create current_recent_methodnum
gen current_recent_methodnum=current_method_most_effective
replace current_recent_methodnum=most_effective_recent if current_recent_methodnum==.
label var current_recent_methodnum "Most effective current or recent method"
label val current_recent_methodnum methods_list

*******************************************************************************
* RECODE EC
*******************************************************************************
**Recode recent EC users to current users
gen current_methodnum=current_recent_methodnum if current_user==1
label val current_methodnum methods_list

gen current_methodnumEC=current_recent_methodnum if current_user==1
replace current_methodnumEC=8 if current_recent_methodnum==8 & current_user!=1
label val current_methodnumEC methods_list

gen current_userEC=current_user
replace current_userEC=. if current_methodnumEC==-99
replace current_userEC=1 if current_recent_methodnum==8 & current_user!=1

gen recent_userEC=recent_user
replace recent_userEC=. if current_recent_methodnum==8 

gen recent_methodnumEC=most_effective_recent
replace recent_methodnumEC=. if most_effective_recent==8
label val recent_methodnumEC methods_list

gen stop_using_whyEC=stop_using_why
replace stop_using_whyEC=. if current_recent_methodnum==8

gen stop_usingEC=stop_using
replace stop_usingEC="" if current_recent_methodnum==8

gen stop_usingSIFEC=stop_usingSIF
replace stop_usingSIFEC=. if current_recent_methodnum==8

gen fp_ever_usedEC=fp_ever_used
replace fp_ever_usedEC=1 if current_recent_methodnum==8 & fp_ever_used!=1

gen future_user_not_currentEC=future_user_not_current
replace future_user_not_currentEC=. if current_recent_methodnum==8

gen future_user_pregnantEC=future_user_pregnant
replace future_user_pregnantEC=. if current_recent_methodnum==8

gen ECrecode=0 
replace ECrecode=1 if current_recent_methodnum==8

*******************************************************************************
* RECODE LAM
*******************************************************************************
tab LAM

* CRITERIA 1.  Birth in last six months
* Calculate time between last birth and date of interview
* FQdoi_corrected is the corrected date of interview
gen double FQdoi_correctedSIF=clock(FQdoi_corrected, "MDYhms")
format FQdoi_correctedSIF %tc
* Number of months since birth=number of hours between date of interview and date 
* of most recent birth divided by number of hours in the month
gen tsincebh=hours(FQdoi_correctedSIF-recent_birthSIF)/730.484
gen tsinceb6=tsincebh<6
replace tsinceb6=. if tsincebh==.
	* If tsinceb6=1 then had birth in last six months

* CRITERIA 2.  Currently ammenhoeric
gen ammen=0

* Ammenhoeric if last period before last birth
replace ammen=1 if menstrual_period==6

* Ammenhoerric if months since last period is greater than months since last birth
g tsincep	    	= 	menstrual_period_value if menstrual_period==3 // months
replace tsincep	    = 	int(menstrual_period_value/30) if menstrual_period==1 // days
replace tsincep	    = 	int(menstrual_period_value/4.3) if menstrual_period==2 // weeks
replace tsincep	    = 	menstrual_period_value*12 if menstrual_period==4 // years

replace ammen=1 if tsincep>tsincebh & tsincep!=.

* Only women both ammenhoerric and birth in last six months can be LAM
gen lamonly=1 if current_method=="LAM"
replace lamonly=0 if current_methodnumEC==14 & (regexm(current_method, "rhythm") | regexm(current_method, "withdrawal") | regexm(current_method, "other_traditional"))
gen LAM2=1 if current_methodnumEC==14 & ammen==1 & tsinceb6==1 
tab current_methodnumEC LAM2, miss
replace LAM2=0 if current_methodnumEC==14 & LAM2!=1

* Replace women who do not meet criteria as traditional method users
capture rename lam_probe_current lam_probe
capture confirm variable lam_probe
if _rc==0 {
capture noisily encode lam_probe, gen(lam_probev2) lab(yes_no_dnk_nr_list)
drop lam_probe
rename lam_probev2 lam_probe
	replace current_methodnumEC=14 if LAM2==1 & lam_probe==1
	replace current_methodnumEC=30 if lam_probe==0 & lamonly==0 & regexm(current_method, "rhythm")
	replace current_methodnumEC=31 if current_methodnumEC==14 & lam_probe==0  & lamonly==0 & regexm(current_method, "withdrawal") & !regexm(current_method, "rhythm")
	replace current_methodnumEC=39 if current_methodnumEC==14 & lam_probe==0  & lamonly==0 & regexm(current_method, "other_traditional") & !regexm(current_method, "withdrawal") & !regexm(current_method, "rhythm")
	replace current_methodnumEC=39 if lam_probe==1 & current_methodnumEC==14 & LAM2==0
	replace current_methodnumEC=. if current_methodnumEC==14 & lam_probe==0 & lamonly==1
	replace current_userEC=0 if current_methodnumEC==. | current_methodnumEC==-99
	}
	
else {
	replace current_methodnumEC=39 if LAM2==0
	}
	

drop tsince* ammen

*******************************************************************************
* RECODE Injectables_SC
*injectable
*******************************************************************************
replace current_methodnumEC=16 if (injectable_probe_current==2 | injectable_probe_current==3) ///
	& (current_recent_methodnum==5 | current_recent_methodnum==6 )

	
*******************************************************************************
* Define CP, MCP, TCP and longacting
*******************************************************************************
gen cp=0 if HHQ_result==1 & FRS_result==1 & (last_night==1)
replace cp=1 if HHQ_result==1 & current_methodnumEC>=1 & current_methodnumEC<=39 & FRS_result==1 & (last_night==1) 
label var cp "Current use of any contraceptive method"

gen mcp=0 if HHQ_result==1 & FRS_result==1 & (last_night==1)
replace mcp=1 if HHQ_result==1 & current_methodnumEC>=1 & current_methodnumEC<=19 & FRS_result==1 & (last_night==1)
label var mcp "Current use of any modern contraceptive method"

gen tcp=0 if HHQ_result==1 & FRS_result==1 & (last_night==1)
replace tcp=1 if HHQ_result==1 & current_methodnumEC>=30 & current_methodnumEC<=39 & FRS_result==1 & (last_night==1)
label var tcp "Current user of any traditional contraceptive method"

gen longacting=current_methodnumEC>=1 & current_methodnumEC<=4 & mcp==1
label variable longacting "Current use of long acting contraceptive method"
label val cp mcp tcp longacting yes_no_dnk_nr_list

sort metainstanceID member_number
gen respondent=1 if firstname!="" & (HHQ_result==1 | HHQ_result==5)
replace respondent=0 if (HHQ_result==1 | HHQ_result==5) & respondent!=1
bysort metainstanceID: egen totalresp=total(respondent)
replace respondent=0 if totalresp>1 & totalresp!=. & relationship!=1 & relationship!=2

recast str244 names, force
save `CCPX'_Combined_ECRecode_$date.dta, replace

****************** KEEP GPS ONLY *******************
********************************************************************
preserve
keep if FQmetainstanceID!=""
keep FQlocationlatitude FQlocationlongitude FQlocationaltitude FQlocationaccuracy RE FQmetainstanceID FQlevel* household structure EA
export excel using "`CCPX'_FQGPS_$date.csv", firstrow(var) replace
restore

preserve
keep if metatag==1
keep locationlatitude locationlongitude locationaltitude locationaccuracy RE metainstanceID $level1name $level2name $level3name $level4name household structure EA
rename location* HQ*
export excel using "`CCPX'_HHQGPS_$date.csv", firstrow(var) replace

restore

****************** REMOVE IDENTIFYING INFORMATION *******************
*******************************************************************
drop *name* 
capture drop 
drop *latitude *longitude *altitude *accuracy FQlevel*
drop $level2name $level3name $level4name
drop flw_number_type flw_number_confirm

save `CCPX'_NONAME_ECRecode_$date.dta, replace 
