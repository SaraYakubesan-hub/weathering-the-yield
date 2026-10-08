# ============================================================
# Difficult-Year Diagnostic
# Senior Thesis
#
# Purpose:
# Identify and describe validation years with unusually high
# development-stage prediction error across model families
# and predictor groups.
#
# Diagnostics include:
# - overall prediction difficulty by validation year
# - observed yield conditions
# - improvement from conventional and extreme-weather
#   predictors
# - growing-season weather conditions
#
# This analysis is descriptive and diagnostic only.
# Weather patterns are interpreted as associations and are
# not treated as causal explanations of prediction error.
#
# Only 2001-2021 development data and completed development-
# stage model results are used.
# The 2022-2025 final holdout is not loaded or used.
# ============================================================

library(tidyverse)


# ------------------------------------------------------------
# 1. Load completed development-stage results
# ------------------------------------------------------------

model_family_comparison <- read_csv(
  "output/model_family_comparison/model_family_yearly_comparison.csv",
  show_col_types = FALSE
)

modeling_development <- readRDS(
  "output/modeling_dataset/modeling_development_2001_2021.rds"
)

dim(
  model_family_comparison
)

dim(
  modeling_development
)

range(
  model_family_comparison$validation_year
)

range(
  modeling_development$year
)

# Holdout safeguards
stopifnot(
  max(
    model_family_comparison$validation_year
  ) <= 2021
)

stopifnot(
  max(
    modeling_development$year
  ) <= 2021
)

# ------------------------------------------------------------
# 2. Summarize prediction difficulty by validation year
# ------------------------------------------------------------

year_difficulty_summary <-
  model_family_comparison %>%
  group_by(
    validation_year
  ) %>%
  summarise(
    model_specifications =
      n(),
    
    mean_rmse =
      mean(rmse),
    
    median_rmse =
      median(rmse),
    
    minimum_rmse =
      min(rmse),
    
    maximum_rmse =
      max(rmse),
    
    mean_mae =
      mean(mae),
    
    median_mae =
      median(mae),
    
    .groups =
      "drop"
  ) %>%
  arrange(
    desc(median_rmse)
  ) %>%
  mutate(
    difficulty_rank =
      row_number()
  )

print(
  year_difficulty_summary,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 3. Identify difficult validation years
# ------------------------------------------------------------

difficult_years <-
  year_difficulty_summary %>%
  slice_head(
    n = 3
  )

print(
  difficult_years,
  n = Inf,
  width = Inf
)

difficult_year_values <-
  difficult_years$
  validation_year

difficult_year_values

stopifnot(
  length(
    difficult_year_values
  ) == 3
)

# ------------------------------------------------------------
# 4. Summarize observed yield conditions by validation year
# ------------------------------------------------------------

validation_yield_summary <-
  modeling_development %>%
  filter(
    year %in% 2012:2021
  ) %>%
  mutate(
    yield_change =
      corn_yield -
      lag1_yield,
    
    absolute_yield_change =
      abs(
        yield_change
      )
  ) %>%
  group_by(
    year
  ) %>%
  summarise(
    observations =
      n(),
    
    mean_yield =
      mean(
        corn_yield
      ),
    
    median_yield =
      median(
        corn_yield
      ),
    
    sd_yield =
      sd(
        corn_yield
      ),
    
    minimum_yield =
      min(
        corn_yield
      ),
    
    maximum_yield =
      max(
        corn_yield
      ),
    
    mean_yield_change =
      mean(
        yield_change
      ),
    
    median_yield_change =
      median(
        yield_change
      ),
    
    mean_absolute_yield_change =
      mean(
        absolute_yield_change
      ),
    
    .groups =
      "drop"
  ) %>%
  rename(
    validation_year =
      year
  )

print(
  validation_yield_summary,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 5. Combine prediction difficulty with yield conditions
# ------------------------------------------------------------

year_difficulty_with_yield <-
  year_difficulty_summary %>%
  left_join(
    validation_yield_summary,
    by =
      "validation_year"
  ) %>%
  mutate(
    difficult_year =
      validation_year %in%
      difficult_year_values
  )

print(
  year_difficulty_with_yield,
  n = Inf,
  width = Inf
)

difficult_year_yield_summary <-
  year_difficulty_with_yield %>%
  filter(
    difficult_year
  ) %>%
  arrange(
    difficulty_rank
  )

print(
  difficult_year_yield_summary,
  n = Inf,
  width = Inf
)

stopifnot(
  nrow(
    year_difficulty_with_yield
  ) == 10
)

stopifnot(
  sum(
    year_difficulty_with_yield$
      difficult_year
  ) == 3
)

stopifnot(
  !any(
    is.na(
      difficult_year_yield_summary$
        mean_yield
    )
  )
)

# ------------------------------------------------------------
# 6. Examine model performance in difficult years
# ------------------------------------------------------------

difficult_year_model_performance <-
  model_family_comparison %>%
  filter(
    validation_year %in%
      difficult_year_values
  ) %>%
  group_by(
    validation_year
  ) %>%
  mutate(
    overall_rmse_rank =
      min_rank(rmse)
  ) %>%
  ungroup() %>%
  arrange(
    validation_year,
    overall_rmse_rank
  )

print(
  difficult_year_model_performance,
  n = Inf,
  width = Inf
)


# Identify the best-performing specification
# within each difficult year
difficult_year_best_models <-
  difficult_year_model_performance %>%
  group_by(
    validation_year
  ) %>%
  slice_min(
    order_by = rmse,
    n = 1,
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  select(
    validation_year,
    algorithm,
    predictor_group,
    n,
    rmse,
    mae,
    r_squared
  )

print(
  difficult_year_best_models,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 7. Measure predictor-group improvement in difficult years
# ------------------------------------------------------------

difficult_year_group_comparison <-
  difficult_year_model_performance %>%
  mutate(
    group_code = case_when(
      predictor_group ==
        "Group 1" ~ "G1",
      
      predictor_group ==
        "Group 2" ~ "G2",
      
      predictor_group ==
        "Group 3" ~ "G3",
      
      TRUE ~ NA_character_
    )
  ) %>%
  select(
    validation_year,
    algorithm,
    group_code,
    rmse,
    mae
  ) %>%
  pivot_wider(
    names_from =
      group_code,
    
    values_from =
      c(
        rmse,
        mae
      ),
    
    names_glue =
      "{.value}_{group_code}"
  ) %>%
  mutate(
    # Positive values indicate lower error
    # after conventional weather is added
    rmse_change_G1_to_G2 =
      rmse_G1 -
      rmse_G2,
    
    rmse_pct_change_G1_to_G2 =
      100 *
      (
        rmse_G1 -
          rmse_G2
      ) /
      rmse_G1,
    
    # Positive values indicate lower error
    # after retained extremes are added
    rmse_change_G2_to_G3 =
      rmse_G2 -
      rmse_G3,
    
    rmse_pct_change_G2_to_G3 =
      100 *
      (
        rmse_G2 -
          rmse_G3
      ) /
      rmse_G2,
    
    rmse_change_G1_to_G3 =
      rmse_G1 -
      rmse_G3,
    
    rmse_pct_change_G1_to_G3 =
      100 *
      (
        rmse_G1 -
          rmse_G3
      ) /
      rmse_G1,
    
    mae_change_G1_to_G2 =
      mae_G1 -
      mae_G2,
    
    mae_pct_change_G1_to_G2 =
      100 *
      (
        mae_G1 -
          mae_G2
      ) /
      mae_G1,
    
    mae_change_G2_to_G3 =
      mae_G2 -
      mae_G3,
    
    mae_pct_change_G2_to_G3 =
      100 *
      (
        mae_G2 -
          mae_G3
      ) /
      mae_G2,
    
    mae_change_G1_to_G3 =
      mae_G1 -
      mae_G3,
    
    mae_pct_change_G1_to_G3 =
      100 *
      (
        mae_G1 -
          mae_G3
      ) /
      mae_G1
  ) %>%
  arrange(
    validation_year,
    algorithm
  )

print(
  difficult_year_group_comparison,
  n = Inf,
  width = Inf
)

stopifnot(
  nrow(
    difficult_year_model_performance
  ) == 27
)

stopifnot(
  nrow(
    difficult_year_group_comparison
  ) == 9
)

# ------------------------------------------------------------
# 8. Summarize weather conditions by validation year
# ------------------------------------------------------------

validation_weather_summary <-
  modeling_development %>%
  filter(
    year %in% 2012:2021
  ) %>%
  group_by(
    year
  ) %>%
  summarise(
    observations =
      n(),
    
    w01_early_tavg =
      mean(
        w01_early_tavg
      ),
    
    w02_early_prcp =
      mean(
        w02_early_prcp
      ),
    
    w03_repro_tavg =
      mean(
        w03_repro_tavg
      ),
    
    w04_repro_prcp =
      mean(
        w04_repro_prcp
      ),
    
    w05_grainfill_tavg =
      mean(
        w05_grainfill_tavg
      ),
    
    w06_grainfill_prcp =
      mean(
        w06_grainfill_prcp
      ),
    
    e02_heat_above_35 =
      mean(
        e02_heat_above_35
      ),
    
    e02_pct_nonzero =
      100 *
      mean(
        e02_heat_above_35 > 0
      ),
    
    e03_longest_dry_spell =
      mean(
        e03_longest_dry_spell
      ),
    
    e04_max_5day_prcp =
      mean(
        e04_max_5day_prcp
      ),
    
    .groups =
      "drop"
  ) %>%
  rename(
    validation_year =
      year
  )

print(
  validation_weather_summary,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 9. Compare difficult-year weather with validation-period
#    conditions
# ------------------------------------------------------------

weather_summary_long <-
  validation_weather_summary %>%
  pivot_longer(
    cols = -c(
      validation_year,
      observations
    ),
    
    names_to =
      "weather_feature",
    
    values_to =
      "year_value"
  )


weather_validation_reference <-
  weather_summary_long %>%
  group_by(
    weather_feature
  ) %>%
  summarise(
    validation_period_mean =
      mean(
        year_value
      ),
    
    validation_period_sd =
      sd(
        year_value
      ),
    
    .groups =
      "drop"
  )


difficult_year_weather_comparison <-
  weather_summary_long %>%
  filter(
    validation_year %in%
      difficult_year_values
  ) %>%
  left_join(
    weather_validation_reference,
    by =
      "weather_feature"
  ) %>%
  mutate(
    difference_from_mean =
      year_value -
      validation_period_mean,
    
    standardized_difference =
      difference_from_mean /
      validation_period_sd
  ) %>%
  arrange(
    validation_year,
    weather_feature
  )

print(
  difficult_year_weather_comparison,
  n = Inf,
  width = Inf
)

stopifnot(
  nrow(
    validation_weather_summary
  ) == 10
)

stopifnot(
  nrow(
    difficult_year_weather_comparison
  ) == 30
)

stopifnot(
  !any(
    is.na(
      difficult_year_weather_comparison$
        year_value
    )
  )
)

# ------------------------------------------------------------
# 10. Identify most unusual weather features
# ------------------------------------------------------------

primary_weather_features <- c(
  "w01_early_tavg",
  "w02_early_prcp",
  "w03_repro_tavg",
  "w04_repro_prcp",
  "w05_grainfill_tavg",
  "w06_grainfill_prcp",
  "e02_heat_above_35",
  "e03_longest_dry_spell",
  "e04_max_5day_prcp"
)

top_difficult_year_weather <-
  difficult_year_weather_comparison %>%
  filter(
    weather_feature %in%
      primary_weather_features
  ) %>%
  mutate(
    weather_feature_label = recode(
      weather_feature,
      
      w01_early_tavg =
        "Early-season mean temperature",
      
      w02_early_prcp =
        "Early-season precipitation",
      
      w03_repro_tavg =
        "July reproductive mean temperature",
      
      w04_repro_prcp =
        "July reproductive precipitation",
      
      w05_grainfill_tavg =
        "Grain-fill mean temperature",
      
      w06_grainfill_prcp =
        "Grain-fill precipitation",
      
      e02_heat_above_35 =
        "Heat accumulation above 35 C",
      
      e03_longest_dry_spell =
        "Longest Jul-Aug dry spell",
      
      e04_max_5day_prcp =
        "Maximum May-Jul 5-day precipitation"
    )
  ) %>%
  group_by(
    validation_year
  ) %>%
  slice_max(
    order_by =
      abs(
        standardized_difference
      ),
    
    n = 3,
    with_ties = FALSE
  ) %>%
  arrange(
    validation_year,
    desc(
      abs(
        standardized_difference
      )
    )
  ) %>%
  mutate(
    weather_rank =
      row_number()
  ) %>%
  ungroup()

print(
  top_difficult_year_weather,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 11. Summarize predictor support in difficult years
# ------------------------------------------------------------

difficult_year_predictor_support <-
  difficult_year_group_comparison %>%
  group_by(
    validation_year
  ) %>%
  summarise(
    algorithms_conventional_improved =
      sum(
        rmse_change_G1_to_G2 > 0
      ),
    
    algorithms_extremes_improved =
      sum(
        rmse_change_G2_to_G3 > 0
      ),
    
    median_rmse_pct_change_G1_to_G2 =
      median(
        rmse_pct_change_G1_to_G2
      ),
    
    median_rmse_pct_change_G2_to_G3 =
      median(
        rmse_pct_change_G2_to_G3
      ),
    
    .groups =
      "drop"
  )

print(
  difficult_year_predictor_support,
  n = Inf,
  width = Inf
)

difficult_year_diagnostic_summary <-
  difficult_year_yield_summary %>%
  select(
    validation_year,
    difficulty_rank,
    median_rmse,
    mean_yield,
    sd_yield,
    mean_yield_change,
    mean_absolute_yield_change
  ) %>%
  left_join(
    difficult_year_best_models %>%
      select(
        validation_year,
        best_algorithm =
          algorithm,
        best_predictor_group =
          predictor_group,
        best_rmse =
          rmse
      ),
    
    by =
      "validation_year"
  ) %>%
  left_join(
    difficult_year_predictor_support,
    by =
      "validation_year"
  )

print(
  difficult_year_diagnostic_summary,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 12. Save difficult-year diagnostic outputs
# ------------------------------------------------------------

diagnostic_output_dir <-
  "output/difficult_year_diagnostic"

dir.create(
  diagnostic_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# Save validation-year difficulty ranking
write_csv(
  year_difficulty_summary,
  file.path(
    diagnostic_output_dir,
    "year_difficulty_summary.csv"
  )
)


# Save yield conditions for all validation years
write_csv(
  validation_yield_summary,
  file.path(
    diagnostic_output_dir,
    "validation_yield_summary.csv"
  )
)


# Save focused difficult-year yield summary
write_csv(
  difficult_year_yield_summary,
  file.path(
    diagnostic_output_dir,
    "difficult_year_yield_summary.csv"
  )
)


# Save model performance for difficult years
write_csv(
  difficult_year_model_performance,
  file.path(
    diagnostic_output_dir,
    "difficult_year_model_performance.csv"
  )
)


# Save best model in each difficult year
write_csv(
  difficult_year_best_models,
  file.path(
    diagnostic_output_dir,
    "difficult_year_best_models.csv"
  )
)


# Save predictor-group comparisons
write_csv(
  difficult_year_group_comparison,
  file.path(
    diagnostic_output_dir,
    "difficult_year_group_comparison.csv"
  )
)


# Save validation-year weather summaries
write_csv(
  validation_weather_summary,
  file.path(
    diagnostic_output_dir,
    "validation_weather_summary.csv"
  )
)


# Save difficult-year standardized weather comparisons
write_csv(
  difficult_year_weather_comparison,
  file.path(
    diagnostic_output_dir,
    "difficult_year_weather_comparison.csv"
  )
)


# Save top three unusual weather features per difficult year
write_csv(
  top_difficult_year_weather,
  file.path(
    diagnostic_output_dir,
    "top_difficult_year_weather.csv"
  )
)


# Save predictor-support summary
write_csv(
  difficult_year_predictor_support,
  file.path(
    diagnostic_output_dir,
    "difficult_year_predictor_support.csv"
  )
)


# Save compact final diagnostic summary
write_csv(
  difficult_year_diagnostic_summary,
  file.path(
    diagnostic_output_dir,
    "difficult_year_diagnostic_summary.csv"
  )
)


# ------------------------------------------------------------
# Final safeguards
# ------------------------------------------------------------

stopifnot(
  nrow(
    difficult_year_diagnostic_summary
  ) == 3
)

stopifnot(
  nrow(
    top_difficult_year_weather
  ) == 9
)

stopifnot(
  all(
    difficult_year_diagnostic_summary$
      validation_year ==
      c(
        2012,
        2013,
        2015
      )
  )
)

stopifnot(
  max(
    modeling_development$year
  ) <= 2021
)


message(
  "Script 21 complete: difficult-year diagnostics saved successfully."
)

message(
  "The 2022-2025 final holdout was not used."
)