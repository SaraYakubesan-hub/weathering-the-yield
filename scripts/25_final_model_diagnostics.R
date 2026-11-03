# ============================================================
# Final Model Diagnostics and Uncertainty
# Senior Thesis
#
# Purpose:
# Perform post-selection diagnostic and uncertainty analyses
# for the formally locked Linear Regression Group 3 model.
#
# The selected model specification is not modified in this
# script. All analyses are descriptive or diagnostic additions
# performed after final model selection and holdout evaluation.
# ============================================================

library(tidyverse)


# ------------------------------------------------------------
# 1. Load the saved locked final model
# ------------------------------------------------------------

final_model_fit <- readRDS(
  "output/final_holdout_evaluation/final_locked_model_fit.rds"
)

# Verify the saved model is a linear model
stopifnot(
  inherits(
    final_model_fit,
    "lm"
  )
)

# Confirm model dimensions
nobs(final_model_fit)
length(coef(final_model_fit))
df.residual(final_model_fit)


# ------------------------------------------------------------
# 2. Extract coefficient estimates and 95% confidence intervals
# ------------------------------------------------------------

coefficient_summary <-
  summary(final_model_fit)$coefficients %>%
  as.data.frame() %>%
  rownames_to_column(
    var = "term"
  ) %>%
  as_tibble() %>%
  rename(
    estimate = Estimate,
    standard_error = `Std. Error`,
    t_value = `t value`,
    p_value = `Pr(>|t|)`
  )


confidence_intervals <-
  confint(
    final_model_fit,
    level = 0.95
  ) %>%
  as.data.frame() %>%
  rownames_to_column(
    var = "term"
  ) %>%
  as_tibble() %>%
  rename(
    conf_low = `2.5 %`,
    conf_high = `97.5 %`
  )


final_model_coefficients <-
  coefficient_summary %>%
  left_join(
    confidence_intervals,
    by = "term"
  )


# Verify expected coefficient count
stopifnot(
  nrow(final_model_coefficients) ==
    length(coef(final_model_fit))
)

stopifnot(
  !any(
    is.na(
      final_model_coefficients$estimate
    )
  )
)


# ------------------------------------------------------------
# 3. Create concise non-county coefficient table
# ------------------------------------------------------------

final_model_noncounty_coefficients <-
  final_model_coefficients %>%
  filter(
    !grepl(
      "^factor\\(fips\\)",
      term
    )
  ) %>%
  select(
    term,
    estimate,
    conf_low,
    conf_high,
    standard_error,
    t_value,
    p_value
  )


print(
  final_model_noncounty_coefficients,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 4. Save coefficient outputs
# ------------------------------------------------------------

diagnostic_output_dir <-
  "output/final_model_diagnostics"

dir.create(
  diagnostic_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


write_csv(
  final_model_coefficients,
  file.path(
    diagnostic_output_dir,
    "final_model_all_coefficients_95ci.csv"
  )
)


write_csv(
  final_model_noncounty_coefficients,
  file.path(
    diagnostic_output_dir,
    "final_model_noncounty_coefficients_95ci.csv"
  )
)


cat(
  "\n",
  "A13 coefficient extraction complete.\n",
  "All coefficients:",
  nrow(final_model_coefficients),
  "\n",
  "Non-county coefficients:",
  nrow(final_model_noncounty_coefficients),
  "\n"
)

# ------------------------------------------------------------
# 5. Create thesis-ready coefficient table
# ------------------------------------------------------------

final_model_coefficient_table <-
  final_model_noncounty_coefficients %>%
  mutate(
    term = recode(
      term,
      "(Intercept)" =
        "Intercept",
      "year_centered" =
        "Centered year",
      "lag1_yield" =
        "Previous-year yield",
      "w01_early_tavg" =
        "Early-season mean temperature",
      "w02_early_prcp" =
        "Early-season total precipitation",
      "w03_repro_tavg" =
        "Reproductive-period mean temperature",
      "w04_repro_prcp" =
        "Reproductive-period total precipitation",
      "w05_grainfill_tavg" =
        "Grain-filling mean temperature",
      "w06_grainfill_prcp" =
        "Grain-filling total precipitation",
      "e02_heat_above_35" =
        "Accumulated July heat above 35°C",
      "e03_longest_dry_spell" =
        "Longest July-August dry spell",
      "e04_max_5day_prcp" =
        "Maximum May-July rolling 5-day precipitation"
    )
  ) %>%
  transmute(
    term,
    estimate =
      round(
        estimate,
        3
      ),
    ci_lower =
      round(
        conf_low,
        3
      ),
    ci_upper =
      round(
        conf_high,
        3
      )
  )


print(
  final_model_coefficient_table,
  n = Inf,
  width = Inf
)


write_csv(
  final_model_coefficient_table,
  file.path(
    diagnostic_output_dir,
    "final_model_coefficient_table.csv"
  )
)

# ------------------------------------------------------------
# 6. County-cluster bootstrap uncertainty for predictive metrics
# ------------------------------------------------------------

# Load existing development-stage Linear Regression predictions
development_predictions <-
  read_csv(
    "output/linear_model_comparison/linear_validation_predictions.csv",
    show_col_types = FALSE
  ) %>%
  filter(
    model_group ==
      "Group 3 - Historical + conventional + extremes"
  )

# Load existing final holdout predictions
holdout_predictions <-
  read_csv(
    "output/final_holdout_evaluation/final_holdout_predictions.csv",
    show_col_types = FALSE
  )


# ------------------------------------------------------------
# Verify prediction datasets
# ------------------------------------------------------------

stopifnot(
  nrow(development_predictions) == 739
)

stopifnot(
  n_distinct(
    development_predictions$fips
  ) == 89
)

stopifnot(
  nrow(holdout_predictions) == 247
)

stopifnot(
  n_distinct(
    holdout_predictions$fips
  ) == 82
)


# ------------------------------------------------------------
# Function to calculate pooled predictive metrics
# ------------------------------------------------------------

calculate_prediction_metrics <- function(data) {
  
  residuals <-
    data$actual_yield -
    data$predicted_yield
  
  squared_errors <-
    residuals^2
  
  absolute_errors <-
    abs(
      residuals
    )
  
  r2_denominator <-
    sum(
      (
        data$actual_yield -
          mean(data$actual_yield)
      )^2
    )
  
  tibble(
    rmse =
      sqrt(
        mean(
          squared_errors
        )
      ),
    
    mae =
      mean(
        absolute_errors
      ),
    
    r_squared =
      ifelse(
        r2_denominator > 0,
        1 -
          sum(
            squared_errors
          ) /
          r2_denominator,
        NA_real_
      )
  )
}


# ------------------------------------------------------------
# Function for county-cluster bootstrap
# ------------------------------------------------------------

county_cluster_bootstrap <- function(
    data,
    bootstrap_replicates = 2000,
    seed = 492
) {
  
  # Preserve all repeated observations belonging to a county
  county_rows <-
    split(
      seq_len(
        nrow(data)
      ),
      as.character(
        data$fips
      )
    )
  
  county_ids <-
    names(
      county_rows
    )
  
  set.seed(
    seed
  )
  
  map_dfr(
    seq_len(
      bootstrap_replicates
    ),
    function(bootstrap_rep) {
      
      # Sample counties with replacement
      sampled_counties <-
        sample(
          county_ids,
          size =
            length(
              county_ids
            ),
          replace = TRUE
        )
      
      # Retain every observation belonging to each sampled
      # county. Repeated sampled counties are retained with
      # their full observation histories each time selected.
      sampled_rows <-
        unlist(
          county_rows[
            sampled_counties
          ],
          use.names = FALSE
        )
      
      bootstrap_data <-
        data[
          sampled_rows,
        ]
      
      calculate_prediction_metrics(
        bootstrap_data
      ) %>%
        mutate(
          bootstrap_rep =
            bootstrap_rep,
          .before = 1
        )
    }
  )
}


# ------------------------------------------------------------
# Calculate original point estimates
# ------------------------------------------------------------

development_metric_estimates <-
  calculate_prediction_metrics(
    development_predictions
  )

holdout_metric_estimates <-
  calculate_prediction_metrics(
    holdout_predictions
  )


print(
  development_metric_estimates,
  width = Inf
)

print(
  holdout_metric_estimates,
  width = Inf
)


# ------------------------------------------------------------
# Run county-cluster bootstrap
# ------------------------------------------------------------

development_bootstrap <-
  county_cluster_bootstrap(
    development_predictions,
    bootstrap_replicates = 2000,
    seed = 492
  )

holdout_bootstrap <-
  county_cluster_bootstrap(
    holdout_predictions,
    bootstrap_replicates = 2000,
    seed = 493
  )


# ------------------------------------------------------------
# Summarize percentile 95% bootstrap intervals
# ------------------------------------------------------------

summarize_bootstrap_metrics <- function(
    point_estimates,
    bootstrap_results,
    evaluation_stage
) {
  
  tibble(
    evaluation_stage =
      evaluation_stage,
    
    metric =
      c(
        "RMSE",
        "MAE",
        "R-squared"
      ),
    
    estimate =
      c(
        point_estimates$rmse,
        point_estimates$mae,
        point_estimates$r_squared
      ),
    
    ci_lower =
      c(
        quantile(
          bootstrap_results$rmse,
          0.025,
          na.rm = TRUE
        ),
        quantile(
          bootstrap_results$mae,
          0.025,
          na.rm = TRUE
        ),
        quantile(
          bootstrap_results$r_squared,
          0.025,
          na.rm = TRUE
        )
      ),
    
    ci_upper =
      c(
        quantile(
          bootstrap_results$rmse,
          0.975,
          na.rm = TRUE
        ),
        quantile(
          bootstrap_results$mae,
          0.975,
          na.rm = TRUE
        ),
        quantile(
          bootstrap_results$r_squared,
          0.975,
          na.rm = TRUE
        )
      )
  )
}


development_bootstrap_summary <-
  summarize_bootstrap_metrics(
    development_metric_estimates,
    development_bootstrap,
    "Development validation, 2012-2021"
  )


holdout_bootstrap_summary <-
  summarize_bootstrap_metrics(
    holdout_metric_estimates,
    holdout_bootstrap,
    "Final holdout, 2022-2025"
  )


bootstrap_metric_summary <-
  bind_rows(
    development_bootstrap_summary,
    holdout_bootstrap_summary
  )


print(
  bootstrap_metric_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Save bootstrap reproducibility outputs
# ------------------------------------------------------------

write_csv(
  development_bootstrap,
  file.path(
    diagnostic_output_dir,
    "development_county_cluster_bootstrap_replicates.csv"
  )
)

write_csv(
  holdout_bootstrap,
  file.path(
    diagnostic_output_dir,
    "holdout_county_cluster_bootstrap_replicates.csv"
  )
)

write_csv(
  bootstrap_metric_summary,
  file.path(
    diagnostic_output_dir,
    "county_cluster_bootstrap_metric_summary.csv"
  )
)


cat(
  "\n",
  "A14 county-cluster bootstrap complete.\n",
  "Development bootstrap replicates:",
  nrow(development_bootstrap),
  "\n",
  "Holdout bootstrap replicates:",
  nrow(holdout_bootstrap),
  "\n"
)

# ------------------------------------------------------------
# 7. Create thesis-ready bootstrap uncertainty table
# ------------------------------------------------------------

bootstrap_metric_table <-
  bootstrap_metric_summary %>%
  mutate(
    evaluation_stage = recode(
      evaluation_stage,
      "Development validation, 2012-2021" =
        "Development validation, 2012–2021",
      "Final holdout, 2022-2025" =
        "Final holdout, 2022–2025"
    ),
    
    estimate = case_when(
      metric == "R-squared" ~ round(estimate, 3),
      TRUE ~ round(estimate, 2)
    ),
    
    ci_lower = case_when(
      metric == "R-squared" ~ round(ci_lower, 3),
      TRUE ~ round(ci_lower, 2)
    ),
    
    ci_upper = case_when(
      metric == "R-squared" ~ round(ci_upper, 3),
      TRUE ~ round(ci_upper, 2)
    )
  ) %>%
  rename(
    `Evaluation Stage` = evaluation_stage,
    `Metric` = metric,
    `Estimate` = estimate,
    `95% CI Lower` = ci_lower,
    `95% CI Upper` = ci_upper
  )


print(
  bootstrap_metric_table,
  n = Inf,
  width = Inf
)


write_csv(
  bootstrap_metric_table,
  file.path(
    diagnostic_output_dir,
    "bootstrap_metric_table.csv"
  )
)

# ------------------------------------------------------------
# 8. Residual-versus-predicted diagnostic analysis
# ------------------------------------------------------------

# Load the complete development dataset used to fit the
# formally locked final model.
final_model_development_data <-
  readRDS(
    "output/modeling_dataset/modeling_development_2001_2021.rds"
  )


# ------------------------------------------------------------
# Verify final-model development observations
# ------------------------------------------------------------

stopifnot(
  nrow(final_model_development_data) ==
    nobs(final_model_fit)
)

stopifnot(
  nrow(final_model_development_data) == 1691
)


# ------------------------------------------------------------
# Create development-stage fitted-value diagnostic data
# ------------------------------------------------------------

development_residual_diagnostic <-
  final_model_development_data %>%
  transmute(
    evaluation_stage =
      "Development fit, 2001-2021",
    
    fips =
      as.character(
        fips
      ),
    
    year = year,
    
    actual_yield =
      corn_yield,
    
    predicted_yield =
      as.numeric(
        fitted(
          final_model_fit
        )
      ),
    
    residual =
      as.numeric(
        residuals(
          final_model_fit
        )
      )
  )


# Confirm residual definition is actual minus predicted
stopifnot(
  max(
    abs(
      development_residual_diagnostic$residual -
        (
          development_residual_diagnostic$actual_yield -
            development_residual_diagnostic$predicted_yield
        )
    )
  ) < 1e-8
)


# ------------------------------------------------------------
# Create final-holdout diagnostic data
# ------------------------------------------------------------

holdout_residual_diagnostic <-
  holdout_predictions %>%
  transmute(
    evaluation_stage =
      "Final holdout, 2022-2025",
    
    fips =
      as.character(
        fips
      ),
    
    year = year,
    
    actual_yield =
      actual_yield,
    
    predicted_yield =
      predicted_yield,
    
    residual =
      actual_yield -
      predicted_yield
  )


# ------------------------------------------------------------
# Verify matching FIPS storage type
# ------------------------------------------------------------

stopifnot(
  is.character(
    development_residual_diagnostic$fips
  )
)

stopifnot(
  is.character(
    holdout_residual_diagnostic$fips
  )
)


# ------------------------------------------------------------
# Combine diagnostic datasets
# ------------------------------------------------------------

residual_diagnostic_data <-
  bind_rows(
    development_residual_diagnostic,
    holdout_residual_diagnostic
  )


print(
  residual_diagnostic_data %>%
    count(
      evaluation_stage
    )
)


# Confirm expected observation counts
stopifnot(
  nrow(
    development_residual_diagnostic
  ) == 1691
)

stopifnot(
  nrow(
    holdout_residual_diagnostic
  ) == 247
)

stopifnot(
  nrow(
    residual_diagnostic_data
  ) == 1938
)


# ------------------------------------------------------------
# Summarize residual patterns by predicted-yield quintile
# ------------------------------------------------------------

residual_pattern_summary <-
  residual_diagnostic_data %>%
  group_by(
    evaluation_stage
  ) %>%
  mutate(
    predicted_yield_quintile =
      ntile(
        predicted_yield,
        5
      )
  ) %>%
  group_by(
    evaluation_stage,
    predicted_yield_quintile
  ) %>%
  summarise(
    observations =
      n(),
    
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
    
    rmse =
      sqrt(
        mean(
          residual^2
        )
      ),
    
    .groups = "drop"
  )


print(
  residual_pattern_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Overall residual diagnostic summary
# ------------------------------------------------------------

residual_overall_summary <-
  residual_diagnostic_data %>%
  group_by(
    evaluation_stage
  ) %>%
  summarise(
    observations =
      n(),
    
    mean_residual =
      mean(
        residual
      ),
    
    median_residual =
      median(
        residual
      ),
    
    residual_sd =
      sd(
        residual
      ),
    
    min_residual =
      min(
        residual
      ),
    
    max_residual =
      max(
        residual
      ),
    
    .groups = "drop"
  )


print(
  residual_overall_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Residual-versus-predicted diagnostic plot
# ------------------------------------------------------------

residual_vs_predicted_plot <-
  residual_diagnostic_data %>%
  mutate(
    evaluation_stage =
      recode(
        evaluation_stage,
        
        "Development fit, 2001-2021" =
          "Development Fit, 2001–2021",
        
        "Final holdout, 2022-2025" =
          "Final Holdout, 2022–2025"
      )
  ) %>%
  ggplot(
    aes(
      x = predicted_yield,
      y = residual
    )
  ) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  geom_point(
    alpha = 0.45,
    size = 1.5
  ) +
  geom_smooth(
    method = "loess",
    formula = y ~ x,
    span = 1,
    se = FALSE,
    linewidth = 0.9
  ) +
  facet_wrap(
    ~ evaluation_stage,
    scales = "fixed"
  ) +
  labs(
    title =
      "Residuals Versus Predicted Yield for the Locked Final Model",
    
    subtitle =
      "Residual = observed yield minus predicted yield",
    
    x =
      "Predicted Corn Yield (bushels per acre)",
    
    y =
      "Residual (bushels per acre)"
  ) +
  theme_minimal()


residual_vs_predicted_plot


# ------------------------------------------------------------
# Save A15 diagnostic outputs
# ------------------------------------------------------------

write_csv(
  residual_pattern_summary,
  file.path(
    diagnostic_output_dir,
    "residual_pattern_by_predicted_quintile.csv"
  )
)


write_csv(
  residual_overall_summary,
  file.path(
    diagnostic_output_dir,
    "residual_overall_summary.csv"
  )
)


write_csv(
  residual_diagnostic_data,
  file.path(
    diagnostic_output_dir,
    "residual_diagnostic_data.csv"
  )
)


ggsave(
  file.path(
    diagnostic_output_dir,
    "residual_vs_predicted_diagnostic.png"
  ),
  plot =
    residual_vs_predicted_plot,
  width = 10,
  height = 5.5,
  dpi = 300
)


cat(
  "\n",
  "A15 residual-versus-predicted diagnostics created.\n",
  "Development observations:",
  nrow(
    development_residual_diagnostic
  ),
  "\n",
  "Holdout observations:",
  nrow(
    holdout_residual_diagnostic
  ),
  "\n",
  "Combined observations:",
  nrow(
    residual_diagnostic_data
  ),
  "\n"
)

# ------------------------------------------------------------
# 9. Influence, heteroscedasticity, and nonlinear diagnostics
# ------------------------------------------------------------

# These diagnostics are performed after formal model selection
# and final holdout evaluation. They are descriptive only and
# do not alter the locked Linear Regression Group 3 model.


# ------------------------------------------------------------
# 9.1 Calculate observation-level influence diagnostics
# ------------------------------------------------------------

diagnostic_n <-
  nobs(
    final_model_fit
  )

diagnostic_p <-
  length(
    coef(
      final_model_fit
    )
  )


# Common descriptive screening thresholds
cook_threshold <-
  4 /
  diagnostic_n

leverage_threshold <-
  2 *
  diagnostic_p /
  diagnostic_n

standardized_residual_threshold <-
  3


model_influence_diagnostics <-
  final_model_development_data %>%
  transmute(
    observation_index =
      row_number(),
    
    fips =
      as.character(
        fips
      ),
    
    county =
      county,
    
    year =
      year,
    
    actual_yield =
      corn_yield,
    
    fitted_yield =
      as.numeric(
        fitted(
          final_model_fit
        )
      ),
    
    residual =
      as.numeric(
        residuals(
          final_model_fit
        )
      ),
    
    standardized_residual =
      as.numeric(
        rstandard(
          final_model_fit
        )
      ),
    
    leverage =
      as.numeric(
        hatvalues(
          final_model_fit
        )
      ),
    
    cooks_distance =
      as.numeric(
        cooks.distance(
          final_model_fit
        )
      )
  ) %>%
  mutate(
    high_cooks_distance =
      cooks_distance >
      cook_threshold,
    
    high_leverage =
      leverage >
      leverage_threshold,
    
    large_standardized_residual =
      abs(
        standardized_residual
      ) >
      standardized_residual_threshold,
    
    any_influence_flag =
      high_cooks_distance |
      high_leverage |
      large_standardized_residual
  )


# ------------------------------------------------------------
# 9.2 Summarize influence diagnostics
# ------------------------------------------------------------

influence_diagnostic_summary <-
  tibble(
    observations =
      diagnostic_n,
    
    model_coefficients =
      diagnostic_p,
    
    cooks_distance_threshold =
      cook_threshold,
    
    leverage_threshold =
      leverage_threshold,
    
    standardized_residual_threshold =
      standardized_residual_threshold,
    
    observations_above_cooks_threshold =
      sum(
        model_influence_diagnostics$high_cooks_distance
      ),
    
    observations_above_leverage_threshold =
      sum(
        model_influence_diagnostics$high_leverage
      ),
    
    observations_with_large_standardized_residual =
      sum(
        model_influence_diagnostics$large_standardized_residual
      ),
    
    observations_with_any_flag =
      sum(
        model_influence_diagnostics$any_influence_flag
      ),
    
    maximum_cooks_distance =
      max(
        model_influence_diagnostics$cooks_distance
      ),
    
    maximum_leverage =
      max(
        model_influence_diagnostics$leverage
      ),
    
    maximum_absolute_standardized_residual =
      max(
        abs(
          model_influence_diagnostics$standardized_residual
        )
      )
  )


print(
  influence_diagnostic_summary,
  width = Inf
)


# ------------------------------------------------------------
# 9.3 Identify observations with largest Cook's distance
# ------------------------------------------------------------

top_influential_observations <-
  model_influence_diagnostics %>%
  arrange(
    desc(
      cooks_distance
    )
  ) %>%
  slice_head(
    n = 15
  )


print(
  top_influential_observations,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 9.4 Summarize residual spread across fitted-yield quintiles
# ------------------------------------------------------------

heteroscedasticity_summary <-
  model_influence_diagnostics %>%
  mutate(
    fitted_yield_quintile =
      ntile(
        fitted_yield,
        5
      )
  ) %>%
  group_by(
    fitted_yield_quintile
  ) %>%
  summarise(
    observations =
      n(),
    
    mean_fitted_yield =
      mean(
        fitted_yield
      ),
    
    residual_sd =
      sd(
        residual
      ),
    
    mean_absolute_residual =
      mean(
        abs(
          residual
        )
      ),
    
    rmse =
      sqrt(
        mean(
          residual^2
        )
      ),
    
    .groups = "drop"
  )


print(
  heteroscedasticity_summary,
  n = Inf,
  width = Inf
)


# Descriptive ratio of largest to smallest residual SD
residual_sd_ratio <-
  max(
    heteroscedasticity_summary$residual_sd
  ) /
  min(
    heteroscedasticity_summary$residual_sd
  )


cat(
  "\n",
  "Largest-to-smallest residual SD ratio:",
  round(
    residual_sd_ratio,
    3
  ),
  "\n"
)


# ------------------------------------------------------------
# 9.5 Cook's distance diagnostic plot
# ------------------------------------------------------------

cooks_distance_plot <-
  model_influence_diagnostics %>%
  ggplot(
    aes(
      x = observation_index,
      y = cooks_distance
    )
  ) +
  geom_point(
    alpha = 0.55,
    size = 1.3
  ) +
  geom_hline(
    yintercept =
      cook_threshold,
    linetype =
      "dashed"
  ) +
  labs(
    title =
      "Cook's Distance for the Locked Final Model",
    
    subtitle =
      paste0(
        "Dashed line = 4/n screening threshold (",
        round(
          cook_threshold,
          4
        ),
        ")"
      ),
    
    x =
      "Development Observation",
    
    y =
      "Cook's Distance"
  ) +
  theme_minimal()


cooks_distance_plot


# ------------------------------------------------------------
# 9.6 Scale-location diagnostic plot
# ------------------------------------------------------------

scale_location_plot <-
  model_influence_diagnostics %>%
  mutate(
    sqrt_absolute_standardized_residual =
      sqrt(
        abs(
          standardized_residual
        )
      )
  ) %>%
  ggplot(
    aes(
      x = fitted_yield,
      y = sqrt_absolute_standardized_residual
    )
  ) +
  geom_point(
    alpha = 0.45,
    size = 1.5
  ) +
  geom_smooth(
    method = "loess",
    formula = y ~ x,
    span = 1,
    se = FALSE,
    linewidth = 0.9
  ) +
  labs(
    title =
      "Scale-Location Diagnostic for the Locked Final Model",
    
    subtitle =
      "Used to assess whether residual spread changes across fitted yield",
    
    x =
      "Predicted Corn Yield (bushels per acre)",
    
    y =
      expression(
        sqrt(
          "|Standardized Residual|"
        )
      )
  ) +
  theme_minimal()


scale_location_plot


# ------------------------------------------------------------
# 9.7 Examine residual patterns against continuous predictors
# ------------------------------------------------------------

continuous_predictors <-
  c(
    "year_centered",
    "lag1_yield",
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


nonlinear_diagnostic_data <-
  final_model_development_data %>%
  mutate(
    residual =
      as.numeric(
        residuals(
          final_model_fit
        )
      )
  ) %>%
  select(
    residual,
    all_of(
      continuous_predictors
    )
  ) %>%
  pivot_longer(
    cols =
      all_of(
        continuous_predictors
      ),
    
    names_to =
      "predictor",
    
    values_to =
      "predictor_value"
  ) %>%
  mutate(
    predictor =
      recode(
        predictor,
        
        "year_centered" =
          "Centered year",
        
        "lag1_yield" =
          "Previous-year yield",
        
        "w01_early_tavg" =
          "Early-season mean temperature",
        
        "w02_early_prcp" =
          "Early-season total precipitation",
        
        "w03_repro_tavg" =
          "Reproductive-period mean temperature",
        
        "w04_repro_prcp" =
          "Reproductive-period total precipitation",
        
        "w05_grainfill_tavg" =
          "Grain-filling mean temperature",
        
        "w06_grainfill_prcp" =
          "Grain-filling total precipitation",
        
        "e02_heat_above_35" =
          "Accumulated July heat above 35°C",
        
        "e03_longest_dry_spell" =
          "Longest July–August dry spell",
        
        "e04_max_5day_prcp" =
          "Maximum May–July rolling 5-day precipitation"
      )
  )


# ------------------------------------------------------------
# 9.8 Residual-versus-predictor diagnostic plot
# ------------------------------------------------------------

residual_by_predictor_plot <-
  nonlinear_diagnostic_data %>%
  ggplot(
    aes(
      x = predictor_value,
      y = residual
    )
  ) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  geom_point(
    alpha = 0.25,
    size = 0.8
  ) +
  geom_smooth(
    method = "loess",
    formula = y ~ x,
    span = 1,
    se = FALSE,
    linewidth = 0.8
  ) +
  facet_wrap(
    ~ predictor,
    scales = "free_x",
    ncol = 3
  ) +
  labs(
    title =
      "Residual Patterns Across Continuous Predictors",
    
    subtitle =
      "Locked Linear Regression Group 3 development fit, 2001–2021",
    
    x =
      "Predictor Value",
    
    y =
      "Residual (bushels per acre)"
  ) +
  theme_minimal()


residual_by_predictor_plot


# ------------------------------------------------------------
# 9.9 Save A16 diagnostic outputs
# ------------------------------------------------------------

write_csv(
  model_influence_diagnostics,
  file.path(
    diagnostic_output_dir,
    "model_influence_diagnostics.csv"
  )
)


write_csv(
  influence_diagnostic_summary,
  file.path(
    diagnostic_output_dir,
    "influence_diagnostic_summary.csv"
  )
)


write_csv(
  top_influential_observations,
  file.path(
    diagnostic_output_dir,
    "top_influential_observations.csv"
  )
)


write_csv(
  heteroscedasticity_summary,
  file.path(
    diagnostic_output_dir,
    "heteroscedasticity_by_fitted_quintile.csv"
  )
)


ggsave(
  file.path(
    diagnostic_output_dir,
    "cooks_distance_diagnostic.png"
  ),
  plot =
    cooks_distance_plot,
  width = 9,
  height = 5.5,
  dpi = 300
)


ggsave(
  file.path(
    diagnostic_output_dir,
    "scale_location_diagnostic.png"
  ),
  plot =
    scale_location_plot,
  width = 9,
  height = 5.5,
  dpi = 300
)


ggsave(
  file.path(
    diagnostic_output_dir,
    "residual_patterns_continuous_predictors.png"
  ),
  plot =
    residual_by_predictor_plot,
  width = 12,
  height = 12,
  dpi = 300
)


cat(
  "\n",
  "A16 influence, heteroscedasticity, and nonlinear diagnostics created.\n",
  "Development observations:",
  diagnostic_n,
  "\n",
  "Model coefficients:",
  diagnostic_p,
  "\n",
  "Cook's distance threshold:",
  round(
    cook_threshold,
    4
  ),
  "\n",
  "Leverage threshold:",
  round(
    leverage_threshold,
    4
  ),
  "\n",
  "Residual SD ratio:",
  round(
    residual_sd_ratio,
    3
  ),
  "\n"
)

# ------------------------------------------------------------
# 9.10 Investigate high-leverage observations
# ------------------------------------------------------------

county_observation_counts <-
  final_model_development_data %>%
  count(
    fips,
    county,
    name = "county_observations"
  ) %>%
  mutate(
    fips =
      as.character(
        fips
      )
  )


high_leverage_observations <-
  model_influence_diagnostics %>%
  filter(
    high_leverage
  ) %>%
  left_join(
    county_observation_counts,
    by = c(
      "fips",
      "county"
    )
  ) %>%
  arrange(
    desc(
      leverage
    )
  ) %>%
  select(
    observation_index,
    fips,
    county,
    year,
    actual_yield,
    fitted_yield,
    residual,
    standardized_residual,
    leverage,
    cooks_distance,
    county_observations
  )


print(
  high_leverage_observations,
  n = Inf,
  width = Inf
)


# Summarize influence flags by year
influence_flags_by_year <-
  model_influence_diagnostics %>%
  group_by(
    year
  ) %>%
  summarise(
    observations =
      n(),
    
    cooks_flags =
      sum(
        high_cooks_distance
      ),
    
    leverage_flags =
      sum(
        high_leverage
      ),
    
    large_residual_flags =
      sum(
        large_standardized_residual
      ),
    
    any_flags =
      sum(
        any_influence_flag
      ),
    
    .groups = "drop"
  )


print(
  influence_flags_by_year,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# Save supplemental A16 influence summaries
# ------------------------------------------------------------

write_csv(
  high_leverage_observations,
  file.path(
    diagnostic_output_dir,
    "high_leverage_observations.csv"
  )
)

write_csv(
  influence_flags_by_year,
  file.path(
    diagnostic_output_dir,
    "influence_flags_by_year.csv"
  )
)

# ------------------------------------------------------------
# 10. Final-holdout prediction interval assessment
# ------------------------------------------------------------

# Purpose:
# Assess the feasibility and empirical calibration of
# conventional model-based 95% prediction intervals for the
# formally locked Linear Regression Group 3 model.
#
# The model is not refit or modified. Prediction intervals are
# generated from the saved final model fit and evaluated using
# the previously reserved 2022-2025 final holdout.
#
# These are conventional OLS prediction intervals and therefore
# rely on the fitted linear-model assumptions. Results are
# interpreted as post-selection diagnostics.


# ------------------------------------------------------------
# 10.1 Load final holdout modeling data
# ------------------------------------------------------------

modeling_holdout <-
  readRDS(
    "output/modeling_dataset/modeling_holdout_2022_2025.rds"
  )


# ------------------------------------------------------------
# Verify holdout structure
# ------------------------------------------------------------

stopifnot(
  nrow(
    modeling_holdout
  ) == 247
)

stopifnot(
  all(
    modeling_holdout$year %in%
      2022:2025
  )
)

stopifnot(
  n_distinct(
    modeling_holdout$fips
  ) == 82
)


# Verify all holdout counties were represented in development
stopifnot(
  length(
    setdiff(
      unique(
        modeling_holdout$fips
      ),
      unique(
        final_model_development_data$fips
      )
    )
  ) == 0
)


# ------------------------------------------------------------
# 10.2 Generate conventional 95% prediction intervals
# ------------------------------------------------------------

holdout_prediction_intervals <-
  predict(
    final_model_fit,
    newdata =
      modeling_holdout,
    interval =
      "prediction",
    level =
      0.95
  )


# Inspect prediction-interval output
head(
  holdout_prediction_intervals
)


# Confirm expected dimensions
stopifnot(
  nrow(
    holdout_prediction_intervals
  ) == 247
)

stopifnot(
  ncol(
    holdout_prediction_intervals
  ) == 3
)


# ------------------------------------------------------------
# 10.3 Create observation-level prediction-interval dataset
# ------------------------------------------------------------

holdout_prediction_interval_data <-
  modeling_holdout %>%
  transmute(
    year =
      year,
    
    fips =
      as.character(
        fips
      ),
    
    county =
      county,
    
    actual_yield =
      corn_yield,
    
    predicted_yield =
      as.numeric(
        holdout_prediction_intervals[
          ,
          "fit"
        ]
      ),
    
    pi_lower =
      as.numeric(
        holdout_prediction_intervals[
          ,
          "lwr"
        ]
      ),
    
    pi_upper =
      as.numeric(
        holdout_prediction_intervals[
          ,
          "upr"
        ]
      )
  ) %>%
  mutate(
    interval_width =
      pi_upper -
      pi_lower,
    
    covered =
      actual_yield >=
      pi_lower &
      actual_yield <=
      pi_upper,
    
    below_interval =
      actual_yield <
      pi_lower,
    
    above_interval =
      actual_yield >
      pi_upper
  )


# ------------------------------------------------------------
# 10.4 Verify point predictions match existing holdout results
# ------------------------------------------------------------

prediction_consistency_check <-
  max(
    abs(
      holdout_prediction_interval_data$predicted_yield -
        holdout_predictions$predicted_yield
    )
  )


cat(
  "\n",
  "Maximum difference from previously saved point predictions:",
  prediction_consistency_check,
  "\n"
)


stopifnot(
  prediction_consistency_check <
    1e-8
)


# ------------------------------------------------------------
# 10.5 Summarize pooled prediction-interval performance
# ------------------------------------------------------------

prediction_interval_pooled_summary <-
  holdout_prediction_interval_data %>%
  summarise(
    observations =
      n(),
    
    covered_observations =
      sum(
        covered
      ),
    
    coverage_rate =
      mean(
        covered
      ),
    
    coverage_percent =
      100 *
      mean(
        covered
      ),
    
    observations_below_interval =
      sum(
        below_interval
      ),
    
    observations_above_interval =
      sum(
        above_interval
      ),
    
    mean_interval_width =
      mean(
        interval_width
      ),
    
    median_interval_width =
      median(
        interval_width
      ),
    
    minimum_interval_width =
      min(
        interval_width
      ),
    
    maximum_interval_width =
      max(
        interval_width
      )
  )


print(
  prediction_interval_pooled_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 10.6 Summarize prediction-interval performance by year
# ------------------------------------------------------------

prediction_interval_yearly_summary <-
  holdout_prediction_interval_data %>%
  group_by(
    year
  ) %>%
  summarise(
    observations =
      n(),
    
    covered_observations =
      sum(
        covered
      ),
    
    coverage_rate =
      mean(
        covered
      ),
    
    coverage_percent =
      100 *
      mean(
        covered
      ),
    
    observations_below_interval =
      sum(
        below_interval
      ),
    
    observations_above_interval =
      sum(
        above_interval
      ),
    
    mean_interval_width =
      mean(
        interval_width
      ),
    
    median_interval_width =
      median(
        interval_width
      ),
    
    .groups =
      "drop"
  )


print(
  prediction_interval_yearly_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 10.7 Identify holdout observations outside prediction interval
# ------------------------------------------------------------

prediction_interval_misses <-
  holdout_prediction_interval_data %>%
  filter(
    !covered
  ) %>%
  mutate(
    distance_outside_interval =
      case_when(
        below_interval ~
          pi_lower -
          actual_yield,
        
        above_interval ~
          actual_yield -
          pi_upper,
        
        TRUE ~
          0
      )
  ) %>%
  arrange(
    desc(
      distance_outside_interval
    )
  )


print(
  prediction_interval_misses,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 10.8 Summarize interval misses by year
# ------------------------------------------------------------

prediction_interval_misses_by_year <-
  prediction_interval_misses %>%
  count(
    year,
    name =
      "interval_misses"
  )


print(
  prediction_interval_misses_by_year,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# 10.9 Create prediction-interval coverage plot
# ------------------------------------------------------------

prediction_interval_plot_data <-
  holdout_prediction_interval_data %>%
  group_by(
    year
  ) %>%
  arrange(
    predicted_yield,
    .by_group = TRUE
  ) %>%
  mutate(
    prediction_order =
      row_number()
  ) %>%
  ungroup()


prediction_interval_plot <-
  prediction_interval_plot_data %>%
  ggplot(
    aes(
      x = prediction_order
    )
  ) +
  geom_ribbon(
    aes(
      ymin = pi_lower,
      ymax = pi_upper
    ),
    alpha = 0.20
  ) +
  geom_line(
    aes(
      y = predicted_yield
    ),
    linewidth = 0.8
  ) +
  geom_point(
    aes(
      y = actual_yield,
      shape = covered
    ),
    size = 1.8,
    alpha = 0.75
  ) +
  facet_wrap(
    ~ year,
    scales = "free_x"
  ) +
  labs(
    title =
      "Final Holdout 95% Prediction Intervals",
    
    subtitle =
      "Locked Linear Regression Group 3, 2022–2025",
    
    x =
      "Holdout Observations Ordered by Predicted Yield",
    
    y =
      "Corn Yield (bushels per acre)",
    
    shape =
      "Actual Yield Within Interval"
  ) +
  theme_minimal()


prediction_interval_plot


# ------------------------------------------------------------
# 10.10 Save A17 outputs
# ------------------------------------------------------------

write_csv(
  holdout_prediction_interval_data,
  file.path(
    diagnostic_output_dir,
    "final_holdout_prediction_intervals.csv"
  )
)


write_csv(
  prediction_interval_pooled_summary,
  file.path(
    diagnostic_output_dir,
    "prediction_interval_pooled_summary.csv"
  )
)


write_csv(
  prediction_interval_yearly_summary,
  file.path(
    diagnostic_output_dir,
    "prediction_interval_yearly_summary.csv"
  )
)


write_csv(
  prediction_interval_misses,
  file.path(
    diagnostic_output_dir,
    "prediction_interval_misses.csv"
  )
)


ggsave(
  file.path(
    diagnostic_output_dir,
    "final_holdout_prediction_intervals.png"
  ),
  plot =
    prediction_interval_plot,
  width = 10,
  height = 7,
  dpi = 300
)


cat(
  "\n",
  "A17 prediction-interval assessment complete.\n",
  "Holdout observations:",
  nrow(
    holdout_prediction_interval_data
  ),
  "\n",
  "Overall 95% prediction-interval coverage:",
  round(
    100 *
      mean(
        holdout_prediction_interval_data$covered
      ),
    1
  ),
  "%\n",
  "Mean prediction-interval width:",
  round(
    mean(
      holdout_prediction_interval_data$interval_width
    ),
    2
  ),
  "bushels per acre\n"
)
