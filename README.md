# Unequal_Risks
Replication code for Manuscript "Unequal Risks: Caesarean Deliveries among Marginalized Populations in the U.S." 
(PRPR submission using 2023 US Natality Data)

*Authors: Maria Ahmed (University of Western Ontario) & Kim Shuey (University of Western Ontario)*

---


## Project Description

This study examines racial and socioeconomic disparities in Caesarean-section (C-section) delivery using 2023 U.S. Natality data (singleton, headfirst, full-term births among first-time mothers, N = 960,154). We employ risk-stratified analyses distinguishing between lower-risk births (LRB) and higher-risk births (HRB) to assess whether disparities persist after accounting for behavioral, medical, fetal, and labor-related risk factors. Guided by Fundamental Cause Theory, the analysis further evaluates whether socioeconomic resources—measured by private insurance and maternal education—confer equivalent protection across racial groups.

---

## Repository Structure

```text
Unequal_Risks/
├── data/ # [NOT INCLUDED] – user must download raw natality data
├── 01_cleaning.do # Clean and recode raw natality data
├── 02_filter.do # Apply exclusionary criteria
├── 03_dtable_colperc.do # Generate descriptive statistics (column percentages)
├── 04_dtable_rowperc.do # Generate descriptive statistics (row percentages)
├── 05_CoR_models.do # Estimate logistic regression models; export baseline and fully adjusted models
├── 06_LRB_HRB_models.do # Estimate LRB/HRB regression models with interactions (race × insurance; race × education)
├── 07_LRB_HRB_PP_AME.do # Compute predicted probabilities, average marginal effects, and second differences for race × insurance and race × education
```

---

## Data Source

U.S. Natality Public Use File (2023)  
The Natality data are originally published by the National Center for Health Statistics (NCHS) and are available in Stata format from the National Bureau of Economic Research (NBER) at:  
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
