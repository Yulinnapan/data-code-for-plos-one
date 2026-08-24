# Data and Code for Journal Submission

This repository contains the replication data and code for the study on the design, pricing, and sustainability of the Long-Term Care Insurance (LTCI) system.

## File Structure & Manifest

The project is structured as follows:

### 1. Code Files (R Scripts)
- **`annual_transition_matrix.R`**: Models the annual transition probabilities of health and dependency states (e.g., transitions between healthy, mild disability, moderate/severe disability, and death).
- **`health_distribution_2025.R`**: Computes the baseline health state distribution of the population for the year 2025.
- **`Inflation Forecast.R`**: Performs forecasting models for medical inflation rates based on historical data.

### 2. Data Files
- **`2020-2029 Population Age Structure & Mortality Rate Projection Table (Cohort Component Method).xlsx`**: Population projections by age group and mortality rate forecasts calculated using the Cohort Component Method.
- **`Forecast of Medical Inflation Rate.RData`**: R workspace file containing variables, parameters, and historical data used for medical inflation rate forecasting.
- **`Pricing Code, Sensitivity Analysis, and Comparison with Government-set Prices.RData`**: R workspace containing premium pricing models, sensitivity analysis data, and comparative statistics with official government-set insurance rates.

### 3. Policy & Supplementary Documents
- **`Implementation Opinions (Interim) of the General Office of the People's Government of Hunan Province on Establishing a Long-Term Care Insurance System (Draft for Comments, February 25, 2025).docx`**: The official interim policy opinion draft from Hunan Province, serving as the policy background and parameter source for our empirical simulation.

---

## How to Reproduce the Results

### Requirements
- **R** (version 4.0.0 or higher is recommended)
- **RStudio** (optional but recommended)
- Required R libraries (e.g., standard statistical packages)

### Execution Steps
1. **Load Data Workspaces**:
   Open R/RStudio and load the `.RData` files to populate the environment with pre-calculated parameters:
   ```R
   load("Forecast of Medical Inflation Rate.RData")
   load("Pricing Code, Sensitivity Analysis, and Comparison with Government-set Prices.RData")
   ```
2. **Run Simulations & Calculations**:
   Execute the R scripts to perform the projections:
   - Run `annual_transition_matrix.R` to compute state transition paths.
   - Run `health_distribution_2025.R` to obtain population health distribution.
   - Run `Inflation Forecast.R` to re-simulate the medical inflation rate projection.

---

## Citation & Licensing
If you find this code or data useful in your research, please cite our paper:
*(Citation details will be updated upon paper publication)*
