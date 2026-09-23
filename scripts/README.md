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


## Notes

Scripts are intended to be run in numerical order where dependencies exist.

Feature definitions, thresholds, and methodological decisions are documented separately in the Methodology Decision Table.
