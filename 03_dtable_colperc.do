*******************************************************************
* Stata Script to Create Descriptive Statistics Table (Table 1)
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: 	Generates descriptive stats (column percentages).
*				Should be used in conjunction with 04_dtable_rowperc.do,
*				which computes row percentages
* Source data: data/natality2023us_filtered.dta
* Output file: tables/Descriptive_Stats_<date>.xlsx
* NOTE: Requires Stata 18 or higher.
* 		Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18
use "data/natality2023us_filtered.dta", clear

quietly {
    *******************************************************
    * Generate today's date in DD-Mon-YY format
    *******************************************************
    local rawdate "`c(current_date)'"           // e.g., "18 Jun 2025"
    local day     = substr("`rawdate'", 1, 2)
    local month   = substr("`rawdate'", 4, 3)
    local year    = substr("`rawdate'", 8, 4)
    local shorty  = substr("`year'", 3, 2)
    local today   = "`day'-`month'-`shorty'"

    *******************************************************
    * Define output path
    *******************************************************
    local filepath "tables/Descriptive_Stats_`today'.xlsx"

    *******************************************************
    * Run descriptive table by delivery method
    *******************************************************
    dtable i.race5 i.USborn i.marstat i.mage3 i.edu i.methpay ///
           i.obesity i.pregsmoke i.prenatal i.num_risk ///
           i.steroids i.sex_infant i.birth_wt ///
           i.apgar5 i.induced ///
           i.infection i.doc, ///
        by(deliv) ///
        sample(, statistics(freq) place(seplabels)) ///
        sformat("(N=%s)" frequency) ///
        note("Note: Vaginal and C-section columns present row percentages; the Total column presents column percentages. Sample includes N=960,276 cephalic, singleton, nulliparous term births delivered in hospitals.") ///
        title("Table 1. Descriptive Characteristics of Births by Delivery Method (Vaginal vs. C-Section)") ///
        export("`filepath'", replace)

    shell "`filepath'"
}
******************************************************************************
///ADDITIONAL NOTE ON FINAL SAMPLE///
******************************************************************************
*Note: Of the 3,605,081 births in the cleaned 2023 Natality dataset, a series of exclusions were applied to restrict the sample to singleton, cephalic, nulliparous, term births delivered in hospital settings with valid delivery method data. These exclusions removed cases with non-cephalic presentations (n=196,095), multiple births (n=77,922), multiparous women (n=2,253,105), preterm births (n=102,844), non-hospital deliveries (n=14,513), and cases with missing delivery method (n=326), yielding a final descriptive sample of 960,276 births. For the logistic regression models, listwise deletion was used to handle missingness on covariates, resulting in a final analytic sample of 960,154 births.
******************************************************************************