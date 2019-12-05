* PMA Core Female Questionnaire Data Checking file
**This .do file imports the Female Questionnaire (without migration) into Stata and cleans it

clear matrix
clear
set more off
label drop _all

cd "$datadir" 

*Macros
local CCPX $CCPX
local FQcsv $FQcsv
local FQcsv2 $FQcsv2
local year1 $year1
local year3 $year3

local today=c(current_date)
local date=subinstr("`today'", " ", "", .)

*Import the FQ csv file and save a dta as is
import delimited "$csvdir/`FQcsv'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
save `CCPX'_FQ.dta, replace

*If a second version of the form was used, append it to the dataset with the first version
clear
capture import delimited "$csvdir/`FQcsv2'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear
if _rc==0 {
	tempfile tempFQ
	save `tempFQ', replace

	use `CCPX'_FQ.dta, clear
	append using `tempFQ', force
	save, replace
	}
	
use `CCPX'_FQ.dta, clear

/* ---------------------------------------------------------
         SECTION 1: Drop columns
   --------------------------------------------------------- */

drop ewempty_form_warning
drop llocation_prompt
drop llocation_prompt_unlinked
drop consent_start
drop consent
capture drop consent_warning
drop sect_background
drop bdbday_note
drop bdbday_note_unlinked
drop fqaage_warn
drop fqaage_diff
drop fqaage_same
drop hcfhcf_note
drop hcf_future_error
drop hcf_error_bb_ym
drop hcf_error_bb_y
drop hcshcs_note
drop hcs_future_error
drop hcs_error_bb_ym
drop hcs_error_bb_y
drop hcs_error1ym
drop hcs_error1y
drop marriage_warning_err
drop sect_reproductive_health
drop fbfb_note
drop fb_future_error
drop fb_error_b10
drop ccal_fb_note
drop rbrb_note
drop rb_future_error
drop rb_error_b10
drop rb_error1ym
drop rb_error1y
drop ccal_rb_note
drop obob_note
drop other_birth_err
drop ccal_ob_note
drop abab_note
drop pregnancy_end_err
drop ccal_ab_note
drop moprbq
drop moprb_note
drop ccal_preg_note
drop ccal_months_preg_note
drop pdebirth_last_note
drop pdepreg_curr_note
drop pdebirth_desired
drop pdecurr_desired
drop future_prompt
drop sect_contraception
drop busbus_prompt
drop busbus_rec_birth
drop busbus_cur_marr
drop bus_future_error
drop bus_error_b10
drop bus_error1ym
drop bus_error1y
drop ccal_fp_user_nr_note
drop ccal_fp_user_note
drop wnuwant_none
drop wnuwant_some
drop wnunowant_none
drop wnunowant_some
drop adffp_ad_prompt_12m
drop fpofp_prompt_view
drop fpsfp_prompt_self
drop snyachieve_self
drop pnyachieve_parent
drop sect_sexual_activity
drop sexual_activity_note
drop afsafsq
drop afsage_note
drop afsbirth_note
drop afspreg_note
drop age_at_first_sex_check_1
drop ltsltsq
drop ltsmos_preg
drop ltsnomos_preg
drop last_time_sex_error1
drop last_time_sex_error2
capture drop lshlast_sex_note
drop sect_wge
drop wge_note_preg
drop wge_note_sex
drop sect_flw
drop thankyou
drop thankyou_non_avail
drop sect_end
drop sect_cc_calendar
drop y1c1cc_year1_note
drop y2c1cc_year2_note
drop y3c1cc_year3_note
drop cc_year1_col2_note
drop y1c2cc_year1_col2_note
drop y2c2cc_year2_col2_note
drop y3c2cc_year3_col2_note
drop metalogging

/* ---------------------------------------------------------
         SECTION 2: Rename
   --------------------------------------------------------- */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         SUBSECTION: Rename to original ODK names
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
rename ewok_continue ok_continue
rename giu* *
rename nyour_name your_name
rename nyour_name_check your_name_check
rename dsystem_date system_date
rename dsystem_date_check system_date_check
rename llevel* level*
rename lea EA
rename lstructure structure
rename lhousehold household
rename llocation_confirmation location_confirmation
capture rename pssign sign
capture rename pscheckbox checkbox
rename bdbirthdate_m birthdate_m
rename bdbirthdate_y birthdate_y
rename bdbirthdate birthdate
rename bdbirthdate_lab birthdate_lab
rename fq_age FQ_age
rename fqaage age
rename hcfhcf_m hcf_m
rename hcfhcf_y hcf_y
rename hcfhcf_y_lab hcf_y_lab
rename hcfhusband_cohabit_start_first husband_cohabit_start_first
rename hcfhusband_cohabit_start_first_l husband_cohabit_start_first_lab
rename hcshcs_m hcs_m
rename hcshcs_y hcs_y
rename hcshcs_y_lab hcs_y_lab
rename hcshusband_cohabit_start_recent husband_cohabit_start_recent
rename hcshusband_cohabit_start_recent_ husband_cohabit_start_recent_lab
rename fbfb_m fb_m
rename fbfb_y fb_y
rename fbfb_y_lab fb_y_lab
rename fbfirst_birth first_birth
rename fbfirst_birth_lab first_birth_lab
rename rbrb_m rb_m
rename rbrb_y rb_y
rename rbrb_y_lab rb_y_lab
rename rbrecent_birth recent_birth
rename rbrecent_birth_lab recent_birth_lab
rename obob_m ob_m
rename obob_y ob_y
rename obob_y_lab ob_y_lab
rename obother_birth other_birth
rename obother_birth_lab other_birth_lab
rename abab_m ab_m
rename abab_y ab_y
rename abab_y_lab ab_y_lab
rename abpregnancy_end pregnancy_end
rename abpregnancy_end_lab pregnancy_end_lab
rename mopmonths_pregnant months_pregnant
rename pdepregnancy_desired pregnancy_desired
rename heard_iud heard_IUD
rename heard_lam heard_LAM
rename cmcurrent_method current_method
rename cmcurrent_method_check current_method_check
rename busbus_m bus_m
rename busbus_y bus_y
rename busbus_y_lab bus_y_lab
rename busbegin_using begin_using
rename busbegin_using_full_lab begin_using_full_lab
rename fppstart_date_lab start_date_lab
rename fppfp_provider_check fp_provider_check
rename fppfp_provider_rw* fp_provider_rw*
rename wnuwhy_not_using why_not_using
rename wnuwhy_not_using_check why_not_using_check
rename adffp_ad_label_12m fp_ad_label_12m
rename adffp_ad_radio_12m fp_ad_radio_12m
rename adffp_ad_tv_12m fp_ad_tv_12m
rename adffp_ad_magazine_12m fp_ad_magazine_12m
rename adffp_ad_call_12m fp_ad_call_12m
rename adffp_ad_social_12m fp_ad_social_12m
rename fpofp_label_view fp_label_view
rename fpofp_promiscuous_view fp_promiscuous_view
rename fpofp_married_view fp_married_view
rename fpofp_no_child_view fp_no_child_view
rename fpofp_lifestyle_view fp_lifestyle_view
rename fpsfp_label_self fp_label_self
rename fpsfp_promiscuous_self fp_promiscuous_self
rename fpsfp_married_self fp_married_self
rename fpsfp_no_child_self fp_no_child_self
rename fpsfp_lifestyle_self fp_lifestyle_self
rename snyachieve_self_label achieve_self_label
rename snyachieve_school_self achieve_school_self
rename snyachieve_uni_self achieve_uni_self
rename snyachieve_job_self achieve_job_self
rename snyachieve_business_self achieve_business_self
rename snyachieve_partner_self achieve_partner_self
rename snyachieve_married_self achieve_married_self
rename snyachieve_children_self achieve_children_self
rename pnyachieve_parent_label achieve_parent_label
rename pnyachieve_school_parent achieve_school_parent
rename pnyachieve_uni_parent achieve_uni_parent
rename pnyachieve_job_parent achieve_job_parent
rename pnyachieve_business_parent achieve_business_parent
rename pnyachieve_partner_parent achieve_partner_parent
rename pnyachieve_married_parent achieve_married_parent
rename pnyachieve_children_parent achieve_children_parent
rename afsage_at_first_sex age_at_first_sex
rename ltslast_time_sex last_time_sex
rename lshlast_sex_label last_sex_label
capture rename lshlast_sex_not_want last_sex_not_want
capture rename lshlast_sex_pressured last_sex_pressured
capture rename lshlast_sex_not_consent last_sex_not_consent
capture rename lshlast_sex_duress last_sex_duress
rename frs_result FRS_result
rename y1c1* *
rename y2c1* *
rename y3c1* *
rename y1c2* *
rename y2c2* *
rename y3c2* *
rename hhq_gps HHQ_GPS
rename metainstanceid metainstanceID
rename age_at_first_use_children_warnin age_at_first_use_children_warn


/* ---------------------------------------------------------
         SECTION 3: Destring
   --------------------------------------------------------- */

destring structure_unlinked, replace
destring household_unlinked, replace
destring structure, replace
destring household, replace
destring FQ_age, replace
destring age, replace
destring highest_grade, replace
destring age_left_school, replace
destring age_met_partner, replace
destring times_married, replace
destring howlong_yrs, replace
destring howlong_hh_yrs, replace
destring nights_away_12mo, replace
destring nights_husb_away_12mo, replace
destring birth_events, replace
destring months_pregnant, replace
destring menstrual_period_value, replace
destring first_period, replace
destring wait_birth_value, replace
capture destring implant_duration_value, replace
destring fp_start_vaue, replace
destring age_at_first_use, replace
destring age_at_first_use_children, replace
destring age_at_first_sex, replace
destring last_time_sex_value, replace


/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */

label define FRS_result_list 1 "completed" 2 "not_at_home" 3 "postponed" 4 "refused" 5 "partly_completed" 6 "incapacitated"
label define acquainted_list 1 "very_well_acquainted" 2 "well_acquainted" 3 "not_well_acquainted" 4 "not_acquainted"
label define agree_2_list 1 "agree" 2 "disagree" -99 "-99"
label define agree_4_top_nolabel_list 1 "strongly_agree" 2 "agree" 3 "disagree" 4 "strongly_disagree" -99 "-99"
capture label define agree_down10_list 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" -88 "-88" -99 "-99"
label define blank_list 1 "1"
capture label define buy_decision_list 1 "respondent" 2 "husband" 3 "joint" 96 "other" -99 "-99"
label define cc_option1_list 40 "B" 41 "P" 42 "T" 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 30 "30" 31 "31" 39 "39"
label define cc_option2_list 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 96 "96"
label define children_none_list 1 "have_child" 2 "no_children" 3 "infertile" -88 "-88" -99 "-99"
label define children_some_list 1 "have_child" 2 "no_children" 3 "infertile" -88 "-88" -99 "-99"
label define decision_list 1 "you_alone" 2 "provider" 3 "partner" 4 "you_and_provider" 5 "you_and_partner" 96 "other" -88 "-88" -99 "-99"
label define dwmy_list 1 "days" 2 "weeks" 3 "months" 4 "years" -99 "-99"
label define first_sex_timing_list 1 "longer" 2 "sooner" 3 "right_time" -99 "-99"
label define first_sex_willing_list 1 "equal" 2 "respondent_more" 3 "partner_more" -99 "-99"
label define fp_start_list 1 "months" 2 "years" 3 "soon" 4 "after_birth" -88 "-88" -99 "-99"
label define fp_view_nolabel_list 1 "most" 2 "some" 3 "few" -99 "-99"
label define happy_5_top_list 1 "very_happy" 2 "happy" 3 "so_so" 4 "unhappy" 5 "very_unhappy" -99 "-99"
capture label define impduration_list 1 "months" 2 "years" -88 "-88" -99 "-99"
capture label define implant_list 1 "one" 2 "two" 3 "six" -88 "-88" -99 "-99"
label define important_top_3_nolabel_list 1 "very" 2 "somewhat" 3 "not" -99 "-99"
capture label define injectable_probe_list 1 "syringe" 2 "small_needle" -99 "-99"
capture label define injectable_self_list 1 "self" 2 "provider" -99 "-99"
label define is_paid_list 1 "cash" 2 "cash_and_kind" 3 "in_kind" 4 "not_paid" -99 "-99"
capture label define knowledgeable_list 1 "not_at_all" 2 "not_very" 3 "somewhat" 4 "very" -99 "-99"
label define last_time_fp_choice_list 1 "respondent" 2 "joint" 3 "partner" 96 "other" -99 "-99"
label define marital_status_list 1 "currently_married" 2 "currently_living_with_man" 3 "divorced" 4 "widow" 5 "never_married" -99 "-99"
label define menstrual_list 1 "days" 2 "weeks" 3 "months" 4 "years" 5 "menopausal_hysterectomy" 6 "before_birth" 7 "never" -99 "-99"
label define month_list 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" -88 "-88"
label define more_less_same_list 1 "more" 2 "less" 3 "same" -99 "-99"
label define much_top3_list 1 "very" 2 "not_very" 3 "not_at_all" -99 "-99"
label define ok_list 1 "ok"
label define partner_overall_list 1 "respondent" 2 "husband" 3 "joint" 96 "other" -99 "-99"
label define pregnancy_desired_list 1 "then" 2 "later" 3 "not_at_all" -99 "-99"
label define providers_self_list 1 "national_hosp" 2 "health_center" 3 "FP_clinic" 4 "mobile_clinic_public" 5 "regional_hosp" 6 "medical_center_surgery" 7 "medical_center" 8 "fieldworker_public" 9 "private_hospital" 10 "pharmacy" 11 "private_doctor" 12 "mobile_clinic_private" 13 "maternity" 14 "health_agent" 15 "store_market_supermarket" 16 "religious_org" 17 "community_event" 18 "friend_relative" 19 "self" 96 "other" -88 "-88" -99 "-99"
label define reason_left_list 1 "finished_ed" 2 "failed_exam" 3 "not_enjoy_school" 4 "too_far" 5 "wanted_to_work" 6 "got_married" 7 "got_pregnant" 8 "parents" 9 "economic" 10 "menstruation" 11 "illness" -99 "-99"
label define visits_list 1 "1" 2 "2" 3 "3"
label define wait_child_list 1 "months" 2 "years" 3 "soon" 4 "infertile" 96 "other" -88 "-88" -99 "-99"
label define whynomethod_list 1 "out_of_stock" 2 "unavailable" 3 "untrained" 4 "different" 5 "ineligible" 6 "decided_not_to_adopt" 7 "cost" 96 "other" -99 "-99"
label define yes_no_dnk_nr_list 1 "yes" 0 "no" -88 "-88" -99 "-99"
label define yes_no_list 1 "yes" 0 "no"
label define yes_no_np_nr_list 1 "yes" 0 "no" 2 "np" -99 "-99"
label define yes_no_nr_list 1 "yes" 0 "no" -99 "-99"
label define yes_no_nr_nolabel_list 1 "yes" 0 "no" -99 "-99"
label define yes_no_us_nr_list 1 "yes" 0 "no" -88 "-88" -99 "-99"

encode age_at_first_use_children_warn, gen(age_at_first_use_children_warnV2) lab(yes_no_list)

encode ok_continue, gen(ok_continueV2) lab(ok_list)

encode acquainted, gen(acquaintedV2) lab(acquainted_list)

encode reason_left_school, gen(reason_left_schoolV2) lab(reason_left_list)

encode marital_status, gen(marital_statusV2) lab(marital_status_list)

encode is_paid, gen(is_paidV2) lab(is_paid_list)

capture confirm var who_earns_more
if _rc==0{
	encode who_earns_more, gen(who_earns_moreV2) lab(more_less_same_list)
	}

capture confirm var money_knowledgeable
if _rc==0 {
	encode money_knowledgeable, gen(money_knowledgeableV2) lab(knowledgeable_list)
	}

encode pregnant, gen(pregnantV2) lab(yes_no_us_nr_list)

encode menstrual_period, gen(menstrual_periodV2) lab(menstrual_list)

encode pregnancy_desired, gen(pregnancy_desiredV2) lab(pregnancy_desired_list)

encode more_children_none, gen(more_children_noneV2) lab(children_none_list)

capture confirm var injectable_probe_current 
if _rc==0{
	encode injectable_probe_current, gen(injectable_probe_currentV2) lab(injectable_probe_list)
	}

capture confirm var injectable_self_current
if _rc==0 {
	encode injectable_self_current, gen(injectable_self_currentV2) lab(injectable_self_list)
	}

capture confirm var implant_type 
if _rc==0{
	encode implant_type, gen(implant_typeV2) lab(implant_list)
	}

capture confirm var implant_duration
if _rc==0 {
	encode implant_duration, gen(implant_durationV2) lab(impduration_list)
	}

encode fp_start, gen(fp_startV2) lab(fp_start_list)

encode fp_obtain_desired_cc, gen(fp_obtain_desired_ccV2) lab(yes_no_np_nr_list)

encode fp_obtain_desired_whynot, gen(fp_obtain_desired_whynotV2) lab(whynomethod_list)

capture confirm var implant_removed_who
if _rc==0 {
	encode implant_removed_who, gen(implant_removed_whoV2) lab(providers_self_list)
	}

encode first_sex_timing, gen(first_sex_timingV2) lab(first_sex_timing_list)

encode first_sex_willing, gen(first_sex_willingV2) lab(first_sex_willing_list)

encode last_time_sex, gen(last_time_sexV2) lab(dwmy_list)

encode last_time_sex_fp_choice, gen(last_time_sex_fp_choiceV2) lab(last_time_fp_choice_list)

encode times_visited, gen(times_visitedV2) lab(visits_list)

encode FRS_result, gen(FRS_resultV2) lab(FRS_result_list)

foreach var in edit_saved_check hh_confirmation your_name_check system_date_check location_confirmation ///
               name_check available begin_interview marriage_warning_first marriage_warning_recent ///
               menstrual_period_warning_1 menstrual_period_warning_4 ///
               menstrual_period_warning_2 implant_check age_at_first_use_check age_at_first_sex_check_2 ///
               age_at_first_sex_check_3 age_at_first_sex_check_4 {
	capture confirm var `var'
	if _rc==0 {
		encode `var', gen(`var'V2) lab(yes_no_list)
		}
	}

foreach var in checkbox witness_auto current_method_check fp_provider_check why_not_using_check  {
	encode `var', gen(`var'V2) lab(blank_list)
	}

foreach var in birthdate_m hcf_m hcs_m fb_m rb_m ob_m ab_m bus_m  {
	encode `var', gen(`var'V2) lab(month_list)
	}

foreach var in attending_school_yn enrolled_training_yn ever_partner_yn currently_have_partner ///
               work_yn_7days work_yn_12mo own_land_yn savings_yn mobile_money_yn money_knowledge_where_yn ///
               has_financial_goal_yn ever_birth other_birth_yn ever_miscarried_yn ///
               heard_female_sterilization heard_male_sterilization heard_implants heard_IUD ///
               heard_pill heard_emergency heard_male_condoms heard_female_condoms ///
                heard_rhythm heard_withdrawal heard_other heard_injectables heard_diaphragm heard_gel heard_beads heard_LAM ///
               current_user partner_know partner_know_nr implant_protect  ///
               fp_side_effects fp_side_effects_instructions fp_told_other_methods_cc ///
               fp_told_future_switch implant_removed_attempt fp_ever_user emergency_12mo_yn condom_12mo_yn ///
               visited_by_health_worker visited_fac_none visited_fac_some facility_fp_discussion ///
               have_insurance_yn first_sex_avoid_preg_yn first_sex_method_want last_time_sex_used_fp_yn ///
               flw_willing flw_number_yn sterlization_permanent_inform {
	capture confirm var `var'
	if _rc==0 {
		encode `var', gen(`var'V2) lab(yes_no_nr_list)
		}
	}


foreach var in married_self_decision will_marry_self_decision first_sex_self_decision  {
	encode `var', gen(`var'V2) lab(much_top3_list)
	}

foreach var in future_user_not_current future_user_pregnant fp_start_support partner_decision ///
               told_removal return_to_provider refer_to_relative fp_ever_used {
	capture confirm var `var'
	if _rc==0{
		encode `var', gen(`var'V2) lab(yes_no_dnk_nr_list)
		}
	}

capture confirm var other_wives
if _rc==0 {
	encode other_wives , gen(other_wivesV2) lab(yes_no_dnk_nr_list)
	}
	
foreach var in buy_decision_major buy_decision_daily buy_decision_medical buy_decision_clothes ///
               decide_spending_mine decide_spending_partner  {
	capture confirm var `var'
	if _rc==0 {
		encode `var', gen(`var'V2) lab(buy_decision_list)
		}
	}

foreach var in more_children_some more_children_pregnant  {
	encode `var', gen(`var'V2) lab(children_some_list)
	}

foreach var in wait_birth_none wait_birth_some wait_birth_pregnant  {
	encode `var', gen(`var'V2) lab(wait_child_list)
	}

foreach var in emotion_pregnant emotion_if_pregnant  {
	encode `var', gen(`var'V2) lab(happy_5_top_list)
	}


foreach var in shy_fp_clinic shy_fp_pharmacy  {
encode `var', gen(`var'V2) lab(agree_2_list)
	}

foreach var in partner_overall why_not_decision  {
	encode `var', gen(`var'V2) lab(partner_overall_list)
	}

foreach var in fp_final_decision rhythm_final lam_final  {
	encode `var', gen(`var'V2) lab(decision_list)
	}

foreach var in fp_ad_label_12m fp_ad_radio_12m fp_ad_tv_12m fp_ad_magazine_12m fp_ad_call_12m ///
               fp_ad_social_12m last_sex_label last_sex_not_want last_sex_pressured last_sex_not_consent ///
               last_sex_duress  {
	capture confirm var `var'
	if _rc==0 {
		encode `var', gen(`var'V2) lab(yes_no_nr_nolabel_list)
		}
	}

foreach var in fp_label_view fp_promiscuous_view fp_married_view fp_no_child_view fp_lifestyle_view  {
	encode `var', gen(`var'V2) lab(fp_view_nolabel_list)
	}

foreach var in fp_label_self fp_promiscuous_self fp_married_self fp_no_child_self fp_lifestyle_self  {
	encode `var', gen(`var'V2) lab(agree_4_top_nolabel_list)
	}

foreach var in achieve_self_label achieve_school_self achieve_uni_self achieve_job_self ///
               achieve_business_self achieve_partner_self achieve_married_self achieve_children_self ///
               achieve_parent_label achieve_school_parent achieve_uni_parent achieve_job_parent ///
               achieve_business_parent achieve_partner_parent achieve_married_parent ///
               achieve_children_parent  {
	encode `var', gen(`var'V2) lab(important_top_3_nolabel_list)
	}

foreach var in wge_seek_partner wge_trouble_preg wge_could_conflict wge_will_conflict wge_abnormal_birth ///
               wge_body_side_effects wge_switch_fp wge_confident_switch wge_finish_school_none ///
               wge_finish_school wge_take_care_family wge_decide_start_none wge_decide_start ///
               wge_partner_talk_start wge_decide_another wge_negotiate_stop_none wge_negotiate_stop ///
               wge_stop_support wge_force wge_hurt wge_promiscuous wge_confident_sex wge_decide_sex ///
               wge_tell_no_sex wge_avoid_sex  {
	capture confirm var `var'
	if _rc==0{
		encode `var', gen(`var'V2) lab(agree_down10_list)
		}
	}

forval year = `year1'/`year3' {
	encode verify_cc_col1_`year', gen(verify_cc_col1_`year'V2) lab(yes_no_list)

	foreach month in 01 02 03 04 05 06 07 08 09 10 11 12 {
		encode cc_col1_`year'_`month', gen(cc_col1_`year'_`month'V2) lab(cc_option1_list)
		encode cc_col2_`year'_`month', gen(cc_col2_`year'_`month'V2) lab(cc_option2_list)
		}
	}

	
unab encoded : *V2
local stubs: subinstr local encoded "V2" "", all
foreach var in `stubs' {
	order `var'V2, after(`var')
	drop `var'
	rename `var'V2 `var'
	}	
	
label define FRS_result_list 1 "Completed" 2 "Not at home" 3 "Postponed" 4 "Refused" 5 "Partly completed" 6 "Incapacitated", replace
label define acquainted_list 1 "Very well acquainted" 2 "Well acquainted" 3 "Not well acquainted" 4 "Not acquainted", replace
label define agree_2_list 1 "Agree" 2 "Disagree" -99 "No response", replace
label define agree_4_top_nolabel_list 1 "4" 2 "3" 3 "2" 4 "1" -99 "-99", replace
capture label define agree_down10_list 1 "Strongly disagree (1)" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Strongly agree (10)" -88 "Do not know" -99 "No response", replace
label define blank_list 1 "", replace
capture label define buy_decision_list 1 "Respondent" 2 "Husband/partner" 3 "Respondent and husband/partner" 96 "Someone else" -99 "No response", replace
label define cc_option1_list 40 "B. Births" 41 "P. Pregnancies" 42 "T. Terminations" 0 "0. No Method Used" 1 "1. Female Sterilization" 2 "2. Male Sterilization" 3 "3. Implant" 4 "4. IUD" 5 "5. Injectables" 6 "6. Injectables 3mo" 7 "7. Pill" 8 "8. Emergency Contraception" 9 "9. Male Condom" 10 "10. Female Condom" 11 "11. Diaphragm" 12 "12. Foam / Jelly" 13 "13. Std Days / Cycle beads" 14 "14. LAM" 15 "15. N tablet" 16 "16. Injectables SC" 30 "30. Rhythm method" 31 "31. Withdrawal" 39 "39. Other traditional methods", replace
label define cc_option2_list 1 "1. Infrequent sex / husband away" 2 "2. Became pregnant while using" 3 "3. Wanted to become pregnant" 4 "4. Husband / partner disapproved" 5 "5. Wanted more effective method" 6 "6. Side effects / health concerns" 7 "7. Lack of access / too far" 8 "8. Costs too much" 9 "9. Inconvenient to use" 10 "10. Up to god / fatalistic" 11 "11. Difficult to get pregnant / menopausal" 12 "12. Marital dissolution / separation" 96 "96. Other", replace
label define children_none_list 1 "Have a child" 2 "Prefer no children" 3 "Says she can't get pregnant" -88 "Undecided / Do not know" -99 "No response", replace
label define children_some_list 1 "Have another child" 2 "No more" 3 "Says she can't get pregnant" -88 "Undecided / Do not know" -99 "No response", replace
label define decision_list 1 "You alone" 2 "Provider" 3 "Partner" 4 "You and provider" 5 "You and partner" 96 "Other" -88 "Do not know" -99 "No response", replace
label define dwmy_list 1 "X days ago" 2 "X weeks ago" 3 "X months ago" 4 "X years ago" -99 "No response", replace
label define first_sex_timing_list 1 "Waited longer" 2 "Not have waited so long" 3 "It was the right time" -99 "No response", replace
label define first_sex_willing_list 1 "Equally willing" 2 "Respondent more willing" 3 "Partner more willing" -99 "No response", replace
label define fp_start_list 1 "X months" 2 "X years" 3 "Soon/now" 4 "After the birth of this child" -88 "Do not know" -99 "No response", replace
label define fp_view_nolabel_list 1 "Most" 2 "Some" 3 "Few" -99 "-99", replace
label define happy_5_top_list 1 "Very happy" 2 "Sort of happy" 3 "Mixed happy and unhappy" 4 "Sort of unhappy" 5 "Very unhappy" -99 "No response", replace
capture label define impduration_list 1 "X months" 2 "X years" -88 "Do not know" -99 "No response", replace
capture label define implant_list 1 "1" 2 "2" 3 "6" -88 "Do not know" -99 "No response", replace
label define important_top_3_nolabel_list 1 "VERY IMPORTANT" 2 "SOMEWHAT IMPORTANT" 3 "NOT IMPORTANT" -99 "No Response", replace
capture label define injectable_probe_list 1 "Syringe" 2 "Small needle (Sayana Press)" -99 "No Response", replace
label define injectable_self_list 1 "Self" 2 "Provider" -99 "No response", replace
label define is_paid_list 1 "Cash" 2 "Cash and kind" 3 "In-kind" 4 "Not paid" -99 "No response", replace
capture label define knowledgeable_list 1 "Not knowledgeable at all" 2 "Not very knowledgeable" 3 "Somewhat knowledgeable" 4 "Very knowledgeable" -99 "No response", replace
label define last_time_fp_choice_list 1 "Respondent" 2 "Respondent and partner" 3 "Partner" 96 "Someone else" -99 "No response", replace
label define marital_status_list 1 "Yes, currently married" 2 "Yes, living with a man" 3 "Not currently in union: Divorced / separated" 4 "Not currently in union: Widow" 5 "No, never in union" -99 "No response", replace
label define menstrual_list 1 "X days ago" 2 "X weeks ago" 3 "X months ago" 4 "X years ago" 5 "Menopausal / Hysterectomy" 6 "Before last birth" 7 "Never menstruated" -99 "No response", replace
label define month_list 1 "February" 2 "March" 3 "April" 4 "May" 5 "June" 6 "July" 7 "August" 8 "September" 9 "October" 10 "November" 11 "December" -88 "Do not know", replace
label define more_less_same_list 1 "More" 2 "Less" 3 "Same" -99 "No response", replace
label define much_top3_list 1 "Very much" 2 "Not very much" 3 "Not at all" -99 "No response", replace
label define ok_list 1 "OK", replace
label define partner_overall_list 1 "Mainly respondent" 2 "Mainly husband/partner" 3 "Joint decision" 96 "Other" -99 "No response", replace
label define pregnancy_desired_list 1 "Then" 2 "Later" 3 "Not at all" -99 "No response", replace
label define providers_self_list 1 "National hospital center" 2 "Health and social services center (public)" 3 "Family planning clinic" 4 "Mobile clinic (public)" 5 "Regional hospital center" 6 "Medical center with surgery unit (public)" 7 "Medical center (public)" 8 "Fieldworker and community health volunteers (public)" 9 "Private hospital or clinic" 10 "Pharmacy" 11 "Private practice" 12 "Mobile clinic (private)" 13 "Maternity" 14 "Health agent" 15 "Store/market/supermarket/mobile vendors" 16 "Religious organizations" 17 "Community event" 18 "Friend / parent" 19 "Self" 96 "Other" -88 "Do not know" -99 "No response", replace
label define reason_left_list 1 "Finished education" 2 "Failed exams" 3 "Did not enjoy school" 4 "School was too far" 5 "Wanted to start working" 6 "Got married" 7 "Got pregnant" 8 "Parents did not want you to continue" 9 "Economic reasons" 10 "Menstruation / period" 11 "Illness" -99 "No response", replace
label define visits_list 1 "1st time" 2 "2nd time" 3 "3rd time", replace
label define wait_child_list 1 "X months" 2 "X years" 3 "Soon/now" 4 "Says she can't get pregnant" 96 "Other" -88 "Do not know" -99 "No response", replace
label define whynomethod_list 1 "Method out of stock that day" 2 "Method not available at all" 3 "Provider not trained to provide the method" 4 "Provider recommended a different method" 5 "Not eligible for method" 6 "Decided not to adopt a method" 7 "Too costly" 96 "Other" -99 "No response", replace
label define yes_no_dnk_nr_list 1 "Yes" 0 "No" -88 "Do not know" -99 "No response", replace
label define yes_no_list 1 "Yes" 0 "No", replace
label define yes_no_np_nr_list 1 "Yes" 0 "No" 2 "Did not have a preference" -99 "No response", replace
label define yes_no_nr_list 1 "Yes" 0 "No" -99 "No response", replace
label define yes_no_nr_nolabel_list 1 "Yes" 0 "No" -99 "-99", replace
label define yes_no_us_nr_list 1 "Yes" 0 "No" -88 "Do not know" -99 "No response", replace

/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */

label define o2s_binary_label 0 No 1 Yes

capture confirm var activity_30d 
if _rc==0{
	***** Begin split of "activity_30d"
	* Create padded variable
	gen activity_30dV2 = " " + activity_30d + " "

	* Build binary variables for each choice
	gen activity_30d_agricultural = 0 if activity_30d != ""
	replace activity_30d_agricultural = 1 if strpos(activity_30dV2, " agricultural ")
	label var activity_30d_agricultural "Did you take part in any of these activities over the past 3 : Agricultural work"

	gen activity_30d_livestock = 0 if activity_30d != ""
	replace activity_30d_livestock = 1 if strpos(activity_30dV2, " livestock ")
	label var activity_30d_livestock "Did you take part in any of these activities over  : Raising poultry / livestock"

	gen activity_30d_ghee = 0 if activity_30d != ""
	replace activity_30d_ghee = 1 if strpos(activity_30dV2, " ghee ")
	label var activity_30d_ghee "Did you take part in any of these activities  : Producing ghee / cheese / butter"

	gen activity_30d_fuel = 0 if activity_30d != ""
	replace activity_30d_fuel = 1 if strpos(activity_30dV2, " fuel ")
	label var activity_30d_fuel "Did you take part in any of these activities ov : Collecting fuel / wood-cutting"

	gen activity_30d_foodprep = 0 if activity_30d != ""
	replace activity_30d_foodprep = 1 if strpos(activity_30dV2, " food_prep ")
	label var activity_30d_foodprep "Did you take part in any of these activities over the past 30 d : Preparing food"

	gen activity_30d_sewing = 0 if activity_30d != ""
	replace activity_30d_sewing = 1 if strpos(activity_30dV2, " sewing ")
	label var activity_30d_sewing "Did you take part in any of these activities  : Sewing / embroidery / crocheting"

	gen activity_30d_textile = 0 if activity_30d != ""
	replace activity_30d_textile = 1 if strpos(activity_30dV2, " textile ")
	label var activity_30d_textile "Did you take part in any  : Producing straw products / carpets / textile / ropes"

	gen activity_30d_services = 0 if activity_30d != ""
	replace activity_30d_services = 1 if strpos(activity_30dV2, " services ")
	label var activity_30d_services "Did you take part in a : Offering services for others in a house, shop, or hotel"

	gen activity_30d_selfwork = 0 if activity_30d != ""
	replace activity_30d_selfwork = 1 if strpos(activity_30dV2, " self_work ")
	label var activity_30d_selfwork "Did you take part in any of these activities over the pa : Independent paid work"

	gen activity_30d_market = 0 if activity_30d != ""
	replace activity_30d_market = 1 if strpos(activity_30dV2, " market ")
	label var activity_30d_market "Did you take part  : Buying / selling goods in the market / the street / at home"

	gen activity_30d_construction = 0 if activity_30d != ""
	replace activity_30d_construction = 1 if strpos(activity_30dV2, " construction ")
	label var activity_30d_construction "Did you take part in any of these activities over : Helping in construction work"

	gen activity_30d_learning = 0 if activity_30d != ""
	replace activity_30d_learning = 1 if strpos(activity_30dV2, " learning ")
	label var activity_30d_learning "Did you take part in any of these activities over the past 30 : Learning a skill"

	* Clean up: reorder binary variables, label binary variables, drop padded variable
	order activity_30d_agricultural-activity_30d_learning, after(activity_30d)
	label values activity_30d_agricultural-activity_30d_learning o2s_binary_label
	drop activity_30dV2
	}
***** Begin split of "current_method"
* Create padded variable
gen current_methodV2 = " " + current_method + " "

* Build binary variables for each choice
gen femalester = 0 if current_method != ""
replace femalester = 1 if strpos(current_methodV2, " female_sterilization ")
label var femalester "Which method or methods are you using? : Female sterilization"

gen malester= 0 if current_method != ""
replace malester = 1 if strpos(current_methodV2, " male_sterilization ")
label var malester "Which method or methods are you using?: Male sterilization"

gen implant = 0 if current_method != ""
replace implant = 1 if strpos(current_methodV2, " implants ")
label var implant "Which method or methods are you using?:  Implant"

gen IUD = 0 if current_method != ""
replace IUD = 1 if strpos(current_methodV2, " IUD ")
label var IUD "Which method or methods are you using?:  IUD"

gen injectables = 0 if current_method != ""
replace injectables = 1 if strpos(current_methodV2, " injectables ")
label var injectables "Which method or methods are you using? : Injectables"

gen injectables1 = 0 if current_method != ""
replace injectables1 = 1 if strpos(current_methodV2, " injectables_1mo ")
label var injectables1 "Which method or methods are you using? : Injectables 1mo"

gen injectables3 = 0 if current_method != ""
replace injectables3 = 1 if strpos(current_methodV2, " injectables_3mo ")
label var injectables3 "Which method or methods are you using? : Injectables 3mo"

gen pill = 0 if current_method != ""
replace pill = 1 if strpos(current_methodV2, " pill ")
label var pill "Which method or methods are you using? : Pill"

gen EC = 0 if current_method != ""
replace EC = 1 if strpos(current_methodV2, " emergency ")
label var EC "Which method or methods are you using? : Emergency Contraception"

gen malecondom = 0 if current_method != ""
replace malecondom = 1 if strpos(current_methodV2, " male_condoms ")
label var malecondom "Which method or methods are you using?: Male condom"

gen femalecondom = 0 if current_method != ""
replace femalecondom = 1 if strpos(current_methodV2, " female_condoms ")
label var femalecondom "Which method or methods are you using?: Female condom"

gen diaphragm = 0 if current_method != ""
replace diaphragm = 1 if strpos(current_methodV2, " diaphragm ")
label var diaphragm "Which method or methods are you using? : Diaphragm"

gen foamjelly = 0 if current_method != ""
replace foamjelly = 1 if strpos(current_methodV2, " foam ")
label var foamjelly "Which method or methods are you using? : Foam/Jelly"

gen stndrddays = 0 if current_method != ""
replace stndrddays = 1 if strpos(current_methodV2, " beads ")
label var stndrddays "Which method or methods are you using? : Standard Days/Cycle beads"

gen LAM = 0 if current_method != ""
replace LAM = 1 if strpos(current_methodV2, " LAM ")
label var LAM "Which method or methods are you using? : LAM"

gen N_tablet = 0 if current_method != ""
replace N_tablet = 1 if strpos(current_methodV2, " N_tablet ")
label var N_tablet "Which method or methods are you using? : N tablet"

gen injectables_sc = 0 if current_method != ""
replace injectables_sc = 1 if strpos(current_methodV2, " injectables_sc ")
label var injectables_sc "Which method or methods are you using? : Injectables SC"

gen rhythm = 0 if current_method != ""
replace rhythm = 1 if strpos(current_methodV2, " rhythm ")
label var rhythm "Which method or methods are you using? : Rhythm method"

gen withdrawal = 0 if current_method != ""
replace withdrawal = 1 if strpos(current_methodV2, " withdrawal ")
label var withdrawal "Which method or methods are you using? : Withdrawal"

gen othertrad = 0 if current_method != ""
replace othertrad = 1 if strpos(current_methodV2, " other_traditional ")
label var othertrad "Which method or methods are you using? : Other traditional method"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order femalester-othertrad, after(current_method)
label values femalester-othertrad o2s_binary_label
drop current_methodV2

***** Begin split of "reason_for_location"
* Create padded variable
gen reason_for_locationV2 = " " + reason_for_location + " "

* Build binary variables for each choice
gen reason_for_locat_close = 0 if reason_for_location != ""
replace reason_for_locat_close = 1 if strpos(reason_for_locationV2, " close ")
label var reason_for_locat_close "Why would you choose this location? : Close to home"

gen reason_for_locat_discreet = 0 if reason_for_location != ""
replace reason_for_locat_discreet = 1 if strpos(reason_for_locationV2, " discreet ")
label var reason_for_locat_discreet "Why would you choose this location? : Discreet location"

gen reason_for_locat_confidentiality = 0 if reason_for_location != ""
replace reason_for_locat_confidentiality = 1 if strpos(reason_for_locationV2, " confidentiality ")
label var reason_for_locat_confidentiality "Why would you choose this location? : Know confidentiality will be respected"

gen reason_for_locat_method = 0 if reason_for_location != ""
replace reason_for_locat_method = 1 if strpos(reason_for_locationV2, " method ")
label var reason_for_locat_method "Why would you choose this location? : Have the method that I want"

gen reason_for_locat_reputation = 0 if reason_for_location != ""
replace reason_for_locat_reputation = 1 if strpos(reason_for_locationV2, " reputation ")
label var reason_for_locat_reputation "Why would you choose this location? : Providers have a good reputation"

gen reason_for_locat_recommended = 0 if reason_for_location != ""
replace reason_for_locat_recommended = 1 if strpos(reason_for_locationV2, " recommended ")
label var reason_for_locat_recommended "Why would you choose this location? : Recommend by friend/relative"

gen reason_for_locat_other = 0 if reason_for_location != ""
replace reason_for_locat_other = 1 if strpos(reason_for_locationV2, " other ")
label var reason_for_locat_other "Why would you choose this location? : Other"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order reason_for_locat_close-reason_for_locat_other, after(reason_for_location)
label values reason_for_locat_close-reason_for_locat_other o2s_binary_label
drop reason_for_locationV2

capture confirm var implant_not_removed
if _rc==0 {
	***** Begin split of "implant_not_removed"
	* Create padded variable
	gen implant_not_removedV2 = " " + implant_not_removed + " "

	* Build binary variables for each choice
	gen implant_not_rem_notopen = 0 if implant_not_removed != ""
	replace implant_not_rem_notopen = 1 if strpos(implant_not_removedV2, " not_open ")
	label var implant_not_rem_notopen "Why were you not able to have your implant removed? : Facility not open"

	gen implant_not_rem_unavailable = 0 if implant_not_removed != ""
	replace implant_not_rem_unavailable = 1 if strpos(implant_not_removedV2, " unavailable ")
	label var implant_not_rem_unavailable "Why were you not able to have your implant re : Qualified provider not available"

	gen implant_not_rem_unsuccessful = 0 if implant_not_removed != ""
	replace implant_not_rem_unsuccessful = 1 if strpos(implant_not_removedV2, " unsuccessful ")
	label var implant_not_rem_unsuccessful "Why were you not able to h : Provider attempted but could not remove the implant"

	gen implant_not_rem_refused = 0 if implant_not_removed != ""
	replace implant_not_rem_refused = 1 if strpos(implant_not_removedV2, " refused ")
	label var implant_not_rem_refused "Why were you not able to have your implant removed? : Provider refused"

	gen implant_not_rem_cost = 0 if implant_not_removed != ""
	replace implant_not_rem_cost = 1 if strpos(implant_not_removedV2, " cost ")
	label var implant_not_rem_cost "Why were you not able to have your implant removed? : Cost of removal services"

	gen implant_not_rem_travel = 0 if implant_not_removed != ""
	replace implant_not_rem_travel = 1 if strpos(implant_not_removedV2, " travel ")
	label var implant_not_rem_travel "Why were you not able to have your implant removed? : Travel cost"

	gen implant_not_rem_counseledagainst = 0 if implant_not_removed != ""
	replace implant_not_rem_counseledagainst = 1 if strpos(implant_not_removedV2, " counseled_against ")
	label var implant_not_rem_counseledagainst "Why were you not able to have your implant  : Provider counseled against removal"

	gen implant_not_rem_toldreturn = 0 if implant_not_removed != ""
	replace implant_not_rem_toldreturn = 1 if strpos(implant_not_removedV2, " told_return ")
	label var implant_not_rem_toldreturn "Why were you not able to have your implant removed? : Told to return another day"

	gen implant_not_rem_toldelsewhere = 0 if implant_not_removed != ""
	replace implant_not_rem_toldelsewhere = 1 if strpos(implant_not_removedV2, " told_elsewhere ")
	label var implant_not_rem_toldelsewhere "Why were you not able to have your implant removed? : Referred elsewhwere"

	gen implant_not_rem_other = 0 if implant_not_removed != ""
	replace implant_not_rem_other = 1 if strpos(implant_not_removedV2, " other ")
	label var implant_not_rem_other "Why were you not able to have your implant removed? : Other"

	* Clean up: reorder binary variables, label binary variables, drop padded variable
	order implant_not_rem_notopen-implant_not_rem_other, after(implant_not_removed)
	label values implant_not_rem_notopen-implant_not_rem_other o2s_binary_label
	drop implant_not_removedV2
	}

***** Begin split of "why_not_using"
* Create padded variable
gen why_not_usingV2 = " " + why_not_using + " "

* Build binary variables for each choice
gen why_not_usingnotmarr = 0 if why_not_using != ""
replace why_not_usingnotmarr = 1 if strpos(why_not_usingV2, " not_married ")
label var why_not_usingnotmarr "Can you tell me why you are not using a method to prevent pregnanc : Not married"

gen why_not_usingnosex = 0 if why_not_using != ""
replace why_not_usingnosex = 1 if strpos(why_not_usingV2, " infrequent_sex ")
label var why_not_usingnosex "Can you tell me why you are not using a method : Infrequent sex / Not having sex"

gen why_not_usingmeno = 0 if why_not_using != ""
replace why_not_usingmeno = 1 if strpos(why_not_usingV2, " menopausal_hysterectomy ")
label var why_not_usingmeno "Can you tell me why you are not using a method to pr : Menopausal / Hysterectomy"

gen why_not_usingsubfec = 0 if why_not_using != ""
replace why_not_usingsubfec = 1 if strpos(why_not_usingV2, " infecund ")
label var why_not_usingsubfec "Can you tell me why you are not using a method to prevent : Subfecund / Infecund"

gen why_not_usingnomens = 0 if why_not_using != ""
replace why_not_usingnomens = 1 if strpos(why_not_usingV2, " not_menstruated ")
label var why_not_usingnomens "Can you tell me why you are not using a metho : Not menstruated since last birth"

gen why_not_usingbreastfd = 0 if why_not_using != ""
replace why_not_usingbreastfd = 1 if strpos(why_not_usingV2, " breastfeeding ")
label var why_not_usingbreastfd "Can you tell me why you are not using a method to prevent pregna : Breastfeeding"

gen why_not_usinghsbndaway = 0 if why_not_using != ""
replace why_not_usinghsbndaway = 1 if strpos(why_not_usingV2, " husband_away ")
label var why_not_usinghsbndaway "Can you tell me why you are not using a method  : Husband away for multiple days"

gen why_not_usinguptogod = 0 if why_not_using != ""
replace why_not_usinguptogod = 1 if strpos(why_not_usingV2, " fatalistic ")
label var why_not_usinguptogod "Can you tell me why you are not using a method to preve : Up to God / fatalistic"

gen why_not_usingrespopp = 0 if why_not_using != ""
replace why_not_usingrespopp = 1 if strpos(why_not_usingV2, " respondent_opposed ")
label var why_not_usingrespopp "Can you tell me why you are not using a method to prevent p : Respondent opposed"

gen why_not_usinghusbopp = 0 if why_not_using != ""
replace why_not_usinghusbopp = 1 if strpos(why_not_usingV2, " partner_opposed ")
label var why_not_usinghusbopp "Can you tell me why you are not using a method to pr : Husband / partner opposed"

gen why_not_usingotheropp = 0 if why_not_using != ""
replace why_not_usingotheropp = 1 if strpos(why_not_usingV2, " others_opposed ")
label var why_not_usingotheropp "Can you tell me why you are not using a method to prevent pregn : Others opposed"

gen why_not_usingrelig = 0 if why_not_using != ""
replace why_not_usingrelig = 1 if strpos(why_not_usingV2, " religion ")
label var why_not_usingrelig "Can you tell me why you are not using a method to preven : Religious prohibition"

gen why_not_usingdkmethod = 0 if why_not_using != ""
replace why_not_usingdkmethod = 1 if strpos(why_not_usingV2, " no_knowledge ")
label var why_not_usingdkmethod "Can you tell me why you are not using a method to prevent preg : Knows no method"

gen why_not_usingdksource = 0 if why_not_using != ""
replace why_not_usingdksource = 1 if strpos(why_not_usingV2, " no_source_known ")
label var why_not_usingdksource "Can you tell me why you are not using a method to prevent preg : Knows no source"

gen why_not_usingfearside = 0 if why_not_using != ""
replace why_not_usingfearside = 1 if strpos(why_not_usingV2, " side_effects ")
label var why_not_usingfearside "Can you tell me why you are not using a method to prevent : Fear of side effects"

gen why_not_usinghealth = 0 if why_not_using != ""
replace why_not_usinghealth = 1 if strpos(why_not_usingV2, " health ")
label var why_not_usinghealth "Can you tell me why you are not using a method to prevent preg : Health concerns"

gen why_not_usingaccess = 0 if why_not_using != ""
replace why_not_usingaccess = 1 if strpos(why_not_usingV2, " no_access ")
label var why_not_usingaccess "Can you tell me why you are not using a method to pr : Lack of access  / too far"

gen why_not_usingcost = 0 if why_not_using != ""
replace why_not_usingcost = 1 if strpos(why_not_usingV2, " cost ")
label var why_not_usingcost "Can you tell me why you are not using a method to prevent pregn : Costs too much"

gen why_not_usingprfnotavail = 0 if why_not_using != ""
replace why_not_usingprfnotavail = 1 if strpos(why_not_usingV2, " preferred_unavailable ")
label var why_not_usingprfnotavail "Can you tell me why you are not using a method  : Preferred method not available"

gen why_not_usingnomethod = 0 if why_not_using != ""
replace why_not_usingnomethod = 1 if strpos(why_not_usingV2, " no_method_available ")
label var why_not_usingnomethod "Can you tell me why you are not using a method to prevent  : No method available"

gen why_not_usinginconv = 0 if why_not_using != ""
replace why_not_usinginconv = 1 if strpos(why_not_usingV2, " inconvenient ")
label var why_not_usinginconv "Can you tell me why you are not using a method to prevent  : Inconvenient to use"

gen why_not_usingbodyproc = 0 if why_not_using != ""
replace why_not_usingbodyproc = 1 if strpos(why_not_usingV2, " interferes_with_body ")
label var why_not_usingbodyproc "Can you tell me why you are not using a metho : Interferes with body’s processes"

gen why_not_usingother = 0 if why_not_using != ""
replace why_not_usingother = 1 if strpos(why_not_usingV2, " other ")
label var why_not_usingother "Can you tell me why you are not using a method to prevent pregnancy?  PR : Other"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order why_not_usingnotmarr-why_not_usingother, after(why_not_using)
label values why_not_usingnotmarr-why_not_usingother o2s_binary_label
drop why_not_usingV2

***** Begin split of "first_sex_applied"
* Create padded variable
gen first_sex_appliedV2 = " " + first_sex_applied + " "

* Build binary variables for each choice
gen first_sex_applied_curious = 0 if first_sex_applied != ""
replace first_sex_applied_curious = 1 if strpos(first_sex_appliedV2, " curious ")
label var first_sex_applied_curious "Which of these applied to you at the first time you had sex? : I was curious"

gen first_sex_applied_carriedaway = 0 if first_sex_applied != ""
replace first_sex_applied_carriedaway = 1 if strpos(first_sex_appliedV2, " carried_away ")
label var first_sex_applied_carriedaway "Which of these applied to you at the first time you had sex : I was carried away"

gen first_sex_applied_substance = 0 if first_sex_applied != ""
replace first_sex_applied_substance = 1 if strpos(first_sex_appliedV2, " substance ")
label var first_sex_applied_substance "Which of these applied to you at the  : I was under the influence of a substance"

gen first_sex_applied_expected = 0 if first_sex_applied != ""
replace first_sex_applied_expected = 1 if strpos(first_sex_appliedV2, " expected ")
label var first_sex_applied_expected "Which of these applied to you at the first : I was doing what was expected of me"

gen first_sex_applied_forced = 0 if first_sex_applied != ""
replace first_sex_applied_forced = 1 if strpos(first_sex_appliedV2, " forced ")
label var first_sex_applied_forced "Which of these applied to you at the first time y : I was forced against my will"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order first_sex_applied_curious-first_sex_applied_forced, after(first_sex_applied)
label values first_sex_applied_curious-first_sex_applied_forced o2s_binary_label
drop first_sex_appliedV2



/* ---------------------------------------------------------
         SECTION 6: Label variable
   --------------------------------------------------------- */

label var ok_continue "Press OK to continue"
label var edit_saved_check "Did you check the Edit Saved forms menu for a linked female questionnaire?"
label var acknowledge_unlinked "Provide your signature to acknowledge that there is no linked FQ form"
label var close_exit "Look for a linked female questionnaire through the ‘Edit Saved Forms' Menu."
label var ea_unlinked "Enumeration Area:"
label var structure_unlinked "Structure number:"
label var household_unlinked "Household number:"
label var hh_confirmation "Are you in the correct household?"
label var your_name "Your name:"
label var your_name_check "Is this your name?"
label var name_typed "Enter your name below."
label var system_date "Current date and time."
label var system_date_check "Is this date and time correct?"
label var manual_date "Record the correct date and time."
label var today "Date of interview"
label var EA "Enumeration Area:"
label var structure "Structure number:"
label var household "Household number:"
label var location_confirmation "Is the above information correct?"
label var name_check "CHECK: You should be attempting to interview NAME. Is that correct?"
label var available "Is the respondent present and available to be interviewed today?"
label var acquainted "How well acquainted are you with the respondent?"
label var begin_interview "May I begin the interview now?"
label var sign "Respondent's signature"
label var checkbox "Checkbox"
label var consent_obtained "Obtained consent"
label var witness_auto "Interviewer's ID:"
label var witness_manual "Interviewer's ID. Please record your ID as a witness to the consent process."
label var firstname_raw "Respondent's first name."
label var firstname "Firstname"
label var birthdate_m "Month:"
label var birthdate_y "Year:"
label var birthdate "Birthdate"
label var FQ_age "How old were you at your last birthday?"
label var school "Highest level of education attained"
label var highest_grade "What is the highest grade/level you completed at that level?"
label var attending_school_yn "Are you still attending school?"
label var age_left_school "How old were you when you left school?"
label var reason_left_school "What was the main reason for stopping your education?"
label var enrolled_training_yn "Are you currently enrolled in any training program?"
label var marital_status "Are you currently married or living together with a man as if married?"
label var married_self_decision "How much were you involved in the decision to get married"
label var will_marry_self_decision "How much do you think you will be involved in the decision to get married"
label var ever_partner_yn "Have you ever had a partner / boyfriend?"
label var age_met_partner "How old were you the first time you had a boyfriend or partner?"
label var currently_have_partner "Do you currently have a boyfriend or partner?"
label var times_married "How many times have you been married or lived with a man as if married?"
label var hcf_m "Month:"
label var hcf_y "Year:"
label var husband_cohabit_start_first "Date of first marriage/cohabitation"
label var marriage_warning_first "CHECK: Based on the response you entered in 106a, the respondent was possibly 15"
label var hcs_m "Month:"
label var hcs_y "Year:"
label var husband_cohabit_start_recent "Date of most recent marriage/cohabitation"
label var marriage_warning_recent "CHECK: Based on the response you entered in 107a, the respondent was possibly 15"
capture label var other_wives "Does your husband/partner have other wives/live with other women as if married?"
label var howlong_yrs "How long have you been living continuously in RESIDENCE?"
label var howlong_hh_yrs "How long have you been living continuously in this particular house / structure?"
label var nights_away_12mo "In the last 12 mo for how many nights have you slept away from your community?"
label var nights_husb_away_12mo "In the last 12 mo for how many nights has your husband slept away ?"
label var work_yn_7days "Aside from your own housework, have you done any work in the last seven days?"
label var work_yn_12mo "Aside from your own housework, have you done any work in the last 12 months?"
label var is_paid "Are you paid in cash or kind for this work or are you not paid at all?"
label var buy_decision_major "Who usually makes decisions about making large household purchases"
label var buy_decision_daily "Who usually makes decisions about making household purchases for daily needs"
label var buy_decision_medical "Who usually makes decisions about getting medical treatment for yourself"
capture label var buy_decision_clothes "Who usually makes decisions about buying clothes for yourself"
capture label var decide_spending_mine "Who usually makes decisions about how your earnings will be used"
capture label var decide_spending_partner "Who usually makes decisions about how your partner's earnings will be used"
capture label var own_land_yn "Do you own any land, either jointly or by yourself?"
capture label var who_earns_more "Would you say that the money that you earn is more than what your partner earns"
capture label var activity_30d "Did you take part in any of these activities over the past 30 days?"
capture label var savings_yn "Do you currently have any savings for the future?"
capture label var mobile_money_yn "Do you currently have any mobile money accounts (e.g. Mpesa)?"
capture label var money_knowledgeable "When it comes to managing financial matters, what is your level of knowledge"
capture label var money_knowledge_where_yn "Do you know where to go for financial information or advice?"
capture label var has_financial_goal_yn "Do you have financial goals toward which you are working?"
label var ever_birth "Have you ever given birth?"
label var birth_events "How many times have you given birth?"
label var fb_m "Month:"
label var fb_y "Year:"
label var first_birth "Date of first birth"
label var rb_m "Month:"
label var rb_y "Year:"
label var recent_birth "Date of most recent birth"
label var other_birth_yn "Have you had any other births since 3 years ago?"
label var ob_m "Month:"
label var ob_y "Year:"
label var other_birth "Date of other birth since 3 years ago"
label var ever_miscarried_yn "Have you ever had a pregnancy that miscarried/aborted/stillbirth since 3 yrs ago"
label var ab_m "Month:"
label var ab_y "Year:"
label var pregnancy_end "When did that pregnancy end"
label var pregnant "Are you pregnant now?"
label var months_pregnant "How many months pregnant are you"
label var menstrual_period "When did your last menstrual period start?"
label var menstrual_period_warning_1 "Is that what she said?"
label var menstrual_period_value "Enter X"
label var menstrual_period_warning_4 "Is that what she said?"
label var menstrual_period_warning_2 "Is that what she said?"
label var first_period "How old were you at the time you experienced your first menstruation?"
label var pregnancy_desired "Did you want to become pregnant then"
label var more_children_none "Would you like to have a child or would you prefer not to have any children?"
label var more_children_some "Would you like to have another child or would you prefer not to have any more"
label var more_children_pregnant "After the child you are expecting now, would you like to have another child"
label var wait_birth_none "How long would you like to wait from now before the birth of a child?"
label var wait_birth_some "How long would you like to wait from now before the birth of another child?"
label var wait_birth_pregnant "After the birth of the child you are expecting, how long would you like to wait"
label var wait_birth_value "Enter the number of X you would like to wait:"
label var emotion_pregnant "When you found out you were pregnant, how did you feel?"
label var emotion_if_pregnant "If you got pregnant now, how would you feel?"
label var heard_female_sterilization "Have you ever heard of female sterilization?"
label var heard_male_sterilization "Have you ever heard of male sterilization?"
label var heard_implants "Have you ever heard of the contraceptive implant?"
label var heard_IUD "Have you ever heard of the IUD?"
capture label var heard_injectables "Have you ever heard of injectables?"
label var heard_pill "Have you ever heard of the (birth control) pill?"
label var heard_emergency "Have you ever heard of emergency contraception?"
label var heard_male_condoms "Have you ever heard of male condoms?"
label var heard_female_condoms "Have you ever heard of female condoms?"
capture label var heard_diaphragm "Have you ever heard of the diaphragm?"
capture label var heard_gel "Have you ever heard of foam or jelly as a contraceptive method?"
capture label var heard_beads "Have you ever heard of the standard days method or Cycle Beads?"
capture label var heard_LAM "Have you ever heard of the Lactational Amenorrhea Method or LAM?"
label var heard_rhythm "Have you ever heard of the rhythm method?"
label var heard_withdrawal "Have you ever heard of the withdrawal method?"
label var heard_other "Have you ever heard of any other ways or methods that  to avoid pregnancy?"
label var current_user "Are you/partner currently using any method to delay or avoid getting pregnant?"
label var current_method "Which method or methods are you using?   PROBE: Anything else?"
label var current_method_check "Check here to acknowledge you considered all options."
label var current_method_most_effective "Most effective current method"
label var ppp_current_method_label "CALCULATE: CURRENT METHOD  THIS WILL NOT APPEAR ON THE SCREEN"
capture label var injectable_probe_current "PROBE: Was the injection administered via syringe or small needle?"
capture label var injectable_self_current "Did you inject it yourself or did a healthcare provider do it for you?"
label var partner_know "Does your husband/partner know that you are using METHOD?"
label var partner_know_nr "Does your husband/partner know that you are using family planning?"
capture label var implant_check "CHECK. In question 302b, the respondent mentioned that she had been using implan"
capture label var implant_type "How many rods is your implant?"
capture label var implant_protect "When the implant was inserted, were you told how long it would protect you ?"
capture label var implant_duration "How long were you told ?"
capture label var implant_duration_value "Enter the number of X you were told:"
capture label var sterlization_permanent_inform "Did the provider tell you or your partner that this method was permanent?"
label var fp_needs_where "If you needed FP where would you go?"
label var reason_for_location "Why would you choose this location?"
label var shy_fp_clinic "Do you you agree with:I would feel too shy or embarrassed to get FP from a clinic/doctor"
label var shy_fp_pharmacy "Do you you agree with:I would feel too shy or embarrassed to get FP from a pharmacy"
label var future_user_not_current "Do you think you will use a contraceptive method at any time in the future?"
label var future_user_pregnant "Do you think you will use a contraceptive method at any time in the future?"
label var fp_start "When do you think you will start using a method?"
label var fp_start_vaue "Enter X:"
label var fp_start_which "What method do you think you will use?"
label var fp_start_support "Would your husband/partner be supportive of you using family planning?"
label var partner_decision "Before you started using METHOD had you discussed the decision with your partner"
label var partner_overall "Would you say that using contraception is mainly your decision"
label var bus_m "Month:"
label var bus_y "Year:"
label var begin_using "Date began using METHOD"
label var fp_provider_rw_known "Where did you and your partner get METHOD at the time"
label var fp_provider_rw_nr "Where did you/your partner get METHOD when you first started using"
label var fp_provider_check "Check here to acknowledge you considered all options."
label var fp_side_effects "When you obtained your METHOD were you told by the provider about side effects?"
label var fp_side_effects_instructions "Were you told what to do if you experienced side effects or problems?"
capture label var told_removal "Were you told where you could go to have the implant removed?"
label var fp_told_other_methods_cc "Were you told by the provider about methods of FP other than the METHOD ?"
label var fp_told_future_switch "Wwere you told that you could switch to a different method in the future?"
label var fp_obtain_desired_cc "During that visit, did you obtain the method you wanted"
label var fp_obtain_desired_whynot "Why didn't you obtain the method you wanted?"
label var fp_final_decision "During that visit, who made the final decision about what method you got?"
label var rhythm_final "Who made the final decision to use rhythm?"
label var lam_final "Who made the final decision to use LAM?"
label var return_to_provider "Would you return to this provider?"
label var refer_to_relative "Would you refer your relative or friend to this provider / facility?"
capture label var implant_removed_attempt "In the past 12 months, have you tried to have your current implant removed?"
capture label var implant_removed_who "Where did you go or who attempted to remove your implant?"
capture label var implant_not_removed "Why were you not able to have your implant removed?"
capture label var implant_not_other "Why were you not able to have your implant removed?"
label var fp_ever_user "Have you ever done anything  to delay or avoid getting pregnant?"
label var fp_ever_used "Woman is a current user or has ever used FP"
label var age_at_first_use "How old were you when you first used a method ?"
label var age_at_first_use_check "Is that what she said?"
label var age_at_first_use_children "How many living children did you have at that time, if any?"
label var age_at_first_use_children_warn "Is this what the respondent said?"
label var emergency_12mo_yn "Have you used emergency contraception at any time in the last 12 months?"
label var condom_12mo_yn "Have you used a condom at any time in the last 12 months?"
label var why_not_using "Can you tell me why you are not using a method to prevent pregnancy?"
label var why_not_using_check "Check here to acknowledge you considered all options."
label var why_not_decision "Would you say that not using contraception is mainly your decision"
label var visited_by_health_worker "Were you visited by a community health worker who talked to you about FP?"
label var visited_fac_none "Have you visited a health facility or camp for care for yourself?"
label var visited_fac_some "Have you visited a health facility/camp for care for yourself or your children?"
label var facility_fp_discussion "Did any staff member at the health facility speak to you about FP methods?"
label var fp_ad_radio_12m "Heard about family planning on the radio?"
label var fp_ad_tv_12m "Seen anything about family planning on the television?"
label var fp_ad_magazine_12m "Read about family planning in a newspaper or magazine?"
label var fp_ad_call_12m "Received a voice or text message about family planning on a mobile phone?"
label var fp_ad_social_12m "Seen anything on social media about family planning"
label var fp_promiscuous_view "Adolescents who use family planning are promiscuous."
label var fp_married_view "Family planning is only for women who are married."
label var fp_no_child_view "Family planning is only for women who don't want any more children."
label var fp_lifestyle_view "People who use family planning have a better quality of life."
label var fp_promiscuous_self "Adolescents who use family planning are promiscuous."
label var fp_married_self "Family planning is only for women who are married."
label var fp_no_child_self "Family planning is only for women who don't want any more children."
label var fp_lifestyle_self "People who use family planning have a better quality of life."
label var achieve_school_self "Complete secondary school / technical school / vocation school"
label var achieve_uni_self "Attend university / tertiary institution"
label var achieve_job_self "Have a good job"
label var achieve_business_self "Start a business"
label var achieve_partner_self "Find a partner"
label var achieve_married_self "Get married"
label var achieve_children_self "Have children"
label var achieve_school_parent "Complete secondary school / technical school / vocation school"
label var achieve_uni_parent "Attend university / tertiary institution"
label var achieve_job_parent "Have a good job"
label var achieve_business_parent "Start a business"
label var achieve_partner_parent "Find a partner"
label var achieve_married_parent "Get married"
label var achieve_children_parent "Have children"
label var have_insurance_yn "Do you have health insurance or are you a member of a mutual health organization"
label var insurance_type "What type of health insurance do you have"
label var age_at_first_sex "Enter the age in years."
label var age_at_first_sex_check_2 "Is that correct?"
label var age_at_first_sex_check_3 "Is that what the she said?"
label var age_at_first_sex_check_4 "Previously the respondent said she has given birth at an earlier age. Is that co"
label var first_sex_timing "Would you have preferred to waited longer before having sex with anyone"
label var first_sex_willing "The 1st time would you say you and partner were both equally willing to have sex"
label var first_sex_applied "Which of these applied to you at the first time you had sex?"
label var first_sex_self_decision "How much do you think you will be involved in the decision to have sex the 1st time"
label var first_sex_avoid_preg_yn "Did you and your partner want to avoid a pregnancy the first time you had sex?"
label var first_sex_method_want "Did you or your partner do something or use any method ?"
label var last_time_sex "When was the last time you had sex"
label var last_time_sex_value "Enter X."
label var last_time_sex_used_fp_yn "The last time you had sex did you or your partner use any method ?"
label var last_time_sex_fp_method "What method did you or your partner use?"
label var last_time_sex_fp_choice "Whose choice was it to use that method?"
capture label var last_sex_not_want "I did not want to have sex at that time"
capture label var last_sex_pressured "I felt pressured by my husband / partner to have sex then"
capture label var last_sex_not_consent "I did not consent (was forced) to have sex then"
capture label var last_sex_duress "I felt at risk of physical violence if I declined to have sex at that time"
capture label var wge_seek_partner "If I use family planning, my husband/partner may seek another sexual partner."
capture label var wge_trouble_preg "If I use FP, I may have trouble getting pregnant the next time I want to"
capture label var wge_could_conflict "There could be conflict in my relationship/marriage if I use family planning."
capture label var wge_will_conflict "There will be conflict in my relationship/marriage if I use family planning."
capture label var wge_abnormal_birth "If I use family planning, my children may not be born normal."
capture label var wge_body_side_effects "If I use FP, my body may experience side effects that will disrupt relations"
capture label var wge_switch_fp "I can decide to switch from one family planning method to another if I want to."
capture label var wge_confident_switch "I feel confident telling my provider what is important when selecting a method"
capture label var wge_finish_school_none "I want to complete my education before I have a child."
capture label var wge_finish_school "I wanted to complete my education before I had a child."
capture label var wge_take_care_family "If I rest between pregnancies, I can take better care of my family."
capture label var wge_decide_start_none "I can decide when I want to start having children."
capture label var wge_decide_start "I could decide when I wanted to start having children."
capture label var wge_partner_talk_start "I feel confident discussing with my partner when to start having children"
capture label var wge_decide_another "I can decide when to have another child."
capture label var wge_negotiate_stop_none "I will be able to negotiate with my husband/partner when to stop having children"
capture label var wge_negotiate_stop "I can negotiate with my husband/partner when to stop having children."
capture label var wge_stop_support "If I refuse sex with my husband/partner, he may stop supporting me."
capture label var wge_force "If I refuse sex with my husband/partner, he may force me to have sex."
capture label var wge_hurt "If I refuse sex with my husband/partner, he may physically hurt me."
capture label var wge_promiscuous "If I show my partner that I want to have sex, he may consider me promiscuous"
capture label var wge_confident_sex "I am confident I can tell my husband/partner when I want to have sex."
capture label var wge_decide_sex "I am able to decide when to have sex."
capture label var wge_tell_no_sex "If I do not want to have sex, I can tell my husband/partner."
capture label var wge_avoid_sex "If I do not want to have sex, I am capable of avoiding it"
label var flw_willing "Would you be willing to participate in another survey one year from now?"
label var flw_number_yn "Do you own a phone?"
label var flw_number_typed "Can I have your primary phone number ?"
label var flw_number_confirm "Can you repeat the number again?"
label var locationlatitude "latitude"
label var locationlongitude "longitude"
label var locationaltitude "altitude"
label var locationaccuracy "Location accuracy"
label var times_visited "How many times have you visited this household to interview this woman"
label var survey_language "In what language was this interview conducted?"
label var FRS_result "Questionnaire Result"
forval year = `year1'/`year3' {
	label var cc_col1_`year'_12 "Enter Value December `year'"
	label var cc_col1_`year'_11 "Enter Value November `year'"
	label var cc_col1_`year'_10 "Enter Value October `year'"
	label var cc_col1_`year'_09 "Enter Value September `year'"
	label var cc_col1_`year'_08 "Enter Value August `year'"
	label var cc_col1_`year'_07 "Enter Value July `year'"
	label var cc_col1_`year'_06 "Enter Value June `year'"
	label var cc_col1_`year'_05 "Enter Value May `year'"
	label var cc_col1_`year'_04 "Enter Value April `year'"
	label var cc_col1_`year'_03 "Enter Value March `year'"
	label var cc_col1_`year'_02 "Enter Value February `year'"
	label var cc_col1_`year'_01 "Enter Value January `year'"
	label var verify_cc_col1_`year' "Please verify your inputs for `year'. Are they correct?"
	label var cc_col2_`year'_12 "Enter Value December `year'"
	label var cc_col2_`year'_11 "Enter Value November `year'"
	label var cc_col2_`year'_10 "Enter Value October `year'"
	label var cc_col2_`year'_09 "Enter Value September `year'"
	label var cc_col2_`year'_08 "Enter Value August `year'"
	label var cc_col2_`year'_07 "Enter Value July `year'"
	label var cc_col2_`year'_06 "Enter Value June `year'"
	label var cc_col2_`year'_05 "Enter Value May `year'"
	label var cc_col2_`year'_04 "Enter Value April `year'"
	label var cc_col2_`year'_03 "Enter Value March `year'"
	label var cc_col2_`year'_02 "Enter Value February `year'"
	label var cc_col2_`year'_01 "Enter Value January `year'"
	}
label var contra_calendar_pic "Take picture of contraceptive calendar visual aid"
label var start "Start of interview"
label var end "End of interview"

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

foreach var in today birthdate husband_cohabit_start_first husband_cohabit_start_recent ///
	first_birth recent_birth other_birth pregnancy_end begin_using {
	gen double `var'SIF=date(`var', "YMD")
	format `var'SIF %td
	local `var'_l : variable label `var'
	label var `var'SIF "``var'_l' SIF"
	order `var'SIF, after(`var')
	} 

/* ---------------------------------------------------------
         SECTION 8: Additional Cleaning
   --------------------------------------------------------- */
rename submissiondate* SubmissionDate*

rename your_name RE
replace RE=name_typed if your_name_check==0 | your_name_check==.
label var RE "RE"

rename metainstancename metainstanceName
rename ea_unlinked unlinkedEA

***Cleaning from PMA2020
replace current_method="" if current_user!=1
foreach var of varlist femalester-othertrad {
	replace `var'=. if current_user!=1
	}
capture rename heard_gel heard_foamjelly

**Check any complete duplicates, duplicates of metainstanceid, and duplicates of structure and household numbers
duplicates tag metainstanceID, gen(dupFQ)
duplicates tag link, gen(duplink)
duplicates report 
duplicates drop


save `CCPX'_FQ_`date'.dta, replace
