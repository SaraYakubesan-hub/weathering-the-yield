# ============================================================
# Development-Stage Model Lock
# Senior Thesis
#
# Purpose:
# Formally lock the final model specification selected from
# development-stage model comparison before evaluating the
# untouched 2022-2025 final holdout.
#
# This script:
# - verifies completed development-stage model results
# - confirms the development comparison is complete
# - documents the final selected algorithm and predictor group
# - preserves the development-stage decision before holdout
#   evaluation
#
# No new models are fitted in this script.
# No predictor definitions are changed.
# No additional model tuning is performed.
#
# Only completed development-stage results through 2021 are
# used. The 2022-2025 final holdout is not loaded or used.
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

difficult_year_diagnostic_summary <- read_csv(
  "output/difficult_year_diagnostic/difficult_year_diagnostic_summary.csv",
  show_col_types = FALSE
)


dim(
  model_family_comparison
)

dim(
  modeling_development
)

dim(
  difficult_year_diagnostic_summary
)


range(
  model_family_comparison$
    validation_year
)

range(
  modeling_development$
    year
)

difficult_year_diagnostic_summary %>%
  select(
    validation_year,
    difficulty_rank,
    median_rmse,
    best_algorithm,
    best_predictor_group,
    best_rmse
  ) %>%
  print(
    n = Inf,
    width = Inf
  )


# ------------------------------------------------------------
# Holdout safeguards
# ------------------------------------------------------------

stopifnot(
  max(
    model_family_comparison$
      validation_year
  ) <= 2021
)

stopifnot(
  max(
    modeling_development$
      year
  ) <= 2021
)

stopifnot(
  max(
    difficult_year_diagnostic_summary$
      validation_year
  ) <= 2021
)

# ------------------------------------------------------------
# 2. Verify development-stage comparison structure
# ------------------------------------------------------------

comparison_structure <-
  model_family_comparison %>%
  count(
    algorithm,
    predictor_group,
    name =
      "validation_years"
  ) %>%
  arrange(
    algorithm,
    predictor_group
  )

print(
  comparison_structure,
  n = Inf,
  width = Inf
)


validation_year_structure <-
  model_family_comparison %>%
  count(
    validation_year,
    name =
      "model_specifications"
  ) %>%
  arrange(
    validation_year
  )

print(
  validation_year_structure,
  n = Inf,
  width = Inf
)


algorithm_values <-
  model_family_comparison %>%
  distinct(
    algorithm
  ) %>%
  arrange(
    algorithm
  )

print(
  algorithm_values,
  n = Inf,
  width = Inf
)


predictor_group_values <-
  model_family_comparison %>%
  distinct(
    predictor_group
  ) %>%
  arrange(
    predictor_group
  )

print(
  predictor_group_values,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Development-comparison safeguards
# ------------------------------------------------------------

stopifnot(
  nrow(
    model_family_comparison
  ) == 90
)

stopifnot(
  n_distinct(
    model_family_comparison$
      validation_year
  ) == 10
)

stopifnot(
  all(
    validation_year_structure$
      model_specifications == 9
  )
)

stopifnot(
  n_distinct(
    model_family_comparison$
      algorithm
  ) == 3
)

stopifnot(
  n_distinct(
    model_family_comparison$
      predictor_group
  ) == 3
)

stopifnot(
  all(
    comparison_structure$
      validation_years == 10
  )
)

# ------------------------------------------------------------
# 3. Load final development-stage comparison evidence
# ------------------------------------------------------------

model_family_pooled_ranked <- read_csv(
  "output/model_family_comparison/model_family_pooled_ranked.csv",
  show_col_types = FALSE
)

model_family_result <- read_csv(
  "output/model_family_comparison/model_family_result.csv",
  show_col_types = FALSE
)

model_family_sensitivity_overall <- read_csv(
  "output/model_family_comparison/model_family_sensitivity_overall.csv",
  show_col_types = FALSE
)


dim(
  model_family_pooled_ranked
)

dim(
  model_family_result
)

dim(
  model_family_sensitivity_overall
)


names(
  model_family_pooled_ranked
)

names(
  model_family_result
)

names(
  model_family_sensitivity_overall
)


print(
  model_family_pooled_ranked,
  n = Inf,
  width = Inf
)

print(
  model_family_result,
  n = Inf,
  width = Inf
)

print(
  model_family_sensitivity_overall,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 4. Verify final development-stage selection
# ------------------------------------------------------------

overall_development_ranking <-
  model_family_pooled_ranked %>%
  mutate(
    overall_rmse_rank =
      min_rank(
        pooled_rmse
      ),
    
    overall_mae_rank =
      min_rank(
        pooled_mae
      ),
    
    overall_r_squared_rank =
      min_rank(
        desc(
          pooled_r_squared
        )
      )
  ) %>%
  arrange(
    overall_rmse_rank,
    overall_mae_rank
  )

print(
  overall_development_ranking,
  n = Inf,
  width = Inf
)


# Identify the specification with the lowest
# pooled development-stage RMSE
development_rmse_winner <-
  overall_development_ranking %>%
  slice_min(
    order_by =
      pooled_rmse,
    
    n = 1,
    with_ties = FALSE
  )

print(
  development_rmse_winner,
  n = Inf,
  width = Inf
)


# Retrieve the final selection saved by Script 20
saved_development_selection <-
  model_family_result %>%
  select(
    best_development_algorithm,
    best_development_predictor_group,
    best_pooled_rmse,
    best_pooled_mae,
    best_pooled_r_squared,
    years_best_overall,
    sensitivity_mean_rmse_excluding_2012,
    sensitivity_mean_mae_excluding_2012
  )

print(
  saved_development_selection,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Check numeric precision of saved comparison values
# ------------------------------------------------------------

print(
  development_rmse_winner$
    pooled_rmse,
  digits = 17
)

print(
  model_family_result$
    best_pooled_rmse,
  digits = 17
)

print(
  development_rmse_winner$
    pooled_mae,
  digits = 17
)

print(
  model_family_result$
    best_pooled_mae,
  digits = 17
)

print(
  development_rmse_winner$
    pooled_r_squared,
  digits = 17
)

print(
  model_family_result$
    best_pooled_r_squared,
  digits = 17
)


numeric_selection_difference <-
  tibble(
    metric =
      c(
        "RMSE",
        "MAE",
        "R-squared"
      ),
    
    pooled_value =
      c(
        development_rmse_winner$
          pooled_rmse,
        
        development_rmse_winner$
          pooled_mae,
        
        development_rmse_winner$
          pooled_r_squared
      ),
    
    saved_result_value =
      c(
        model_family_result$
          best_pooled_rmse,
        
        model_family_result$
          best_pooled_mae,
        
        model_family_result$
          best_pooled_r_squared
      )
  ) %>%
  mutate(
    difference =
      pooled_value -
      saved_result_value
  )

print(
  numeric_selection_difference,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Verify that the saved Script 20 decision agrees with
# the pooled development-stage results
# ------------------------------------------------------------

stopifnot(
  development_rmse_winner$
    algorithm ==
    model_family_result$
    best_development_algorithm
)

stopifnot(
  development_rmse_winner$
    predictor_group ==
    model_family_result$
    best_development_predictor_group
)


# Verify saved performance values within the precision used
# in the final Script 20 summary
stopifnot(
  near(
    development_rmse_winner$
      pooled_rmse,
    
    model_family_result$
      best_pooled_rmse,
    
    tol = 0.05
  )
)

stopifnot(
  near(
    development_rmse_winner$
      pooled_mae,
    
    model_family_result$
      best_pooled_mae,
    
    tol = 0.05
  )
)

stopifnot(
  near(
    development_rmse_winner$
      pooled_r_squared,
    
    model_family_result$
      best_pooled_r_squared,
    
    tol = 0.0005
  )
)


# The selected specification should rank first
# on all three pooled performance measures
stopifnot(
  development_rmse_winner$
    overall_rmse_rank == 1
)

stopifnot(
  development_rmse_winner$
    overall_mae_rank == 1
)

stopifnot(
  development_rmse_winner$
    overall_r_squared_rank == 1
)

# ------------------------------------------------------------
# 5. Define and lock final development-stage specification
# ------------------------------------------------------------

historical_predictors <- c(
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

retained_extreme_weather_predictors <- c(
  "e02_heat_above_35",
  "e03_longest_dry_spell",
  "e04_max_5day_prcp"
)

group_3_predictors <- c(
  historical_predictors,
  conventional_weather_predictors,
  retained_extreme_weather_predictors
)


# County identity remains a factor in the final
# Linear Regression specification.
locked_model_formula <-
  corn_yield ~
  factor(fips) +
  year_centered +
  lag1_yield +
  w01_early_tavg +
  w02_early_prcp +
  w03_repro_tavg +
  w04_repro_prcp +
  w05_grainfill_tavg +
  w06_grainfill_prcp +
  e02_heat_above_35 +
  e03_longest_dry_spell +
  e04_max_5day_prcp


locked_model_formula_text <-
  paste(
    deparse(
      locked_model_formula
    ),
    collapse = " "
  )


print(
  historical_predictors
)

print(
  conventional_weather_predictors
)

print(
  retained_extreme_weather_predictors
)

print(
  group_3_predictors
)

print(
  locked_model_formula
)


# ------------------------------------------------------------
# Verify locked predictor definition
# ------------------------------------------------------------

required_model_columns <- c(
  "corn_yield",
  group_3_predictors
)

missing_model_columns <-
  setdiff(
    required_model_columns,
    names(
      modeling_development
    )
  )

print(
  missing_model_columns
)


stopifnot(
  length(
    missing_model_columns
  ) == 0
)

stopifnot(
  length(
    historical_predictors
  ) == 3
)

stopifnot(
  length(
    conventional_weather_predictors
  ) == 6
)

stopifnot(
  length(
    retained_extreme_weather_predictors
  ) == 3
)

stopifnot(
  length(
    group_3_predictors
  ) == 12
)

stopifnot(
  n_distinct(
    group_3_predictors
  ) == 12
)


# E01 was excluded during development-stage
# extreme-weather screening and must remain excluded.
stopifnot(
  !(
    "e01_hot_days_30" %in%
      group_3_predictors
  )
)

# ------------------------------------------------------------
# Create development-stage lock record
# ------------------------------------------------------------

development_stage_lock <-
  tibble(
    analysis =
      "Development-stage model lock",
    
    lock_status =
      "LOCKED BEFORE FINAL HOLDOUT EVALUATION",
    
    development_period =
      model_family_result$
      development_period,
    
    validation_period =
      model_family_result$
      validation_period,
    
    selected_algorithm =
      model_family_result$
      best_development_algorithm,
    
    selected_predictor_group =
      model_family_result$
      best_development_predictor_group,
    
    outcome =
      "corn_yield",
    
    historical_predictors =
      paste(
        historical_predictors,
        collapse = ", "
      ),
    
    conventional_weather_predictors =
      paste(
        conventional_weather_predictors,
        collapse = ", "
      ),
    
    retained_extreme_weather_predictors =
      paste(
        retained_extreme_weather_predictors,
        collapse = ", "
      ),
    
    excluded_extreme_predictor =
      "e01_hot_days_30",
    
    locked_formula =
      locked_model_formula_text,
    
    primary_selection_metric =
      "Pooled RMSE",
    
    pooled_rmse =
      development_rmse_winner$
      pooled_rmse,
    
    pooled_mae =
      development_rmse_winner$
      pooled_mae,
    
    pooled_r_squared =
      development_rmse_winner$
      pooled_r_squared,
    
    overall_rmse_rank =
      development_rmse_winner$
      overall_rmse_rank,
    
    overall_mae_rank =
      development_rmse_winner$
      overall_mae_rank,
    
    overall_r_squared_rank =
      development_rmse_winner$
      overall_r_squared_rank,
    
    years_best_overall =
      model_family_result$
      years_best_overall,
    
    sensitivity_mean_rmse_excluding_2012 =
      model_family_result$
      sensitivity_mean_rmse_excluding_2012,
    
    sensitivity_mean_mae_excluding_2012 =
      model_family_result$
      sensitivity_mean_mae_excluding_2012,
    
    difficult_year_diagnostic_completed =
      TRUE,
    
    difficult_years =
      paste(
        difficult_year_diagnostic_summary$
          validation_year,
        collapse = ", "
      ),
    
    model_changes_after_diagnostic =
      FALSE,
    
    final_holdout_period =
      "2022-2025",
    
    final_holdout_used =
      FALSE
  )


print(
  development_stage_lock,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# Final lock safeguards
# ------------------------------------------------------------

stopifnot(
  nrow(
    development_stage_lock
  ) == 1
)

stopifnot(
  development_stage_lock$
    selected_algorithm ==
    "Linear Regression"
)

stopifnot(
  development_stage_lock$
    selected_predictor_group ==
    "Group 3"
)

stopifnot(
  development_stage_lock$
    overall_rmse_rank == 1
)

stopifnot(
  development_stage_lock$
    overall_mae_rank == 1
)

stopifnot(
  development_stage_lock$
    overall_r_squared_rank == 1
)

stopifnot(
  development_stage_lock$
    model_changes_after_diagnostic ==
    FALSE
)

stopifnot(
  development_stage_lock$
    final_holdout_used ==
    FALSE
)

stopifnot(
  max(
    modeling_development$
      year
  ) <= 2021
)

# ------------------------------------------------------------
# 6. Save development-stage lock artifacts
# ------------------------------------------------------------

lock_output_dir <-
  "output/development_stage_lock"

dir.create(
  lock_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# Save the formal development-stage lock record
write_csv(
  development_stage_lock,
  file.path(
    lock_output_dir,
    "development_stage_lock.csv"
  )
)


# Save the overall nine-specification development ranking
write_csv(
  overall_development_ranking,
  file.path(
    lock_output_dir,
    "overall_development_ranking.csv"
  )
)


# Save the numeric precision check documenting agreement
# between the detailed pooled results and Script 20 summary
write_csv(
  numeric_selection_difference,
  file.path(
    lock_output_dir,
    "numeric_selection_difference.csv"
  )
)


# Save the exact locked predictor definitions
locked_predictor_definition <-
  tibble(
    predictor_group =
      c(
        rep(
          "Historical",
          length(
            historical_predictors
          )
        ),
        
        rep(
          "Conventional Weather",
          length(
            conventional_weather_predictors
          )
        ),
        
        rep(
          "Retained Extreme Weather",
          length(
            retained_extreme_weather_predictors
          )
        )
      ),
    
    predictor =
      c(
        historical_predictors,
        conventional_weather_predictors,
        retained_extreme_weather_predictors
      )
  )

print(
  locked_predictor_definition,
  n = Inf,
  width = Inf
)

write_csv(
  locked_predictor_definition,
  file.path(
    lock_output_dir,
    "locked_predictor_definition.csv"
  )
)

# ------------------------------------------------------------
# Save machine-readable lock object
# ------------------------------------------------------------

development_stage_lock_object <-
  list(
    lock_record =
      development_stage_lock,
    
    formula =
      locked_model_formula,
    
    historical_predictors =
      historical_predictors,
    
    conventional_weather_predictors =
      conventional_weather_predictors,
    
    retained_extreme_weather_predictors =
      retained_extreme_weather_predictors,
    
    group_3_predictors =
      group_3_predictors,
    
    overall_development_ranking =
      overall_development_ranking
  )


saveRDS(
  development_stage_lock_object,
  file.path(
    lock_output_dir,
    "development_stage_lock_object.rds"
  )
)

# ------------------------------------------------------------
# Verify saved lock artifacts
# ------------------------------------------------------------

expected_lock_files <- c(
  "development_stage_lock.csv",
  "overall_development_ranking.csv",
  "numeric_selection_difference.csv",
  "locked_predictor_definition.csv",
  "development_stage_lock_object.rds"
)


saved_lock_files <-
  list.files(
    lock_output_dir
  )

print(
  saved_lock_files
)


missing_lock_files <-
  setdiff(
    expected_lock_files,
    saved_lock_files
  )

print(
  missing_lock_files
)


stopifnot(
  length(
    missing_lock_files
  ) == 0
)


# Reload the saved lock object to verify that the
# checkpoint can be read successfully
lock_verification <-
  readRDS(
    file.path(
      lock_output_dir,
      "development_stage_lock_object.rds"
    )
  )

names(
  lock_verification
)


stopifnot(
  lock_verification$
    lock_record$
    selected_algorithm ==
    "Linear Regression"
)

stopifnot(
  lock_verification$
    lock_record$
    selected_predictor_group ==
    "Group 3"
)

stopifnot(
  lock_verification$
    lock_record$
    final_holdout_used ==
    FALSE
)

stopifnot(
  identical(
    lock_verification$
      group_3_predictors,
    
    group_3_predictors
  )
)

# ------------------------------------------------------------
# 7. Final pre-holdout checkpoint
# ------------------------------------------------------------

pre_holdout_checkpoint <-
  tibble(
    script =
      "22_development_stage_lock.R",
    
    script_status =
      "COMPLETE",
    
    development_stage_locked =
      TRUE,
    
    selected_algorithm =
      development_stage_lock$
      selected_algorithm,
    
    selected_predictor_group =
      development_stage_lock$
      selected_predictor_group,
    
    development_period =
      development_stage_lock$
      development_period,
    
    validation_period =
      development_stage_lock$
      validation_period,
    
    final_holdout_period =
      development_stage_lock$
      final_holdout_period,
    
    difficult_year_diagnostic_completed =
      development_stage_lock$
      difficult_year_diagnostic_completed,
    
    model_changes_after_diagnostic =
      development_stage_lock$
      model_changes_after_diagnostic,
    
    new_model_fitting_in_script_22 =
      FALSE,
    
    additional_model_tuning_in_script_22 =
      FALSE,
    
    predictor_changes_in_script_22 =
      FALSE,
    
    final_holdout_used =
      development_stage_lock$
      final_holdout_used,
    
    next_stage =
      "Final holdout evaluation"
  )


print(
  pre_holdout_checkpoint,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# Save final pre-holdout checkpoint
# ------------------------------------------------------------

write_csv(
  pre_holdout_checkpoint,
  file.path(
    lock_output_dir,
    "pre_holdout_checkpoint.csv"
  )
)

# ------------------------------------------------------------
# Final Script 22 safeguards
# ------------------------------------------------------------

stopifnot(
  pre_holdout_checkpoint$
    development_stage_locked ==
    TRUE
)

stopifnot(
  pre_holdout_checkpoint$
    selected_algorithm ==
    "Linear Regression"
)

stopifnot(
  pre_holdout_checkpoint$
    selected_predictor_group ==
    "Group 3"
)

stopifnot(
  pre_holdout_checkpoint$
    difficult_year_diagnostic_completed ==
    TRUE
)

stopifnot(
  pre_holdout_checkpoint$
    model_changes_after_diagnostic ==
    FALSE
)

stopifnot(
  pre_holdout_checkpoint$
    new_model_fitting_in_script_22 ==
    FALSE
)

stopifnot(
  pre_holdout_checkpoint$
    additional_model_tuning_in_script_22 ==
    FALSE
)

stopifnot(
  pre_holdout_checkpoint$
    predictor_changes_in_script_22 ==
    FALSE
)

stopifnot(
  pre_holdout_checkpoint$
    final_holdout_used ==
    FALSE
)

stopifnot(
  file.exists(
    file.path(
      lock_output_dir,
      "development_stage_lock.csv"
    )
  )
)

stopifnot(
  file.exists(
    file.path(
      lock_output_dir,
      "development_stage_lock_object.rds"
    )
  )
)

stopifnot(
  file.exists(
    file.path(
      lock_output_dir,
      "pre_holdout_checkpoint.csv"
    )
  )
)


message(
  "Script 22 complete: development-stage model specification is locked."
)

message(
  "Selected model: Linear Regression with Group 3 predictors."
)

message(
  "No model fitting, tuning, or predictor changes were performed in Script 22."
)

message(
  "The 2022-2025 final holdout remains untouched."
)

