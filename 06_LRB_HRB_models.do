*******************************************************************
* Stata Script to Estimate LRB and HRB Logistic Regression Models
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: Estimates logistic regression models for
*              lower-risk (LRB) and higher-risk (HRB) birth subgroups:
*              Model A = main effects
*              Model B = race × insurance (methpay)
*              Model C = race × education (edu)
* Source data: data/natality2023us_filtered.dta
* Output file: Tables/LRB_HRB_Models_AOR_[date].xlsx
* NOTE: Requires Stata 18 or higher (uses etable/collect).
*       Recommended: Install `estout` package: ssc install estout
*       Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18
use "data/natality2023us_filtered.dta", clear

quietly {

    * Format today's date for output file naming
    local rawdate "`c(current_date)'"
    local day    = substr("`rawdate'", 1, 2)
    local month  = substr("`rawdate'", 4, 3)
    local year   = substr("`rawdate'", 8, 4)
    local shorty = substr("`year'", 3, 2)
    local today  = "`day'-`month'-`shorty'"

    *******************************************
    * Drop observations with missing values
    *******************************************
    drop if missing(deliv, race5, methpay, USborn, edu, marstat, obesity, mage3, ///
                    pregsmoke, prenatal, num_risk, sex_infant, birth_wt, apgar5, ///
                    steroids, infection, induced, doc)

    eststo clear

    *******************************************
    * LOWER-RISK subset (LRB)
    *******************************************
    preserve
        keep if num_risk == 0
        keep if birth_wt == 2
        keep if apgar5 == 3
        keep if steroids == 0
        keep if obesity == 0
        drop if mage3 == 3

        * Store N for table note
        count
        local N_low = r(N)

        * Model A: main effects
        eststo LRB_Model_A: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
            i.pregsmoke i.prenatal i.mage3 ///
            i.sex_infant i.infection i.induced i.doc, or vce(robust)

        * Model B: race × insurance
        eststo LRB_Model_B: logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
            i.pregsmoke i.prenatal i.mage3 ///
            i.sex_infant i.infection i.induced i.doc, or vce(robust)

        * Model C: race × education
        eststo LRB_Model_C: logit deliv i.race5##i.edu ib1.USborn i.methpay i.marstat ///
            i.pregsmoke i.prenatal i.mage3 ///
            i.sex_infant i.infection i.induced i.doc, or vce(robust)

    restore

    *******************************************
    * HIGHER-RISK subset (HRB)
    *******************************************
    preserve
        keep if num_risk != 0

        * Store N for table note
        count
        local N_high = r(N)

        * Model A: main effects
        eststo HRB_Model_A: logit deliv i.race5 i.methpay ib1.USborn i.edu i.marstat ///
            i.obesity i.mage3 i.pregsmoke i.prenatal ///
            i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
            i.num_risk i.infection i.induced i.doc, or vce(robust)

        * Model B: race × insurance
        eststo HRB_Model_B: logit deliv i.race5##i.methpay ib1.USborn i.edu i.marstat ///
            i.obesity i.mage3 i.pregsmoke i.prenatal ///
            i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
            i.num_risk i.infection i.induced i.doc, or vce(robust)

        * Model C: race × education
        eststo HRB_Model_C: logit deliv i.race5##i.edu ib1.USborn i.methpay i.marstat ///
            i.obesity i.mage3 i.pregsmoke i.prenatal ///
            i.sex_infant ib2.birth_wt ib3.apgar5 i.steroids ///
            i.num_risk i.infection i.induced i.doc, or vce(robust)

    restore

    *******************************************
    * EXPORT TABLE
    *******************************************
    etable, column(index) ///
        estimates(LRB_Model_A LRB_Model_B LRB_Model_C HRB_Model_A HRB_Model_B HRB_Model_C) ///
        showstars ///
        title("Logistic Regression Results for C-section Delivery by Risk Group") ///
        note("NOTE: ^p < .10; *p < .05; **p < .01 (two-tailed tests). Standard errors in parentheses. Models are based on the full analytic sample of singleton, cephalic, nulliparous, term, hospital births. Lower-risk sample (N = `N_low') excludes clinical indicators of elevated C-section risk. Higher-risk sample (N = `N_high') includes births with ≥1 reported health risk.")

    collect style header result[N], level(value)
    collect preview

    local filepath_aor "Tables/LRB_HRB_Models_AOR_`today'.xlsx"
    collect export "`filepath_aor'", replace
    * shell "`filepath_aor'"
}
