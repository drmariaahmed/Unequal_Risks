# Unequal_Risks
Replication code for Manuscript "Unequal Risks: Caesarean Deliveries among Marginalized Populations in the U.S." 
(PRPR submission using 2023 US Natality Data)
*Author: Maria Ahmed, Western University*
*Author: Kim Shuey, Western University*

---

This repository contains all analytic code used in the manuscript:

## Project Description

This study investigates racial and class disparities in Caesarean-section (C-section) procedures using 2023 U.S. Natality data. The analysis uses a chain-of-risks modeling strategy and risk-stratified analyses distinguishing between lower-risk births (LRB) and higher-risk births (HRB) to examine how disparities persist even after accounting for behavioral clinical risk profiles.

---

## Repository Structure

```
Unequal_Risks/
├── data/                  # [NOT INCLUDED] – user must download raw data from source
├── 01_cleaning.do         # Clean and recode raw natality data
├── 02_filter.do           # Apply exclusionary criteria 
├── 03_dtable_colperc.do   # Generate descriptive statistics using `dtable`
├── 04_dtable_rowperc.do   # Compute row percentages by delivery method
├── 05_CoR_models.do       # Run chain-of-risk logistic regression models
├── 06_LRB_HRB_models.do   # Run LRB and HRB regression models with interactions
├── 07_LRB_HRB_PP_AME.do   # Compute predicted probabilities and marginal effects
```

---

## Data Source

U.S. Natality Public Use File (2023)  
Available via the National Bureau of Economic Research (NBER):  
https://www.nber.org/research/data/vital-statistics-natality-birth-data

**Note:** The raw data file (`natality2023us.dta`) is not included in this repository due to size and licensing. Please download it directly from the NBER website and place it in the `/data/` folder.

---

## Requirements

- **Stata Version**: 18 or higher  
  Uses Stata 18-specific functions (e.g., `etable`, `dtable`, `collect`, etc.)

- **Recommended Package**:
  ```stata
  ssc install estout
  ```

---

## License

This project is licensed under the MIT License.

---

## Reproducibility

To replicate the analysis:

1. Download the [2023 Natality dataset](https://www.nber.org/research/data/vital-statistics-natality-birth-data)
2. Place the raw file in: `Unequal_Risks/data/natality2023us.dta`
3. Open Stata (version 18+), set your working directory to the root folder:
   ```stata
   cd "your/local/path/Unequal_Risks"
   ```
4. Run the scripts in order:
   - `01_cleaning.do`
   - `02_filter.do`
   - `03_dtable_colperc.do`
   - `04_dtable_rowperc.do`
   - `05_CoR_models.do`
   - `06_LRB_HRB_models.do`
   - `07_LRB_HRB_PP_AME.do`
