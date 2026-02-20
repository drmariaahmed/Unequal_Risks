/******************************************************************
* Stata Script to Estimate LRB/HRB Predicted Probabilities (PP),
* Average Marginal Effects (AME), and Second Differences
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: Estimates population-averaged predicted probabilities (PP),
*              within-race marginal effects (AMEs), and cross-race second
*              differences for:
*                 (A) Race x Insurance (methpay)
*                 (B) Race x Education (edu)
* Source data: data/natality2023us_filtered.dta
* Output: Console output for copy/paste into Excel
* NOTE: Requires Stata 18 or higher (margins; vce(robust)).
*       Ensure working directory is set to the root of this repository.
******************************************************************/

clear all
version 18
use "data/natality2023us_filtered.dta", clear

******************************************************************
* Analytic sample: drop observations with missing model variables
******************************************************************
drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, ///
                pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, ///
                steroids, infection, induced, doc)

******************************************************************
* Helper: LRB definition used throughout
* (singleton, cephalic, term, nulliparous already defined upstream in dataset)
******************************************************************

/******************************************************************
* SECTION A: Race x Insurance (methpay)
******************************************************************/

/******************************************************************
* LOWER-RISK births (LRB): Race x Insurance
******************************************************************/
preserve
    keep if num_risk == 0
    keep if birth_wt == 2
    keep if apgar5 == 3
    keep if steroids == 0
    keep if obesity == 0
    drop if mage3 == 3

    di "=============================================================="
    di "LRB: Race x Insurance (methpay)"
    di "LRB sample size = " _N
    di "=============================================================="

    logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
          i.pregsmoke i.prenatal i.mage3 i.sex_infant ///
          i.infection i.induced i.doc, vce(robust)

    * (1) Predicted probabilities (race x insurance)
    margins race5#methpay, predict(pr) vce(unconditional)

    * (2) Within-race insurance effects (AME): Insured - Not insured, by race
    margins race5, dydx(methpay) predict(pr) vce(unconditional)

    * (3) Second differences: do insurance effects differ across race?
    margins race5, dydx(methpay) predict(pr) vce(unconditional) pwcompare(effects)

restore


/******************************************************************
* HIGHER-RISK births (HRB): Race x Insurance
******************************************************************/
preserve
    keep if num_risk != 0

    di "=============================================================="
    di "HRB: Race x Insurance (methpay)"
    di "HRB sample size = " _N
    di "=============================================================="

    logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
        i.obesity i.mage3 i.pregsmoke i.prenatal ///
        i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
        i.num_risk i.infection i.induced i.doc, vce(robust)

    * (1) Predicted probabilities (race x insurance)
    margins race5#methpay, predict(pr) vce(unconditional)

    * (2) Within-race insurance effects (AME)
    margins race5, dydx(methpay) predict(pr) vce(unconditional)

    * (3) Second differences: compare insurance effects across race
    margins race5, dydx(methpay) predict(pr) vce(unconditional) pwcompare(effects)

restore


/******************************************************************
* SECTION B: Race x Education (edu)
******************************************************************/

/******************************************************************
* LOWER-RISK births (LRB): Race x Education
******************************************************************/
preserve
    keep if num_risk == 0
    keep if birth_wt == 2
    keep if apgar5 == 3
    keep if steroids == 0
    keep if obesity == 0
    drop if mage3 == 3

    di "=============================================================="
    di "LRB: Race x Education (edu)"
    di "LRB sample size = " _N
    di "=============================================================="

    logit deliv i.race5##i.edu ib1.USborn i.methpay i.marstat ///
          i.pregsmoke i.prenatal i.mage3 i.sex_infant ///
          i.infection i.induced i.doc, vce(robust)

    * (1) Predicted probabilities (race x edu)
    margins race5#edu, predict(pr) vce(unconditional)

    * (2) Within-race education effects (AMEs): SC-HS and BA-HS (vs base=HS), by race
    margins race5, dydx(edu) predict(pr) vce(unconditional)

    * (3) Second differences: do education effects differ across race?
    margins race5, dydx(edu) predict(pr) vce(unconditional) pwcompare(effects)

restore


/******************************************************************
* HIGHER-RISK births (HRB): Race x Education
******************************************************************/
preserve
    keep if num_risk != 0

    di "=============================================================="
    di "HRB: Race x Education (edu)"
    di "HRB sample size = " _N
    di "=============================================================="

    logit deliv i.race5##i.edu ib1.USborn i.methpay i.marstat ///
        i.obesity i.mage3 i.pregsmoke i.prenatal ///
        i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
        i.num_risk i.infection i.induced i.doc, vce(robust)

    * (1) Predicted probabilities (race x edu)
    margins race5#edu, predict(pr) vce(unconditional)

    * (2) Within-race education effects (AMEs)
    margins race5, dydx(edu) predict(pr) vce(unconditional)

    * (3) Second differences: compare education effects across race
    margins race5, dydx(edu) predict(pr) vce(unconditional) pwcompare(effects)

restore
