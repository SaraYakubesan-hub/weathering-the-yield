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

Three predictor groups will be compared:

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

The development dataset contains 1,691 county-year observations across 91 Indiana counties from 2001–2021.

The final holdout contains 247 lag-1-eligible county-year observations across 82 Indiana counties from 2022–2025.

The 2022–2025 holdout has not been used for feature selection, model-development decisions, or tuning.
