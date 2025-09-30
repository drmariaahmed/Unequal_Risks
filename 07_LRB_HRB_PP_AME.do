*******************************************************************
* Stata Script to Estimate LRB/HRB Predicted Probabilities (PP) & Average Marginal Effects (AME)
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: Estimates population-averaged predicted probabilities (PP)
*              and average marginal effects (AMEs) for lower-risk (LRB)
*              and higher-risk (HRB) birth cohorts.
* Source data: data/natality2023us_filtered.dta
* Output: Console output or graphs (optional)
* NOTE: Requires Stata 18 or higher (uses margins & vce(robust)).
*       Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18

use "data/natality2023us_filtered.dta", clear

* Drop missing values on model variables
drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, ///
                pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, ///
                steroids, infection, induced, doc)

*---------------------------------------------------------------
* LOWER-RISK (LRB) cohort
*---------------------------------------------------------------

* Restrict to lower-risk births
keep if num_risk == 0
keep if birth_wt == 2
keep if apgar5 == 3
keep if steroids == 0
keep if obesity == 0
drop if mage3 == 3

* Logistic regression with interaction
logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
      i.pregsmoke i.prenatal i.mage3 i.sex_infant ///
      i.infection i.induced i.doc, vce(robust)

* (A) Predicted probabilities (POP-AVERAGED)
margins, at(race5=(1 2 3 4) methpay=(0 1))

* (B) Average Marginal Effects (Insured − Not Insured), POP-AVERAGED
margins, dydx(1.methpay) at(race5=(1 2 3 4))

*---------------------------------------------------------------
* Clear for next model
*---------------------------------------------------------------
clear all
version 18


use "data/natality2023us_filtered.dta", clear

* Drop missing values on model variables
drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, ///
                pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, ///
                steroids, infection, induced, doc)
				
*---------------------------------------------------------------
* HIGHER-RISK (HRB) cohort
*---------------------------------------------------------------

* Restrict to higher-risk births
drop if num_risk == 0

* Logistic regression with interaction
logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
    i.obesity i.mage3 i.pregsmoke i.prenatal ///
    i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
    i.num_risk i.infection i.induced i.doc, vce(robust)

* (A) Predicted probabilities (POP-AVERAGED)
margins, at(race5=(1 2 3 4) methpay=(0 1))

* (B) Average Marginal Effects (Insured − Not Insured), POP-AVERAGED
margins, dydx(1.methpay) at(race5=(1 2 3 4))
