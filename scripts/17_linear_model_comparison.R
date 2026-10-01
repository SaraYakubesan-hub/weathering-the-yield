# ============================================================
# Linear Model Predictor-Group Comparison
# Senior Thesis
#
# Purpose:
# Compare the three finalized predictor groups using multiple
# linear regression and 2012-2021 expanding-window validation.
#
# Predictor groups:
# 1. Historical baseline
# 2. Historical baseline + conventional weather
# 3. Historical baseline + conventional weather +
#    retained extreme-weather indicators
#
# E01 hot-day count is excluded following the development-
# period multicollinearity sensitivity analysis.
#
# Only 2001-2021 development data are used.
# The 2022-2025 final holdout is not loaded or used.
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. Load development modeling dataset
# ------------------------------------------------------------

modeling_development <- readRDS(
  "output/modeling_dataset/modeling_development_2001_2021.rds"
)

dim(modeling_development)

range(modeling_development$year)

n_distinct(modeling_development$fips)

# Holdout safeguards
stopifnot(
  max(modeling_development$year) <= 2021
)

stopifnot(
  !any(modeling_development$year >= 2022)
)

# ------------------------------------------------------------
# 2. Define finalized linear-model formulas
# ------------------------------------------------------------

formula_group_1 <- corn_yield ~
  factor(fips) +
  year_centered +
  lag1_yield

formula_group_2 <- corn_yield ~
  factor(fips) +
  year_centered +
  lag1_yield +
  w01_early_tavg +
  w02_early_prcp +
  w03_repro_tavg +
  w04_repro_prcp +
  w05_grainfill_tavg +
  w06_grainfill_prcp

formula_group_3 <- corn_yield ~
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

# ------------------------------------------------------------
# 3. Create rolling-origin prediction function
# ------------------------------------------------------------

generate_lm_predictions <- function(
    model_formula,
    model_group,
    data,
    validation_years = 2012:2021
) {
  
  map_dfr(
    validation_years,
    function(validation_year) {
      
      training_data <- data %>%
        filter(
          year < validation_year
        )
      
      validation_data <- data %>%
        filter(
          year == validation_year
        )
      
      model_fit <- lm(
        model_formula,
        data = training_data
      )
      
      predicted_yield <- predict(
        model_fit,
        newdata = validation_data
      )
      
      validation_data %>%
        transmute(
          model_group = model_group,
          validation_year = validation_year,
          fips = fips,
          county = county,
          actual_yield = corn_yield,
          predicted_yield = predicted_yield,
          residual = actual_yield - predicted_yield,
          absolute_error = abs(residual),
          squared_error = residual^2,
          training_observations = nrow(training_data)
        )
    }
  )
}

# ------------------------------------------------------------
# 4. Generate rolling-origin predictions
# ------------------------------------------------------------

predictions_group_1 <- generate_lm_predictions(
  formula_group_1,
  "Group 1 - Historical baseline",
  modeling_development
)

predictions_group_2 <- generate_lm_predictions(
  formula_group_2,
  "Group 2 - Historical + conventional weather",
  modeling_development
)

predictions_group_3 <- generate_lm_predictions(
  formula_group_3,
  "Group 3 - Historical + conventional + extremes",
  modeling_development
)

linear_predictions <- bind_rows(
  predictions_group_1,
  predictions_group_2,
  predictions_group_3
)

dim(linear_predictions)

glimpse(linear_predictions)

# ------------------------------------------------------------
# 5. Verify identical comparison observations
# ------------------------------------------------------------

comparison_counts <- linear_predictions %>%
  group_by(
    model_group,
    validation_year
  ) %>%
  summarise(
    observations = n(),
    .groups = "drop"
  )

print(
  comparison_counts,
  n = Inf
)

comparison_ids <- linear_predictions %>%
  count(
    validation_year,
    fips,
    name = "model_count"
  )

comparison_ids %>%
  filter(
    model_count != 3
  )

# ------------------------------------------------------------
# 6. Calculate validation metrics by year
# ------------------------------------------------------------

linear_metrics_by_year <- linear_predictions %>%
  group_by(
    model_group,
    validation_year
  ) %>%
  summarise(
    observations = n(),
    
    rmse = sqrt(
      mean(squared_error)
    ),
    
    mae = mean(
      absolute_error
    ),
    
    r_squared =
      1 -
      sum(squared_error) /
      sum(
        (actual_yield - mean(actual_yield))^2
      ),
    
    .groups = "drop"
  )

print(
  linear_metrics_by_year,
  n = Inf
)

# ------------------------------------------------------------
# 7. Summarize development-period performance
# ------------------------------------------------------------

linear_performance_summary <- linear_metrics_by_year %>%
  group_by(
    model_group
  ) %>%
  summarise(
    mean_rmse = mean(rmse),
    median_rmse = median(rmse),
    
    mean_mae = mean(mae),
    median_mae = median(mae),
    
    mean_r_squared = mean(r_squared),
    
    .groups = "drop"
  ) %>%
  arrange(
    mean_rmse
  )

linear_performance_summary

linear_pooled_performance <- linear_predictions %>%
  group_by(
    model_group
  ) %>%
  summarise(
    observations = n(),
    
    rmse = sqrt(
      mean(squared_error)
    ),
    
    mae = mean(
      absolute_error
    ),
    
    r_squared =
      1 -
      sum(squared_error) /
      sum(
        (actual_yield - mean(actual_yield))^2
      ),
    
    .groups = "drop"
  ) %>%
  arrange(
    rmse
  )

linear_pooled_performance

# ------------------------------------------------------------
# 8. Calculate incremental improvement by validation year
# ------------------------------------------------------------

linear_metrics_short <- linear_metrics_by_year %>%
  mutate(
    model_code = case_when(
      model_group == "Group 1 - Historical baseline" ~ "G1",
      model_group == "Group 2 - Historical + conventional weather" ~ "G2",
      model_group == "Group 3 - Historical + conventional + extremes" ~ "G3"
    )
  )

incremental_by_year <- linear_metrics_short %>%
  select(
    validation_year,
    model_code,
    rmse,
    mae
  ) %>%
  pivot_wider(
    names_from = model_code,
    values_from = c(
      rmse,
      mae
    )
  ) %>%
  mutate(
    rmse_reduction_G1_to_G2 =
      rmse_G1 - rmse_G2,
    
    rmse_pct_reduction_G1_to_G2 =
      100 * (rmse_G1 - rmse_G2) / rmse_G1,
    
    rmse_reduction_G2_to_G3 =
      rmse_G2 - rmse_G3,
    
    rmse_pct_reduction_G2_to_G3 =
      100 * (rmse_G2 - rmse_G3) / rmse_G2,
    
    mae_reduction_G1_to_G2 =
      mae_G1 - mae_G2,
    
    mae_pct_reduction_G1_to_G2 =
      100 * (mae_G1 - mae_G2) / mae_G1,
    
    mae_reduction_G2_to_G3 =
      mae_G2 - mae_G3,
    
    mae_pct_reduction_G2_to_G3 =
      100 * (mae_G2 - mae_G3) / mae_G2
  )

print(
  incremental_by_year,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 9. Summarize pooled incremental improvement
# ------------------------------------------------------------

pooled_comparison <- linear_pooled_performance %>%
  mutate(
    model_code = case_when(
      model_group == "Group 1 - Historical baseline" ~ "G1",
      model_group == "Group 2 - Historical + conventional weather" ~ "G2",
      model_group == "Group 3 - Historical + conventional + extremes" ~ "G3"
    )
  ) %>%
  select(
    model_code,
    rmse,
    mae,
    r_squared
  ) %>%
  pivot_wider(
    names_from = model_code,
    values_from = c(
      rmse,
      mae,
      r_squared
    )
  ) %>%
  mutate(
    rmse_pct_reduction_G1_to_G2 =
      100 * (rmse_G1 - rmse_G2) / rmse_G1,
    
    rmse_pct_reduction_G2_to_G3 =
      100 * (rmse_G2 - rmse_G3) / rmse_G2,
    
    rmse_pct_reduction_G1_to_G3 =
      100 * (rmse_G1 - rmse_G3) / rmse_G1,
    
    mae_pct_reduction_G1_to_G2 =
      100 * (mae_G1 - mae_G2) / mae_G1,
    
    mae_pct_reduction_G2_to_G3 =
      100 * (mae_G2 - mae_G3) / mae_G2,
    
    mae_pct_reduction_G1_to_G3 =
      100 * (mae_G1 - mae_G3) / mae_G1
  )

pooled_comparison

# ------------------------------------------------------------
# 10. Count yearly performance wins
# ------------------------------------------------------------

rmse_yearly_wins <- linear_metrics_by_year %>%
  group_by(validation_year) %>%
  filter(
    rmse == min(rmse)
  ) %>%
  ungroup() %>%
  count(
    model_group,
    name = "years_lowest_rmse"
  )

mae_yearly_wins <- linear_metrics_by_year %>%
  group_by(validation_year) %>%
  filter(
    mae == min(mae)
  ) %>%
  ungroup() %>%
  count(
    model_group,
    name = "years_lowest_mae"
  )

rmse_yearly_wins
mae_yearly_wins

# ------------------------------------------------------------
# 11. Sensitivity summary excluding 2012
# ------------------------------------------------------------

linear_summary_excluding_2012 <- linear_metrics_by_year %>%
  filter(
    validation_year != 2012
  ) %>%
  group_by(
    model_group
  ) %>%
  summarise(
    years = n(),
    mean_rmse = mean(rmse),
    mean_mae = mean(mae),
    .groups = "drop"
  ) %>%
  arrange(
    mean_rmse
  )

linear_summary_excluding_2012

# ------------------------------------------------------------
# 12. Identify difficult validation years
# ------------------------------------------------------------

group3_difficult_years <- linear_metrics_by_year %>%
  filter(
    model_group ==
      "Group 3 - Historical + conventional + extremes"
  ) %>%
  arrange(
    desc(rmse)
  )

group3_difficult_years

# ------------------------------------------------------------
# 13. Plot RMSE across validation years
# ------------------------------------------------------------

linear_rmse_by_year_plot <- linear_metrics_by_year %>%
  ggplot(
    aes(
      x = validation_year,
      y = rmse,
      group = model_group,
      linetype = model_group,
      shape = model_group
    )
  ) +
  geom_line() +
  geom_point(
    size = 2.5
  ) +
  scale_x_continuous(
    breaks = 2012:2021
  ) +
  labs(
    title = "Linear Model RMSE by Validation Year",
    subtitle = "Expanding-window validation, 2012-2021",
    x = "Validation Year",
    y = "RMSE (bushels per acre)",
    linetype = "Predictor Group",
    shape = "Predictor Group"
  ) +
  theme_minimal()

linear_rmse_by_year_plot

# ------------------------------------------------------------
# 14. Save linear-model comparison outputs
# ------------------------------------------------------------

dir.create(
  "output/linear_model_comparison",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  linear_predictions,
  "output/linear_model_comparison/linear_validation_predictions.csv"
)

write_csv(
  linear_metrics_by_year,
  "output/linear_model_comparison/linear_metrics_by_year.csv"
)

write_csv(
  linear_performance_summary,
  "output/linear_model_comparison/linear_performance_summary.csv"
)

write_csv(
  linear_pooled_performance,
  "output/linear_model_comparison/linear_pooled_performance.csv"
)

write_csv(
  incremental_by_year,
  "output/linear_model_comparison/incremental_improvement_by_year.csv"
)

write_csv(
  pooled_comparison,
  "output/linear_model_comparison/pooled_incremental_comparison.csv"
)

write_csv(
  linear_summary_excluding_2012,
  "output/linear_model_comparison/sensitivity_excluding_2012.csv"
)

write_csv(
  group3_difficult_years,
  "output/linear_model_comparison/group3_year_difficulty.csv"
)

ggsave(
  "output/linear_model_comparison/linear_rmse_by_validation_year.png",
  plot = linear_rmse_by_year_plot,
  width = 9,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# 15. Document linear-model comparison result
# ------------------------------------------------------------

linear_model_result <- tibble(
  analysis = "Linear predictor-group comparison",
  development_period = "2001-2021",
  validation_period = "2012-2021",
  validation_observations = 739,
  primary_metrics = "RMSE and MAE",
  best_overall_group =
    "Group 3 - Historical + conventional + extremes",
  group3_years_lowest_rmse = 7,
  group3_years_lowest_mae = 5,
  group3_mean_rmse_excluding_2012 = 19.5,
  group3_mean_mae_excluding_2012 = 16.8,
  interpretation = paste(
    "Conventional weather alone provided limited overall",
    "improvement beyond the historical baseline.",
    "Adding retained extreme-weather indicators produced",
    "substantially lower validation error overall and",
    "remained superior when 2012 was excluded."
  )
)

linear_model_result

write_csv(
  linear_model_result,
  "output/linear_model_comparison/linear_model_result.csv"
)

