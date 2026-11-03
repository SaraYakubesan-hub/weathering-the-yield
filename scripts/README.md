# Scripts

This folder contains the R scripts used for data auditing, historical-baseline development, weather-feature engineering, model development and comparison, final evaluation, diagnostic analysis, uncertainty assessment, and final figure standardization for the senior thesis project.

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
  
- `23_final_holdout_evaluation.R` — fits the formally locked Linear Regression Group 3 specification using the full 2001–2021 development dataset and evaluates it on the previously 
  untouched 2022–2025 final holdout. Produces pooled and year-specific RMSE, MAE, and R², prediction-bias summaries, development-versus-holdout comparisons, diagnostic figures, and 
  the final fitted model. No model tuning or predictor changes are performed after holdout evaluation.

- `24_spatial_error_diagnostic.R` — performs a descriptive county-level spatial diagnostic using existing 2012–2021 Linear Regression rolling-validation predictions. Summarizes Group 3 
  county-level RMSE, compares county RMSE between Group 1 and Group 3, evaluates validation coverage, and produces Indiana county maps of Group 3 error and RMSE reduction. This diagnostic 
  does not refit or modify the selected model.

- `25_final_model_diagnostics.R` — performs post-selection diagnostic and uncertainty analyses for the formally locked Linear Regression Group 3 model. Extracts final-model coefficient estimates and model-based 95% confidence intervals, calculates county-clustered bootstrap uncertainty intervals for development-stage and final-holdout predictive performance, evaluates residual patterns, influence, leverage, heteroscedasticity, and possible nonlinear structure, and generates conventional 95% prediction intervals for the final holdout. These analyses are supplemental assessments only and do not refit, retune, or modify the locked model.

- `26_final_figure_standardization.R` — creates final standardized versions of selected thesis figures using previously completed analytical outputs. Refreshes Figures 1–4 and Figures 7–8 with consistent labeling, legends, grayscale readability, and map formatting. This script changes figure presentation only and does not refit models, change model selection, or recalculate final-holdout performance.

## Notes

Scripts are intended to be run in numerical order where dependencies exist.

Feature definitions, thresholds, and methodological decisions are documented separately in the Methodology Decision Table.

The final development-stage specification is Linear Regression with Group 3 predictors. This specification was formally locked before evaluation of the 2022–2025 final holdout.

Script 23 completed the final holdout evaluation using the locked specification. Final pooled holdout performance was RMSE 11.97 bushels per acre, MAE 9.79 bushels per acre, and R² 0.392 across 247 county-year observations.

Script 24 completed the descriptive county-level spatial diagnostic using 2012–2021 development-stage rolling-validation predictions. Group 3 had lower county-level RMSE than Group 1 in 78 of 89 evaluated counties.

Script 25 completed the final post-selection diagnostic and uncertainty assessment for the locked Linear Regression Group 3 model. The analysis included final-model coefficient confidence intervals, 2,000 county-clustered bootstrap resamples for predictive-performance uncertainty, residual and influence diagnostics, heteroscedasticity and nonlinear-pattern assessment, and conventional 95% prediction intervals for the 2022–2025 final holdout. These supplemental analyses did not result in predictor removal, model refitting, tuning, or modification of the locked specification.

Script 26 completed the final thesis figure-standardization workflow using previously generated development-stage and spatial-analysis results. Standardized versions of Figures 1–4 and Figures 7–8 were produced without changing the underlying analytical results.

No model tuning, predictor changes, or model-family changes were made after final holdout evaluation or spatial diagnostic review.
