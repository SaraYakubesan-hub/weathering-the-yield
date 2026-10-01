# ============================================================
# Random Forest Predictor-Group Comparison
# Senior Thesis
#
# Purpose:
# Compare the three finalized predictor groups using Random
# Forest models and expanding-window validation.
#
# Predictor groups:
# 1. Historical baseline
# 2. Historical baseline + conventional weather
# 3. Historical baseline + conventional weather +
#    retained extreme-weather indicators
#
# Hyperparameter tuning will be performed using only
# information available within each training period.
#
# Only 2001-2021 development data are used.
# The 2022-2025 final holdout is not loaded or used.
# ============================================================

library(tidyverse)
library(ranger)

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
# 2. Define finalized predictor groups
# ------------------------------------------------------------

rf_predictor_groups <- list(
  
  group_1 = c(
    "fips",
    "year_centered",
    "lag1_yield"
  ),
  
  group_2 = c(
    "fips",
    "year_centered",
    "lag1_yield",
    "w01_early_tavg",
    "w02_early_prcp",
    "w03_repro_tavg",
    "w04_repro_prcp",
    "w05_grainfill_tavg",
    "w06_grainfill_prcp"
  ),
  
  group_3 = c(
    "fips",
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
)

rf_predictor_groups

length(rf_predictor_groups$group_1)
length(rf_predictor_groups$group_2)
length(rf_predictor_groups$group_3)

# Confirm every planned predictor exists
all_rf_predictors <- unique(
  unlist(rf_predictor_groups)
)

stopifnot(
  all(
    all_rf_predictors %in%
      names(modeling_development)
  )
)

# Confirm E01 was not accidentally reintroduced
stopifnot(
  !any(
    grepl(
      "^e01",
      rf_predictor_groups$group_3,
      ignore.case = TRUE
    )
  )
)

# ------------------------------------------------------------
# 3. Function to prepare one outer validation fold
# ------------------------------------------------------------

prepare_rf_fold <- function(
    data,
    validation_year
) {
  
  training_data <- data %>%
    filter(
      year < validation_year
    )
  
  validation_data <- data %>%
    filter(
      year == validation_year
    )
  
  # Define county factor levels from training data only
  training_data$fips <- factor(
    training_data$fips
  )
  
  validation_data$fips <- factor(
    validation_data$fips,
    levels = levels(training_data$fips)
  )
  
  # Stop if validation contains a county not present in training
  stopifnot(
    !any(is.na(validation_data$fips))
  )
  
  list(
    training = training_data,
    validation = validation_data
  )
}

# ------------------------------------------------------------
# 4. Smoke test:
# Group 3 predicting the 2012 validation year
# ------------------------------------------------------------

smoke_fold <- prepare_rf_fold(
  modeling_development,
  validation_year = 2012
)

nrow(smoke_fold$training)
nrow(smoke_fold$validation)

nlevels(smoke_fold$training$fips)

sum(
  is.na(smoke_fold$validation$fips)
)

rf_formula_group_3 <- reformulate(
  rf_predictor_groups$group_3,
  response = "corn_yield"
)

rf_formula_group_3

# Starting mtry for smoke test
smoke_mtry <- max(
  1,
  floor(
    sqrt(
      length(
        rf_predictor_groups$group_3
      )
    )
  )
)

smoke_mtry

set.seed(492)

rf_smoke_fit <- ranger(
  formula = rf_formula_group_3,
  
  data = smoke_fold$training %>%
    select(
      corn_yield,
      all_of(
        rf_predictor_groups$group_3
      )
    ),
  
  num.trees = 500,
  
  mtry = smoke_mtry,
  
  min.node.size = 5,
  
  respect.unordered.factors = "order",
  
  seed = 492
)

rf_smoke_predictions <- predict(
  rf_smoke_fit,
  
  data = smoke_fold$validation %>%
    select(
      all_of(
        rf_predictor_groups$group_3
      )
    )
)$predictions

length(rf_smoke_predictions)

sum(
  is.na(rf_smoke_predictions)
)

summary(rf_smoke_predictions)

# ------------------------------------------------------------
# 5. Calculate smoke-test performance
# ------------------------------------------------------------

rf_smoke_results <- smoke_fold$validation %>%
  transmute(
    validation_year = year,
    fips = as.character(fips),
    county = county,
    actual_yield = corn_yield,
    predicted_yield = rf_smoke_predictions,
    residual =
      actual_yield - predicted_yield,
    absolute_error =
      abs(residual),
    squared_error =
      residual^2
  )

rf_smoke_metrics <- rf_smoke_results %>%
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
        (
          actual_yield -
            mean(actual_yield)
        )^2
      )
  )

rf_smoke_metrics

# ------------------------------------------------------------
# 6. Create Random Forest tuning grid
# ------------------------------------------------------------

create_rf_tuning_grid <- function(
    predictors
) {
  
  p <- length(predictors)
  
  mtry_values <- unique(
    pmax(
      1,
      pmin(
        p,
        c(
          1,
          floor(sqrt(p)),
          ceiling(p / 3),
          ceiling(p / 2),
          p
        )
      )
    )
  )
  
  expand_grid(
    mtry = mtry_values,
    min.node.size = c(
      5,
      10,
      20
    )
  )
}

rf_grid_group_1 <- create_rf_tuning_grid(
  rf_predictor_groups$group_1
)

rf_grid_group_2 <- create_rf_tuning_grid(
  rf_predictor_groups$group_2
)

rf_grid_group_3 <- create_rf_tuning_grid(
  rf_predictor_groups$group_3
)

rf_grid_group_1
rf_grid_group_2
rf_grid_group_3

# ------------------------------------------------------------
# 7. Prepare inner Random Forest tuning folds
# ------------------------------------------------------------

prepare_rf_inner_fold <- function(
    data,
    validation_year
) {
  
  # Create chronological training and validation sets
  training_data <- data %>%
    filter(
      year < validation_year
    )
  
  validation_data <- data %>%
    filter(
      year == validation_year
    )
  
  # Convert FIPS to character before comparing county sets
  training_data$fips <-
    as.character(training_data$fips)
  
  validation_data$fips <-
    as.character(validation_data$fips)
  
  # Counties represented in training
  training_counties <- unique(
    training_data$fips
  )
  
  # Identify validation counties not yet represented
  unseen_fips_values <- setdiff(
    unique(validation_data$fips),
    training_counties
  )
  
  # Count validation observations affected
  unseen_observations <- sum(
    !validation_data$fips %in%
      training_counties
  )
  
  # Keep only validation counties already represented
  # in the corresponding training period
  validation_data <- validation_data %>%
    filter(
      fips %in% training_counties
    )
  
  # Define county factor levels using training data only
  training_data$fips <- factor(
    training_data$fips
  )
  
  validation_data$fips <- factor(
    validation_data$fips,
    levels = levels(training_data$fips)
  )
  
  # Safeguards
  stopifnot(
    !any(is.na(validation_data$fips))
  )
  
  stopifnot(
    nrow(validation_data) > 0
  )
  
  list(
    training = training_data,
    validation = validation_data,
    unseen_fips = unseen_fips_values,
    unseen_observations =
      unseen_observations
  )
}

# ------------------------------------------------------------
# 8. Tune Random Forest within an outer training period
# ------------------------------------------------------------

tune_rf_model <- function(
    outer_training_data,
    predictors,
    outer_validation_year,
    tuning_trees = 300
) {
  
  model_formula <- reformulate(
    predictors,
    response = "corn_yield"
  )
  
  tuning_grid <- create_rf_tuning_grid(
    predictors
  )
  
  # Use the five most recent years available
  # inside the outer training period
  inner_validation_years <- seq(
    from = outer_validation_year - 5,
    to = outer_validation_year - 1
  )
  
  tuning_results <- map_dfr(
    seq_len(nrow(tuning_grid)),
    function(grid_row) {
      
      current_mtry <-
        tuning_grid$mtry[grid_row]
      
      current_min_node <-
        tuning_grid$min.node.size[grid_row]
      
      inner_results <- map_dfr(
        inner_validation_years,
        function(inner_validation_year) {
          
          # Prepare inner tuning fold
          inner_fold <- prepare_rf_inner_fold(
            outer_training_data,
            validation_year =
              inner_validation_year
          )
          
          # Reproducible seed unique to outer fold,
          # tuning combination, and inner year
          current_seed <-
            492 +
            (outer_validation_year - 2000) * 1000 +
            grid_row * 10 +
            (inner_validation_year - 2000)
          
          # Fit Random Forest
          inner_fit <- ranger(
            formula = model_formula,
            
            data =
              inner_fold$training %>%
              select(
                corn_yield,
                all_of(predictors)
              ),
            
            num.trees =
              tuning_trees,
            
            mtry =
              current_mtry,
            
            min.node.size =
              current_min_node,
            
            respect.unordered.factors =
              "order",
            
            seed =
              current_seed
          )
          
          # Generate inner validation predictions
          inner_predictions <- predict(
            inner_fit,
            
            data =
              inner_fold$validation %>%
              select(
                all_of(predictors)
              )
          )$predictions
          
          actual_values <-
            inner_fold$validation$corn_yield
          
          # Calculate inner-fold metrics
          tibble(
            inner_validation_year =
              inner_validation_year,
            
            observations =
              length(actual_values),
            
            unseen_observations_excluded =
              inner_fold$unseen_observations,
            
            rmse =
              sqrt(
                mean(
                  (
                    actual_values -
                      inner_predictions
                  )^2
                )
              ),
            
            mae =
              mean(
                abs(
                  actual_values -
                    inner_predictions
                )
              )
          )
        }
      )
      
      # Summarize this hyperparameter combination
      tibble(
        mtry =
          current_mtry,
        
        min.node.size =
          current_min_node,
        
        mean_inner_rmse =
          mean(
            inner_results$rmse
          ),
        
        median_inner_rmse =
          median(
            inner_results$rmse
          ),
        
        mean_inner_mae =
          mean(
            inner_results$mae
          ),
        
        median_inner_mae =
          median(
            inner_results$mae
          ),
        
        total_inner_observations =
          sum(
            inner_results$observations
          ),
        
        unseen_observations_excluded =
          sum(
            inner_results$
              unseen_observations_excluded
          )
      )
    }
  ) %>%
    
    # Mean inner RMSE is the primary
    # hyperparameter selection criterion
    arrange(
      mean_inner_rmse,
      mean_inner_mae,
      mtry,
      min.node.size
    )
  
  tuning_results
}

# ------------------------------------------------------------
# Diagnose unseen counties in 2012 inner tuning folds
# ------------------------------------------------------------

inner_county_audit_2012 <- map_dfr(
  2007:2011,
  function(inner_validation_year) {
    
    # Training data include only years before
    # the inner validation year
    inner_training <- smoke_fold$training %>%
      filter(
        year < inner_validation_year
      )
    
    # Validation data contain only the
    # current inner validation year
    inner_validation <- smoke_fold$training %>%
      filter(
        year == inner_validation_year
      )
    
    # Extract unique county FIPS codes
    training_counties <- inner_training %>%
      pull(fips) %>%
      as.character() %>%
      unique()
    
    validation_counties <- inner_validation %>%
      pull(fips) %>%
      as.character() %>%
      unique()
    
    # Identify validation counties that do not yet
    # appear in the corresponding training period
    unseen_fips_values <- setdiff(
      validation_counties,
      training_counties
    )
    
    # Summarize this inner fold
    tibble(
      inner_validation_year =
        inner_validation_year,
      
      training_counties =
        length(training_counties),
      
      validation_counties =
        length(validation_counties),
      
      unseen_counties =
        length(unseen_fips_values),
      
      unseen_fips =
        if (
          length(unseen_fips_values) == 0
        ) {
          NA_character_
        } else {
          paste(
            unseen_fips_values,
            collapse = ", "
          )
        }
    )
  }
)

print(
  inner_county_audit_2012,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 9. Test nested tuning:
# Group 3 for the 2012 outer fold
# ------------------------------------------------------------

set.seed(492)

rf_tuning_test_2012 <- tune_rf_model(
  outer_training_data =
    smoke_fold$training,
  
  predictors =
    rf_predictor_groups$group_3,
  
  outer_validation_year = 2012,
  
  tuning_trees = 300
)

print(
  rf_tuning_test_2012,
  n = Inf,
  width = Inf
)

best_rf_parameters_2012 <-
  rf_tuning_test_2012 %>%
  slice(1)

best_rf_parameters_2012

# ------------------------------------------------------------
# 10. Fit tuned Group 3 Random Forest for 2012
# ------------------------------------------------------------

set.seed(492)

rf_tuned_fit_2012 <- ranger(
  formula = rf_formula_group_3,
  
  data = smoke_fold$training %>%
    select(
      corn_yield,
      all_of(
        rf_predictor_groups$group_3
      )
    ),
  
  num.trees = 500,
  
  mtry =
    best_rf_parameters_2012$mtry,
  
  min.node.size =
    best_rf_parameters_2012$min.node.size,
  
  respect.unordered.factors =
    "order",
  
  seed = 492
)

rf_tuned_predictions_2012 <- predict(
  rf_tuned_fit_2012,
  
  data = smoke_fold$validation %>%
    select(
      all_of(
        rf_predictor_groups$group_3
      )
    )
)$predictions

length(
  rf_tuned_predictions_2012
)

sum(
  is.na(
    rf_tuned_predictions_2012
  )
)

summary(
  rf_tuned_predictions_2012
)

rf_tuned_results_2012 <-
  smoke_fold$validation %>%
  transmute(
    validation_year = year,
    
    fips =
      as.character(fips),
    
    county = county,
    
    actual_yield =
      corn_yield,
    
    predicted_yield =
      rf_tuned_predictions_2012,
    
    residual =
      actual_yield -
      predicted_yield,
    
    absolute_error =
      abs(residual),
    
    squared_error =
      residual^2
  )

rf_tuned_metrics_2012 <-
  rf_tuned_results_2012 %>%
  summarise(
    observations =
      n(),
    
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
            mean(actual_yield)
        )^2
      )
  )

rf_tuned_metrics_2012

# Confirm tuned model reproduces smoke-test model
# when the selected parameters are identical

all.equal(
  rf_tuned_predictions_2012,
  rf_smoke_predictions
)

# ------------------------------------------------------------
# 11. Fit and evaluate one tuned outer Random Forest fold
# ------------------------------------------------------------

evaluate_rf_outer_fold <- function(
    data,
    predictors,
    model_group,
    validation_year,
    tuning_trees = 300,
    final_trees = 500
) {
  
  # ----------------------------------------------------------
  # Prepare outer training and validation data
  # ----------------------------------------------------------
  
  outer_fold <- prepare_rf_fold(
    data,
    validation_year =
      validation_year
  )
  
  # ----------------------------------------------------------
  # Tune hyperparameters using only the outer training period
  # ----------------------------------------------------------
  
  tuning_results <- tune_rf_model(
    outer_training_data =
      outer_fold$training,
    
    predictors =
      predictors,
    
    outer_validation_year =
      validation_year,
    
    tuning_trees =
      tuning_trees
  )
  
  best_parameters <- tuning_results %>%
    slice(1)
  
  # ----------------------------------------------------------
  # Create model formula
  # ----------------------------------------------------------
  
  model_formula <- reformulate(
    predictors,
    response = "corn_yield"
  )
  
  # ----------------------------------------------------------
  # Fit final model using all outer-training observations
  # ----------------------------------------------------------
  
  final_seed <-
    492 +
    (validation_year - 2000) * 100
  
  final_fit <- ranger(
    formula =
      model_formula,
    
    data =
      outer_fold$training %>%
      select(
        corn_yield,
        all_of(predictors)
      ),
    
    num.trees =
      final_trees,
    
    mtry =
      best_parameters$mtry,
    
    min.node.size =
      best_parameters$min.node.size,
    
    respect.unordered.factors =
      "order",
    
    seed =
      final_seed
  )
  
  # ----------------------------------------------------------
  # Predict outer validation year
  # ----------------------------------------------------------
  
  final_predictions <- predict(
    final_fit,
    
    data =
      outer_fold$validation %>%
      select(
        all_of(predictors)
      )
  )$predictions
  
  # ----------------------------------------------------------
  # Safeguards
  # ----------------------------------------------------------
  
  stopifnot(
    length(final_predictions) ==
      nrow(outer_fold$validation)
  )
  
  stopifnot(
    !any(is.na(final_predictions))
  )
  
  # ----------------------------------------------------------
  # Save county-year predictions
  # ----------------------------------------------------------
  
  prediction_results <-
    outer_fold$validation %>%
    transmute(
      model_group =
        model_group,
      
      validation_year =
        validation_year,
      
      fips =
        as.character(fips),
      
      county =
        county,
      
      actual_yield =
        corn_yield,
      
      predicted_yield =
        final_predictions,
      
      residual =
        actual_yield -
        predicted_yield,
      
      absolute_error =
        abs(residual),
      
      squared_error =
        residual^2,
      
      training_observations =
        nrow(
          outer_fold$training
        ),
      
      selected_mtry =
        best_parameters$mtry,
      
      selected_min_node_size =
        best_parameters$min.node.size
    )
  
  # ----------------------------------------------------------
  # Calculate outer-fold metrics
  # ----------------------------------------------------------
  
  fold_metrics <-
    prediction_results %>%
    summarise(
      model_group =
        first(model_group),
      
      validation_year =
        first(validation_year),
      
      observations =
        n(),
      
      training_observations =
        first(
          training_observations
        ),
      
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
              mean(actual_yield)
          )^2
        ),
      
      selected_mtry =
        first(
          selected_mtry
        ),
      
      selected_min_node_size =
        first(
          selected_min_node_size
        ),
      
      inner_mean_rmse =
        best_parameters$
        mean_inner_rmse,
      
      inner_mean_mae =
        best_parameters$
        mean_inner_mae,
      
      inner_observations =
        best_parameters$
        total_inner_observations,
      
      inner_unseen_excluded =
        best_parameters$
        unseen_observations_excluded
    )
  
  # ----------------------------------------------------------
  # Add identifying information to full tuning table
  # ----------------------------------------------------------
  
  tuning_results <-
    tuning_results %>%
    mutate(
      model_group =
        model_group,
      
      outer_validation_year =
        validation_year,
      
      .before = 1
    )
  
  # ----------------------------------------------------------
  # Return all useful outputs
  # ----------------------------------------------------------
  
  list(
    predictions =
      prediction_results,
    
    metrics =
      fold_metrics,
    
    tuning =
      tuning_results,
    
    best_parameters =
      best_parameters
  )
}

# ------------------------------------------------------------
# 12. Test formal outer-fold function:
# Group 3 predicting 2013
# ------------------------------------------------------------

rf_test_2013_group3 <- evaluate_rf_outer_fold(
  data =
    modeling_development,
  
  predictors =
    rf_predictor_groups$group_3,
  
  model_group =
    "Group 3 - Historical + conventional + extremes",
  
  validation_year =
    2013,
  
  tuning_trees =
    300,
  
  final_trees =
    500
)

rf_test_2013_group3$metrics

rf_test_2013_group3$best_parameters

dim(
  rf_test_2013_group3$predictions
)

sum(
  is.na(
    rf_test_2013_group3$
      predictions$predicted_yield
  )
)

rf_test_2013_group3$metrics %>%
  select(
    validation_year,
    inner_observations,
    inner_unseen_excluded,
    selected_mtry,
    selected_min_node_size,
    rmse,
    mae,
    r_squared
  )

# ------------------------------------------------------------
# 13. Run full Random Forest development comparison
# ------------------------------------------------------------

rf_group_labels <- c(
  group_1 =
    "Group 1 - Historical baseline",
  
  group_2 =
    "Group 2 - Historical + conventional weather",
  
  group_3 =
    "Group 3 - Historical + conventional + extremes"
)

validation_years <- 2012:2021

run_rf_group <- function(
    data,
    predictors,
    model_group,
    validation_years = 2012:2021
) {
  
  map(
    validation_years,
    function(validation_year) {
      
      message(
        "Running ",
        model_group,
        " - ",
        validation_year
      )
      
      evaluate_rf_outer_fold(
        data =
          data,
        
        predictors =
          predictors,
        
        model_group =
          model_group,
        
        validation_year =
          validation_year,
        
        tuning_trees =
          300,
        
        final_trees =
          500
      )
    }
  )
}

set.seed(492)

rf_results_group_1 <- run_rf_group(
  data =
    modeling_development,
  
  predictors =
    rf_predictor_groups$group_1,
  
  model_group =
    rf_group_labels["group_1"],
  
  validation_years =
    validation_years
)

rf_predictions_group_1 <- map_dfr(
  rf_results_group_1,
  "predictions"
)

rf_metrics_group_1 <- map_dfr(
  rf_results_group_1,
  "metrics"
)

rf_tuning_group_1 <- map_dfr(
  rf_results_group_1,
  "tuning"
)

print(
  rf_metrics_group_1,
  n = Inf,
  width = Inf
)

dim(
  rf_predictions_group_1
)

sum(
  is.na(
    rf_predictions_group_1$
      predicted_yield
  )
)

sum(
  rf_metrics_group_1$
    observations
)

rf_metrics_group_1 %>%
  select(
    validation_year,
    observations,
    selected_mtry,
    selected_min_node_size,
    inner_mean_rmse,
    rmse,
    mae,
    r_squared
  )

# ------------------------------------------------------------
# 14. Run Group 2 Random Forest comparison
# ------------------------------------------------------------

set.seed(492)

rf_results_group_2 <- run_rf_group(
  data =
    modeling_development,
  
  predictors =
    rf_predictor_groups$group_2,
  
  model_group =
    rf_group_labels["group_2"],
  
  validation_years =
    validation_years
)

rf_predictions_group_2 <- map_dfr(
  rf_results_group_2,
  "predictions"
)

rf_metrics_group_2 <- map_dfr(
  rf_results_group_2,
  "metrics"
)

rf_tuning_group_2 <- map_dfr(
  rf_results_group_2,
  "tuning"
)

print(
  rf_metrics_group_2,
  n = Inf,
  width = Inf
)

dim(
  rf_predictions_group_2
)

sum(
  is.na(
    rf_predictions_group_2$
      predicted_yield
  )
)

sum(
  rf_metrics_group_2$
    observations
)

# ------------------------------------------------------------
# 15. Run Group 3 Random Forest comparison
# ------------------------------------------------------------

set.seed(492)

rf_results_group_3 <- run_rf_group(
  data =
    modeling_development,
  
  predictors =
    rf_predictor_groups$group_3,
  
  model_group =
    rf_group_labels["group_3"],
  
  validation_years =
    validation_years
)

rf_predictions_group_3 <- map_dfr(
  rf_results_group_3,
  "predictions"
)

rf_metrics_group_3 <- map_dfr(
  rf_results_group_3,
  "metrics"
)

rf_tuning_group_3 <- map_dfr(
  rf_results_group_3,
  "tuning"
)

print(
  rf_metrics_group_3,
  n = Inf,
  width = Inf
)

dim(
  rf_predictions_group_3
)

sum(
  is.na(
    rf_predictions_group_3$
      predicted_yield
  )
)

sum(
  rf_metrics_group_3$
    observations
)

# ------------------------------------------------------------
# 16. Combine all Random Forest results
# ------------------------------------------------------------

rf_predictions_all <- bind_rows(
  rf_predictions_group_1,
  rf_predictions_group_2,
  rf_predictions_group_3
)

rf_metrics_all <- bind_rows(
  rf_metrics_group_1,
  rf_metrics_group_2,
  rf_metrics_group_3
)

rf_tuning_all <- bind_rows(
  rf_tuning_group_1,
  rf_tuning_group_2,
  rf_tuning_group_3
)

dim(
  rf_predictions_all
)

print(
  rf_metrics_all,
  n = Inf,
  width = Inf
)

rf_comparison_ids <- rf_predictions_all %>%
  count(
    validation_year,
    fips,
    name = "model_count"
  )

rf_comparison_ids %>%
  filter(
    model_count != 3
  )

# ------------------------------------------------------------
# 17. Save Random Forest development results
# ------------------------------------------------------------

rf_output_dir <-
  "output/random_forest_comparison"

dir.create(
  rf_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

# Save combined prediction, metric, and tuning tables
write_csv(
  rf_predictions_all,
  file.path(
    rf_output_dir,
    "rf_validation_predictions.csv"
  )
)

write_csv(
  rf_metrics_all,
  file.path(
    rf_output_dir,
    "rf_metrics_by_year.csv"
  )
)

write_csv(
  rf_tuning_all,
  file.path(
    rf_output_dir,
    "rf_tuning_results.csv"
  )
)

# Save complete R objects for easy recovery
saveRDS(
  rf_predictions_all,
  file.path(
    rf_output_dir,
    "rf_validation_predictions.rds"
  )
)

saveRDS(
  rf_metrics_all,
  file.path(
    rf_output_dir,
    "rf_metrics_by_year.rds"
  )
)

saveRDS(
  rf_tuning_all,
  file.path(
    rf_output_dir,
    "rf_tuning_results.rds"
  )
)

list.files(
  rf_output_dir
)

# ------------------------------------------------------------
# 18. Summarize Random Forest performance
# ------------------------------------------------------------

rf_performance_summary <- rf_metrics_all %>%
  group_by(
    model_group
  ) %>%
  summarise(
    validation_years =
      n(),
    
    mean_rmse =
      mean(rmse),
    
    median_rmse =
      median(rmse),
    
    mean_mae =
      mean(mae),
    
    median_mae =
      median(mae),
    
    mean_r_squared =
      mean(r_squared),
    
    .groups = "drop"
  ) %>%
  arrange(
    mean_rmse
  )

print(
  rf_performance_summary,
  width = Inf
)

# ------------------------------------------------------------
# 19. Calculate pooled Random Forest performance
# ------------------------------------------------------------

rf_pooled_performance <- rf_predictions_all %>%
  group_by(
    model_group
  ) %>%
  summarise(
    observations =
      n(),
    
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
            mean(actual_yield)
        )^2
      ),
    
    .groups = "drop"
  ) %>%
  arrange(
    rmse
  )

print(
  rf_pooled_performance,
  width = Inf
)

write_csv(
  rf_performance_summary,
  file.path(
    rf_output_dir,
    "rf_performance_summary.csv"
  )
)

write_csv(
  rf_pooled_performance,
  file.path(
    rf_output_dir,
    "rf_pooled_performance.csv"
  )
)

# ------------------------------------------------------------
# 20. Calculate incremental improvement by validation year
# ------------------------------------------------------------

rf_metrics_labeled <- rf_metrics_all %>%
  mutate(
    group_code = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "G1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "G2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "G3",
      
      TRUE ~ NA_character_
    )
  )

# Safeguard
stopifnot(
  !any(
    is.na(
      rf_metrics_labeled$group_code
    )
  )
)

rf_incremental_by_year <- rf_metrics_labeled %>%
  select(
    validation_year,
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
    rmse_reduction_G1_to_G2_pct =
      100 *
      (
        rmse_G1 -
          rmse_G2
      ) /
      rmse_G1,
    
    rmse_reduction_G1_to_G3_pct =
      100 *
      (
        rmse_G1 -
          rmse_G3
      ) /
      rmse_G1,
    
    rmse_reduction_G2_to_G3_pct =
      100 *
      (
        rmse_G2 -
          rmse_G3
      ) /
      rmse_G2,
    
    mae_reduction_G1_to_G2_pct =
      100 *
      (
        mae_G1 -
          mae_G2
      ) /
      mae_G1,
    
    mae_reduction_G1_to_G3_pct =
      100 *
      (
        mae_G1 -
          mae_G3
      ) /
      mae_G1,
    
    mae_reduction_G2_to_G3_pct =
      100 *
      (
        mae_G2 -
          mae_G3
      ) /
      mae_G2
  )

print(
  rf_incremental_by_year,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 21. Calculate pooled incremental improvement
# ------------------------------------------------------------

rf_pooled_labeled <- rf_pooled_performance %>%
  mutate(
    group_code = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "G1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "G2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "G3",
      
      TRUE ~ NA_character_
    )
  )

rf_pooled_wide <- rf_pooled_labeled %>%
  select(
    group_code,
    rmse,
    mae,
    r_squared
  ) %>%
  
  pivot_wider(
    names_from =
      group_code,
    
    values_from =
      c(
        rmse,
        mae,
        r_squared
      ),
    
    names_glue =
      "{.value}_{group_code}"
  )

rf_pooled_incremental <- rf_pooled_wide %>%
  transmute(
    rmse_G1,
    rmse_G2,
    rmse_G3,
    
    rmse_reduction_G1_to_G2_pct =
      100 *
      (
        rmse_G1 -
          rmse_G2
      ) /
      rmse_G1,
    
    rmse_reduction_G1_to_G3_pct =
      100 *
      (
        rmse_G1 -
          rmse_G3
      ) /
      rmse_G1,
    
    rmse_reduction_G2_to_G3_pct =
      100 *
      (
        rmse_G2 -
          rmse_G3
      ) /
      rmse_G2,
    
    mae_G1,
    mae_G2,
    mae_G3,
    
    mae_reduction_G1_to_G2_pct =
      100 *
      (
        mae_G1 -
          mae_G2
      ) /
      mae_G1,
    
    mae_reduction_G1_to_G3_pct =
      100 *
      (
        mae_G1 -
          mae_G3
      ) /
      mae_G1,
    
    mae_reduction_G2_to_G3_pct =
      100 *
      (
        mae_G2 -
          mae_G3
      ) /
      mae_G2,
    
    r_squared_G1,
    r_squared_G2,
    r_squared_G3
  )

print(
  rf_pooled_incremental,
  width = Inf
)

# ------------------------------------------------------------
# 22. Count yearly predictor-group wins
# ------------------------------------------------------------

rf_rmse_winners <- rf_metrics_labeled %>%
  arrange(
    validation_year,
    rmse,
    mae
  ) %>%
  
  group_by(
    validation_year
  ) %>%
  
  slice(1) %>%
  
  ungroup() %>%
  
  select(
    validation_year,
    group_code,
    rmse,
    mae
  )

rf_mae_winners <- rf_metrics_labeled %>%
  arrange(
    validation_year,
    mae,
    rmse
  ) %>%
  
  group_by(
    validation_year
  ) %>%
  
  slice(1) %>%
  
  ungroup() %>%
  
  select(
    validation_year,
    group_code,
    mae,
    rmse
  )

rf_yearly_win_counts <- bind_rows(
  rf_rmse_winners %>%
    count(
      group_code,
      name = "wins"
    ) %>%
    mutate(
      metric = "RMSE"
    ),
  
  rf_mae_winners %>%
    count(
      group_code,
      name = "wins"
    ) %>%
    mutate(
      metric = "MAE"
    )
) %>%
  select(
    metric,
    group_code,
    wins
  ) %>%
  arrange(
    metric,
    group_code
  )

rf_rmse_winners

rf_mae_winners

rf_yearly_win_counts

# ------------------------------------------------------------
# 23. Sensitivity analysis excluding 2012
# ------------------------------------------------------------

rf_sensitivity_excluding_2012 <-
  rf_metrics_all %>%
  
  filter(
    validation_year != 2012
  ) %>%
  
  group_by(
    model_group
  ) %>%
  
  summarise(
    validation_years =
      n(),
    
    mean_rmse =
      mean(rmse),
    
    median_rmse =
      median(rmse),
    
    mean_mae =
      mean(mae),
    
    median_mae =
      median(mae),
    
    mean_r_squared =
      mean(r_squared),
    
    .groups = "drop"
  ) %>%
  
  arrange(
    mean_rmse
  )

print(
  rf_sensitivity_excluding_2012,
  width = Inf
)

# ------------------------------------------------------------
# 24. Plot RMSE by validation year
# ------------------------------------------------------------

rf_plot_data <- rf_metrics_labeled %>%
  mutate(
    predictor_group = factor(
      group_code,
      
      levels = c(
        "G1",
        "G2",
        "G3"
      ),
      
      labels = c(
        "Historical baseline",
        "Baseline + conventional weather",
        "Baseline + weather + extremes"
      )
    )
  )

rf_rmse_plot <- ggplot(
  rf_plot_data,
  aes(
    x = validation_year,
    y = rmse,
    group = predictor_group,
    color = predictor_group,
    linetype = predictor_group
  )
) +
  geom_line(
    linewidth = 0.9
  ) +
  geom_point(
    size = 2.2
  ) +
  scale_x_continuous(
    breaks = 2012:2021
  ) +
  labs(
    title =
      "Random Forest RMSE by Validation Year",
    
    x =
      "Validation Year",
    
    y =
      "RMSE (bushels per acre)",
    
    color =
      "Predictor Group",
    
    linetype =
      "Predictor Group"
  ) +
  theme_minimal() +
  theme(
    legend.position =
      "bottom",
    
    axis.text.x =
      element_text(
        angle = 45,
        hjust = 1
      )
  )

rf_rmse_plot

ggsave(
  filename =
    file.path(
      rf_output_dir,
      "rf_rmse_by_validation_year.png"
    ),
  
  plot =
    rf_rmse_plot,
  
  width =
    9,
  
  height =
    6,
  
  dpi =
    300
)

write_csv(
  rf_incremental_by_year,
  file.path(
    rf_output_dir,
    "rf_incremental_improvement_by_year.csv"
  )
)

write_csv(
  rf_pooled_incremental,
  file.path(
    rf_output_dir,
    "rf_pooled_incremental_comparison.csv"
  )
)

write_csv(
  rf_yearly_win_counts,
  file.path(
    rf_output_dir,
    "rf_yearly_win_counts.csv"
  )
)

write_csv(
  rf_sensitivity_excluding_2012,
  file.path(
    rf_output_dir,
    "rf_sensitivity_excluding_2012.csv"
  )
)

# ------------------------------------------------------------
# 25. Record Random Forest development result
# ------------------------------------------------------------

rf_model_result <- tibble(
  algorithm =
    "Random Forest",
  
  preferred_predictor_group =
    "Group 3",
  
  pooled_rmse =
    29.4,
  
  pooled_mae =
    23.0,
  
  pooled_r_squared =
    0.240,
  
  rmse_wins =
    6,
  
  mae_wins =
    5,
  
  sensitivity_mean_rmse_excluding_2012 =
    22.7,
  
  sensitivity_mean_mae_excluding_2012 =
    19.7,
  
  interpretation =
    paste(
      "Conventional weather substantially improved",
      "Random Forest performance over the historical",
      "baseline. Retained extreme-weather indicators",
      "provided a smaller additional improvement."
    )
)

rf_model_result

write_csv(
  rf_model_result,
  file.path(
    rf_output_dir,
    "rf_model_result.csv"
  )
)
