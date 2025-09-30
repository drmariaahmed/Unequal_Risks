*******************************************************************
* Stata Script to Add Row Percentages by Delivery Method to Table 1
* Author: Maria Ahmed
* GitHub Repository: https://github.com/drmariaahmed/Unequal_Risks
* Description: 	Computes row percentages by delivery method for all 
* 				variables in Table 1. Complements 03_dtable_colperc.do output, which  
* 				presents column percentages in the "Total" column. These row  
* 				percentages are then manually copied into Table 1 with:
*   			– Row percentages in the Vaginal and C-section columns
*   			– Column percentages from the original dtable in the Total column 
* Source data: data/natality2023us_filtered.dta
* NOTE: Requires Stata 18 or higher.
* 	 	Ensure working directory is set to the root of this repository before running.
*******************************************************************

clear all
version 18
use "data/natality2023us_filtered.dta", clear

// Define a local macro with the updated list of variables (NO 'i.')
local variables race5 USborn marstat mage3 edu methpay ///
       obesity pregsmoke prenatal num_risk ///
       steroids sex_infant singleton null birth_wt ///
       gest_age apgar5 ceph induced ///
       infection hospital doc

// Loop over each variable in the list
foreach var of local variables {
    tab `var' deliv, row
}