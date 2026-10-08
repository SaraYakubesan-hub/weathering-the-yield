# ============================================================
# Gradient Boosting Predictor-Group Comparison
# Senior Thesis
#
# Purpose:
# Compare the three finalized predictor groups using XGBoost
# models and expanding-window validation.
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
library(xgboost)

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

xgb_predictor_groups <- list(
  
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

xgb_predictor_groups

length(xgb_predictor_groups$group_1)
length(xgb_predictor_groups$group_2)
length(xgb_predictor_groups$group_3)

# Confirm every planned predictor exists
all_xgb_predictors <- unique(
  unlist(xgb_predictor_groups)
)

stopifnot(
  all(
    all_xgb_predictors %in%
      names(modeling_development)
  )
)

# Confirm E01 was not accidentally reintroduced
stopifnot(
  !any(
    grepl(
      "^e01",
      xgb_predictor_groups$group_3,
      ignore.case = TRUE
    )
  )
)

# ------------------------------------------------------------
# 3. Function to prepare one outer validation fold
# ------------------------------------------------------------

prepare_xgb_fold <- function(
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

smoke_fold <- prepare_xgb_fold(
  modeling_development,
  validation_year = 2012
)

nrow(smoke_fold$training)
nrow(smoke_fold$validation)

nlevels(smoke_fold$training$fips)

sum(
  is.na(smoke_fold$validation$fips)
)

# ------------------------------------------------------------
# 5. Function to create XGBoost model matrices
# ------------------------------------------------------------

prepare_xgb_matrices <- function(
    training_data,
    validation_data,
    predictors
) {
  
  training_predictors <- training_data %>%
    select(
      all_of(predictors)
    )
  
  validation_predictors <- validation_data %>%
    select(
      all_of(predictors)
    )
  
  # Convert predictors to numeric model matrices
  # County FIPS is expanded into indicator variables
  training_matrix <- model.matrix(
    ~ . - 1,
    data = training_predictors
  )
  
  validation_matrix <- model.matrix(
    ~ . - 1,
    data = validation_predictors
  )
  
  # Confirm identical predictor columns
  stopifnot(
    identical(
      colnames(training_matrix),
      colnames(validation_matrix)
    )
  )
  
  # Confirm matrices contain no missing values
  stopifnot(
    !any(is.na(training_matrix))
  )
  
  stopifnot(
    !any(is.na(validation_matrix))
  )
  
  list(
    training_matrix = training_matrix,
    validation_matrix = validation_matrix,
    training_labels = training_data$corn_yield,
    validation_labels = validation_data$corn_yield
  )
}

# ------------------------------------------------------------
# 6. Test Group 3 XGBoost matrix preparation for 2012
# ------------------------------------------------------------

xgb_smoke_data <- prepare_xgb_matrices(
  training_data =
    smoke_fold$training,
  
  validation_data =
    smoke_fold$validation,
  
  predictors =
    xgb_predictor_groups$group_3
)

dim(
  xgb_smoke_data$training_matrix
)

dim(
  xgb_smoke_data$validation_matrix
)

length(
  xgb_smoke_data$training_labels
)

length(
  xgb_smoke_data$validation_labels
)

identical(
  colnames(
    xgb_smoke_data$training_matrix
  ),
  colnames(
    xgb_smoke_data$validation_matrix
  )
)

sum(
  is.na(
    xgb_smoke_data$training_matrix
  )
)

sum(
  is.na(
    xgb_smoke_data$validation_matrix
  )
)

head(
  colnames(
    xgb_smoke_data$training_matrix
  ),
  15
)

# ------------------------------------------------------------
# 7. Fit Group 3 XGBoost smoke-test model for 2012
# ------------------------------------------------------------

xgb_smoke_training <- xgb.DMatrix(
  data =
    xgb_smoke_data$training_matrix,
  
  label =
    xgb_smoke_data$training_labels
)

xgb_smoke_validation <- xgb.DMatrix(
  data =
    xgb_smoke_data$validation_matrix,
  
  label =
    xgb_smoke_data$validation_labels
)

# Starting parameters for smoke test only
xgb_smoke_parameters <- list(
  objective =
    "reg:squarederror",
  
  eval_metric =
    "rmse",
  
  eta =
    0.05,
  
  max_depth =
    4,
  
  min_child_weight =
    1,
  
  subsample =
    0.8,
  
  colsample_bytree =
    0.8,
  
  nthread =
    1
)

xgb_smoke_parameters

set.seed(492)

xgb_smoke_fit <- xgb.train(
  params =
    xgb_smoke_parameters,
  
  data =
    xgb_smoke_training,
  
  nrounds =
    300,
  
  verbose =
    0
)

xgb_smoke_predictions <- predict(
  xgb_smoke_fit,
  xgb_smoke_validation
)

length(
  xgb_smoke_predictions
)

sum(
  is.na(
    xgb_smoke_predictions
  )
)

summary(
  xgb_smoke_predictions
)

# ------------------------------------------------------------
# 8. Calculate smoke-test performance
# ------------------------------------------------------------

xgb_smoke_results <- smoke_fold$validation %>%
  transmute(
    validation_year = year,
    fips = as.character(fips),
    county = county,
    actual_yield = corn_yield,
    predicted_yield = xgb_smoke_predictions,
    residual =
      actual_yield - predicted_yield,
    absolute_error =
      abs(residual),
    squared_error =
      residual^2
  )

xgb_smoke_metrics <- xgb_smoke_results %>%
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

xgb_smoke_metrics

# ------------------------------------------------------------
# 9. Create XGBoost tuning grid
# ------------------------------------------------------------

create_xgb_tuning_grid <- function() {
  
  expand_grid(
    eta = c(
      0.05,
      0.10
    ),
    
    max_depth = c(
      2,
      4,
      6
    ),
    
    min_child_weight = c(
      1,
      5
    )
  )
}

xgb_tuning_grid <- create_xgb_tuning_grid()

xgb_tuning_grid

nrow(
  xgb_tuning_grid
)

# ------------------------------------------------------------
# 10. Prepare inner XGBoost tuning folds
# ------------------------------------------------------------

prepare_xgb_inner_fold <- function(
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

xgb_inner_test_2011 <- prepare_xgb_inner_fold(
  smoke_fold$training,
  validation_year = 2011
)

nrow(
  xgb_inner_test_2011$training
)

nrow(
  xgb_inner_test_2011$validation
)

xgb_inner_test_2011$unseen_observations

xgb_inner_test_2011$unseen_fips

sum(
  is.na(
    xgb_inner_test_2011$validation$fips
  )
)

# ------------------------------------------------------------
# 11. Tune XGBoost within an outer training period
# ------------------------------------------------------------

tune_xgb_model <- function(
    outer_training_data,
    predictors,
    outer_validation_year,
    max_nrounds = 1000,
    early_stopping_rounds = 50
) {
  
  tuning_grid <- create_xgb_tuning_grid()
  
  # Use the five most recent years available
  # inside the outer training period
  inner_validation_years <- seq(
    from = outer_validation_year - 5,
    to = outer_validation_year - 1
  )
  
  tuning_results <- map_dfr(
    seq_len(nrow(tuning_grid)),
    function(grid_row) {
      
      current_eta <-
        tuning_grid$eta[grid_row]
      
      current_max_depth <-
        tuning_grid$max_depth[grid_row]
      
      current_min_child_weight <-
        tuning_grid$min_child_weight[grid_row]
      
      inner_results <- map_dfr(
        inner_validation_years,
        function(inner_validation_year) {
          
          # Prepare inner tuning fold
          inner_fold <- prepare_xgb_inner_fold(
            outer_training_data,
            validation_year =
              inner_validation_year
          )
          
          # Create training and validation matrices
          inner_matrices <- prepare_xgb_matrices(
            training_data =
              inner_fold$training,
            
            validation_data =
              inner_fold$validation,
            
            predictors =
              predictors
          )
          
          inner_training_matrix <- xgb.DMatrix(
            data =
              inner_matrices$training_matrix,
            
            label =
              inner_matrices$training_labels
          )
          
          inner_validation_matrix <- xgb.DMatrix(
            data =
              inner_matrices$validation_matrix,
            
            label =
              inner_matrices$validation_labels
          )
          
          # Reproducible seed unique to outer fold,
          # tuning combination, and inner year
          current_seed <-
            492 +
            (outer_validation_year - 2000) * 1000 +
            grid_row * 10 +
            (inner_validation_year - 2000)
          
          set.seed(
            current_seed
          )
          
          # Fit XGBoost using inner validation only
          # for early stopping
          inner_fit <- xgb.train(
            params = list(
              objective =
                "reg:squarederror",
              
              eval_metric =
                "rmse",
              
              eta =
                current_eta,
              
              max_depth =
                current_max_depth,
              
              min_child_weight =
                current_min_child_weight,
              
              subsample =
                0.8,
              
              colsample_bytree =
                0.8,
              
              seed =
                current_seed,
              
              nthread =
                1
            ),
            
            data =
              inner_training_matrix,
            
            nrounds =
              max_nrounds,
            
            evals = list(
              validation =
                inner_validation_matrix
            ),
            
            early_stopping_rounds =
              early_stopping_rounds,
            
            verbose =
              0
          )
          
          # Retrieve best boosting iteration selected
          # using the inner validation fold
          current_best_iteration_zero_based <-
            xgb.attr(
              inner_fit,
              "best_iteration"
            )
          
          # Safeguard
          stopifnot(
            !is.null(
              current_best_iteration_zero_based
            )
          )
          
          # Convert XGBoost's zero-based stored iteration
          # to the one-based iteration count used in R
          current_best_iteration <-
            as.integer(
              current_best_iteration_zero_based
            ) + 1L
          
          stopifnot(
            is.finite(
              current_best_iteration
            )
          )
          
          # Generate inner-validation predictions
          # using only the selected boosting rounds
          inner_predictions <- predict(
            inner_fit,
            inner_validation_matrix
          )
          
          actual_values <-
            inner_matrices$validation_labels
          
          # Calculate inner-fold metrics
          tibble(
            inner_validation_year =
              inner_validation_year,
            
            observations =
              length(actual_values),
            
            unseen_observations_excluded =
              inner_fold$unseen_observations,
            
            best_iteration =
              current_best_iteration,
            
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
        eta =
          current_eta,
        
        max_depth =
          current_max_depth,
        
        min_child_weight =
          current_min_child_weight,
        
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
        
        mean_best_iteration =
          mean(
            inner_results$best_iteration
          ),
        
        median_best_iteration =
          median(
            inner_results$best_iteration
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
      eta,
      max_depth,
      min_child_weight
    )
  
  tuning_results
}

# ------------------------------------------------------------
# Diagnose unseen counties in 2012 inner tuning folds
# ------------------------------------------------------------

xgb_inner_county_audit_2012 <- map_dfr(
  2007:2011,
  function(inner_validation_year) {
    
    # Prepare chronological inner tuning fold
    inner_fold <- prepare_xgb_inner_fold(
      smoke_fold$training,
      validation_year =
        inner_validation_year
    )
    
    # Summarize this inner fold
    tibble(
      inner_validation_year =
        inner_validation_year,
      
      training_observations =
        nrow(
          inner_fold$training
        ),
      
      validation_observations =
        nrow(
          inner_fold$validation
        ),
      
      unseen_observations =
        inner_fold$unseen_observations,
      
      unseen_fips =
        if (
          length(
            inner_fold$unseen_fips
          ) == 0
        ) {
          NA_character_
        } else {
          paste(
            inner_fold$unseen_fips,
            collapse = ", "
          )
        }
    )
  }
)

print(
  xgb_inner_county_audit_2012,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 12. Test nested tuning:
# Group 3 for the 2012 outer fold
# ------------------------------------------------------------

set.seed(492)

xgb_tuning_test_2012 <- tune_xgb_model(
  outer_training_data =
    smoke_fold$training,
  
  predictors =
    xgb_predictor_groups$group_3,
  
  outer_validation_year =
    2012,
  
  max_nrounds =
    1000,
  
  early_stopping_rounds =
    50
)

print(
  xgb_tuning_test_2012,
  n = Inf,
  width = Inf
)

best_xgb_parameters_2012 <-
  xgb_tuning_test_2012 %>%
  slice(1)

best_xgb_parameters_2012

# ------------------------------------------------------------
# 13. Fit tuned Group 3 XGBoost for 2012
# ------------------------------------------------------------

selected_nrounds_2012 <-
  as.integer(
    round(
      best_xgb_parameters_2012$
        median_best_iteration
    )
  )

selected_nrounds_2012

stopifnot(
  selected_nrounds_2012 > 0
)

set.seed(492)

xgb_tuned_fit_2012 <- xgb.train(
  params = list(
    objective =
      "reg:squarederror",
    
    eval_metric =
      "rmse",
    
    eta =
      best_xgb_parameters_2012$eta,
    
    max_depth =
      best_xgb_parameters_2012$max_depth,
    
    min_child_weight =
      best_xgb_parameters_2012$
      min_child_weight,
    
    subsample =
      0.8,
    
    colsample_bytree =
      0.8,
    
    seed =
      492,
    
    nthread =
      1
  ),
  
  data =
    xgb_smoke_training,
  
  nrounds =
    selected_nrounds_2012,
  
  verbose =
    0
)

xgb_tuned_predictions_2012 <- predict(
  xgb_tuned_fit_2012,
  xgb_smoke_validation
)

length(
  xgb_tuned_predictions_2012
)

sum(
  is.na(
    xgb_tuned_predictions_2012
  )
)

summary(
  xgb_tuned_predictions_2012
)

xgb_tuned_results_2012 <-
  smoke_fold$validation %>%
  transmute(
    validation_year = year,
    
    fips =
      as.character(fips),
    
    county = county,
    
    actual_yield =
      corn_yield,
    
    predicted_yield =
      xgb_tuned_predictions_2012,
    
    residual =
      actual_yield -
      predicted_yield,
    
    absolute_error =
      abs(residual),
    
    squared_error =
      residual^2
  )

xgb_tuned_metrics_2012 <-
  xgb_tuned_results_2012 %>%
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

xgb_tuned_metrics_2012

best_xgb_parameters_2012 %>%
  select(
    eta,
    max_depth,
    min_child_weight,
    mean_inner_rmse,
    median_inner_rmse,
    median_best_iteration
  )

# ------------------------------------------------------------
# 14. Fit and evaluate one tuned outer XGBoost fold
# ------------------------------------------------------------

evaluate_xgb_outer_fold <- function(
    data,
    predictors,
    model_group,
    validation_year,
    max_nrounds = 1000,
    early_stopping_rounds = 50
) {
  
  # ----------------------------------------------------------
  # Prepare outer training and validation data
  # ----------------------------------------------------------
  
  outer_fold <- prepare_xgb_fold(
    data,
    validation_year =
      validation_year
  )
  
  # ----------------------------------------------------------
  # Tune hyperparameters using only the outer training period
  # ----------------------------------------------------------
  
  tuning_results <- tune_xgb_model(
    outer_training_data =
      outer_fold$training,
    
    predictors =
      predictors,
    
    outer_validation_year =
      validation_year,
    
    max_nrounds =
      max_nrounds,
    
    early_stopping_rounds =
      early_stopping_rounds
  )
  
  best_parameters <- tuning_results %>%
    slice(1)
  
  # ----------------------------------------------------------
  # Select number of boosting rounds from inner tuning
  # ----------------------------------------------------------
  
  selected_nrounds <-
    as.integer(
      round(
        best_parameters$
          median_best_iteration[[1]]
      )
    )
  
  stopifnot(
    selected_nrounds > 0
  )
  
  # ----------------------------------------------------------
  # Create final outer-fold model matrices
  # ----------------------------------------------------------
  
  outer_matrices <- prepare_xgb_matrices(
    training_data =
      outer_fold$training,
    
    validation_data =
      outer_fold$validation,
    
    predictors =
      predictors
  )
  
  outer_training_matrix <- xgb.DMatrix(
    data =
      outer_matrices$training_matrix,
    
    label =
      outer_matrices$training_labels
  )
  
  outer_validation_matrix <- xgb.DMatrix(
    data =
      outer_matrices$validation_matrix,
    
    label =
      outer_matrices$validation_labels
  )
  
  # ----------------------------------------------------------
  # Fit final model using all outer-training observations
  # ----------------------------------------------------------
  
  final_seed <-
    492 +
    (validation_year - 2000) * 100
  
  set.seed(
    final_seed
  )
  
  final_fit <- xgb.train(
    params = list(
      objective =
        "reg:squarederror",
      
      eval_metric =
        "rmse",
      
      eta =
        best_parameters$eta[[1]],
      
      max_depth =
        as.integer(
          best_parameters$max_depth[[1]]
        ),
      
      min_child_weight =
        best_parameters$
        min_child_weight[[1]],
      
      subsample =
        0.8,
      
      colsample_bytree =
        0.8,
      
      seed =
        final_seed,
      
      nthread =
        1
    ),
    
    data =
      outer_training_matrix,
    
    nrounds =
      selected_nrounds,
    
    verbose =
      0
  )
  
  # ----------------------------------------------------------
  # Predict outer validation year
  # ----------------------------------------------------------
  
  final_predictions <- predict(
    final_fit,
    outer_validation_matrix
  )
  
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
      
      selected_eta =
        best_parameters$eta[[1]],
      
      selected_max_depth =
        best_parameters$
        max_depth[[1]],
      
      selected_min_child_weight =
        best_parameters$
        min_child_weight[[1]],
      
      selected_nrounds =
        selected_nrounds
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
      
      selected_eta =
        first(
          selected_eta
        ),
      
      selected_max_depth =
        first(
          selected_max_depth
        ),
      
      selected_min_child_weight =
        first(
          selected_min_child_weight
        ),
      
      selected_nrounds =
        first(
          selected_nrounds
        ),
      
      inner_mean_rmse =
        best_parameters$
        mean_inner_rmse[[1]],
      
      inner_mean_mae =
        best_parameters$
        mean_inner_mae[[1]],
      
      inner_median_best_iteration =
        best_parameters$
        median_best_iteration[[1]],
      
      inner_observations =
        best_parameters$
        total_inner_observations[[1]],
      
      inner_unseen_excluded =
        best_parameters$
        unseen_observations_excluded[[1]]
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
# 15. Test formal outer-fold function:
# Group 3 predicting 2013
# ------------------------------------------------------------

xgb_test_2013_group3 <- evaluate_xgb_outer_fold(
  data =
    modeling_development,
  
  predictors =
    xgb_predictor_groups$group_3,
  
  model_group =
    "Group 3 - Historical + conventional + extremes",
  
  validation_year =
    2013,
  
  max_nrounds =
    1000,
  
  early_stopping_rounds =
    50
)

xgb_test_2013_group3$metrics

xgb_test_2013_group3$best_parameters

dim(
  xgb_test_2013_group3$predictions
)

sum(
  is.na(
    xgb_test_2013_group3$
      predictions$predicted_yield
  )
)

xgb_test_2013_group3$metrics %>%
  select(
    validation_year,
    observations,
    inner_observations,
    inner_unseen_excluded,
    selected_eta,
    selected_max_depth,
    selected_min_child_weight,
    selected_nrounds,
    inner_mean_rmse,
    rmse,
    mae,
    r_squared
  )

# ------------------------------------------------------------
# 16. Run Group 1 XGBoost development comparison
# ------------------------------------------------------------

xgb_group_labels <- c(
  group_1 =
    "Group 1 - Historical baseline",
  
  group_2 =
    "Group 2 - Historical + conventional weather",
  
  group_3 =
    "Group 3 - Historical + conventional + extremes"
)

validation_years <- 2012:2021

run_xgb_group <- function(
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
      
      evaluate_xgb_outer_fold(
        data =
          data,
        
        predictors =
          predictors,
        
        model_group =
          model_group,
        
        validation_year =
          validation_year,
        
        max_nrounds =
          1000,
        
        early_stopping_rounds =
          50
      )
    }
  )
}

set.seed(492)

xgb_results_group_1 <- run_xgb_group(
  data =
    modeling_development,
  
  predictors =
    xgb_predictor_groups$group_1,
  
  model_group =
    xgb_group_labels["group_1"],
  
  validation_years =
    validation_years
)

xgb_predictions_group_1 <- map_dfr(
  xgb_results_group_1,
  "predictions"
)

xgb_metrics_group_1 <- map_dfr(
  xgb_results_group_1,
  "metrics"
)

xgb_tuning_group_1 <- map_dfr(
  xgb_results_group_1,
  "tuning"
)

print(
  xgb_metrics_group_1,
  n = Inf,
  width = Inf
)

dim(
  xgb_predictions_group_1
)

sum(
  is.na(
    xgb_predictions_group_1$
      predicted_yield
  )
)

sum(
  xgb_metrics_group_1$
    observations
)

xgb_metrics_group_1 %>%
  select(
    validation_year,
    observations,
    selected_eta,
    selected_max_depth,
    selected_min_child_weight,
    selected_nrounds,
    inner_mean_rmse,
    rmse,
    mae,
    r_squared
  )

# ------------------------------------------------------------
# 17. Run Group 2 XGBoost comparison
# ------------------------------------------------------------

set.seed(492)

xgb_results_group_2 <- run_xgb_group(
  data =
    modeling_development,
  
  predictors =
    xgb_predictor_groups$group_2,
  
  model_group =
    xgb_group_labels["group_2"],
  
  validation_years =
    validation_years
)

xgb_predictions_group_2 <- map_dfr(
  xgb_results_group_2,
  "predictions"
)

xgb_metrics_group_2 <- map_dfr(
  xgb_results_group_2,
  "metrics"
)

xgb_tuning_group_2 <- map_dfr(
  xgb_results_group_2,
  "tuning"
)

print(
  xgb_metrics_group_2,
  n = Inf,
  width = Inf
)

dim(
  xgb_predictions_group_2
)

sum(
  is.na(
    xgb_predictions_group_2$
      predicted_yield
  )
)

sum(
  xgb_metrics_group_2$
    observations
)

xgb_metrics_group_2 %>%
  select(
    validation_year,
    observations,
    selected_eta,
    selected_max_depth,
    selected_min_child_weight,
    selected_nrounds,
    inner_mean_rmse,
    rmse,
    mae,
    r_squared
  )

# ------------------------------------------------------------
# 18. Run Group 3 XGBoost comparison
# ------------------------------------------------------------

set.seed(492)

xgb_results_group_3 <- run_xgb_group(
  data =
    modeling_development,
  
  predictors =
    xgb_predictor_groups$group_3,
  
  model_group =
    xgb_group_labels["group_3"],
  
  validation_years =
    validation_years
)

xgb_predictions_group_3 <- map_dfr(
  xgb_results_group_3,
  "predictions"
)

xgb_metrics_group_3 <- map_dfr(
  xgb_results_group_3,
  "metrics"
)

xgb_tuning_group_3 <- map_dfr(
  xgb_results_group_3,
  "tuning"
)

print(
  xgb_metrics_group_3,
  n = Inf,
  width = Inf
)

dim(
  xgb_predictions_group_3
)

sum(
  is.na(
    xgb_predictions_group_3$
      predicted_yield
  )
)

sum(
  xgb_metrics_group_3$
    observations
)

xgb_metrics_group_3 %>%
  select(
    validation_year,
    observations,
    selected_eta,
    selected_max_depth,
    selected_min_child_weight,
    selected_nrounds,
    inner_mean_rmse,
    rmse,
    mae,
    r_squared
  )

# ------------------------------------------------------------
# 19. Combine XGBoost results and verify comparison observations
# ------------------------------------------------------------

xgb_predictions_all <- bind_rows(
  xgb_predictions_group_1,
  xgb_predictions_group_2,
  xgb_predictions_group_3
)

xgb_metrics_all <- bind_rows(
  xgb_metrics_group_1,
  xgb_metrics_group_2,
  xgb_metrics_group_3
)

xgb_tuning_all <- bind_rows(
  xgb_tuning_group_1,
  xgb_tuning_group_2,
  xgb_tuning_group_3
)

# Confirm total prediction rows
dim(
  xgb_predictions_all
)

# Confirm observation counts by predictor group
xgb_predictions_all %>%
  count(
    model_group,
    name = "observations"
  )

# Confirm no missing predictions
sum(
  is.na(
    xgb_predictions_all$
      predicted_yield
  )
)

# Confirm each predictor group contains
# the same validation years
xgb_metrics_all %>%
  count(
    model_group,
    name = "validation_years"
  )

# Create observation identifiers for comparison
xgb_group_1_ids <- xgb_predictions_group_1 %>%
  select(
    validation_year,
    fips,
    county,
    actual_yield
  ) %>%
  arrange(
    validation_year,
    fips
  )

xgb_group_2_ids <- xgb_predictions_group_2 %>%
  select(
    validation_year,
    fips,
    county,
    actual_yield
  ) %>%
  arrange(
    validation_year,
    fips
  )

xgb_group_3_ids <- xgb_predictions_group_3 %>%
  select(
    validation_year,
    fips,
    county,
    actual_yield
  ) %>%
  arrange(
    validation_year,
    fips
  )

# Confirm identical observations across groups
identical(
  xgb_group_1_ids,
  xgb_group_2_ids
)

identical(
  xgb_group_1_ids,
  xgb_group_3_ids
)

# Additional safeguards
stopifnot(
  nrow(xgb_predictions_group_1) == 739
)

stopifnot(
  nrow(xgb_predictions_group_2) == 739
)

stopifnot(
  nrow(xgb_predictions_group_3) == 739
)

stopifnot(
  identical(
    xgb_group_1_ids,
    xgb_group_2_ids
  )
)

stopifnot(
  identical(
    xgb_group_1_ids,
    xgb_group_3_ids
  )
)

stopifnot(
  !any(
    is.na(
      xgb_predictions_all$
        predicted_yield
    )
  )
)

# ------------------------------------------------------------
# 20. Summarize XGBoost performance
# ------------------------------------------------------------

# Annual performance summary across validation years
xgb_performance_summary <- xgb_metrics_all %>%
  group_by(
    model_group
  ) %>%
  summarise(
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
    
    .groups =
      "drop"
  )

print(
  xgb_performance_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Pooled performance across all validation observations
# ------------------------------------------------------------

xgb_pooled_performance <- xgb_predictions_all %>%
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
    
    .groups =
      "drop"
  )

print(
  xgb_pooled_performance,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# Calculate incremental predictor-group improvements
# ------------------------------------------------------------

xgb_group_1_pooled <- xgb_pooled_performance %>%
  filter(
    model_group ==
      xgb_group_labels[["group_1"]]
  )

xgb_group_2_pooled <- xgb_pooled_performance %>%
  filter(
    model_group ==
      xgb_group_labels[["group_2"]]
  )

xgb_group_3_pooled <- xgb_pooled_performance %>%
  filter(
    model_group ==
      xgb_group_labels[["group_3"]]
  )

stopifnot(
  nrow(xgb_group_1_pooled) == 1,
  nrow(xgb_group_2_pooled) == 1,
  nrow(xgb_group_3_pooled) == 1
)

xgb_pooled_incremental_comparison <- tibble(
  comparison = c(
    "Group 1 to Group 2",
    "Group 1 to Group 3",
    "Group 2 to Group 3"
  ),
  
  rmse_reduction = c(
    xgb_group_1_pooled$rmse -
      xgb_group_2_pooled$rmse,
    
    xgb_group_1_pooled$rmse -
      xgb_group_3_pooled$rmse,
    
    xgb_group_2_pooled$rmse -
      xgb_group_3_pooled$rmse
  ),
  
  rmse_percent_reduction = c(
    100 *
      (
        xgb_group_1_pooled$rmse -
          xgb_group_2_pooled$rmse
      ) /
      xgb_group_1_pooled$rmse,
    
    100 *
      (
        xgb_group_1_pooled$rmse -
          xgb_group_3_pooled$rmse
      ) /
      xgb_group_1_pooled$rmse,
    
    100 *
      (
        xgb_group_2_pooled$rmse -
          xgb_group_3_pooled$rmse
      ) /
      xgb_group_2_pooled$rmse
  ),
  
  mae_reduction = c(
    xgb_group_1_pooled$mae -
      xgb_group_2_pooled$mae,
    
    xgb_group_1_pooled$mae -
      xgb_group_3_pooled$mae,
    
    xgb_group_2_pooled$mae -
      xgb_group_3_pooled$mae
  ),
  
  mae_percent_reduction = c(
    100 *
      (
        xgb_group_1_pooled$mae -
          xgb_group_2_pooled$mae
      ) /
      xgb_group_1_pooled$mae,
    
    100 *
      (
        xgb_group_1_pooled$mae -
          xgb_group_3_pooled$mae
      ) /
      xgb_group_1_pooled$mae,
    
    100 *
      (
        xgb_group_2_pooled$mae -
          xgb_group_3_pooled$mae
      ) /
      xgb_group_2_pooled$mae
  )
)

print(
  xgb_pooled_incremental_comparison,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 21. Compare yearly wins and sensitivity excluding 2012
# ------------------------------------------------------------

# ------------------------------------------------------------
# Identify lowest-RMSE model group for each validation year
# ------------------------------------------------------------

xgb_rmse_winners <- xgb_metrics_all %>%
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
    model_group,
    rmse
  )

print(
  xgb_rmse_winners,
  n = Inf,
  width = Inf
)

xgb_rmse_win_counts <- xgb_rmse_winners %>%
  count(
    model_group,
    name = "rmse_wins"
  )

print(
  xgb_rmse_win_counts,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Identify lowest-MAE model group for each validation year
# ------------------------------------------------------------

xgb_mae_winners <- xgb_metrics_all %>%
  group_by(
    validation_year
  ) %>%
  slice_min(
    order_by = mae,
    n = 1,
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  select(
    validation_year,
    model_group,
    mae
  )

print(
  xgb_mae_winners,
  n = Inf,
  width = Inf
)

xgb_mae_win_counts <- xgb_mae_winners %>%
  count(
    model_group,
    name = "mae_wins"
  )

print(
  xgb_mae_win_counts,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Combine yearly win counts
# ------------------------------------------------------------

xgb_yearly_win_counts <- full_join(
  xgb_rmse_win_counts,
  xgb_mae_win_counts,
  by = "model_group"
) %>%
  mutate(
    rmse_wins =
      replace_na(
        rmse_wins,
        0L
      ),
    
    mae_wins =
      replace_na(
        mae_wins,
        0L
      )
  )

print(
  xgb_yearly_win_counts,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Sensitivity analysis excluding 2012
# ------------------------------------------------------------

xgb_sensitivity_excluding_2012 <- xgb_metrics_all %>%
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
    
    .groups =
      "drop"
  )

print(
  xgb_sensitivity_excluding_2012,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 22. Plot RMSE by validation year
# ------------------------------------------------------------

xgb_rmse_plot_data <- xgb_metrics_all %>%
  mutate(
    model_group = factor(
      model_group,
      levels = c(
        xgb_group_labels[["group_1"]],
        xgb_group_labels[["group_2"]],
        xgb_group_labels[["group_3"]]
      ),
      labels = c(
        "Group 1 - Historical baseline",
        "Group 2 - + Conventional weather",
        "Group 3 - + Conventional + extremes"
      )
    )
  )

xgb_rmse_plot <- ggplot(
  xgb_rmse_plot_data,
  aes(
    x = validation_year,
    y = rmse,
    group = model_group,
    linetype = model_group,
    shape = model_group
  )
) +
  geom_line(
    linewidth = 0.8
  ) +
  geom_point(
    size = 2.5
  ) +
  scale_x_continuous(
    breaks = 2012:2021
  ) +
  labs(
    title =
      "XGBoost RMSE by Validation Year",
    
    x =
      "Validation Year",
    
    y =
      "RMSE (bushels per acre)",
    
    linetype =
      "Predictor Group",
    
    shape =
      "Predictor Group"
  ) +
  theme_minimal(
    base_size = 12
  ) +
  theme(
    legend.position =
      "bottom"
  ) +
  guides(
    linetype = guide_legend(
      nrow = 2,
      byrow = TRUE
    ),
    
    shape = guide_legend(
      nrow = 2,
      byrow = TRUE
    )
  )

print(
  xgb_rmse_plot
)

xgb_output_directory <-
  "output/gradient_boosting"

dir.create(
  xgb_output_directory,
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  filename =
    file.path(
      xgb_output_directory,
      "xgb_rmse_by_validation_year.png"
    ),
  
  plot =
    xgb_rmse_plot,
  
  width =
    9,
  
  height =
    5,
  
  dpi =
    300
)

# ------------------------------------------------------------
# 23. Save final XGBoost outputs
# ------------------------------------------------------------

write_csv(
  xgb_predictions_all,
  file.path(
    xgb_output_directory,
    "xgb_predictions_all.csv"
  )
)

write_csv(
  xgb_metrics_all,
  file.path(
    xgb_output_directory,
    "xgb_yearly_performance.csv"
  )
)

write_csv(
  xgb_performance_summary,
  file.path(
    xgb_output_directory,
    "xgb_performance_summary.csv"
  )
)

write_csv(
  xgb_pooled_performance,
  file.path(
    xgb_output_directory,
    "xgb_pooled_performance.csv"
  )
)

write_csv(
  xgb_pooled_incremental_comparison,
  file.path(
    xgb_output_directory,
    "xgb_pooled_incremental_comparison.csv"
  )
)

write_csv(
  xgb_yearly_win_counts,
  file.path(
    xgb_output_directory,
    "xgb_yearly_win_counts.csv"
  )
)

write_csv(
  xgb_sensitivity_excluding_2012,
  file.path(
    xgb_output_directory,
    "xgb_sensitivity_excluding_2012.csv"
  )
)

write_csv(
  xgb_tuning_all,
  file.path(
    xgb_output_directory,
    "xgb_tuning_results.csv"
  )
)

saveRDS(
  xgb_results_group_1,
  file.path(
    xgb_output_directory,
    "xgb_results_group_1.rds"
  )
)

saveRDS(
  xgb_results_group_2,
  file.path(
    xgb_output_directory,
    "xgb_results_group_2.rds"
  )
)

saveRDS(
  xgb_results_group_3,
  file.path(
    xgb_output_directory,
    "xgb_results_group_3.rds"
  )
)

list.files(
  xgb_output_directory
)

# ------------------------------------------------------------
# 24. Record XGBoost development result
# ------------------------------------------------------------

xgb_model_result <- tibble(
  algorithm =
    "XGBoost",
  
  preferred_predictor_group =
    "Group 3",
  
  pooled_rmse =
    28.4,
  
  pooled_mae =
    22.2,
  
  pooled_r_squared =
    0.289,
  
  rmse_wins =
    6,
  
  mae_wins =
    5,
  
  sensitivity_mean_rmse_excluding_2012 =
    22.4,
  
  sensitivity_mean_mae_excluding_2012 =
    19.0,
  
  interpretation =
    paste(
      "Conventional weather substantially improved",
      "XGBoost performance over the historical baseline.",
      "Retained extreme-weather indicators provided",
      "a further overall improvement, although Group 3",
      "was not the best-performing group in every year."
    )
)

xgb_model_result

write_csv(
  xgb_model_result,
  file.path(
    xgb_output_directory,
    "xgb_model_result.csv"
  )
)

list.files(
  xgb_output_directory
)
