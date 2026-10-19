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

The 2022–2025 period was reserved for final evaluation and was not used for model selection or tuning.

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

### Week 4
Completed work includes:

- completion of the XGBoost comparison across all three finalized predictor
  groups using the same 2012–2021 expanding-window validation framework
- implementation of nested time-aware XGBoost hyperparameter tuning using
  development-stage data only
- completion of the cross-model comparison of Linear Regression, Random
  Forest, and XGBoost across all nine algorithm and predictor-group
  specifications
- identification of Linear Regression with Group 3 predictors as the
  strongest overall development-stage specification
- confirmation that the selected specification ranked first on pooled RMSE,
  MAE, and R²
- sensitivity analysis confirming that the selected specification remained
  strongest when 2012 was excluded
- descriptive diagnostic analysis of the most difficult validation years:
  2012, 2013, and 2015
- confirmation that the difficult-year diagnostic did not result in
  additional tuning, predictor changes, or model-family changes
- formal locking of the Linear Regression Group 3 specification before final
  holdout evaluation
- documentation of the exact locked predictor set and pre-holdout checkpoint
- addition of 19_gradient_boosting_comparison.R,
  20_model_family_comparison.R, 21_difficult_year_diagnostic.R, and
  22_development_stage_lock.R
- organization of selected Week 4 outputs under evidence/week_04/

### Week 5
Completed work includes:

- completion of the final 2022–2025 holdout evaluation using the formally
  locked Linear Regression Group 3 specification
- fitting of the locked model using the full 2001–2021 development dataset
  with no post-holdout tuning or predictor changes
- evaluation of final holdout performance across 247 county-year observations
  from 82 Indiana counties
- final pooled holdout performance of RMSE 11.97 bushels per acre,
  MAE 9.79 bushels per acre, and R² 0.392
- evaluation of year-specific holdout performance for 2022–2025
- assessment of overall prediction bias and observed-versus-predicted behavior
- comparison of development-stage validation and final holdout performance
- completion of a descriptive county-level spatial error diagnostic using
  2012–2021 rolling-validation predictions
- evaluation of county-level RMSE for the selected Group 3 specification
- comparison of county-level RMSE between Group 1 and Group 3
- confirmation that Group 3 produced lower county-level RMSE in 78 of
  89 evaluated counties
- creation of Indiana county maps showing Group 3 RMSE and the change in RMSE
  from Group 1 to Group 3
- confirmation that the spatial diagnostic did not result in any model changes
- addition of `23_final_holdout_evaluation.R` and
  `24_spatial_error_diagnostic.R`
- organization of selected Week 5 outputs and figures under
  `evidence/week_05/`


The selected final model is Multiple Linear Regression with Group 3 predictors.

The locked Group 3 specification includes county identity, centered year,
lag-1 yield, six conventional weather predictors, and three retained
extreme-weather predictors. E01 hot-day count remains excluded.

The development dataset contains 1,691 county-year observations across
91 Indiana counties from 2001–2021.

The final holdout contains 247 lag-1-eligible county-year observations across
82 Indiana counties from 2022–2025.

The final model specification was selected and formally locked before the
2022–2025 holdout was evaluated. No model tuning, predictor changes, or
model-family changes were made after viewing final holdout results.

Final pooled holdout performance was RMSE 11.97 bushels per acre,
MAE 9.79 bushels per acre, and R² 0.392.

A descriptive county-level spatial diagnostic was also completed using
2012–2021 development-stage rolling-validation predictions. Group 3 produced
lower county-level RMSE than Group 1 in 78 of 89 evaluated counties. The
spatial diagnostic was not used to modify the selected model.

The planned modeling and evaluation analyses are complete.
