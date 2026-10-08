# Week 4 Evidence

This folder contains supporting evidence for the Week 4 thesis status report.

## Gradient Boosting

The `gradient_boosting` folder contains development-period results from the
XGBoost comparison of the three finalized predictor groups using the same
2012–2021 expanding-window validation framework used for the linear regression
and Random Forest analyses.

Hyperparameters were selected within each outer training period using nested
time-aware validation.

Key evidence includes:

- annual and pooled performance summaries
- incremental predictor-group comparisons
- yearly predictor-group win counts
- sensitivity analysis excluding 2012
- RMSE-by-validation-year figure
- summary of the primary XGBoost development result

Group 3 produced the strongest overall XGBoost performance.

## Model-Family Comparison

The `model_family_comparison` folder contains the development-stage comparison
of Linear Regression, Random Forest, and XGBoost across all three finalized
predictor groups.

All nine model specifications were evaluated using the same 2012–2021
validation years and the same 739 pooled validation observations per
specification.

Key evidence includes:

- pooled rankings across all nine model specifications
- complete yearly model-family comparisons
- sensitivity analysis excluding 2012
- model-specification win counts
- RMSE-by-validation-year figure
- summary of the final development-stage comparison

Linear Regression with Group 3 predictors produced the strongest overall
development-stage performance and ranked first on pooled RMSE, MAE, and R².

## Difficult-Year Diagnostic

The `difficult_year_diagnostic` folder contains a descriptive follow-up
analysis of validation years with unusually high prediction error across the
completed development-stage model specifications.

The three difficult years were selected systematically using median RMSE
across all nine model specifications. The identified years were 2012, 2013,
and 2015.

Key evidence includes:

- compact difficult-year diagnostic summary
- most unusual weather features for each difficult year
- predictor-group support within the difficult years

The difficult years showed different yield and weather conditions rather than
one common failure pattern. This analysis was diagnostic only and did not
result in additional model tuning, predictor changes, or model-family changes.

## Development-Stage Lock

The `development_stage_lock` folder documents the formal model-selection
checkpoint completed before final holdout evaluation.

Linear Regression with Group 3 predictors was selected as the final
development-stage specification.

Key evidence includes:

- formal development-stage lock record
- overall ranking of all nine development-stage model specifications
- exact locked predictor definition
- final pre-holdout checkpoint

The locked Group 3 specification includes county identity, centered year,
lag-1 yield, the six conventional weather predictors W01–W06, and the retained
extreme-weather predictors E02–E04. E01 remains excluded.

No new model fitting, tuning, or predictor changes were performed during the
development-stage lock.

## Holdout Safeguard

All Week 4 model-development results use only pre-2022 development data.

The 2022–2025 final holdout remained unused throughout gradient boosting,
model-family comparison, difficult-year diagnostics, model selection, and the
formal development-stage lock.

The final model specification was therefore fixed before final holdout
evaluation.