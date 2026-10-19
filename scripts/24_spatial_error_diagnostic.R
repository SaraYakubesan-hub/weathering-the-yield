# ============================================================
# Spatial Error Diagnostic
# Senior Thesis
#
# Purpose:
# Examine geographic variation in development-stage prediction
# error using the existing 2012-2021 Linear Regression
# rolling-validation predictions.
#
# The analysis focuses on:
# 1. County-level RMSE for the selected Group 3 model
# 2. Change in county-level RMSE from Group 1 to Group 3
#
# This is a descriptive diagnostic only.
# No new models are fitted.
# No predictors are changed.
# No model tuning is performed.
# The 2022-2025 final holdout is not loaded or used.
# ============================================================

library(tidyverse)


# ------------------------------------------------------------
# 1. Load completed Linear Regression validation predictions
# ------------------------------------------------------------

linear_validation_predictions <- read_csv(
  "output/linear_model_comparison/linear_validation_predictions.csv",
  show_col_types = FALSE
)


dim(
  linear_validation_predictions
)

names(
  linear_validation_predictions
)

glimpse(
  linear_validation_predictions
)


# ------------------------------------------------------------
# Verify development-stage prediction period
# ------------------------------------------------------------

range(
  linear_validation_predictions$
    validation_year
)

stopifnot(
  min(
    linear_validation_predictions$
      validation_year
  ) == 2012
)

stopifnot(
  max(
    linear_validation_predictions$
      validation_year
  ) == 2021
)

stopifnot(
  !any(
    linear_validation_predictions$
      validation_year >= 2022
  )
)


# ------------------------------------------------------------
# 2. Retain Group 1 and Group 3 predictions
# ------------------------------------------------------------

spatial_comparison_predictions <-
  linear_validation_predictions %>%
  filter(
    model_group %in%
      c(
        "Group 1 - Historical baseline",
        "Group 3 - Historical + conventional + extremes"
      )
  )


dim(
  spatial_comparison_predictions
)


spatial_comparison_predictions %>%
  count(
    model_group,
    name = "observations"
  ) %>%
  print(
    n = Inf,
    width = Inf
  )


# ------------------------------------------------------------
# Verify matching county-year observations
# ------------------------------------------------------------

spatial_comparison_ids <-
  spatial_comparison_predictions %>%
  count(
    validation_year,
    fips,
    county,
    name = "model_count"
  )


spatial_comparison_problems <-
  spatial_comparison_ids %>%
  filter(
    model_count != 2
  )


print(
  spatial_comparison_problems,
  n = Inf,
  width = Inf
)


stopifnot(
  nrow(
    spatial_comparison_problems
  ) == 0
)


# ------------------------------------------------------------
# 3. Audit county-level validation coverage
# ------------------------------------------------------------

county_validation_coverage <-
  spatial_comparison_predictions %>%
  distinct(
    model_group,
    validation_year,
    fips,
    county
  ) %>%
  count(
    model_group,
    fips,
    county,
    name =
      "validation_observations"
  ) %>%
  arrange(
    model_group,
    fips
  )


print(
  county_validation_coverage,
  n = Inf,
  width = Inf
)


county_coverage_summary <-
  county_validation_coverage %>%
  group_by(
    model_group
  ) %>%
  summarise(
    counties =
      n(),
    
    minimum_validation_observations =
      min(
        validation_observations
      ),
    
    median_validation_observations =
      median(
        validation_observations
      ),
    
    maximum_validation_observations =
      max(
        validation_observations
      ),
    
    .groups = "drop"
  )


print(
  county_coverage_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Verify identical county coverage across Groups 1 and 3
# ------------------------------------------------------------

county_coverage_comparison <-
  county_validation_coverage %>%
  select(
    model_group,
    fips,
    county,
    validation_observations
  ) %>%
  pivot_wider(
    names_from =
      model_group,
    
    values_from =
      validation_observations,
    
    names_prefix =
      "observations_"
  )


county_coverage_mismatch <-
  county_coverage_comparison %>%
  filter(
    `observations_Group 1 - Historical baseline` !=
      `observations_Group 3 - Historical + conventional + extremes`
  )


print(
  county_coverage_mismatch,
  n = Inf,
  width = Inf
)


stopifnot(
  nrow(
    county_coverage_mismatch
  ) == 0
)


# ------------------------------------------------------------
# 4. Calculate county-level prediction error
# ------------------------------------------------------------

county_model_performance <-
  spatial_comparison_predictions %>%
  group_by(
    model_group,
    fips,
    county
  ) %>%
  summarise(
    validation_observations =
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
    
    mean_residual =
      mean(
        residual
      ),
    
    .groups = "drop"
  )


print(
  county_model_performance,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Compare Group 1 and Group 3 county RMSE
# ------------------------------------------------------------

county_rmse_comparison <-
  county_model_performance %>%
  select(
    model_group,
    fips,
    county,
    validation_observations,
    rmse,
    mae,
    mean_residual
  ) %>%
  pivot_wider(
    names_from =
      model_group,
    
    values_from =
      c(
        validation_observations,
        rmse,
        mae,
        mean_residual
      )
  ) %>%
  mutate(
    rmse_reduction_G1_to_G3 =
      `rmse_Group 1 - Historical baseline` -
      `rmse_Group 3 - Historical + conventional + extremes`,
    
    rmse_pct_reduction_G1_to_G3 =
      100 *
      rmse_reduction_G1_to_G3 /
      `rmse_Group 1 - Historical baseline`
  ) %>%
  arrange(
    desc(
      rmse_reduction_G1_to_G3
    )
  )


print(
  county_rmse_comparison,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Summarize county-level Group 3 performance
# ------------------------------------------------------------

group3_county_summary <-
  county_model_performance %>%
  filter(
    model_group ==
      "Group 3 - Historical + conventional + extremes"
  ) %>%
  summarise(
    counties =
      n(),
    
    mean_county_rmse =
      mean(
        rmse
      ),
    
    median_county_rmse =
      median(
        rmse
      ),
    
    minimum_county_rmse =
      min(
        rmse
      ),
    
    maximum_county_rmse =
      max(
        rmse
      )
  )


print(
  group3_county_summary,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Summarize county-level change from Group 1 to Group 3
# ------------------------------------------------------------

county_improvement_summary <-
  county_rmse_comparison %>%
  summarise(
    counties =
      n(),
    
    counties_lower_rmse_with_group3 =
      sum(
        rmse_reduction_G1_to_G3 > 0
      ),
    
    counties_higher_rmse_with_group3 =
      sum(
        rmse_reduction_G1_to_G3 < 0
      ),
    
    counties_equal_rmse =
      sum(
        rmse_reduction_G1_to_G3 == 0
      ),
    
    median_rmse_reduction =
      median(
        rmse_reduction_G1_to_G3
      ),
    
    mean_rmse_reduction =
      mean(
        rmse_reduction_G1_to_G3
      ),
    
    median_percent_reduction =
      median(
        rmse_pct_reduction_G1_to_G3
      )
  )


print(
  county_improvement_summary,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 5. Prepare Indiana county map and verify spatial join
# ------------------------------------------------------------

# The maps package provides county boundary data used only
# for visualization.
if (
  !requireNamespace(
    "maps",
    quietly = TRUE
  )
) {
  stop(
    paste(
      "The 'maps' package is required for the spatial",
      "diagnostic. Install it with install.packages('maps')",
      "and rerun this section."
    )
  )
}


# ------------------------------------------------------------
# Load Indiana county polygon data
# ------------------------------------------------------------

indiana_county_map <-
  ggplot2::map_data(
    "county",
    region = "indiana"
  ) %>%
  mutate(
    county_key =
      subregion %>%
      str_to_lower() %>%
      str_replace_all(
        "[^a-z0-9]",
        ""
      )
  )


dim(
  indiana_county_map
)

names(
  indiana_county_map
)


# ------------------------------------------------------------
# Create spatial metric table
# ------------------------------------------------------------

county_spatial_metrics <-
  county_rmse_comparison %>%
  transmute(
    fips =
      sprintf(
        "%05d",
        as.integer(
          fips
        )
      ),
    
    county = county,
    
    county_key =
      county %>%
      str_to_lower() %>%
      str_replace_all(
        "[^a-z0-9]",
        ""
      ),
    
    validation_observations =
      `validation_observations_Group 3 - Historical + conventional + extremes`,
    
    group1_rmse =
      `rmse_Group 1 - Historical baseline`,
    
    group3_rmse =
      `rmse_Group 3 - Historical + conventional + extremes`,
    
    rmse_reduction_G1_to_G3 =
      rmse_reduction_G1_to_G3,
    
    rmse_pct_reduction_G1_to_G3 =
      rmse_pct_reduction_G1_to_G3
  )


print(
  county_spatial_metrics,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Create unique county lookup from map data
# ------------------------------------------------------------

map_county_lookup <-
  indiana_county_map %>%
  distinct(
    county_key,
    map_county =
      subregion
  ) %>%
  arrange(
    county_key
  )


print(
  as_tibble(
    map_county_lookup
  ),
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Verify map county structure
# ------------------------------------------------------------

stopifnot(
  nrow(
    map_county_lookup
  ) == 92
)

stopifnot(
  n_distinct(
    map_county_lookup$
      county_key
  ) == 92
)


# ------------------------------------------------------------
# Identify modeled counties that do not match map counties
# ------------------------------------------------------------

unmatched_model_counties <-
  county_spatial_metrics %>%
  anti_join(
    map_county_lookup,
    by = "county_key"
  )


print(
  unmatched_model_counties,
  n = Inf,
  width = Inf
)

map_county_lookup <-
  as_tibble(
    map_county_lookup
  )

indiana_county_map <-
  as_tibble(
    indiana_county_map
  )

# ------------------------------------------------------------
# Identify Indiana counties without validation results
# ------------------------------------------------------------

map_counties_without_validation <-
  map_county_lookup %>%
  anti_join(
    county_spatial_metrics,
    by = "county_key"
  )


print(
  map_counties_without_validation,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Join county metrics to Indiana map polygons
# ------------------------------------------------------------

indiana_spatial_results <-
  indiana_county_map %>%
  left_join(
    county_spatial_metrics,
    by = "county_key"
  )


# ------------------------------------------------------------
# Verify spatial join
# ------------------------------------------------------------

mapped_model_counties <-
  indiana_spatial_results %>%
  filter(
    !is.na(
      group3_rmse
    )
  ) %>%
  distinct(
    county_key
  )


nrow(
  mapped_model_counties
)


stopifnot(
  nrow(
    unmatched_model_counties
  ) == 0
)

stopifnot(
  nrow(
    mapped_model_counties
  ) == 89
)

# ------------------------------------------------------------
# 6. Create county-level spatial diagnostic maps
# ------------------------------------------------------------

spatial_output_dir <-
  "output/spatial_error_diagnostic"


dir.create(
  spatial_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------
# Map 1: Group 3 county-level RMSE
# ------------------------------------------------------------

group3_rmse_map <-
  indiana_spatial_results %>%
  ggplot(
    aes(
      x = long,
      y = lat,
      group = group,
      fill = group3_rmse
    )
  ) +
  geom_polygon(
    linewidth = 0.2
  ) +
  coord_quickmap() +
  scale_fill_viridis_c(
    option = "C",
    na.value = "grey90",
    name =
      "RMSE\n(bu/acre)"
  ) +
  labs(
    title =
      "County-Level RMSE for the Selected Group 3 Model",
    subtitle =
      "Linear Regression rolling validation, 2012-2021",
    caption =
      "Gray counties had no eligible validation observations."
  ) +
  theme_void() +
  theme(
    plot.title =
      element_text(
        face = "bold"
      ),
    
    legend.position =
      "right"
  )


group3_rmse_map


# ------------------------------------------------------------
# Map 2: RMSE change from Group 1 to Group 3
# ------------------------------------------------------------

rmse_reduction_limit <-
  max(
    abs(
      indiana_spatial_results$
        rmse_reduction_G1_to_G3
    ),
    na.rm = TRUE
  )


rmse_reduction_map <-
  indiana_spatial_results %>%
  ggplot(
    aes(
      x = long,
      y = lat,
      group = group,
      fill =
        rmse_reduction_G1_to_G3
    )
  ) +
  geom_polygon(
    linewidth = 0.2
  ) +
  coord_quickmap() +
  scale_fill_gradient2(
    midpoint = 0,
    limits =
      c(
        -rmse_reduction_limit,
        rmse_reduction_limit
      ),
    na.value = "grey90",
    name =
      "RMSE reduction\n(bu/acre)"
  ) +
  labs(
    title =
      "County-Level Change in RMSE from Group 1 to Group 3",
    subtitle =
      paste(
        "Positive values indicate lower prediction error",
        "after adding weather predictors"
      ),
    caption =
      paste(
        "Linear Regression rolling validation, 2012-2021.",
        "Gray counties had no eligible validation observations."
      )
  ) +
  theme_void() +
  theme(
    plot.title =
      element_text(
        face = "bold"
      ),
    
    legend.position =
      "right"
  )


rmse_reduction_map


# ------------------------------------------------------------
# Save spatial diagnostic figures
# ------------------------------------------------------------

ggsave(
  file.path(
    spatial_output_dir,
    "group3_county_rmse_map.png"
  ),
  plot = group3_rmse_map,
  width = 8,
  height = 8,
  dpi = 300
)


ggsave(
  file.path(
    spatial_output_dir,
    "county_rmse_reduction_G1_to_G3_map.png"
  ),
  plot = rmse_reduction_map,
  width = 8,
  height = 8,
  dpi = 300
)


# ------------------------------------------------------------
# Verify saved spatial figures
# ------------------------------------------------------------

expected_spatial_figure_files <- c(
  "county_rmse_reduction_G1_to_G3_map.png",
  "group3_county_rmse_map.png"
)


saved_spatial_figure_files <-
  list.files(
    spatial_output_dir
  )


print(
  saved_spatial_figure_files
)


missing_spatial_figure_files <-
  setdiff(
    expected_spatial_figure_files,
    saved_spatial_figure_files
  )


print(
  missing_spatial_figure_files
)


stopifnot(
  length(
    missing_spatial_figure_files
  ) == 0
)

# ------------------------------------------------------------
# 7. Document and save spatial diagnostic results
# ------------------------------------------------------------

# Create concise spatial diagnostic result record
spatial_diagnostic_result <-
  tibble(
    analysis =
      "Development-stage spatial error diagnostic",
    
    model_algorithm =
      "Linear Regression",
    
    comparison =
      "Group 1 vs. Group 3",
    
    development_period =
      "2001-2021",
    
    validation_period =
      "2012-2021",
    
    counties_evaluated =
      nrow(
        county_rmse_comparison
      ),
    
    counties_without_validation =
      nrow(
        map_counties_without_validation
      ),
    
    median_validation_observations_per_county =
      median(
        county_spatial_metrics$
          validation_observations
      ),
    
    group3_mean_county_rmse =
      group3_county_summary$
      mean_county_rmse,
    
    group3_median_county_rmse =
      group3_county_summary$
      median_county_rmse,
    
    counties_lower_rmse_with_group3 =
      county_improvement_summary$
      counties_lower_rmse_with_group3,
    
    counties_higher_rmse_with_group3 =
      county_improvement_summary$
      counties_higher_rmse_with_group3,
    
    median_rmse_reduction =
      county_improvement_summary$
      median_rmse_reduction,
    
    mean_rmse_reduction =
      county_improvement_summary$
      mean_rmse_reduction,
    
    median_percent_rmse_reduction =
      county_improvement_summary$
      median_percent_reduction,
    
    spatial_analysis_descriptive_only =
      TRUE,
    
    model_changes_after_spatial_diagnostic =
      FALSE
  )


print(
  spatial_diagnostic_result,
  n = Inf,
  width = Inf
)


# ------------------------------------------------------------
# Save county-level spatial diagnostic tables
# ------------------------------------------------------------

write_csv(
  county_model_performance,
  file.path(
    spatial_output_dir,
    "county_model_performance.csv"
  )
)


write_csv(
  county_rmse_comparison,
  file.path(
    spatial_output_dir,
    "county_rmse_comparison_G1_to_G3.csv"
  )
)


write_csv(
  county_validation_coverage,
  file.path(
    spatial_output_dir,
    "county_validation_coverage.csv"
  )
)


write_csv(
  county_improvement_summary,
  file.path(
    spatial_output_dir,
    "county_improvement_summary.csv"
  )
)


write_csv(
  group3_county_summary,
  file.path(
    spatial_output_dir,
    "group3_county_summary.csv"
  )
)


write_csv(
  county_spatial_metrics,
  file.path(
    spatial_output_dir,
    "county_spatial_metrics.csv"
  )
)


write_csv(
  map_counties_without_validation,
  file.path(
    spatial_output_dir,
    "counties_without_validation.csv"
  )
)


write_csv(
  spatial_diagnostic_result,
  file.path(
    spatial_output_dir,
    "spatial_diagnostic_result.csv"
  )
)


# ------------------------------------------------------------
# Verify final spatial diagnostic output package
# ------------------------------------------------------------

expected_spatial_files <- c(
  "counties_without_validation.csv",
  "county_improvement_summary.csv",
  "county_model_performance.csv",
  "county_rmse_comparison_G1_to_G3.csv",
  "county_rmse_reduction_G1_to_G3_map.png",
  "county_spatial_metrics.csv",
  "county_validation_coverage.csv",
  "group3_county_rmse_map.png",
  "group3_county_summary.csv",
  "spatial_diagnostic_result.csv"
)


saved_spatial_files <-
  list.files(
    spatial_output_dir
  )


print(
  saved_spatial_files
)


missing_spatial_files <-
  setdiff(
    expected_spatial_files,
    saved_spatial_files
  )


print(
  missing_spatial_files
)


stopifnot(
  length(
    missing_spatial_files
  ) == 0
)


# ------------------------------------------------------------
# Final Script 24 safeguards
# ------------------------------------------------------------

stopifnot(
  spatial_diagnostic_result$
    counties_evaluated ==
    89
)

stopifnot(
  spatial_diagnostic_result$
    counties_without_validation ==
    3
)

stopifnot(
  spatial_diagnostic_result$
    counties_lower_rmse_with_group3 ==
    78
)

stopifnot(
  spatial_diagnostic_result$
    counties_higher_rmse_with_group3 ==
    11
)

stopifnot(
  spatial_diagnostic_result$
    spatial_analysis_descriptive_only ==
    TRUE
)

stopifnot(
  spatial_diagnostic_result$
    model_changes_after_spatial_diagnostic ==
    FALSE
)


# ------------------------------------------------------------
# Script completion checkpoint
# ------------------------------------------------------------

cat(
  "\n",
  "Script 24 complete.\n",
  "Spatial diagnostic period: 2012-2021 validation\n",
  "Models compared: Linear Regression Group 1 vs. Group 3\n",
  "Counties evaluated:",
  spatial_diagnostic_result$counties_evaluated,
  "\n",
  "Counties with lower RMSE under Group 3:",
  spatial_diagnostic_result$counties_lower_rmse_with_group3,
  "\n",
  "Counties with higher RMSE under Group 3:",
  spatial_diagnostic_result$counties_higher_rmse_with_group3,
  "\n",
  "Median county RMSE reduction:",
  round(
    spatial_diagnostic_result$
      median_rmse_reduction,
    2
  ),
  "bu/acre\n",
  "Median percent RMSE reduction:",
  round(
    spatial_diagnostic_result$
      median_percent_rmse_reduction,
    1
  ),
  "%\n",
  "Model changes after spatial diagnostic: FALSE\n"
)
