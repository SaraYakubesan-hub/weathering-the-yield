# Week 5 Evidence

This folder contains supporting evidence for the Week 5 thesis analysis and
final evaluation.

## Final Holdout Evaluation

The `final_holdout_evaluation` folder contains results from the final evaluation
of the locked Linear Regression Group 3 specification on the 2022–2025
holdout period.

The model specification was selected and formally locked using development-stage
information through 2021 before the final holdout was evaluated. No model
tuning, predictor changes, or model-family changes were made after viewing
holdout performance.

The final holdout contained 247 lag-1-eligible county-year observations across
82 Indiana counties.

Key evidence includes:

- final pooled holdout performance
- year-specific holdout performance for 2022–2025
- comparison of development-stage validation and final holdout metrics
- overall holdout prediction-bias summary
- observed-versus-predicted diagnostic figure
- residual distribution by holdout year

The locked model achieved final pooled holdout performance of:

- RMSE: 11.97 bushels per acre
- MAE: 9.79 bushels per acre
- R²: 0.392

Holdout RMSE and MAE were lower than the corresponding 2012–2021
development-stage rolling-validation values. These results are reported as
performance differences rather than as a direct percentage improvement because
the development and final-holdout evaluation settings differ.

## Spatial Error Diagnostic

The `spatial_error_diagnostic` folder contains a descriptive county-level
analysis of development-stage validation error for the selected Linear
Regression Group 3 specification.

The spatial diagnostic uses the existing 2012–2021 rolling-validation
predictions rather than the final holdout because the development-stage
predictions provide more repeated validation observations per county.

Key evidence includes:

- county-level Group 3 RMSE
- county-level RMSE comparison between Group 1 and Group 3
- county validation-observation coverage
- statewide summary of county-level improvement
- counties without eligible validation observations
- map of Group 3 county-level RMSE
- map of the change in county-level RMSE from Group 1 to Group 3

Eighty-nine Indiana counties had eligible validation observations. Brown,
Crawford, and Perry counties did not.

Group 3 produced lower county-level RMSE than Group 1 in 78 of the 89 evaluated
counties. The median county-level RMSE reduction was 11.33 bushels per acre,
with a median percentage reduction of 35.7%.

County-level results are descriptive. Counties had different numbers of
eligible validation observations, so county-specific RMSE estimates are not
equally precise. The spatial diagnostic was not used to modify the selected
model.

## Analysis Completion

The final holdout evaluation and spatial diagnostic complete the planned model
evaluation analyses.

The selected model remains Linear Regression with Group 3 predictors, and no
model changes were made after final holdout evaluation or spatial diagnostic
review.