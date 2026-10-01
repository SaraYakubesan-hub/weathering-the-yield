# Weathering the Yield

**Senior Thesis – INFO-I 492**

This project examines whether growing-season weather conditions and
extreme-weather indicators improve prediction of Indiana county-level
corn grain yield beyond historical yield patterns.

## Research Question

To what extent do growing-season weather conditions and extreme-weather
indicators improve the prediction of Indiana county-level corn yields
beyond historical yield patterns?

## Data Sources

- USDA NASS Quick Stats – Indiana county-level corn grain yield
- NOAA nClimGrid Daily data accessed through EpiNOAA

Study period: 2000–2025

## Modeling Design

Three predictor groups are compared:

1. Historical yield baseline
2. Historical baseline + conventional weather
3. Historical baseline + conventional weather + extreme-weather indicators

The 2022–2025 period is reserved for final evaluation.

## Repository Structure

- `scripts/` – reproducible R scripts used for data preparation, feature engineering, auditing, modeling, and evaluation
- `data/processed/` – finalized development and holdout modeling datasets
- `methodology/` – methodology decision documentation
- `evidence/` – selected outputs organized by weekly status-report period
- `docs/` – project documentation and status materials

## Current Progress

### Week 1
Completed work includes:

- literature-informed methodology decisions
- historical-yield feature audit
- lag-1 baseline selection and setup
- weather-feature definitions
- full 2000–2025 weather-feature engineering
- development-period weather-feature audit

### Week 2
Completed work includes:

- integration of historical yield and engineered weather features
- creation of separate development and final holdout modeling datasets
- finalization of the three planned predictor groups
- advisor-requested W03/E01 multicollinearity sensitivity analysis
- retention of W03 July mean temperature and exclusion of E01 hot-day count
  from the primary predictor set
- update of the Methodology Decision Table
- modeling-readiness audit of the finalized predictor groups
- verification of the 2012–2021 rolling-origin validation structure
- confirmation that all three planned linear-model specifications can be fit
  across all validation folds without prediction or rank-deficiency problems
  
### Week 3
Completed work includes:

- completion of the multiple linear regression comparison across all three
  finalized predictor groups using 2012–2021 expanding-window validation
- evaluation of annual and pooled RMSE, MAE, and R² for the linear models
- sensitivity analysis confirming that the linear-model predictor-group
  comparison was not driven solely by the 2012 validation year
- completion of the Random Forest comparison across the same predictor groups
  and validation years
- implementation of nested time-aware Random Forest hyperparameter tuning
  within each outer training period
- verification that all three predictor groups were evaluated on the same
  739 development-period validation observations
- calculation of annual, pooled, incremental, sensitivity, and yearly-win
  comparisons for Random Forest
- creation of RMSE-by-validation-year figures for both linear regression and
  Random Forest
- addition of `17_linear_model_comparison.R` and
  `18_random_forest_comparison.R` to the modeling workflow
- organization of selected Week 3 outputs and figures under
  `evidence/week_03/`

Linear regression and Random Forest development-stage comparisons are now
complete. Gradient boosting remains the next planned modeling approach before
development-stage model decisions are finalized.

The development dataset contains 1,691 county-year observations across 91 Indiana counties from 2001–2021.

The final holdout contains 247 lag-1-eligible county-year observations across 82 Indiana counties from 2022–2025.

The 2022–2025 holdout has not been used for feature selection, model-development decisions, or tuning.
