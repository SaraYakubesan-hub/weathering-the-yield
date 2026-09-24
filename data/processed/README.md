# Processed Modeling Data

This folder contains processed datasets created for the senior thesis modeling workflow.

## Files

### `modeling_development_2001_2021.csv`
Development modeling dataset used for feature evaluation, rolling-origin validation, and model development.

The dataset:
- covers 2001–2021;
- contains 1,691 county-year observations across 91 Indiana counties;
- includes the historical baseline variables and engineered weather features;
- excludes observations without current-year or lag-1 yield values; and
- is the only dataset used for development-period feature and model decisions.

### `modeling_holdout_2022_2025.csv`
Final holdout dataset reserved for evaluation after model-development decisions are complete.

The dataset:
- covers 2022–2025;
- contains 247 lag-1-eligible county-year observations across 82 Indiana counties;
- was created using the same processing rules as the development dataset; and
- is kept separate from the development data to reduce the risk of information leakage.

## Data Sources

Processed datasets are derived from:
- USDA NASS county-level Indiana corn yield data
- NOAA EpiNOAA county-level weather data

## Reproducibility

The processed datasets are created by:

`14_modeling_dataset_integration.R`

Feature definitions and modeling decisions are documented in the `methodology/` folder.

The 2022–2025 holdout should not be used for feature selection, model tuning, or other development decisions.
