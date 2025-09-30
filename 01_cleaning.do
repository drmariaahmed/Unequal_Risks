*******************************************************************
* Stata Cleaning Script for US Natality Data (2023)
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: Cleans and recodes variables for chain-of-risk analysis
* Source data: U.S. Natality Public Use File (2023)
* Download from: https://www.nber.org/research/data/vital-statistics-natality-birth-data
* Source data: data/natality2023us.dta
* Output file: data/natality2023us_cleaned.dta
*
* NOTE: Requires Stata 18 or higher.
*       This script uses Stata 18-only functions (e.g., etable, collect, dtable).
*       Recommended: Install `estout` package using: ssc install estout
*
*		Ensure working directory is set to the root of this repository before running.
*      	Uncomment and customize below if needed:
*      	cd "your/local/path/Unequal_Risks"
*******************************************************************
*
clear all
version 18
use "data/natality2023us.dta", clear
*
quietly{
**********************************************************
///////////////////Dependent Variable////////////////////
*********************************************************
*Recode Method of Delivery
cap drop deliv
recode dmeth_rec (1=0 "Vaginal") (2=1 "C-Section") (9=.), gen (deliv)
lab var deliv "Method of Delivery"
tab deliv dmeth_rec, m
*
******************************************************
//CHAIN OF RISKS #1:Sociodemographic Characteristics//
******************************************************
*
*Mother's Race
cap drop race5
recode mracehisp (1=1 "White") (2=2 "Black") (7=3 "Hispanic") (4=4 "Asian") (3=5 "Other") (5/6=5 "Other") (8=8 "Missing"), gen (race5)
lab var race5 "Race"
tab race5 mracehisp, m
*
*Recode Mother's Education
cap drop edu
recode meduc (1/3=1 "HS or less")(4/5=2 "Some_College/Assoc") (6/8=3 "BA_or_more") (9=9 "Missing"), gen (edu)
lab var edu "Mother's Education"
tab edu meduc, m
*
*Recode Method of Payment as dummy variable
cap drop methpay
recode pay_rec (2=1 "Insured") (1=0 "Not Insured") (3=0 "Not Insured") (4=0 "Not Insured") (9=9 "Missing"), gen (methpay)
lab var methpay "Method of Payment"
tab pay_rec methpay, m
*
*Recode Marital Status
cap drop marstat
destring dmar, replace
recode dmar (1=1 "Married") (2=0 "Unmarried") (.=3 "Missing"), gen (marstat)
lab var marstat "Marital Status"
tab marstat dmar, m
*
*Recode Mother's Nativity 
cap drop USborn
recode mbstate_rec (1=1 "Born in US") (2=0 "Immigrant") (3=3 "Missing"), gen (USborn)
lab var USborn "US Born"
tab mbstate_rec USborn, m
*
***************************************************
//CHAIN OF RISKS #2:Maternal Pre-Pregnancy Risks//
**************************************************
*Recode BMI/Obesity (Dummy Variable)
*Note that 5 and 6 represent Obesity II and Extreme Obesity
cap drop obesity
recode bmi_r (4/6=1 "Obese") (1/3=0 "Not Obese") (9=9 "Missing"), gen (obesity)
lab var obesity "Obesity"
tab bmi_r obesity, m
*
*Mother's Age Recoded (3 levels)
cap drop mage3
recode mager9 (1/2=1 "<19yrs") (3/5=2 "20-34yrs") (6/9=3 "35+years"), gen (mage3)
lab var mage3 "Mother's Age" 
tab mage3 mager9, m
*
*Recode Prenatal Care
cap drop prenatal
recode precare5 (1=1 "1st term") (2/3=2 "2nd/3rd_term") (4=3 "No_care") (5=5 "Missing"), gen (prenatal)
lab var prenatal "Prenatal Care Term Commenced"
tab prenatal precare5, m
*
*Recode Smoking (Dummy Variable)
cap drop pregsmoke
label define smokelbl 1 "Y" 0 "N" 9 "U"
encode cig_rec, gen(smoke) label(smokelbl)
recode smoke (1=1 "Smokes") (0=0 "Does Not Smoke") (9=9 "Missing"), gen (pregsmoke)
lab var pregsmoke "Smoking during Pregnancy"
tab cig_rec pregsmoke, m
*********************************************************
//CHAIN OF RISKS #3: Maternal Prenatal-Gestational Risks//
*********************************************************
*Risk Factors Reported (Dummy Variable)
*cap drop risk_factors
*recode no_risks (1=0 "No Risk Factors") (0=1 "Risk_Factors_Reported") (9=.), gen (risk_factors)
*lab var risk_factors "Risk Factors Reported"
*tab no_risks risk_factors, m
*
*Number of Risk Factors Variable
*Drop any existing versions
cap drop diab hype eclamp infert total_num_risk num_risk
* Define common label
label define yesno_lbl 1 "Y" 0 "N" 9 "U"
* Encode all 6 string variables
encode rf_pdiab, gen(rf_pdiab_n) label(yesno_lbl)
encode rf_gdiab, gen(rf_gdiab_n) label(yesno_lbl)
encode rf_phype, gen(rf_phype_n) label(yesno_lbl)
encode rf_ghype, gen(rf_ghype_n) label(yesno_lbl)
encode rf_ehype, gen(rf_ehype_n) label(yesno_lbl)
encode rf_inftr, gen(rf_inftr_n) label(yesno_lbl)
*Create separate dummy indicators for diabetes, hypertension, eclampsia, infertility treatments
*Pre-pregnancy Diabetes OR Gestational Diabetes 
gen diab = 0
replace diab = 1 if rf_pdiab_n == 1 | rf_gdiab_n == 1
*Pre-pregnancy Hypertension OR Gestational Hypertension
gen hype = 0
replace hype = 1 if rf_phype_n == 1 | rf_ghype_n == 1
*Eclampsia 
gen eclamp = 0
replace eclamp = 1 if rf_ehype_n == 1
*Infertility Treatment Used 
gen infert = 0
replace infert = 1 if rf_inftr_n == 1
*Sum to get count of risk factors
gen total_num_risk = diab + hype + eclamp + infert
lab var total_num_risk "Total Number of Risk Factors"
*Create final dummy variable (1 = 1 issue, 2 = 2 or more)
cap drop num_risk
gen num_risk = 0
replace num_risk = 1 if total_num_risk == 1
replace num_risk = 2 if total_num_risk >= 2
lab var num_risk "Number of Risk Factors"
lab def num_risklbl 0 "No Health Issues" 1 "1 Health Issue" 2 "2+ Health Issues"
lab val num_risk num_risklbl
tab num_risk, m
*********************************************************
////////////////CHAIN OF RISKS #4: Fetal Risks///////////
*********************************************************
*Recode Steroids for Fetal Lung Maturity
cap drop steroids_fetal
label define steroids_fetal_lbl 1 "Y" 0 "N" 9 "U"
encode ld_ster, gen(steroids_fetal) label(steroids_fetal_lbl)
recode steroids_fetal (1=1 "Steroids_Given") (0=0 "Steroids_Not_Given") (9=9 "Missing"), gen (steroids)
lab var steroids "Steroids for Fetal Lung Maturity"
tab steroids ld_ster, m
*
*Recode Sex of Infant
cap drop sex_inf
label define sex_inf 1 "F" 2 "M"
encode sex, gen(sex_inf) label(sex_inf_lbl)
recode sex_inf (1=1 "Female") (2=2 "Male"), gen (sex_infant)
lab var sex_infant "Sex of Infant"
tab sex sex_infant, m
*
*Recode Plurality to Singleton
cap drop singleton
recode dplural (1=1 "Singleton") (2/4=0 "Multiples") (9=.), gen (singleton)
lab var singleton "Singleton"
tab dplural singleton, m
*
*Recode Total Birth Order to Nulliparity
cap drop null
recode tbo_rec (1=1 "First-time Mother") (2/8=0 "Not First-time Mother") (9=.), gen (null)
lab var null "Nulliparity"
tab tbo_rec null, m
*
*Recode Birth Weight
cap drop birth_wt
recode bwtr12 (1/5=1 "Low:<2,500") (6/8=2 "Normal:2500-4000g") (9/11=3 "High:>4000") (12=12 "Missing"), gen (birth_wt)
lab var birth_wt "Birth Weight"
tab birth_wt bwtr12, m
*
*Recode Gestational Age
cap drop gest_age
recode gestrec10 (01/05=1 ">37") (06/07=2 "37-40") (08/10=3 "40+") (99=.), gen (gest_age)
lab var gest_age "Gestational Age"
tab gest_age gestrec10, m
*
*Recode APGAR5
cap drop apgar5
recode apgar5r (1=1 ">3") (2=2 "4to6") (3/4=3 "7to10") (5=5 "Missing"), gen (apgar5)
lab var apgar5 "APGAR5"
tab apgar5 apgar5r, m
**********************************************************
///////////////CHAIN OF RISKS #5: Labor Risks////////////
*********************************************************
*Recode Cephalic/Breech Birth
cap drop ceph
recode me_pres (1=1 "Cephalic") (2=0 "Breech") (3=.) (9=.), gen (ceph)
lab var ceph "Fetal Presentation at Delivery"
tab ceph me_pres, m
*
*Recode Labor Attempted (if cesarean) (missing: 2,449,704)
cap drop labor_attempt
label define labor_attempt_lbl 1 "Y" 0 "N" 9 "U" 
encode me_trial, gen(labor_attempt) label(labor_attempt_lbl)
recode labor_attempt (1=1 "Labor Attempted") (0=0 "Labor Not Attempted") (9=9 "Missing"), gen (labor_att)
lab var labor_att "Labor Attempted (if cesarean)"
tab labor_att me_trial, m
*
*Recode Induction of Labor
cap drop induced_labor
label define induced_labor_lbl 1 "Y" 0 "N" 9 "U"
encode ld_indl, gen(induced_labor) label(induced_labor_lbl)
recode induced_labor (1=1 "Induced") (0=0 "Not Induced") (9=.), gen (induced)
lab var induced "Induction of Labor"
tab induced ld_indl, m
*
*Recode Infections Reported 
cap drop infection
recode no_infec (1=0 "No Infection Reported") (0=1 "Infection_Reported") (9=9 "Not Reported"), gen (infection)
lab var infection "Infection Reported"
tab no_infec infection, m
*
*Recode Birth Location
cap drop hospital
recode bfacil3 (1=1 "Hospital") (2=0 "Not in Hospital") (3=.), gen (hospital)
lab var hospital "Birth Facility"
tab bfacil3 hospital, m
*
*Recode Medical Attendant
cap drop doc
recode attend (1/2=1 "MD or DO") (3/5=0 "Other") (9=9 "Missing"), gen (doc)
lab var doc "Medical Attendant"
tab attend doc, m
*
*****************************************************
* Save the dataset
save "data/natality2023us_cleaned.dta", replace
}
