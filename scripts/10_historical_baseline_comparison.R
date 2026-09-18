# ============================================================
# Historical Baseline Feature Comparison
# Senior Thesis
#
# Purpose:
# Compare two candidate representations of recent county-level
# corn yield history for the historical baseline model:
#
#   1. Previous-year yield (lag-1)
#   2. Flexible 3-year trailing mean
#
# Candidate features are compared using identical observations
# and forward expanding-window rolling-origin validation.
#
# Development validation:
#   Initial training period: 2003-2011
#   Validation years: 2012-2021
#
# The 2022-2025 final holdout is not used in this comparison.
# ============================================================


library(tidyverse)

# ------------------------------------------------------------
# 1. Load common baseline comparison sample
# ------------------------------------------------------------

baseline_data <- read_csv(
  "output/yield_history_audit/common_baseline_comparison_sample.csv",
  col_types = cols(
    fips = col_character(),
    .default = col_guess()
  )
)

# Verify dimensions and structure
dim(baseline_data)
glimpse(baseline_data)

# Confirm development-period range
range(baseline_data$year)

# Confirm county coverage
n_distinct(baseline_data$fips)

# Confirm candidate features contain no missing values
sum(is.na(baseline_data$lag1_yield))
sum(is.na(baseline_data$trailing_3yr_mean))

# ------------------------------------------------------------
# 2. Prepare baseline predictors
# ------------------------------------------------------------

baseline_data <- baseline_data %>%
  mutate(
    year_centered = year - 2000,
    fips = factor(fips)
  )

# ------------------------------------------------------------
# 3. Define rolling-origin validation years
# ------------------------------------------------------------

validation_years <- 2012:2021

validation_years

# ------------------------------------------------------------
# 4. Verify rolling-origin folds
# ------------------------------------------------------------

fold_summary <- map_dfr(
  validation_years,
  function(validation_year) {
    
    training_data <- baseline_data %>%
      filter(year < validation_year)
    
    validation_data <- baseline_data %>%
      filter(year == validation_year)
    
    tibble(
      validation_year = validation_year,
      training_start = min(training_data$year),
      training_end = max(training_data$year),
      training_observations = nrow(training_data),
      training_counties = n_distinct(training_data$fips),
      validation_observations = nrow(validation_data),
      validation_counties = n_distinct(validation_data$fips)
    )
  }
)

print(fold_summary, n = Inf)

# ------------------------------------------------------------
# 5. Fit candidate historical baseline models
#    using rolling-origin validation
# ------------------------------------------------------------

rolling_predictions <- map_dfr(
  validation_years,
  function(validation_year) {
    
    # Training data include only years before the
    # current validation year.
    training_data <- baseline_data %>%
      filter(year < validation_year)
    
    # Validation data include only the current year.
    validation_data <- baseline_data %>%
      filter(year == validation_year)
    
    # Model A:
    # County + time trend + previous-year yield
    model_lag1 <- lm(
      corn_yield ~ fips + year_centered + lag1_yield,
      data = training_data
    )
    
    # Model B:
    # County + time trend + flexible 3-year trailing mean
    model_trailing <- lm(
      corn_yield ~ fips + year_centered + trailing_3yr_mean,
      data = training_data
    )
    
    # Generate out-of-time predictions for both models
    bind_rows(
      
      validation_data %>%
        transmute(
          fips,
          county,
          year,
          actual_yield = corn_yield,
          model = "Lag-1 yield",
          predicted_yield = as.numeric(
            predict(
              model_lag1,
              newdata = validation_data
            )
          )
        ),
      
      validation_data %>%
        transmute(
          fips,
          county,
          year,
          actual_yield = corn_yield,
          model = "Flexible 3-year mean",
          predicted_yield = as.numeric(
            predict(
              model_trailing,
              newdata = validation_data
            )
          )
        )
    )
  }
)

# ------------------------------------------------------------
# 6. Verify rolling-origin predictions
# ------------------------------------------------------------

# Check dimensions
dim(rolling_predictions)

# Number of predictions from each model
rolling_predictions %>%
  count(model)

# Number of predictions by validation year and model
rolling_predictions %>%
  count(year, model) %>%
  print(n = Inf)

# Check for missing actual values or predictions
rolling_predictions %>%
  summarise(
    missing_actual = sum(is.na(actual_yield)),
    missing_predictions = sum(is.na(predicted_yield))
  )

# Preview predictions
rolling_predictions %>%
  arrange(year, fips, model) %>%
  print(n = 20)

# ------------------------------------------------------------
# 7. Calculate performance by validation year
# ------------------------------------------------------------

fold_metrics <- rolling_predictions %>%
  mutate(
    error = actual_yield - predicted_yield,
    squared_error = error^2,
    absolute_error = abs(error)
  ) %>%
  group_by(year, model) %>%
  summarise(
    observations = n(),
    
    # Root Mean Squared Error
    rmse = sqrt(
      mean(squared_error)
    ),
    
    # Mean Absolute Error
    mae = mean(
      absolute_error
    ),
    
    # Out-of-time R-squared
    r_squared =
      1 -
      sum(squared_error) /
      sum(
        (actual_yield - mean(actual_yield))^2
      ),
    
    .groups = "drop"
  )

print(
  fold_metrics,
  n = Inf
)

# ------------------------------------------------------------
# 8. Summarize performance across validation years
# ------------------------------------------------------------

validation_performance_summary <- fold_metrics %>%
  group_by(model) %>%
  summarise(
    validation_years = n(),
    
    mean_yearly_rmse = mean(rmse),
    median_yearly_rmse = median(rmse),
    
    mean_yearly_mae = mean(mae),
    median_yearly_mae = median(mae),
    
    mean_yearly_r_squared = mean(r_squared),
    
    .groups = "drop"
  )

validation_performance_summary

pooled_validation_metrics <- rolling_predictions %>%
  mutate(
    error = actual_yield - predicted_yield,
    squared_error = error^2,
    absolute_error = abs(error)
  ) %>%
  group_by(model) %>%
  summarise(
    observations = n(),
    
    pooled_rmse =
      sqrt(mean(squared_error)),
    
    pooled_mae =
      mean(absolute_error),
    
    pooled_r_squared =
      1 -
      sum(squared_error) /
      sum(
        (actual_yield - mean(actual_yield))^2
      ),
    
    .groups = "drop"
  )

pooled_validation_metrics

# ------------------------------------------------------------
# 9. Compare candidate performance within each validation year
# ------------------------------------------------------------

yearly_candidate_comparison <- fold_metrics %>%
  select(
    year,
    model,
    rmse,
    mae
  ) %>%
  pivot_wider(
    names_from = model,
    values_from = c(rmse, mae)
  ) %>%
  mutate(
    # Positive difference means lag-1 had lower error.
    rmse_improvement_lag1 =
      `rmse_Flexible 3-year mean` -
      `rmse_Lag-1 yield`,
    
    mae_improvement_lag1 =
      `mae_Flexible 3-year mean` -
      `mae_Lag-1 yield`,
    
    rmse_winner = case_when(
      rmse_improvement_lag1 > 0 ~ "Lag-1 yield",
      rmse_improvement_lag1 < 0 ~ "Flexible 3-year mean",
      TRUE ~ "Tie"
    ),
    
    mae_winner = case_when(
      mae_improvement_lag1 > 0 ~ "Lag-1 yield",
      mae_improvement_lag1 < 0 ~ "Flexible 3-year mean",
      TRUE ~ "Tie"
    )
  )

print(
  yearly_candidate_comparison,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 10. Summarize consistency across validation years
# ------------------------------------------------------------

candidate_win_summary <- tibble(
  metric = c("RMSE", "MAE"),
  
  lag1_wins = c(
    sum(
      yearly_candidate_comparison$rmse_winner ==
        "Lag-1 yield"
    ),
    sum(
      yearly_candidate_comparison$mae_winner ==
        "Lag-1 yield"
    )
  ),
  
  trailing_mean_wins = c(
    sum(
      yearly_candidate_comparison$rmse_winner ==
        "Flexible 3-year mean"
    ),
    sum(
      yearly_candidate_comparison$mae_winner ==
        "Flexible 3-year mean"
    )
  ),
  
  ties = c(
    sum(yearly_candidate_comparison$rmse_winner == "Tie"),
    sum(yearly_candidate_comparison$mae_winner == "Tie")
  )
)

candidate_win_summary

# ------------------------------------------------------------
# 11. Summarize paired yearly differences
# ------------------------------------------------------------

candidate_difference_summary <- yearly_candidate_comparison %>%
  summarise(
    mean_rmse_improvement_lag1 =
      mean(rmse_improvement_lag1),
    
    median_rmse_improvement_lag1 =
      median(rmse_improvement_lag1),
    
    mean_mae_improvement_lag1 =
      mean(mae_improvement_lag1),
    
    median_mae_improvement_lag1 =
      median(mae_improvement_lag1)
  )

candidate_difference_summary

# ------------------------------------------------------------
# 12. Save historical baseline comparison results
# ------------------------------------------------------------

dir.create(
  "output/historical_baseline_comparison",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  fold_summary,
  "output/historical_baseline_comparison/rolling_fold_summary.csv"
)

write_csv(
  fold_metrics,
  "output/historical_baseline_comparison/yearly_model_metrics.csv"
)

write_csv(
  validation_performance_summary,
  "output/historical_baseline_comparison/validation_performance_summary.csv"
)

write_csv(
  pooled_validation_metrics,
  "output/historical_baseline_comparison/pooled_validation_metrics.csv"
)

write_csv(
  yearly_candidate_comparison,
  "output/historical_baseline_comparison/yearly_candidate_comparison.csv"
)

write_csv(
  candidate_win_summary,
  "output/historical_baseline_comparison/candidate_win_summary.csv"
)

write_csv(
  candidate_difference_summary,
  "output/historical_baseline_comparison/candidate_difference_summary.csv"
)

write_csv(
  rolling_predictions,
  "output/historical_baseline_comparison/rolling_predictions.csv"
)

# ------------------------------------------------------------
# 13. Plot yearly RMSE for candidate history features
# ------------------------------------------------------------

rmse_comparison_plot <- fold_metrics %>%
  ggplot(
    aes(
      x = year,
      y = rmse,
      group = model,
      linetype = model
    )
  ) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  scale_x_continuous(
    breaks = 2012:2021
  ) +
  labs(
    title = "Rolling-Origin Validation of Historical Yield Features",
    subtitle = "Indiana county-level corn yield, 2012–2021 validation years",
    x = "Validation year",
    y = "RMSE (bu/acre)",
    linetype = "Recent-yield feature"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom"
  )

rmse_comparison_plot

ggsave(
  "output/historical_baseline_comparison/yearly_rmse_comparison.png",
  plot = rmse_comparison_plot,
  width = 9,
  height = 6,
  dpi = 300
)

