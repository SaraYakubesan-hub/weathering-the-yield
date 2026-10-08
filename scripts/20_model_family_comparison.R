# ============================================================
# Model-Family Comparison
# Senior Thesis
#
# Purpose:
# Compare development-stage performance across multiple linear
# regression, Random Forest, and XGBoost using the same
# predictor groups and 2012-2021 validation period.
#
# RMSE and MAE are the primary comparison metrics.
# R-squared is retained as a secondary metric.
#
# Only completed development-stage results are used.
# The 2022-2025 final holdout is not loaded or used.
# ============================================================

library(tidyverse)


# ------------------------------------------------------------
# 1. Load completed model-family results
# ------------------------------------------------------------

linear_metrics <- read_csv(
  "output/linear_model_comparison/linear_metrics_by_year.csv",
  show_col_types = FALSE
)

rf_metrics <- read_csv(
  "output/random_forest_comparison/rf_metrics_by_year.csv",
  show_col_types = FALSE
)

xgb_metrics <- read_csv(
  "output/gradient_boosting/xgb_yearly_performance.csv",
  show_col_types = FALSE
)

dim(
  linear_metrics
)

dim(
  rf_metrics
)

dim(
  xgb_metrics
)

names(
  linear_metrics
)

names(
  rf_metrics
)

names(
  xgb_metrics
)

range(
  linear_metrics$validation_year
)

range(
  rf_metrics$validation_year
)

range(
  xgb_metrics$validation_year
)

# ------------------------------------------------------------
# 2. Standardize model-family results
# ------------------------------------------------------------

linear_comparison <- linear_metrics %>%
  transmute(
    algorithm =
      "Linear Regression",
    
    predictor_group = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "Group 1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "Group 2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "Group 3",
      
      TRUE ~ NA_character_
    ),
    
    validation_year =
      validation_year,
    
    n =
      observations,
    
    rmse =
      rmse,
    
    mae =
      mae,
    
    r_squared =
      r_squared
  )


rf_comparison <- rf_metrics %>%
  transmute(
    algorithm =
      "Random Forest",
    
    predictor_group = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "Group 1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "Group 2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "Group 3",
      
      TRUE ~ NA_character_
    ),
    
    validation_year =
      validation_year,
    
    n =
      observations,
    
    rmse =
      rmse,
    
    mae =
      mae,
    
    r_squared =
      r_squared
  )


xgb_comparison <- xgb_metrics %>%
  transmute(
    algorithm =
      "XGBoost",
    
    predictor_group = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "Group 1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "Group 2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "Group 3",
      
      TRUE ~ NA_character_
    ),
    
    validation_year =
      validation_year,
    
    n =
      observations,
    
    rmse =
      rmse,
    
    mae =
      mae,
    
    r_squared =
      r_squared
  )


model_family_comparison <- bind_rows(
  linear_comparison,
  rf_comparison,
  xgb_comparison
)

dim(
  model_family_comparison
)

names(
  model_family_comparison
)

print(
  model_family_comparison,
  n = 15,
  width = Inf
)

# ------------------------------------------------------------
# 3. Verify model-family comparison structure
# ------------------------------------------------------------

# Confirm no predictor-group labels failed
sum(
  is.na(
    model_family_comparison$
      predictor_group
  )
)

# Confirm 10 validation years per
# algorithm and predictor group
model_family_comparison %>%
  count(
    algorithm,
    predictor_group,
    name = "validation_years"
  )

# Confirm identical observation counts
# across algorithms within each year/group
comparison_observation_check <-
  model_family_comparison %>%
  group_by(
    validation_year,
    predictor_group
  ) %>%
  summarise(
    algorithms =
      n_distinct(algorithm),
    
    minimum_n =
      min(n),
    
    maximum_n =
      max(n),
    
    .groups =
      "drop"
  )

print(
  comparison_observation_check,
  n = Inf,
  width = Inf
)

# Safeguards
stopifnot(
  nrow(model_family_comparison) == 90
)

stopifnot(
  !any(
    is.na(
      model_family_comparison$
        predictor_group
    )
  )
)

stopifnot(
  all(
    comparison_observation_check$
      algorithms == 3
  )
)

stopifnot(
  all(
    comparison_observation_check$
      minimum_n ==
      comparison_observation_check$
      maximum_n
  )
)

# ------------------------------------------------------------
# 4. Summarize annual model-family performance
# ------------------------------------------------------------

model_family_annual_summary <-
  model_family_comparison %>%
  group_by(
    algorithm,
    predictor_group
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
  ) %>%
  arrange(
    predictor_group,
    mean_rmse
  )

print(
  model_family_annual_summary,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 5. Load pooled model-family performance
# ------------------------------------------------------------

linear_pooled <- read_csv(
  "output/linear_model_comparison/linear_pooled_performance.csv",
  show_col_types = FALSE
)

rf_pooled <- read_csv(
  "output/random_forest_comparison/rf_pooled_performance.csv",
  show_col_types = FALSE
)

xgb_pooled <- read_csv(
  "output/gradient_boosting/xgb_pooled_performance.csv",
  show_col_types = FALSE
)

dim(
  linear_pooled
)

dim(
  rf_pooled
)

dim(
  xgb_pooled
)

names(
  linear_pooled
)

names(
  rf_pooled
)

names(
  xgb_pooled
)

print(
  linear_pooled,
  n = Inf,
  width = Inf
)

print(
  rf_pooled,
  n = Inf,
  width = Inf
)

print(
  xgb_pooled,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 6. Standardize pooled model-family performance
# ------------------------------------------------------------

linear_pooled_comparison <- linear_pooled %>%
  transmute(
    algorithm =
      "Linear Regression",
    
    predictor_group = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "Group 1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "Group 2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "Group 3",
      
      TRUE ~ NA_character_
    ),
    
    observations =
      observations,
    
    pooled_rmse =
      rmse,
    
    pooled_mae =
      mae,
    
    pooled_r_squared =
      r_squared
  )


rf_pooled_comparison <- rf_pooled %>%
  transmute(
    algorithm =
      "Random Forest",
    
    predictor_group = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "Group 1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "Group 2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "Group 3",
      
      TRUE ~ NA_character_
    ),
    
    observations =
      observations,
    
    pooled_rmse =
      rmse,
    
    pooled_mae =
      mae,
    
    pooled_r_squared =
      r_squared
  )


xgb_pooled_comparison <- xgb_pooled %>%
  transmute(
    algorithm =
      "XGBoost",
    
    predictor_group = case_when(
      str_starts(
        model_group,
        "Group 1"
      ) ~ "Group 1",
      
      str_starts(
        model_group,
        "Group 2"
      ) ~ "Group 2",
      
      str_starts(
        model_group,
        "Group 3"
      ) ~ "Group 3",
      
      TRUE ~ NA_character_
    ),
    
    observations =
      observations,
    
    pooled_rmse =
      rmse,
    
    pooled_mae =
      mae,
    
    pooled_r_squared =
      r_squared
  )


model_family_pooled_comparison <- bind_rows(
  linear_pooled_comparison,
  rf_pooled_comparison,
  xgb_pooled_comparison
) %>%
  arrange(
    predictor_group,
    pooled_rmse
  )

print(
  model_family_pooled_comparison,
  n = Inf,
  width = Inf
)


# Safeguards
stopifnot(
  nrow(
    model_family_pooled_comparison
  ) == 9
)

stopifnot(
  !any(
    is.na(
      model_family_pooled_comparison$
        predictor_group
    )
  )
)

stopifnot(
  all(
    model_family_pooled_comparison$
      observations == 739
  )
)

# ------------------------------------------------------------
# 7. Rank algorithms within each predictor group
# ------------------------------------------------------------

model_family_pooled_ranked <-
  model_family_pooled_comparison %>%
  group_by(
    predictor_group
  ) %>%
  mutate(
    rmse_rank =
      rank(
        pooled_rmse,
        ties.method = "min"
      ),
    
    mae_rank =
      rank(
        pooled_mae,
        ties.method = "min"
      ),
    
    r_squared_rank =
      rank(
        -pooled_r_squared,
        ties.method = "min"
      )
  ) %>%
  ungroup() %>%
  arrange(
    predictor_group,
    rmse_rank
  )

print(
  model_family_pooled_ranked,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 8. Rank algorithms within each predictor group by year
# ------------------------------------------------------------

model_family_yearly_ranked <-
  model_family_comparison %>%
  group_by(
    validation_year,
    predictor_group
  ) %>%
  mutate(
    rmse_rank =
      min_rank(rmse),
    
    mae_rank =
      min_rank(mae),
    
    r_squared_rank =
      min_rank(
        desc(r_squared)
      )
  ) %>%
  ungroup() %>%
  arrange(
    validation_year,
    predictor_group,
    rmse_rank
  )

print(
  model_family_yearly_ranked,
  n = Inf,
  width = Inf
)

yearly_algorithm_winners <-
  model_family_yearly_ranked %>%
  filter(
    rmse_rank == 1
  ) %>%
  select(
    validation_year,
    predictor_group,
    algorithm,
    n,
    rmse,
    mae,
    r_squared
  ) %>%
  arrange(
    validation_year,
    predictor_group
  )

print(
  yearly_algorithm_winners,
  n = Inf,
  width = Inf
)

yearly_algorithm_win_counts <-
  yearly_algorithm_winners %>%
  count(
    predictor_group,
    algorithm,
    name = "rmse_wins"
  ) %>%
  arrange(
    predictor_group,
    desc(rmse_wins)
  )

print(
  yearly_algorithm_win_counts,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 9. Identify best overall model specification by year
# ------------------------------------------------------------

best_model_by_year <-
  model_family_comparison %>%
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
  ) %>%
  arrange(
    validation_year
  )

print(
  best_model_by_year,
  n = Inf,
  width = Inf
)

best_model_win_counts <-
  best_model_by_year %>%
  count(
    algorithm,
    predictor_group,
    name = "years_best_overall"
  ) %>%
  arrange(
    desc(years_best_overall)
  )

print(
  best_model_win_counts,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 10. Sensitivity analysis excluding 2012
# ------------------------------------------------------------

model_family_sensitivity_excluding_2012 <-
  model_family_comparison %>%
  filter(
    validation_year != 2012
  ) %>%
  group_by(
    algorithm,
    predictor_group
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
  ) %>%
  group_by(
    predictor_group
  ) %>%
  mutate(
    rmse_rank =
      min_rank(
        mean_rmse
      ),
    
    mae_rank =
      min_rank(
        mean_mae
      )
  ) %>%
  ungroup() %>%
  arrange(
    predictor_group,
    rmse_rank
  )

print(
  model_family_sensitivity_excluding_2012,
  n = Inf,
  width = Inf
)


# Identify overall ranking after excluding 2012
model_family_sensitivity_overall <-
  model_family_sensitivity_excluding_2012 %>%
  arrange(
    mean_rmse
  ) %>%
  mutate(
    overall_rmse_rank =
      row_number()
  )

print(
  model_family_sensitivity_overall,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 11. Plot RMSE across model families
# ------------------------------------------------------------

model_family_plot_data <-
  model_family_comparison %>%
  mutate(
    algorithm = factor(
      algorithm,
      levels = c(
        "Linear Regression",
        "Random Forest",
        "XGBoost"
      )
    ),
    
    predictor_group = factor(
      predictor_group,
      levels = c(
        "Group 1",
        "Group 2",
        "Group 3"
      ),
      labels = c(
        "Group 1 - Historical baseline",
        "Group 2 - + Conventional weather",
        "Group 3 - + Conventional + extremes"
      )
    )
  )

model_family_rmse_plot <- ggplot(
  model_family_plot_data,
  aes(
    x = validation_year,
    y = rmse,
    group = algorithm,
    color = algorithm,
    linetype = algorithm,
    shape = algorithm
  )
) +
  geom_line(
    linewidth = 0.8
  ) +
  geom_point(
    size = 2.2
  ) +
  facet_wrap(
    ~ predictor_group,
    ncol = 1
  ) +
  scale_x_continuous(
    breaks = 2012:2021
  ) +
  labs(
    title =
      "RMSE by Algorithm and Predictor Group",
    
    subtitle =
      "Expanding-window validation, 2012-2021",
    
    x =
      "Validation Year",
    
    y =
      "RMSE (bushels per acre)",
    
    color =
      "Algorithm",
    
    linetype =
      "Algorithm",
    
    shape =
      "Algorithm"
  ) +
  theme_minimal(
    base_size = 12
  ) +
  theme(
    legend.position =
      "bottom",
    
    axis.text.x =
      element_text(
        angle = 45,
        hjust = 1
      )
  )

print(
  model_family_rmse_plot
)

# ------------------------------------------------------------
# 12. Save model-family comparison outputs
# ------------------------------------------------------------

model_family_output_dir <-
  "output/model_family_comparison"

dir.create(
  model_family_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# Save standardized yearly comparison
write_csv(
  model_family_comparison,
  file.path(
    model_family_output_dir,
    "model_family_yearly_comparison.csv"
  )
)


# Save annual summary
write_csv(
  model_family_annual_summary,
  file.path(
    model_family_output_dir,
    "model_family_annual_summary.csv"
  )
)


# Save pooled comparison
write_csv(
  model_family_pooled_comparison,
  file.path(
    model_family_output_dir,
    "model_family_pooled_comparison.csv"
  )
)


# Save pooled rankings
write_csv(
  model_family_pooled_ranked,
  file.path(
    model_family_output_dir,
    "model_family_pooled_ranked.csv"
  )
)


# Save yearly rankings
write_csv(
  model_family_yearly_ranked,
  file.path(
    model_family_output_dir,
    "model_family_yearly_ranked.csv"
  )
)


# Save yearly algorithm winners
write_csv(
  yearly_algorithm_winners,
  file.path(
    model_family_output_dir,
    "yearly_algorithm_winners.csv"
  )
)


# Save algorithm win counts
write_csv(
  yearly_algorithm_win_counts,
  file.path(
    model_family_output_dir,
    "yearly_algorithm_win_counts.csv"
  )
)


# Save best overall specification by year
write_csv(
  best_model_by_year,
  file.path(
    model_family_output_dir,
    "best_model_by_year.csv"
  )
)


# Save best overall win counts
write_csv(
  best_model_win_counts,
  file.path(
    model_family_output_dir,
    "best_model_win_counts.csv"
  )
)


# Save 2012 sensitivity results
write_csv(
  model_family_sensitivity_excluding_2012,
  file.path(
    model_family_output_dir,
    "model_family_sensitivity_excluding_2012.csv"
  )
)

write_csv(
  model_family_sensitivity_overall,
  file.path(
    model_family_output_dir,
    "model_family_sensitivity_overall.csv"
  )
)


# Save cross-algorithm RMSE figure
ggsave(
  filename =
    file.path(
      model_family_output_dir,
      "model_family_rmse_by_validation_year.png"
    ),
  
  plot =
    model_family_rmse_plot,
  
  width =
    10,
  
  height =
    9,
  
  dpi =
    300
)

list.files(
  model_family_output_dir
)

# ------------------------------------------------------------
# 13. Record model-family development result
# ------------------------------------------------------------

model_family_result <- tibble(
  analysis =
    "Development-stage model-family comparison",
  
  development_period =
    "2001-2021",
  
  validation_period =
    "2012-2021",
  
  algorithms_compared =
    "Linear Regression, Random Forest, XGBoost",
  
  predictor_groups_compared =
    3,
  
  validation_observations_per_specification =
    739,
  
  best_development_algorithm =
    "Linear Regression",
  
  best_development_predictor_group =
    "Group 3",
  
  best_pooled_rmse =
    22.6,
  
  best_pooled_mae =
    18.1,
  
  best_pooled_r_squared =
    0.553,
  
  years_best_overall =
    6,
  
  sensitivity_mean_rmse_excluding_2012 =
    19.5,
  
  sensitivity_mean_mae_excluding_2012 =
    16.8,
  
  interpretation =
    paste(
      "Linear Regression with conventional and retained",
      "extreme-weather predictors produced the strongest",
      "overall development-stage performance. It had the",
      "lowest pooled RMSE and MAE and was the best overall",
      "specification in six of ten validation years.",
      "Its advantage remained when 2012 was excluded,",
      "although other model families performed best in",
      "some individual years."
    )
)

model_family_result

write_csv(
  model_family_result,
  file.path(
    model_family_output_dir,
    "model_family_result.csv"
  )
)

list.files(
  model_family_output_dir
)
