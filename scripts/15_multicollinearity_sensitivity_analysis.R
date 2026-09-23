# ============================================================
# Multicollinearity Sensitivity Analysis
# Senior Thesis
#
# Purpose:
# Evaluate the strong relationship between July mean
# temperature (W03) and July hot-day count (E01) identified
# during the development-period weather-feature audit.
#
# This analysis responds to advisor feedback recommending
# comparison of model performance with and without one of
# these highly correlated predictors.
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

# Confirm that no holdout years are present
stopifnot(
  max(modeling_development$year) <= 2021
)

stopifnot(
  !any(modeling_development$year >= 2022)
)

# ------------------------------------------------------------
# 2. Recheck W03/E01 relationship
# ------------------------------------------------------------

w03_e01_correlation <- cor(
  modeling_development$w03_repro_tavg,
  modeling_development$e01_hot_days_30,
  use = "complete.obs"
)

w03_e01_correlation

w03_e01_summary <- modeling_development %>%
  summarise(
    observations = n(),
    w03_mean = mean(w03_repro_tavg),
    w03_sd = sd(w03_repro_tavg),
    e01_mean = mean(e01_hot_days_30),
    e01_sd = sd(e01_hot_days_30),
    correlation = cor(
      w03_repro_tavg,
      e01_hot_days_30
    )
  )

w03_e01_summary

w03_e01_plot <- modeling_development %>%
  ggplot(
    aes(
      x = w03_repro_tavg,
      y = e01_hot_days_30
    )
  ) +
  geom_point(
    alpha = 0.4
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "July Mean Temperature vs. July Hot-Day Count",
    subtitle = "Development modeling sample, 2001-2021",
    x = "July Mean Temperature (°C)",
    y = "July Days with Tmax > 30°C"
  ) +
  theme_minimal()

w03_e01_plot

# ------------------------------------------------------------
# 3. Multicollinearity diagnostics
# ------------------------------------------------------------

w03_auxiliary_model <- lm(
  w03_repro_tavg ~
    factor(fips) +
    year_centered +
    lag1_yield +
    w01_early_tavg +
    w02_early_prcp +
    w04_repro_prcp +
    w05_grainfill_tavg +
    w06_grainfill_prcp +
    e01_hot_days_30 +
    e02_heat_above_35 +
    e03_longest_dry_spell +
    e04_max_5day_prcp,
  data = modeling_development
)

w03_r2 <- summary(
  w03_auxiliary_model
)$r.squared

w03_vif <- 1 / (
  1 - w03_r2
)

e01_auxiliary_model <- lm(
  e01_hot_days_30 ~
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
    e04_max_5day_prcp,
  data = modeling_development
)

e01_r2 <- summary(
  e01_auxiliary_model
)$r.squared

e01_vif <- 1 / (
  1 - e01_r2
)

multicollinearity_diagnostics <- tibble(
  predictor = c(
    "W03 July mean temperature",
    "E01 July hot-day count"
  ),
  auxiliary_r_squared = c(
    w03_r2,
    e01_r2
  ),
  vif = c(
    w03_vif,
    e01_vif
  )
)

multicollinearity_diagnostics

# ------------------------------------------------------------
# 4. Define sensitivity-analysis model formulas
# ------------------------------------------------------------

# Model A:
# Full planned predictor set containing both W03 and E01
formula_both <- corn_yield ~
  factor(fips) +
  year_centered +
  lag1_yield +
  w01_early_tavg +
  w02_early_prcp +
  w03_repro_tavg +
  w04_repro_prcp +
  w05_grainfill_tavg +
  w06_grainfill_prcp +
  e01_hot_days_30 +
  e02_heat_above_35 +
  e03_longest_dry_spell +
  e04_max_5day_prcp

# Model B:
# Retain W03 July mean temperature and remove E01 hot-day count
formula_without_e01 <- corn_yield ~
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

# Model C:
# Retain E01 hot-day count and remove W03 July mean temperature
formula_without_w03 <- corn_yield ~
  factor(fips) +
  year_centered +
  lag1_yield +
  w01_early_tavg +
  w02_early_prcp +
  w04_repro_prcp +
  w05_grainfill_tavg +
  w06_grainfill_prcp +
  e01_hot_days_30 +
  e02_heat_above_35 +
  e03_longest_dry_spell +
  e04_max_5day_prcp

# ------------------------------------------------------------
# 5. Create rolling-origin evaluation function
# ------------------------------------------------------------

evaluate_lm_variant <- function(
    model_formula,
    model_name,
    data,
    validation_years = 2012:2021
) {
  
  map_dfr(
    validation_years,
    function(validation_year) {
      
      training_data <- data %>%
        filter(year < validation_year)
      
      validation_data <- data %>%
        filter(year == validation_year)
      
      model_fit <- lm(
        model_formula,
        data = training_data
      )
      
      predictions <- predict(
        model_fit,
        newdata = validation_data
      )
      
      tibble(
        model = model_name,
        validation_year = validation_year,
        training_observations = nrow(training_data),
        validation_observations = nrow(validation_data),
        rmse = sqrt(
          mean(
            (validation_data$corn_yield - predictions)^2
          )
        ),
        mae = mean(
          abs(
            validation_data$corn_yield - predictions
          )
        )
      )
    }
  )
}

# ------------------------------------------------------------
# 6. Run rolling-origin sensitivity comparison
# ------------------------------------------------------------

results_both <- evaluate_lm_variant(
  formula_both,
  "Both W03 and E01",
  modeling_development
)

results_without_e01 <- evaluate_lm_variant(
  formula_without_e01,
  "W03 only",
  modeling_development
)

results_without_w03 <- evaluate_lm_variant(
  formula_without_w03,
  "E01 only",
  modeling_development
)

sensitivity_results <- bind_rows(
  results_both,
  results_without_e01,
  results_without_w03
)

print(
  sensitivity_results,
  n = Inf
)

# ------------------------------------------------------------
# 7. Verify identical rolling-origin folds
# ------------------------------------------------------------

fold_comparison <- sensitivity_results %>%
  select(
    model,
    validation_year,
    training_observations,
    validation_observations
  ) %>%
  pivot_wider(
    names_from = model,
    values_from = c(
      training_observations,
      validation_observations
    )
  )

print(
  fold_comparison,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 8. Summarize rolling-origin performance
# ------------------------------------------------------------

sensitivity_summary <- sensitivity_results %>%
  group_by(model) %>%
  summarise(
    mean_rmse = mean(rmse),
    median_rmse = median(rmse),
    mean_mae = mean(mae),
    median_mae = median(mae),
    .groups = "drop"
  ) %>%
  arrange(mean_rmse)

sensitivity_summary

rmse_yearly_wins <- sensitivity_results %>%
  group_by(validation_year) %>%
  filter(
    rmse == min(rmse)
  ) %>%
  ungroup() %>%
  count(
    model,
    name = "years_lowest_rmse"
  )

mae_yearly_wins <- sensitivity_results %>%
  group_by(validation_year) %>%
  filter(
    mae == min(mae)
  ) %>%
  ungroup() %>%
  count(
    model,
    name = "years_lowest_mae"
  )

rmse_yearly_wins
mae_yearly_wins

yearly_comparison <- sensitivity_results %>%
  select(
    validation_year,
    model,
    rmse,
    mae
  ) %>%
  pivot_wider(
    names_from = model,
    values_from = c(
      rmse,
      mae
    )
  )

print(
  yearly_comparison,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 9. Document sensitivity-analysis decision
# ------------------------------------------------------------

sensitivity_decision <- tibble(
  comparison = "W03 / E01 multicollinearity sensitivity analysis",
  development_period = "2001-2021",
  validation_period = "2012-2021",
  w03_e01_correlation = w03_e01_correlation,
  w03_vif = w03_vif,
  e01_vif = e01_vif,
  selected_specification = "Retain W03; exclude E01",
  rationale = paste(
    "W03 and E01 were strongly correlated.",
    "The W03-only specification produced the lowest mean",
    "rolling-origin RMSE and MAE and performed best in",
    "most validation years. E01 was excluded before",
    "evaluation on the 2022-2025 final holdout."
  )
)

sensitivity_decision

# ------------------------------------------------------------
# 10. Save multicollinearity sensitivity outputs
# ------------------------------------------------------------

dir.create(
  "output/multicollinearity_analysis",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  multicollinearity_diagnostics,
  "output/multicollinearity_analysis/multicollinearity_diagnostics.csv"
)

write_csv(
  sensitivity_results,
  "output/multicollinearity_analysis/rolling_sensitivity_results.csv"
)

write_csv(
  sensitivity_summary,
  "output/multicollinearity_analysis/sensitivity_summary.csv"
)

write_csv(
  yearly_comparison,
  "output/multicollinearity_analysis/yearly_comparison.csv"
)

write_csv(
  sensitivity_decision,
  "output/multicollinearity_analysis/sensitivity_decision.csv"
)

ggsave(
  "output/multicollinearity_analysis/w03_e01_relationship.png",
  plot = w03_e01_plot,
  width = 8,
  height = 6,
  dpi = 300
)
