*******************************************************************
* Stata Script to Apply Exclusion Criteria (Filtered Dataset)
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: Applies analytic sample criteria to cleaned natality data
* Source data: data/natality2023us_cleaned.dta
* Output file: data/natality2023us_filtered.dta
* NOTE: Requires Stata 18 or higher.
* 		Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18
use "data/natality2023us_cleaned.dta", clear

quietly {
    *******************************************
    ///////////// FILTER DATA /////////////////
    *******************************************
    * Keep only singleton, cephalic, nulliparous, term, hospital births

    keep if ceph == 1
    keep if singleton == 1
    keep if null == 1
    drop if gest_age == 1       // Drop births <37 weeks
    keep if hospital == 1

    *******************************************
    * Save filtered dataset
    *******************************************
    save "data/natality2023us_filtered.dta", replace
}
