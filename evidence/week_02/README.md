# Week 2 Evidence

This folder contains selected evidence supporting the Week 2 project status report.

## Week 2 Focus

Week 2 completed the modeling-data integration stage, addressed advisor feedback regarding multicollinearity between W03 and E01, and verified that the finalized predictor groups and rolling-origin validation structure are ready for formal model development.

## Evidence Included

### Figure
- `w03_e01_relationship.png` — visualizes the strong relationship between July mean temperature and July hot-day count in the development sample.

### Integration and Holdout Audit
- `holdout_eligibility_audit.csv` — summarizes current-year and lag-1 yield availability for the 2022–2025 holdout period.

### Multicollinearity Sensitivity Analysis
- `multicollinearity_diagnostics.csv` — records the W03/E01 multicollinearity diagnostics.
- `sensitivity_summary.csv` — summarizes rolling-origin RMSE and MAE for the three W03/E01 model specifications.
- `yearly_comparison.csv` — compares performance by validation year.
- `sensitivity_decision.csv` — documents the decision to retain W03 and exclude E01 before final holdout evaluation.

### Modeling Readiness
- `rolling_fold_readiness.csv` — verifies the 2012–2021 expanding-window validation structure and absence of unseen validation counties.
- `model_readiness_summary.csv` — summarizes linear-model fit and prediction readiness across all three predictor groups.
- `modeling_readiness_decision.csv` — records the final readiness determination before formal model development.

## Related Repository Files

- `scripts/14_modeling_dataset_integration.R`
- `scripts/15_multicollinearity_sensitivity_analysis.R`
- `scripts/16_modeling_readiness_audit.R`
- `methodology/Methodology_Decision_Table.xlsx`
- `data/processed/modeling_development_2001_2021.csv`
- `data/processed/modeling_holdout_2022_2025.csv`

The 2022–2025 holdout was not used to make feature-selection or model-development decisions.
