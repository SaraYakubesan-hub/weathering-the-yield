# Scripts

This folder contains the R scripts used for data auditing, historical-baseline development, weather-feature engineering, and feature evaluation for the senior thesis project.

## Script Order

- `07_usda_coverage_audit.R`  
  Audits USDA NASS county-level corn-yield coverage for the 2000–2025 study period.

- `08_noaa_coverage_audit.R`  
  Audits NOAA nClimGrid daily county-level weather coverage and data quality.

- `09_yield_history_availability_audit.R`  
  Evaluates availability of lagged historical yield features and compares candidate recent-yield representations.

- `10_historical_baseline_comparison.R`  
  Compares historical baseline candidates using expanding-window rolling-origin validation.

- `11_historical_baseline_setup.R`  
  Creates the final lag-1 historical development sample and audits the planned validation folds.

- `12_weather_feature_engineering.R`  
  Engineers six conventional weather predictors and four extreme-weather predictors from daily NOAA data.

- `13_weather_feature_audit.R`  
  Audits the engineered weather features using the 2000–2021 development period while preserving 2022–2025 as the final holdout.

- `14_modeling_dataset_integration.R`
  Integrates the finalized lag-1 historical baseline sample with the engineered weather features and creates the modeling datasets used for development and final evaluation.

- `15_multicollinearity_sensitivity_analysis.R`
  Evaluates the strong relationship between July mean temperature (W03) and July hot-day count (E01) identified during development-period feature auditing.

- `16_modeling_readiness_audit.R`
  Verifies that the finalized development dataset and revised predictor groups are ready for formal model development.

- `17_linear_model_comparison.R` — compares the three finalized predictor groups using multiple linear regression and 2012–2021 expanding-window
  validation. Produces annual and pooled performance metrics, incremental predictor-group comparisons, sensitivity analysis, and validation-year
  performance figures.
  
- `18_random_forest_comparison.R` — compares the same three predictor groups using Random Forest models with nested time-aware hyper-parameter tuning.
  Uses the same 2012–2021 outer validation folds and performance metrics as the linear-model analysis and produces annual, pooled, incremental,
  sensitivity, and year-to-year comparison outputs.

- `19_gradient_boosting_comparison.R` — compares the three finalized predictor groups using XGBoost with nested time-aware hyperparameter tuning. Uses the same 2012–2021 outer validation
  structure and performance metrics as the linear regression and Random Forest
  analyses.
  
- `20_model_family_comparison.R` — combines completed Linear Regression, Random Forest, and XGBoost results to compare all nine algorithm and predictor-group specifications using the same
  2012–2021 validation period. Produces pooled rankings, yearly comparisons, sensitivity results, and the final development-stage model-family comparison.

- `21_difficult_year_diagnostic.R` — identifies validation years with unusually high prediction error across the completed model specifications and describes their yield and weather
  conditions. This script is diagnostic only and does not perform additional model tuning or predictor selection.
  
- `22_development_stage_lock.R` — formally locks the selected development-stage model specification before final holdout evaluation. Verifies the completed model comparison, records
  the exact locked predictor set, and confirms that the 2022–2025 final holdout remains unused.

## Notes

Scripts are intended to be run in numerical order where dependencies exist.

Feature definitions, thresholds, and methodological decisions are documented separately in the Methodology Decision Table.

The final development-stage specification is Linear Regression with Group 3 predictors. This specification was locked before evaluation of the 2022–2025 final holdout.
