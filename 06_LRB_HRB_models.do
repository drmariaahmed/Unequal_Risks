*******************************************************************
* Stata Script to Estimate LRB and HRB Logistic Regression Models
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: Estimates logistic regression models for 
*              lower-risk (LRB) and higher-risk (HRB) birth subgroups,
*              with main effects and interaction terms (race × insurance).
* Source data: data/natality2023us_filtered.dta
* Output file: Tables/LRB_HRB_Models_Coeff_[date].xlsx
* NOTE: Requires Stata 18 or higher (uses etable/collect).
*       Recommended: Install `estout` package: ssc install estout
*       Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18
use "data/natality2023us_filtered.dta", clear

quietly {

    * Get today's date in DD-Mon-YY format
    local rawdate "`c(current_date)'"
    local day    = substr("`rawdate'", 1, 2)
    local month  = substr("`rawdate'", 4, 3)
    local year   = substr("`rawdate'", 8, 4)
    local shorty = substr("`year'", 3, 2)
    local today  = "`day'-`month'-`shorty'"

    *******************************************
    * Drop observations with missing values
    *******************************************
    drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, steroids, infection, induced, doc)

    eststo clear

    *******************************************
    * LOWER-RISK subset
    *******************************************
    preserve
        keep if num_risk == 0
        keep if birth_wt == 2
        keep if apgar5 == 3
        keep if steroids == 0
        keep if obesity == 0
        drop if mage3 == 3
        drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, steroids, infection, induced, doc)

        eststo LRB_ME: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
            i.pregsmoke i.prenatal i.mage3 ///
            i.sex_infant i.infection i.induced i.doc, vce(robust)

        eststo LRB_IE: logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
            i.pregsmoke i.prenatal i.mage3 ///
            i.sex_infant i.infection i.induced i.doc, vce(robust)
    restore

    *******************************************
    * HIGHER-RISK subset
    *******************************************
    drop if num_risk == 0
    drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, steroids, infection, induced, doc)

    eststo HRB_ME: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
        i.obesity i.mage3 i.pregsmoke i.prenatal ///
        i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
        i.num_risk i.infection i.induced i.doc, vce(robust)

    eststo HRB_IE: logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
        i.obesity i.mage3 i.pregsmoke i.prenatal ///
        i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
        i.num_risk i.infection i.induced i.doc, vce(robust)

    *******************************************
    * EXPORT TABLE
    *******************************************
    etable, column(index) ///
        estimates(LRB_ME LRB_IE HRB_ME HRB_IE) ///
        showstars ///
        title("Logistic Regression Results for C-section Delivery by Risk Group") ///
        note("NOTE: *p < .05; **p < .01 (two-tailed tests). Standard errors in parentheses. Models are based on the full analytic sample of singleton, cephalic, nulliparous, term, hospital births. Lower-risk sample (N = `N_low') excludes clinical indicators of elevated C-section risk. Higher-risk sample (N = `N_high') includes births with ≥1 reported health risk.")

    collect style header result[N], level(value)
    collect preview

    local filepath_coef "Tables/LRB_HRB_Models_Coeff_`today'.xlsx"
    collect export "`filepath_coef'", replace
    shell "`filepath_coef'"
}