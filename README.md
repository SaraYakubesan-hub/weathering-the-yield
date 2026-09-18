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

- `scripts/` – reproducible R scripts used for data preparation,
  feature engineering, auditing, modeling, and evaluation
- `methodology/` – methodology decision documentation
- `evidence/` – selected outputs organized by weekly status-report period
- `docs/` – project documentation and status materials

## Current Progress

Week 1 work includes:

- literature-informed methodology decisions
- historical-yield feature audit
- lag-1 baseline selection and setup
- weather-feature definitions
- full 2000–2025 weather-feature engineering
- development-period weather-feature audit

The 2022–2025 holdout period has not been used for feature-selection decisions.
