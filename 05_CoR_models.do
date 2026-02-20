*******************************************************************
* Stata Script to Estimate Logistic Regression Models
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description:  Estimates five nested models for internal verification; 
*				exports Models 1 and 5 (baseline and fully adjusted) to Excel
* Source data: data/natality2023us_filtered.dta
* Output file: Tables/Logit_Models_AOR_[date].xlsx
* NOTE: Requires Stata 18 or higher (uses etable/collect).
*       Recommended: Install `estout` package: ssc install estout
*       Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18
use "data/natality2023us_filtered.dta", clear

quietly {
*******************************************************************
* Handle missing data on model variables
*******************************************************************
display "Before dropping missing: " _N
drop if missing(deliv, race5, methpay, USborn, edu, marstat, ///
                obesity, mage3, pregsmoke, prenatal, num_risk, ///
                sex_infant, birth_wt, apgar5, steroids, ///
                infection, induced, doc)
display "After dropping missing: " _N

*******************************************************************
* Format today's date for output file naming
*******************************************************************
local rawdate "`c(current_date)'"         
local day    = substr("`rawdate'", 1, 2)   
local month  = substr("`rawdate'", 4, 3)   
local year   = substr("`rawdate'", 8, 4)   
local shorty = substr("`year'", 3, 2)      
local today = "`day'-`month'-`shorty'"     

*******************************************************************
* Stepwise Logistic Models (Adjusted Odds Ratios)
*******************************************************************

* Model 1: Sociodemographic
eststo model1: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat, or vce(robust)

* Model 2: + Pre-pregnancy risks
eststo model2: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
                            i.obesity i.mage3, or vce(robust)

* Model 3: + Prenatal-gestational risks
eststo model3: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
                            i.obesity i.mage3 ///
                            i.pregsmoke i.prenatal i.num_risk, or vce(robust)

* Model 4: + Fetal risks
eststo model4: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
                            i.obesity i.mage3 ///
                            i.pregsmoke i.prenatal i.num_risk ///
                            i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids, or vce(robust)

* Model 5: + Labor risks
eststo model5: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
                            i.obesity i.mage3 ///
                            i.pregsmoke i.prenatal i.num_risk ///
                            i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
                            i.infection i.induced i.doc, or vce(robust)

*******************************************************************
* Export models to Excel (etable/collect)
*******************************************************************

etable, column(index) estimates(model1 model5) showstars title("Logistic Regression Results as Adjusted Odds Ratios for C-section Delivery ") note("NOTE: *p < .05; **p < .01; ***p < .001 (two-tailed tests). Standard errors are in parenthesis. Sample restricted to singleton, cephalic, nulliparous, term births delivered in hospital settings.")
* Show the level values of the result dimension. This will affect the row header for the observation number
collect style header result[N], level(value)
collect preview

local outpath "Tables/Logit_Models_AOR_`today'.xlsx"
collect export "`outpath'", replace
* shell "`outpath'"
}
