# ============================================================
# Modeling Dataset Integration
# Senior Thesis
#
# Purpose:
# Combine the finalized historical lag-1 baseline sample with
# the validated engineered weather features and establish the
# common county-year sample used for model development.
#
# Week 2 priorities:
# 1. Verify input datasets and join keys
# 2. Create a common modeling sample
# 3. Define the three planned predictor groups
# 4. Preserve 2022-2025 as the untouched final holdout
# 5. Prepare for the advisor-requested W03/E01
#    multicollinearity sensitivity analysis
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. Load saved project datasets
# ------------------------------------------------------------

lag1_development <- read_csv(
  "output/historical_baseline/final_lag1_development_sample.csv",
  show_col_types = FALSE
)

weather_features_all <- readRDS(
  "output/weather_features/indiana_weather_features_2000_2025.rds"
)

# ------------------------------------------------------------
# 2. Inspect input datasets
# ------------------------------------------------------------

dim(lag1_development)
names(lag1_development)
glimpse(lag1_development)

dim(weather_features_all)
names(weather_features_all)
glimpse(weather_features_all)

# Historical lag-1 sample
lag1_development %>%
  summarise(
    first_year = min(year),
    last_year = max(year),
    counties = n_distinct(fips),
    observations = n()
  )

# Weather feature dataset
weather_features_all %>%
  summarise(
    first_year = min(year),
    last_year = max(year),
    counties = n_distinct(fips),
    observations = n()
  )

# ------------------------------------------------------------
# 3. Standardize join-key data types
# ------------------------------------------------------------

lag1_development <- lag1_development %>%
  mutate(
    fips = sprintf(
      "%05d",
      as.integer(fips)
    ),
    year = as.integer(year)
  )

weather_features_all <- weather_features_all %>%
  mutate(
    fips = as.character(fips),
    year = as.integer(year)
  )

# Confirm matching data types
class(lag1_development$fips)
class(weather_features_all$fips)

class(lag1_development$year)
class(weather_features_all$year)

# ------------------------------------------------------------
# 4. Verify county-year join keys
# ------------------------------------------------------------

lag1_development %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

weather_features_all %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

# ------------------------------------------------------------
# 5. Check join coverage before merging
# ------------------------------------------------------------

development_without_weather <- lag1_development %>%
  anti_join(
    weather_features_all,
    by = c(
      "fips",
      "year"
    )
  )

nrow(development_without_weather)

development_without_weather

# ------------------------------------------------------------
# 6. Merge lag-1 development sample with weather features
# ------------------------------------------------------------

modeling_development <- lag1_development %>%
  left_join(
    weather_features_all %>%
      select(
        fips,
        year,
        w01_early_tavg,
        w02_early_prcp,
        w03_repro_tavg,
        w04_repro_prcp,
        w05_grainfill_tavg,
        w06_grainfill_prcp,
        e01_hot_days_30,
        e02_heat_above_35,
        e03_longest_dry_spell,
        e04_max_5day_prcp
      ),
    by = c(
      "fips",
      "year"
    )
  )

# ------------------------------------------------------------
# 7. Verify merged development dataset
# ------------------------------------------------------------

dim(modeling_development)

glimpse(modeling_development)

modeling_development %>%
  summarise(
    first_year = min(year),
    last_year = max(year),
    counties = n_distinct(fips),
    observations = n()
  )

modeling_development %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

modeling_development %>%
  summarise(
    missing_yield = sum(is.na(corn_yield)),
    missing_lag1 = sum(is.na(lag1_yield)),
    missing_w01 = sum(is.na(w01_early_tavg)),
    missing_w02 = sum(is.na(w02_early_prcp)),
    missing_w03 = sum(is.na(w03_repro_tavg)),
    missing_w04 = sum(is.na(w04_repro_prcp)),
    missing_w05 = sum(is.na(w05_grainfill_tavg)),
    missing_w06 = sum(is.na(w06_grainfill_prcp)),
    missing_e01 = sum(is.na(e01_hot_days_30)),
    missing_e02 = sum(is.na(e02_heat_above_35)),
    missing_e03 = sum(is.na(e03_longest_dry_spell)),
    missing_e04 = sum(is.na(e04_max_5day_prcp))
  )

# ------------------------------------------------------------
# 8. Define planned predictor groups
# ------------------------------------------------------------

baseline_predictors <- c(
  "fips",
  "year_centered",
  "lag1_yield"
)

conventional_weather_predictors <- c(
  "w01_early_tavg",
  "w02_early_prcp",
  "w03_repro_tavg",
  "w04_repro_prcp",
  "w05_grainfill_tavg",
  "w06_grainfill_prcp"
)

extreme_weather_predictors <- c(
  "e01_hot_days_30",
  "e02_heat_above_35",
  "e03_longest_dry_spell",
  "e04_max_5day_prcp"
)

model_group_1 <- baseline_predictors

model_group_2 <- c(
  baseline_predictors,
  conventional_weather_predictors
)

model_group_3 <- c(
  baseline_predictors,
  conventional_weather_predictors,
  extreme_weather_predictors
)

model_group_1
model_group_2
model_group_3

# ------------------------------------------------------------
# 9. Rebuild full USDA yield history for holdout construction
# ------------------------------------------------------------

usda_raw <- read_csv(
  "data/raw/IN_CornYield_AllYears.csv",
  show_col_types = FALSE
)

yield_history_full <- usda_raw %>%
  filter(
    Year >= 2000,
    Year <= 2025,
    `Geo Level` == "COUNTY",
    Commodity == "CORN",
    `Data Item` == "CORN, GRAIN - YIELD, MEASURED IN BU / ACRE",
    !is.na(`County ANSI`)
  ) %>%
  mutate(
    fips = paste0(
      sprintf("%02d", as.integer(`State ANSI`)),
      sprintf("%03d", as.integer(`County ANSI`))
    ),
    corn_yield = parse_number(as.character(Value))
  ) %>%
  select(
    fips,
    county = County,
    year = Year,
    corn_yield
  ) %>%
  arrange(
    fips,
    year
  )

# ------------------------------------------------------------
# 10. Create complete 2000-2025 county-year panel
# ------------------------------------------------------------

county_lookup_full <- yield_history_full %>%
  distinct(
    fips,
    county
  ) %>%
  arrange(fips)

full_yield_panel <- expand_grid(
  fips = county_lookup_full$fips,
  year = 2000:2025
) %>%
  left_join(
    county_lookup_full,
    by = "fips"
  ) %>%
  left_join(
    yield_history_full %>%
      select(
        fips,
        year,
        corn_yield
      ),
    by = c(
      "fips",
      "year"
    )
  ) %>%
  arrange(
    fips,
    year
  )

# ------------------------------------------------------------
# 11. Create lag-1 yield across full study period
# ------------------------------------------------------------

full_lag1_panel <- full_yield_panel %>%
  group_by(fips) %>%
  arrange(
    year,
    .by_group = TRUE
  ) %>%
  mutate(
    lag1_yield = lag(
      corn_yield,
      1
    )
  ) %>%
  ungroup()

# ------------------------------------------------------------
# 12. Construct lag-1 eligible holdout sample
# ------------------------------------------------------------

lag1_holdout <- full_lag1_panel %>%
  filter(
    year >= 2022,
    year <= 2025,
    !is.na(corn_yield),
    !is.na(lag1_yield)
  ) %>%
  mutate(
    year_centered = year - 2000
  )

dim(lag1_holdout)

lag1_holdout %>%
  summarise(
    first_year = min(year),
    last_year = max(year),
    counties = n_distinct(fips),
    observations = n()
  )

lag1_holdout %>%
  group_by(year) %>%
  summarise(
    observations = n(),
    counties = n_distinct(fips),
    .groups = "drop"
  ) %>%
  print(n = Inf)

lag1_holdout %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

lag1_holdout %>%
  filter(
    is.na(lag1_yield)
  )

# ------------------------------------------------------------
# 13. Verify weather availability for holdout sample
# ------------------------------------------------------------

holdout_without_weather <- lag1_holdout %>%
  anti_join(
    weather_features_all,
    by = c(
      "fips",
      "year"
    )
  )

nrow(holdout_without_weather)

holdout_without_weather

# ------------------------------------------------------------
# 14. Merge holdout sample with weather features
# ------------------------------------------------------------

lag1_holdout <- lag1_holdout %>%
  mutate(
    year = as.integer(year)
  )

modeling_holdout <- lag1_holdout %>%
  left_join(
    weather_features_all %>%
      select(
        fips,
        year,
        w01_early_tavg,
        w02_early_prcp,
        w03_repro_tavg,
        w04_repro_prcp,
        w05_grainfill_tavg,
        w06_grainfill_prcp,
        e01_hot_days_30,
        e02_heat_above_35,
        e03_longest_dry_spell,
        e04_max_5day_prcp
      ),
    by = c(
      "fips",
      "year"
    )
  )

dim(modeling_holdout)

modeling_holdout %>%
  summarise(
    first_year = min(year),
    last_year = max(year),
    counties = n_distinct(fips),
    observations = n()
  )

modeling_holdout %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

modeling_holdout %>%
  summarise(
    missing_yield = sum(is.na(corn_yield)),
    missing_lag1 = sum(is.na(lag1_yield)),
    missing_w01 = sum(is.na(w01_early_tavg)),
    missing_w02 = sum(is.na(w02_early_prcp)),
    missing_w03 = sum(is.na(w03_repro_tavg)),
    missing_w04 = sum(is.na(w04_repro_prcp)),
    missing_w05 = sum(is.na(w05_grainfill_tavg)),
    missing_w06 = sum(is.na(w06_grainfill_prcp)),
    missing_e01 = sum(is.na(e01_hot_days_30)),
    missing_e02 = sum(is.na(e02_heat_above_35)),
    missing_e03 = sum(is.na(e03_longest_dry_spell)),
    missing_e04 = sum(is.na(e04_max_5day_prcp))
  )

# ------------------------------------------------------------
# 15. Verify development / holdout separation
# ------------------------------------------------------------

development_holdout_overlap <- modeling_development %>%
  inner_join(
    modeling_holdout,
    by = c(
      "fips",
      "year"
    )
  )

nrow(development_holdout_overlap)

range(modeling_development$year)
range(modeling_holdout$year)

unseen_holdout_counties <- setdiff(
  unique(modeling_holdout$fips),
  unique(modeling_development$fips)
)

length(unseen_holdout_counties)

unseen_holdout_counties

# ------------------------------------------------------------
# 16. Audit holdout lag-1 eligibility
# ------------------------------------------------------------

holdout_eligibility_audit <- full_lag1_panel %>%
  filter(
    year >= 2022,
    year <= 2025
  ) %>%
  mutate(
    current_yield_available = !is.na(corn_yield),
    lag1_available = !is.na(lag1_yield),
    eligible_for_modeling =
      current_yield_available & lag1_available
  ) %>%
  group_by(year) %>%
  summarise(
    possible_counties = n(),
    current_yield_available = sum(current_yield_available),
    lag1_available = sum(lag1_available),
    modeling_eligible = sum(eligible_for_modeling),
    .groups = "drop"
  )

print(
  holdout_eligibility_audit,
  n = Inf
)

# ------------------------------------------------------------
# 17. Save integrated modeling datasets
# ------------------------------------------------------------

dir.create(
  "output/modeling_dataset",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  modeling_development,
  "output/modeling_dataset/modeling_development_2001_2021.csv"
)

saveRDS(
  modeling_development,
  "output/modeling_dataset/modeling_development_2001_2021.rds"
)

write_csv(
  modeling_holdout,
  "output/modeling_dataset/modeling_holdout_2022_2025.csv"
)

saveRDS(
  modeling_holdout,
  "output/modeling_dataset/modeling_holdout_2022_2025.rds"
)

write_csv(
  holdout_eligibility_audit,
  "output/modeling_dataset/holdout_eligibility_audit.csv"
)
