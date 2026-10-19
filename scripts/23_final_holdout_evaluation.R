# ============================================================
# Final Holdout Evaluation
# Senior Thesis
#
# Purpose:
# Evaluate the formally locked development-stage model on the
# previously untouched 2022-2025 final holdout.
#
# The final model specification was selected and locked in
# Script 22 using development-stage information through 2021.
#
# This script:
# 1. Loads the locked development-stage specification
# 2. Loads the full 2001-2021 development dataset
# 3. Loads the untouched 2022-2025 final holdout
# 4. Verifies the model lock and holdout structure
# 5. Fits the locked model using the full development dataset
# 6. Generates final holdout predictions
# 7. Calculates pooled and yearly holdout performance
#
# The final holdout is used for evaluation only.
# No predictor selection, model tuning, or model changes are
# performed after viewing holdout performance.
# ============================================================

library(tidyverse)


# ------------------------------------------------------------
# 1. Load development-stage lock
# ------------------------------------------------------------

development_stage_lock_object <- readRDS(
  "output/development_stage_lock/development_stage_lock_object.rds"
)

development_stage_lock <-
  development_stage_lock_object$lock_record

locked_model_formula <-
  development_stage_lock_object$formula

locked_group_3_predictors <-
  development_stage_lock_object$group_3_predictors


print(
  development_stage_lock,
  n = Inf,
  width = Inf
)

locked_model_formula

locked_group_3_predictors


# ------------------------------------------------------------
# 2. Verify locked model specification
# ------------------------------------------------------------

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
    model_changes_after_diagnostic ==
    FALSE
)

stopifnot(
  development_stage_lock$
    final_holdout_used ==
    FALSE
)

stopifnot(
  development_stage_lock$
    final_holdout_period ==
    "2022-2025"
)

stopifnot(
  length(
    locked_group_3_predictors
  ) == 12
)

stopifnot(
  !"e01_hot_days_30" %in%
    locked_group_3_predictors
)


# ------------------------------------------------------------
# 3. Load development and final holdout datasets
# ------------------------------------------------------------

modeling_development <- readRDS(
  "output/modeling_dataset/modeling_development_2001_2021.rds"
)

modeling_holdout <- readRDS(
  "output/modeling_dataset/modeling_holdout_2022_2025.rds"
)


dim(
  modeling_development
)

range(
  modeling_development$
    year
)

n_distinct(
  modeling_development$
    fips
)


dim(
  modeling_holdout
)

range(
  modeling_holdout$
    year
)

n_distinct(
  modeling_holdout$
    fips
)


# ------------------------------------------------------------
# 4. Final pre-fit holdout audit
# ------------------------------------------------------------

required_model_columns <- c(
  "corn_yield",
  "year",
  locked_group_3_predictors
)


# ------------------------------------------------------------
# Verify all required model columns are present
# ------------------------------------------------------------

missing_development_columns <-
  setdiff(
    required_model_columns,
    names(
      modeling_development
    )
  )


missing_holdout_columns <-
  setdiff(
    required_model_columns,
    names(
      modeling_holdout
    )
  )


print(
  missing_development_columns
)

print(
  missing_holdout_columns
)


stopifnot(
  length(
    missing_development_columns
  ) == 0
)

stopifnot(
  length(
    missing_holdout_columns
  ) == 0
)


# ------------------------------------------------------------
# Verify temporal separation
# ------------------------------------------------------------

stopifnot(
  max(
    modeling_development$
      year
  ) <= 2021
)

stopifnot(
  min(
    modeling_holdout$
      year
  ) >= 2022
)

stopifnot(
  max(
    modeling_holdout$
      year
  ) <= 2025
)


# ------------------------------------------------------------
# Verify unique county-year observations
# ------------------------------------------------------------

duplicate_development_rows <-
  modeling_development %>%
  count(
    fips,
    year
  ) %>%
  filter(
    n > 1
  )


duplicate_holdout_rows <-
  modeling_holdout %>%
  count(
    fips,
    year
  ) %>%
  filter(
    n > 1
  )


print(
  duplicate_development_rows,
  n = Inf,
  width = Inf
)

print(
  duplicate_holdout_rows,
  n = Inf,
  width = Inf
)


stopifnot(
  nrow(
    duplicate_development_rows
  ) == 0
)

stopifnot(
  nrow(
    duplicate_holdout_rows
  ) == 0
)


# ------------------------------------------------------------
# Verify required-column missingness
# ------------------------------------------------------------

development_missingness <-
  modeling_development %>%
  select(
    all_of(
      required_model_columns
    )
  ) %>%
  summarise(
    across(
      everything(),
      ~ sum(
        is.na(.x)
      )
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to =
      "variable",
    values_to =
      "missing_values"
  )


holdout_missingness <-
  modeling_holdout %>%
  select(
    all_of(
      required_model_columns
    )
  ) %>%
  summarise(
    across(
      everything(),
      ~ sum(
        is.na(.x)
      )
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to =
      "variable",
    values_to =
      "missing_values"
  )


print(
  development_missingness,
  n = Inf,
  width = Inf
)

print(
  holdout_missingness,
  n = Inf,
  width = Inf
)


stopifnot(
  all(
    development_missingness$
      missing_values == 0
  )
)

stopifnot(
  all(
    holdout_missingness$
      missing_values == 0
  )
)


# ------------------------------------------------------------
# Verify all holdout counties were observed in development
# ------------------------------------------------------------

unseen_holdout_counties <-
  setdiff(
    unique(
      modeling_holdout$
        fips
    ),
    unique(
      modeling_development$
        fips
    )
  )


print(
  unseen_holdout_counties
)


stopifnot(
  length(
    unseen_holdout_counties
  ) == 0
)


# ------------------------------------------------------------
# Summarize final holdout structure
# ------------------------------------------------------------

holdout_structure <-
  modeling_holdout %>%
  group_by(
    year
  ) %>%
  summarise(
    observations =
      n(),
    
    counties =
      n_distinct(
        fips
      ),
    
    .groups = "drop"
  )


print(
  holdout_structure,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 5. Fit locked final model
# ------------------------------------------------------------

final_model_fit <- lm(
  locked_model_formula,
  data = modeling_development
)


summary(
  final_model_fit
)


final_model_coefficients <-
  coef(
    final_model_fit
  )


final_model_fit_audit <-
  tibble(
    development_observations =
      nrow(
        modeling_development
      ),
    
    development_counties =
      n_distinct(
        modeling_development$
          fips
      ),
    
    model_rank =
      final_model_fit$
      rank,
    
    coefficient_count =
      length(
        final_model_coefficients
      ),
    
    aliased_coefficients =
      sum(
        is.na(
          final_model_coefficients
        )
      ),
    
    residual_degrees_freedom =
      df.residual(
        final_model_fit
      )
  )


print(
  final_model_fit_audit,
  n = Inf,
  width = Inf
)


stopifnot(
  final_model_fit_audit$
    development_observations ==
    1691
)

stopifnot(
  final_model_fit_audit$
    development_counties ==
    91
)

stopifnot(
  final_model_fit_audit$
    aliased_coefficients ==
    0
)

stopifnot(
  nobs(
    final_model_fit
  ) ==
    nrow(
      modeling_development
    )
)


formula(
  final_model_fit
)


# ------------------------------------------------------------
# 6. Generate final holdout predictions
# ------------------------------------------------------------

final_holdout_predicted_yield <-
  predict(
    final_model_fit,
    newdata = modeling_holdout
  )


# ------------------------------------------------------------
# Verify prediction output
# ------------------------------------------------------------

length(
  final_holdout_predicted_yield
)

sum(
  is.na(
    final_holdout_predicted_yield
  )
)

sum(
  is.infinite(
    final_holdout_predicted_yield
  )
)


stopifnot(
  length(
    final_holdout_predicted_yield
  ) ==
    nrow(
      modeling_holdout
    )
)

stopifnot(
  sum(
    is.na(
      final_holdout_predicted_yield
    )
  ) == 0
)

stopifnot(
  sum(
    is.infinite(
      final_holdout_predicted_yield
    )
  ) == 0
)


# ------------------------------------------------------------
# Create final holdout prediction dataset
# ------------------------------------------------------------

final_holdout_predictions <-
  modeling_holdout %>%
  transmute(
    year = year,
    fips = fips,
    county = county,
    actual_yield = corn_yield,
    
    predicted_yield =
      as.numeric(
        final_holdout_predicted_yield
      ),
    
    residual =
      actual_yield -
      predicted_yield,
    
    absolute_error =
      abs(
        residual
      ),
    
    squared_error =
      residual^2
  )


dim(
  final_holdout_predictions
)

glimpse(
  final_holdout_predictions
)


print(
  final_holdout_predictions,
  n = 10,
  width = Inf
)


# ------------------------------------------------------------
# Final prediction safeguards
# ------------------------------------------------------------

stopifnot(
  nrow(
    final_holdout_predictions
  ) == 247
)

stopifnot(
  !any(
    is.na(
      final_holdout_predictions$
        predicted_yield
    )
  )
)

stopifnot(
  !any(
    is.infinite(
      final_holdout_predictions$
        predicted_yield
    )
  )
)

stopifnot(
  all(
    final_holdout_predictions$
      year %in%
      2022:2025
  )
)


# ------------------------------------------------------------
# Verify prediction counts by holdout year
# ------------------------------------------------------------

final_prediction_counts <-
  final_holdout_predictions %>%
  count(
    year,
    name =
      "predictions"
  )


print(
  final_prediction_counts,
  n = Inf,
  width = Inf
)


stopifnot(
  identical(
    final_prediction_counts$
      predictions,
    holdout_structure$
      observations
  )
)


# ------------------------------------------------------------
# 7. Calculate final holdout performance
# ------------------------------------------------------------

# Calculate pooled performance across all 2022-2025
# holdout observations
final_holdout_pooled_metrics <-
  final_holdout_predictions %>%
  summarise(
    observations = n(),
    
    rmse =
      sqrt(
        mean(
          squared_error
        )
      ),
    
    mae =
      mean(
        absolute_error
      ),
    
    r_squared =
      1 -
      sum(
        squared_error
      ) /
      sum(
        (
          actual_yield -
            mean(
              actual_yield
            )
        )^2
      )
  )


print(
  final_holdout_pooled_metrics,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Calculate performance separately by holdout year
# ------------------------------------------------------------

final_holdout_metrics_by_year <-
  final_holdout_predictions %>%
  group_by(
    year
  ) %>%
  summarise(
    observations = n(),
    
    rmse =
      sqrt(
        mean(
          squared_error
        )
      ),
    
    mae =
      mean(
        absolute_error
      ),
    
    r_squared =
      1 -
      sum(
        squared_error
      ) /
      sum(
        (
          actual_yield -
            mean(
              actual_yield
            )
        )^2
      ),
    
    mean_actual_yield =
      mean(
        actual_yield
      ),
    
    mean_predicted_yield =
      mean(
        predicted_yield
      ),
    
    mean_residual =
      mean(
        residual
      ),
    
    .groups = "drop"
  )


print(
  final_holdout_metrics_by_year,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Basic metric safeguards
# ------------------------------------------------------------

stopifnot(
  final_holdout_pooled_metrics$
    observations ==
    247
)

stopifnot(
  nrow(
    final_holdout_metrics_by_year
  ) == 4
)

stopifnot(
  all(
    final_holdout_metrics_by_year$
      year ==
      2022:2025
  )
)

stopifnot(
  sum(
    final_holdout_metrics_by_year$
      observations
  ) == 247
)


# ------------------------------------------------------------
# 8. Compare development validation and final holdout
# ------------------------------------------------------------

# Retrieve the locked development-stage performance values
development_validation_metrics <-
  tibble(
    evaluation_stage =
      "Development validation",
    
    period =
      "2012-2021",
    
    rmse =
      development_stage_lock$
      pooled_rmse,
    
    mae =
      development_stage_lock$
      pooled_mae,
    
    r_squared =
      development_stage_lock$
      pooled_r_squared
  )


# Create corresponding final holdout summary
holdout_evaluation_metrics <-
  tibble(
    evaluation_stage =
      "Final holdout",
    
    period =
      "2022-2025",
    
    rmse =
      final_holdout_pooled_metrics$
      rmse,
    
    mae =
      final_holdout_pooled_metrics$
      mae,
    
    r_squared =
      final_holdout_pooled_metrics$
      r_squared
  )


development_holdout_comparison <-
  bind_rows(
    development_validation_metrics,
    holdout_evaluation_metrics
  )


print(
  development_holdout_comparison,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Quantify differences between evaluation stages
# ------------------------------------------------------------

performance_difference <-
  tibble(
    metric =
      c(
        "RMSE",
        "MAE",
        "R-squared"
      ),
    
    development_value =
      c(
        development_stage_lock$
          pooled_rmse,
        
        development_stage_lock$
          pooled_mae,
        
        development_stage_lock$
          pooled_r_squared
      ),
    
    holdout_value =
      c(
        final_holdout_pooled_metrics$
          rmse,
        
        final_holdout_pooled_metrics$
          mae,
        
        final_holdout_pooled_metrics$
          r_squared
      )
  ) %>%
  mutate(
    absolute_difference =
      holdout_value -
      development_value,
    
    percent_difference =
      100 *
      (
        holdout_value -
          development_value
      ) /
      development_value
  )


print(
  performance_difference,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Summarize overall holdout prediction bias
# ------------------------------------------------------------

final_holdout_bias_summary <-
  final_holdout_predictions %>%
  summarise(
    observations = n(),
    
    mean_actual_yield =
      mean(
        actual_yield
      ),
    
    mean_predicted_yield =
      mean(
        predicted_yield
      ),
    
    mean_residual =
      mean(
        residual
      ),
    
    median_residual =
      median(
        residual
      ),
    
    sd_actual_yield =
      sd(
        actual_yield
      ),
    
    sd_predicted_yield =
      sd(
        predicted_yield
      )
  )


print(
  final_holdout_bias_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 9. Create final holdout diagnostic figures
# ------------------------------------------------------------

final_output_dir <-
  "output/final_holdout_evaluation"

dir.create(
  final_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------
# Observed vs. predicted yield
# ------------------------------------------------------------

observed_predicted_plot <-
  final_holdout_predictions %>%
  ggplot(
    aes(
      x = actual_yield,
      y = predicted_yield
    )
  ) +
  geom_point(
    alpha = 0.7
  ) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  facet_wrap(
    ~ year
  ) +
  labs(
    title = "Observed vs. Predicted Corn Yield",
    subtitle = "Final 2022-2025 holdout evaluation",
    x = "Observed Yield (bushels per acre)",
    y = "Predicted Yield (bushels per acre)"
  ) +
  theme_minimal()


observed_predicted_plot


# ------------------------------------------------------------
# Residual distribution by holdout year
# ------------------------------------------------------------

residual_by_year_plot <-
  final_holdout_predictions %>%
  mutate(
    year =
      factor(
        year
      )
  ) %>%
  ggplot(
    aes(
      x = year,
      y = residual
    )
  ) +
  geom_boxplot() +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "Final Holdout Residuals by Year",
    subtitle = "Positive residuals indicate underprediction",
    x = "Holdout Year",
    y = "Residual (Observed - Predicted)"
  ) +
  theme_minimal()


residual_by_year_plot


# ------------------------------------------------------------
# Save final holdout figures
# ------------------------------------------------------------

ggsave(
  file.path(
    final_output_dir,
    "holdout_observed_vs_predicted.png"
  ),
  plot = observed_predicted_plot,
  width = 9,
  height = 6,
  dpi = 300
)


ggsave(
  file.path(
    final_output_dir,
    "holdout_residuals_by_year.png"
  ),
  plot = residual_by_year_plot,
  width = 9,
  height = 6,
  dpi = 300
)


# ------------------------------------------------------------
# Verify saved figures
# ------------------------------------------------------------

expected_figure_files <- c(
  "holdout_observed_vs_predicted.png",
  "holdout_residuals_by_year.png"
)


saved_figure_files <-
  list.files(
    final_output_dir
  )


print(
  saved_figure_files
)


missing_figure_files <-
  setdiff(
    expected_figure_files,
    saved_figure_files
  )


print(
  missing_figure_files
)


stopifnot(
  length(
    missing_figure_files
  ) == 0
)


# ------------------------------------------------------------
# 10. Document and save final holdout evaluation
# ------------------------------------------------------------

# Create a concise final evaluation record
final_holdout_evaluation_result <-
  tibble(
    analysis =
      "Final holdout evaluation",
    
    model_algorithm =
      development_stage_lock$
      selected_algorithm,
    
    predictor_group =
      development_stage_lock$
      selected_predictor_group,
    
    development_period =
      "2001-2021",
    
    development_observations =
      nrow(
        modeling_development
      ),
    
    development_counties =
      n_distinct(
        modeling_development$
          fips
      ),
    
    final_holdout_period =
      "2022-2025",
    
    holdout_observations =
      nrow(
        modeling_holdout
      ),
    
    holdout_counties =
      n_distinct(
        modeling_holdout$
          fips
      ),
    
    pooled_rmse =
      final_holdout_pooled_metrics$
      rmse,
    
    pooled_mae =
      final_holdout_pooled_metrics$
      mae,
    
    pooled_r_squared =
      final_holdout_pooled_metrics$
      r_squared,
    
    mean_residual =
      final_holdout_bias_summary$
      mean_residual,
    
    development_validation_rmse =
      development_stage_lock$
      pooled_rmse,
    
    development_validation_mae =
      development_stage_lock$
      pooled_mae,
    
    development_validation_r_squared =
      development_stage_lock$
      pooled_r_squared,
    
    model_changed_after_holdout =
      FALSE,
    
    final_holdout_evaluation_complete =
      TRUE
  )


print(
  final_holdout_evaluation_result,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Save prediction-level and performance outputs
# ------------------------------------------------------------

write_csv(
  final_holdout_predictions,
  file.path(
    final_output_dir,
    "final_holdout_predictions.csv"
  )
)


write_csv(
  final_holdout_pooled_metrics,
  file.path(
    final_output_dir,
    "final_holdout_pooled_metrics.csv"
  )
)


write_csv(
  final_holdout_metrics_by_year,
  file.path(
    final_output_dir,
    "final_holdout_metrics_by_year.csv"
  )
)


write_csv(
  development_holdout_comparison,
  file.path(
    final_output_dir,
    "development_holdout_comparison.csv"
  )
)


write_csv(
  performance_difference,
  file.path(
    final_output_dir,
    "development_holdout_metric_differences.csv"
  )
)


write_csv(
  final_holdout_bias_summary,
  file.path(
    final_output_dir,
    "final_holdout_bias_summary.csv"
  )
)


write_csv(
  final_model_fit_audit,
  file.path(
    final_output_dir,
    "final_model_fit_audit.csv"
  )
)


write_csv(
  final_holdout_evaluation_result,
  file.path(
    final_output_dir,
    "final_holdout_evaluation_result.csv"
  )
)


# ------------------------------------------------------------
# Save final fitted model
# ------------------------------------------------------------

saveRDS(
  final_model_fit,
  file.path(
    final_output_dir,
    "final_locked_model_fit.rds"
  )
)


# ------------------------------------------------------------
# Verify final output package
# ------------------------------------------------------------

expected_final_files <- c(
  "development_holdout_comparison.csv",
  "development_holdout_metric_differences.csv",
  "final_holdout_bias_summary.csv",
  "final_holdout_evaluation_result.csv",
  "final_holdout_metrics_by_year.csv",
  "final_holdout_pooled_metrics.csv",
  "final_holdout_predictions.csv",
  "final_locked_model_fit.rds",
  "final_model_fit_audit.csv",
  "holdout_observed_vs_predicted.png",
  "holdout_residuals_by_year.png"
)


saved_final_files <-
  list.files(
    final_output_dir
  )


print(
  saved_final_files
)


missing_final_files <-
  setdiff(
    expected_final_files,
    saved_final_files
  )


print(
  missing_final_files
)


stopifnot(
  length(
    missing_final_files
  ) == 0
)


# ------------------------------------------------------------
# Final Script 23 safeguards
# ------------------------------------------------------------

stopifnot(
  final_holdout_evaluation_result$
    model_algorithm ==
    "Linear Regression"
)

stopifnot(
  final_holdout_evaluation_result$
    predictor_group ==
    "Group 3"
)

stopifnot(
  final_holdout_evaluation_result$
    holdout_observations ==
    247
)

stopifnot(
  final_holdout_evaluation_result$
    model_changed_after_holdout ==
    FALSE
)

stopifnot(
  final_holdout_evaluation_result$
    final_holdout_evaluation_complete ==
    TRUE
)


# ------------------------------------------------------------
# Script completion checkpoint
# ------------------------------------------------------------

cat(
  "\n",
  "Script 23 complete.\n",
  "Final holdout evaluation: 2022-2025\n",
  "Locked model: Linear Regression, Group 3\n",
  "Holdout observations:", nrow(modeling_holdout), "\n",
  "Pooled RMSE:",
  round(final_holdout_pooled_metrics$rmse, 2), "\n",
  "Pooled MAE:",
  round(final_holdout_pooled_metrics$mae, 2), "\n",
  "Pooled R-squared:",
  round(final_holdout_pooled_metrics$r_squared, 3), "\n",
  "Model changes after holdout: FALSE\n"
)