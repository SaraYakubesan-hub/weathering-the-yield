# Week 3 Evidence

This folder contains supporting evidence for the Week 3 thesis status report.

## Linear Model

The `linear_model` folder contains development-period results from the
multiple linear regression comparison of the three finalized predictor
groups using expanding-window validation from 2012 through 2021.

Key evidence includes:

- annual and pooled performance summaries
- incremental predictor-group comparisons
- sensitivity analysis excluding 2012
- RMSE-by-validation-year figure
- summary of the primary linear-model development result

## Random Forest

The `random_forest` folder contains results from the Random Forest
comparison using the same development observations, predictor groups,
outer validation years, and performance metrics as the linear-model
analysis.

Hyperparameters were selected within each outer training period using
nested time-aware validation.

Key evidence includes:

- annual and pooled performance summaries
- incremental predictor-group comparisons
- yearly predictor-group win counts
- sensitivity analysis excluding 2012
- RMSE-by-validation-year figure
- summary of the primary Random Forest development result

## Holdout Safeguard

All Week 3 model-development results use only pre-2022 development data.
The 2022–2025 final holdout has not been used for model selection or
development-stage performance comparisons.