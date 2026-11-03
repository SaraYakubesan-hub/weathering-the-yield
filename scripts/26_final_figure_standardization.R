# ============================================================
# Final Figure Standardization
# Senior Thesis
#
# Purpose:
# Create final presentation-ready versions of selected thesis
# figures using results that were already generated during the
# completed development-stage and spatial analyses.
#
# IMPORTANT:
# - This script does not refit any models.
# - This script does not change model selection.
# - This script does not recalculate holdout performance.
# - This script changes figure presentation only.
#
# Figures refreshed:
#   Figure 1 - Linear Regression RMSE
#   Figure 2 - Random Forest RMSE
#   Figure 3 - XGBoost RMSE
#   Figure 4 - Cross-model-family RMSE
#   Figure 7 - County-level Group 3 RMSE
#   Figure 8 - County-level RMSE change, Group 1 to Group 3
# ============================================================


library(tidyverse)


# ------------------------------------------------------------
# 1. Create output directory
# ------------------------------------------------------------

figure_output_dir <-
  "output/final_figure_standardization"


dir.create(
  figure_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------
# 2. Load completed development-stage comparison results
# ------------------------------------------------------------

model_family_comparison <-
  read_csv(
    "output/model_family_comparison/model_family_yearly_comparison.csv",
    show_col_types = FALSE
  )


print(
  dim(
    model_family_comparison
  )
)


print(
  names(
    model_family_comparison
  )
)


# Verify expected completed-development structure
stopifnot(
  nrow(
    model_family_comparison
  ) == 90
)

stopifnot(
  n_distinct(
    model_family_comparison$algorithm
  ) == 3
)

stopifnot(
  n_distinct(
    model_family_comparison$predictor_group
  ) == 3
)

stopifnot(
  min(
    model_family_comparison$validation_year
  ) == 2012
)

stopifnot(
  max(
    model_family_comparison$validation_year
  ) == 2021
)


# ------------------------------------------------------------
# 3. Define standardized predictor-group labels
# ------------------------------------------------------------

predictor_group_labels <- c(
  "Group 1" =
    "Group 1: Historical baseline",
  
  "Group 2" =
    "Group 2: Historical + conventional weather",
  
  "Group 3" =
    "Group 3: Historical + conventional + extremes"
)


predictor_group_linetypes <- c(
  "Group 1" = "solid",
  "Group 2" = "dashed",
  "Group 3" = "dotted"
)


predictor_group_shapes <- c(
  "Group 1" = 16,
  "Group 2" = 17,
  "Group 3" = 15
)


# ------------------------------------------------------------
# 4. Create common function for Figures 1-3
# ------------------------------------------------------------

make_predictor_group_rmse_plot <- function(
    plot_data
) {
  
  ggplot(
    plot_data,
    aes(
      x = validation_year,
      y = rmse,
      group = predictor_group,
      linetype = predictor_group,
      shape = predictor_group
    )
  ) +
    
    geom_line(
      linewidth = 0.85
    ) +
    
    geom_point(
      size = 2.5
    ) +
    
    scale_x_continuous(
      breaks = 2012:2021
    ) +
    
    scale_linetype_manual(
      values =
        predictor_group_linetypes,
      
      labels =
        predictor_group_labels,
      
      name =
        "Predictor Group"
    ) +
    
    scale_shape_manual(
      values =
        predictor_group_shapes,
      
      labels =
        predictor_group_labels,
      
      name =
        "Predictor Group"
    ) +
    
    labs(
      x =
        "Validation Year",
      
      y =
        "RMSE (bushels per acre)"
    ) +
    
    theme_minimal(
      base_size = 12
    ) +
    
    theme(
      panel.grid.minor =
        element_blank(),
      
      legend.position =
        "bottom",
      
      legend.title =
        element_text(
          face = "bold"
        ),
      
      axis.text.x =
        element_text(
          angle = 45,
          hjust = 1
        )
    ) +
    
    guides(
      linetype =
        guide_legend(
          ncol = 1,
          byrow = TRUE
        ),
      
      shape =
        guide_legend(
          ncol = 1,
          byrow = TRUE
        )
    )
}


# ------------------------------------------------------------
# 5. Figure 1 - Linear Regression
# ------------------------------------------------------------

figure_1_linear <-
  model_family_comparison %>%
  filter(
    algorithm ==
      "Linear Regression"
  ) %>%
  make_predictor_group_rmse_plot()


figure_1_linear


# ------------------------------------------------------------
# 6. Figure 2 - Random Forest
# ------------------------------------------------------------

figure_2_rf <-
  model_family_comparison %>%
  filter(
    algorithm ==
      "Random Forest"
  ) %>%
  make_predictor_group_rmse_plot()


figure_2_rf


# ------------------------------------------------------------
# 7. Figure 3 - XGBoost
# ------------------------------------------------------------

figure_3_xgb <-
  model_family_comparison %>%
  filter(
    algorithm ==
      "XGBoost"
  ) %>%
  make_predictor_group_rmse_plot()


figure_3_xgb


# ------------------------------------------------------------
# 8. Prepare data for Figure 4
# ------------------------------------------------------------

figure_4_data <-
  model_family_comparison %>%
  mutate(
    predictor_group =
      factor(
        predictor_group,
        levels = c(
          "Group 1",
          "Group 2",
          "Group 3"
        ),
        labels = c(
          "Group 1: Historical baseline",
          "Group 2: Historical + conventional weather",
          "Group 3: Historical + conventional + extremes"
        )
      ),
    
    algorithm =
      factor(
        algorithm,
        levels = c(
          "Linear Regression",
          "Random Forest",
          "XGBoost"
        )
      )
  )


# ------------------------------------------------------------
# 9. Figure 4 - Model-family comparison
# ------------------------------------------------------------

figure_4_model_family <-
  ggplot(
    figure_4_data,
    aes(
      x = validation_year,
      y = rmse,
      group = algorithm,
      linetype = algorithm,
      shape = algorithm
    )
  ) +
  
  geom_line(
    linewidth = 0.8
  ) +
  
  geom_point(
    size = 2.3
  ) +
  
  facet_wrap(
    ~ predictor_group,
    ncol = 1
  ) +
  
  scale_x_continuous(
    breaks = 2012:2021
  ) +
  
  scale_linetype_manual(
    values = c(
      "Linear Regression" = "solid",
      "Random Forest" = "dashed",
      "XGBoost" = "dotted"
    )
  ) +
  
  scale_shape_manual(
    values = c(
      "Linear Regression" = 16,
      "Random Forest" = 17,
      "XGBoost" = 15
    )
  ) +
  
  labs(
    x =
      "Validation Year",
    
    y =
      "RMSE (bushels per acre)",
    
    linetype =
      "Algorithm",
    
    shape =
      "Algorithm"
  ) +
  
  theme_minimal(
    base_size = 11
  ) +
  
  theme(
    panel.grid.minor =
      element_blank(),
    
    legend.position =
      "bottom",
    
    legend.title =
      element_text(
        face = "bold"
      ),
    
    strip.text =
      element_text(
        face = "bold",
        size = 11
      ),
    
    axis.text.x =
      element_text(
        angle = 45,
        hjust = 1
      )
  )


figure_4_model_family


# ------------------------------------------------------------
# 10. Save Figures 1-4
# ------------------------------------------------------------

ggsave(
  file.path(
    figure_output_dir,
    "figure1_linear_rmse_standardized.png"
  ),
  plot = figure_1_linear,
  width = 7,
  height = 5,
  dpi = 300,
  bg = "white"
)


ggsave(
  file.path(
    figure_output_dir,
    "figure2_rf_rmse_standardized.png"
  ),
  plot = figure_2_rf,
  width = 7,
  height = 5,
  dpi = 300,
  bg = "white"
)


ggsave(
  file.path(
    figure_output_dir,
    "figure3_xgb_rmse_standardized.png"
  ),
  plot = figure_3_xgb,
  width = 7,
  height = 5,
  dpi = 300,
  bg = "white"
)


ggsave(
  file.path(
    figure_output_dir,
    "figure4_model_family_rmse_standardized.png"
  ),
  plot = figure_4_model_family,
  width = 7,
  height = 8,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 11. Load completed county-level spatial results
# ------------------------------------------------------------

county_spatial_metrics <-
  read_csv(
    "output/spatial_error_diagnostic/county_spatial_metrics.csv",
    show_col_types = FALSE
  )


print(
  dim(
    county_spatial_metrics
  )
)


print(
  names(
    county_spatial_metrics
  )
)


stopifnot(
  nrow(
    county_spatial_metrics
  ) == 89
)


# ------------------------------------------------------------
# 12. Prepare Indiana county polygons
# ------------------------------------------------------------

if (
  !requireNamespace(
    "maps",
    quietly = TRUE
  )
) {
  
  stop(
    paste(
      "The 'maps' package is required.",
      "Install it with install.packages('maps')."
    )
  )
}


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


# ------------------------------------------------------------
# 13. Join saved metrics to map polygons
# ------------------------------------------------------------

spatial_plot_data <-
  indiana_county_map %>%
  left_join(
    county_spatial_metrics,
    by = "county_key"
  )


mapped_counties <-
  spatial_plot_data %>%
  filter(
    !is.na(
      group3_rmse
    )
  ) %>%
  distinct(
    county_key
  )


stopifnot(
  nrow(
    mapped_counties
  ) == 89
)


# ------------------------------------------------------------
# 14. Figure 7 - Group 3 county RMSE
# ------------------------------------------------------------

figure_7_group3_rmse <-
  ggplot(
    spatial_plot_data,
    aes(
      x = long,
      y = lat,
      group = group,
      fill = group3_rmse
    )
  ) +
  
  geom_polygon(
    color = "white",
    linewidth = 0.25
  ) +
  
  coord_quickmap(
    expand = FALSE
  ) +
  
  scale_fill_viridis_c(
    option = "C",
    na.value = "grey70",
    name =
      "RMSE\n(bu/acre)"
  ) +
  
  guides(
    fill =
      guide_colorbar(
        title.position = "top",
        barheight =
          grid::unit(
            2.4,
            "in"
          ),
        barwidth =
          grid::unit(
            0.25,
            "in"
          )
      )
  ) +
  
  theme_void(
    base_size = 12
  ) +
  
  theme(
    legend.position =
      "right",
    
    legend.title =
      element_text(
        face = "bold",
        size = 10
      ),
    
    legend.text =
      element_text(
        size = 10
      ),
    
    plot.background =
      element_rect(
        fill = "white",
        color = NA
      ),
    
    panel.background =
      element_rect(
        fill = "white",
        color = NA
      ),
    
    legend.background =
      element_rect(
        fill = "white",
        color = NA
      )
  )


figure_7_group3_rmse


# ------------------------------------------------------------
# 15. Figure 8 - RMSE change from Group 1 to Group 3
# ------------------------------------------------------------

rmse_reduction_limit <-
  max(
    abs(
      spatial_plot_data$
        rmse_reduction_G1_to_G3
    ),
    na.rm = TRUE
  )


figure_8_rmse_change <-
  ggplot(
    spatial_plot_data,
    aes(
      x = long,
      y = lat,
      group = group,
      fill =
        rmse_reduction_G1_to_G3
    )
  ) +
  
  geom_polygon(
    color = "white",
    linewidth = 0.25
  ) +
  
  coord_quickmap(
    expand = FALSE
  ) +
  
  scale_fill_gradient2(
    low = "#B2182B",
    mid = "white",
    high = "#2166AC",
    midpoint = 0,
    limits = c(
      -rmse_reduction_limit,
      rmse_reduction_limit
    ),
    na.value = "grey70",
    name =
      "RMSE change\n(bu/acre)"
  ) +
  
  guides(
    fill =
      guide_colorbar(
        title.position = "top",
        barheight =
          grid::unit(
            2.4,
            "in"
          ),
        barwidth =
          grid::unit(
            0.25,
            "in"
          )
      )
  ) +
  
  theme_void(
    base_size = 12
  ) +
  
  theme(
    legend.position =
      "right",
    
    legend.title =
      element_text(
        face = "bold",
        size = 10
      ),
    
    legend.text =
      element_text(
        size = 9
      ),
    
    plot.background =
      element_rect(
        fill = "white",
        color = NA
      ),
    
    panel.background =
      element_rect(
        fill = "white",
        color = NA
      ),
    
    legend.background =
      element_rect(
        fill = "white",
        color = NA
      )
  )


figure_8_rmse_change


# ------------------------------------------------------------
# 16. Save Figures 7-8
# ------------------------------------------------------------

ggsave(
  file.path(
    figure_output_dir,
    "figure7_group3_county_rmse_standardized.png"
  ),
  plot = figure_7_group3_rmse,
  width = 6.5,
  height = 7,
  dpi = 300,
  bg = "white"
)


ggsave(
  file.path(
    figure_output_dir,
    "figure8_county_rmse_change_standardized.png"
  ),
  plot = figure_8_rmse_change,
  width = 6.5,
  height = 7,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 17. Create figure-refresh manifest
# ------------------------------------------------------------

figure_refresh_manifest <-
  tibble(
    thesis_figure = c(
      "Figure 1",
      "Figure 2",
      "Figure 3",
      "Figure 4",
      "Figure 7",
      "Figure 8"
    ),
    
    output_file = c(
      "figure1_linear_rmse_standardized.png",
      "figure2_rf_rmse_standardized.png",
      "figure3_xgb_rmse_standardized.png",
      "figure4_model_family_rmse_standardized.png",
      "figure7_group3_county_rmse_standardized.png",
      "figure8_county_rmse_change_standardized.png"
    ),
    
    change_type = c(
      "Cosmetic standardization only",
      "Cosmetic standardization only",
      "Cosmetic standardization only",
      "Cosmetic standardization only",
      "Cosmetic standardization only",
      "Cosmetic standardization only"
    )
  )


write_csv(
  figure_refresh_manifest,
  file.path(
    figure_output_dir,
    "figure_refresh_manifest.csv"
  )
)


print(
  figure_refresh_manifest,
  n = Inf
)


# ------------------------------------------------------------
# 18. Verify expected files
# ------------------------------------------------------------

expected_files <- c(
  "figure1_linear_rmse_standardized.png",
  "figure2_rf_rmse_standardized.png",
  "figure3_xgb_rmse_standardized.png",
  "figure4_model_family_rmse_standardized.png",
  "figure7_group3_county_rmse_standardized.png",
  "figure8_county_rmse_change_standardized.png",
  "figure_refresh_manifest.csv"
)


saved_files <-
  list.files(
    figure_output_dir
  )


missing_files <-
  setdiff(
    expected_files,
    saved_files
  )


print(
  missing_files
)


stopifnot(
  length(
    missing_files
  ) == 0
)


# ============================================================
# End of Script 26
# ============================================================
