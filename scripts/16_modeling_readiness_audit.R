# ============================================================
# Modeling Readiness Audit
# Senior Thesis
#
# Purpose:
# Verify that the finalized development modeling dataset and
# revised predictor groups are ready for formal model
# development.
#
# This audit:
# 1. Defines the finalized predictor groups
# 2. Verifies complete and identical observations
# 3. Checks remaining predictor correlations
# 4. Audits 2012-2021 rolling-origin folds
# 5. Checks for unseen counties and zero-variance predictors
#
# E01 hot-day count is excluded from the primary predictor
# set following the development-period sensitivity analysis.
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

# Holdout safeguard
stopifnot(
  max(modeling_development$year) <= 2021
)

stopifnot(
  !any(modeling_development$year >= 2022)
)

# ------------------------------------------------------------
# 2. Define finalized predictor groups
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

retained_extreme_predictors <- c(
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
  retained_extreme_predictors
)

model_group_1
model_group_2
model_group_3

# ------------------------------------------------------------
# 3. Verify required variables
# ------------------------------------------------------------

all_required_variables <- unique(
  c(
    "corn_yield",
    "year",
    model_group_3
  )
)

missing_required_variables <- setdiff(
  all_required_variables,
  names(modeling_development)
)

missing_required_variables

# Confirm that E01 is NOT in the finalized Group 3
"e01_hot_days_30" %in% model_group_3

# E01 should remain in the underlying dataset though
"e01_hot_days_30" %in% names(modeling_development)

# ------------------------------------------------------------
# 4. Verify complete common modeling sample
# ------------------------------------------------------------

modeling_readiness_missingness <- modeling_development %>%
  summarise(
    across(
      all_of(
        c(
          "corn_yield",
          model_group_3
        )
      ),
      ~ sum(is.na(.x))
    )
  )

modeling_readiness_missingness

complete_modeling_rows <- modeling_development %>%
  filter(
    if_all(
      all_of(
        c(
          "corn_yield",
          model_group_3
        )
      ),
      ~ !is.na(.x)
    )
  )

nrow(complete_modeling_rows)

identical(
  nrow(complete_modeling_rows),
  nrow(modeling_development)
)

# ------------------------------------------------------------
# 5. Audit correlations among retained numeric predictors
# ------------------------------------------------------------

retained_numeric_predictors <- c(
  "year_centered",
  "lag1_yield",
  conventional_weather_predictors,
  retained_extreme_predictors
)

retained_correlation_matrix <- modeling_development %>%
  select(
    all_of(retained_numeric_predictors)
  ) %>%
  cor(
    use = "complete.obs"
  )

round(
  retained_correlation_matrix,
  3
)

high_correlation_pairs <- as.data.frame(
  as.table(retained_correlation_matrix)
) %>%
  as_tibble() %>%
  rename(
    predictor_1 = Var1,
    predictor_2 = Var2,
    correlation = Freq
  ) %>%
  filter(
    predictor_1 != predictor_2,
    abs(correlation) >= 0.80
  ) %>%
  mutate(
    pair = map2_chr(
      predictor_1,
      predictor_2,
      ~ paste(sort(c(.x, .y)), collapse = " | ")
    )
  ) %>%
  distinct(
    pair,
    .keep_all = TRUE
  ) %>%
  select(
    predictor_1,
    predictor_2,
    correlation
  ) %>%
  arrange(
    desc(abs(correlation))
  )

high_correlation_pairs

# ------------------------------------------------------------
# 6. Audit finalized rolling-origin folds
# ------------------------------------------------------------

validation_years <- 2012:2021

rolling_fold_readiness <- map_dfr(
  validation_years,
  function(validation_year) {
    
    training_data <- modeling_development %>%
      filter(
        year < validation_year
      )
    
    validation_data <- modeling_development %>%
      filter(
        year == validation_year
      )
    
    unseen_fips <- setdiff(
      unique(validation_data$fips),
      unique(training_data$fips)
    )
    
    tibble(
      validation_year = validation_year,
      training_start = min(training_data$year),
      training_end = max(training_data$year),
      training_observations = nrow(training_data),
      training_counties = n_distinct(training_data$fips),
      validation_observations = nrow(validation_data),
      validation_counties = n_distinct(validation_data$fips),
      unseen_validation_counties = length(unseen_fips)
    )
  }
)

print(
  rolling_fold_readiness,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 7. Check predictor variation within each training fold
# ------------------------------------------------------------

numeric_model_predictors <- c(
  "year_centered",
  "lag1_yield",
  conventional_weather_predictors,
  retained_extreme_predictors
)

training_variation_audit <- map_dfr(
  validation_years,
  function(validation_year) {
    
    training_data <- modeling_development %>%
      filter(
        year < validation_year
      )
    
    map_dfr(
      numeric_model_predictors,
      function(predictor) {
        
        values <- training_data[[predictor]]
        
        tibble(
          validation_year = validation_year,
          predictor = predictor,
          unique_values = n_distinct(values),
          standard_deviation = sd(values),
          zero_variance =
            n_distinct(values) <= 1
        )
      }
    )
  }
)

training_variation_audit %>%
  filter(
    zero_variance
  )

# ------------------------------------------------------------
# 8. Define finalized linear-model formulas
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
# 9. Check model fit and prediction readiness
# ------------------------------------------------------------

check_model_readiness <- function(
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
      
      predictions <- predict(
        model_fit,
        newdata = validation_data
      )
      
      coefficients <- coef(model_fit)
      
      tibble(
        model_group = model_group,
        validation_year = validation_year,
        training_observations = nrow(training_data),
        validation_observations = nrow(validation_data),
        
        model_rank = model_fit$rank,
        
        coefficient_count = length(
          coefficients
        ),
        
        aliased_coefficients = sum(
          is.na(coefficients)
        ),
        
        missing_predictions = sum(
          is.na(predictions)
        ),
        
        infinite_predictions = sum(
          is.infinite(predictions)
        )
      )
    }
  )
}

# ------------------------------------------------------------
# 10. Audit all predictor groups across rolling folds
# ------------------------------------------------------------

readiness_group_1 <- check_model_readiness(
  formula_group_1,
  "Group 1 - Historical baseline",
  modeling_development
)

readiness_group_2 <- check_model_readiness(
  formula_group_2,
  "Group 2 - Historical + conventional weather",
  modeling_development
)

readiness_group_3 <- check_model_readiness(
  formula_group_3,
  "Group 3 - Historical + conventional + extremes",
  modeling_development
)

model_fit_readiness <- bind_rows(
  readiness_group_1,
  readiness_group_2,
  readiness_group_3
)

print(
  model_fit_readiness,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 11. Identify any model-readiness problems
# ------------------------------------------------------------

model_fit_problems <- model_fit_readiness %>%
  filter(
    aliased_coefficients > 0 |
      missing_predictions > 0 |
      infinite_predictions > 0
  )

model_fit_problems

model_readiness_summary <- model_fit_readiness %>%
  group_by(
    model_group
  ) %>%
  summarise(
    folds_checked = n(),
    folds_with_aliased_coefficients =
      sum(aliased_coefficients > 0),
    
    total_aliased_coefficients =
      sum(aliased_coefficients),
    
    folds_with_missing_predictions =
      sum(missing_predictions > 0),
    
    total_missing_predictions =
      sum(missing_predictions),
    
    folds_with_infinite_predictions =
      sum(infinite_predictions > 0),
    
    .groups = "drop"
  )

model_readiness_summary

# ------------------------------------------------------------
# 12. Save modeling-readiness outputs
# ------------------------------------------------------------

dir.create(
  "output/modeling_readiness",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  as.data.frame(
    retained_correlation_matrix
  ) %>%
    rownames_to_column(
      "predictor"
    ),
  "output/modeling_readiness/retained_predictor_correlation_matrix.csv"
)

write_csv(
  high_correlation_pairs,
  "output/modeling_readiness/high_correlation_pairs.csv"
)

write_csv(
  rolling_fold_readiness,
  "output/modeling_readiness/rolling_fold_readiness.csv"
)

write_csv(
  training_variation_audit,
  "output/modeling_readiness/training_variation_audit.csv"
)

write_csv(
  model_fit_readiness,
  "output/modeling_readiness/model_fit_readiness.csv"
)

write_csv(
  model_readiness_summary,
  "output/modeling_readiness/model_readiness_summary.csv"
)

# ------------------------------------------------------------
# 13. Document modeling-readiness decision
# ------------------------------------------------------------

modeling_readiness_decision <- tibble(
  development_observations = nrow(modeling_development),
  development_counties = n_distinct(modeling_development$fips),
  validation_years = "2012-2021",
  high_correlation_pairs_ge_080 = nrow(high_correlation_pairs),
  folds_with_unseen_counties =
    sum(rolling_fold_readiness$unseen_validation_counties > 0),
  zero_variance_fold_predictors =
    sum(training_variation_audit$zero_variance),
  model_fit_problems =
    nrow(model_fit_problems),
  readiness_status = "Ready for formal model development"
)

modeling_readiness_decision

write_csv(
  modeling_readiness_decision,
  "output/modeling_readiness/modeling_readiness_decision.csv"
)
