# ============================================================
# Weather Feature Audit
# Senior Thesis
#
# Purpose:
# Evaluate the engineered conventional and extreme-weather
# predictors before they are merged with the corn-yield data
# and used for model development.
#
# IMPORTANT:
# Feature-retention and methodology decisions use only
# pre-2022 development data. The 2022-2025 final holdout
# remains excluded from feature evaluation.
#
# Input:
# output/weather_features/
#   indiana_weather_features_2000_2025.rds
#
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. Load engineered weather features
# ------------------------------------------------------------

weather_features_all <- readRDS(
  "output/weather_features/indiana_weather_features_2000_2025.rds"
)

dim(weather_features_all)
glimpse(weather_features_all)

# ------------------------------------------------------------
# 2. Separate development and final holdout periods
# ------------------------------------------------------------

weather_features_development <- weather_features_all %>%
  filter(
    year <= 2021
  )

weather_features_holdout <- weather_features_all %>%
  filter(
    year >= 2022
  )

dim(weather_features_development)
dim(weather_features_holdout)

range(weather_features_development$year)
range(weather_features_holdout$year)

# ------------------------------------------------------------
# 3. Structural integrity checks
# ------------------------------------------------------------

# One observation per county-year
weather_features_all %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

# County coverage by year
weather_features_all %>%
  group_by(year) %>%
  summarise(
    counties = n_distinct(fips),
    .groups = "drop"
  ) %>%
  print(n = Inf)

# Missing values across engineered predictors
weather_features_all %>%
  summarise(
    missing_w01 = sum(is.na(w01_early_tavg)),
    missing_w02 = sum(is.na(w02_early_prcp)),
    missing_w03 = sum(is.na(w03_repro_tavg)),
    missing_w04 = sum(is.na(w04_repro_prcp)),
    missing_w05 = sum(is.na(w05_grainfill_tavg)),
    missing_w06 = sum(is.na(w06_grainfill_prcp)),
    missing_e01 = sum(is.na(e01_hot_days_30)),
    missing_e02 = sum(is.na(e02_heat_above_35)),
    missing_e03 = sum(is.na(e03_longest_dry_spell)),
    missing_e04 = sum(is.na(e04_max_5day_prcp))
  )

# ------------------------------------------------------------
# 4. Development-period feature summary
# ------------------------------------------------------------

weather_predictors <- c(
  "w01_early_tavg",
  "w02_early_prcp",
  "w03_repro_tavg",
  "w04_repro_prcp",
  "w05_grainfill_tavg",
  "w06_grainfill_prcp",
  "e01_hot_days_30",
  "e02_heat_above_35",
  "e03_longest_dry_spell",
  "e04_max_5day_prcp"
)

development_feature_summary <-
  weather_features_development %>%
  select(
    all_of(weather_predictors)
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "feature",
    values_to = "value"
  ) %>%
  group_by(feature) %>%
  summarise(
    n = n(),
    unique_values = n_distinct(value),
    min = min(value),
    q1 = quantile(value, 0.25),
    median = median(value),
    mean = mean(value),
    q3 = quantile(value, 0.75),
    max = max(value),
    sd = sd(value),
    .groups = "drop"
  )

development_feature_summary %>%
  print(n = Inf)

# ------------------------------------------------------------
# 5. Audit E02 severe-heat feature
# ------------------------------------------------------------

e02_summary <- weather_features_development %>%
  summarise(
    total_county_years = n(),
    
    nonzero_county_years =
      sum(e02_heat_above_35 > 0),
    
    zero_county_years =
      sum(e02_heat_above_35 == 0),
    
    percent_nonzero =
      100 * mean(e02_heat_above_35 > 0),
    
    max_e02 =
      max(e02_heat_above_35)
  )

e02_summary

e02_by_year <- weather_features_development %>%
  group_by(year) %>%
  summarise(
    counties = n(),
    
    counties_nonzero =
      sum(e02_heat_above_35 > 0),
    
    percent_nonzero =
      100 * mean(e02_heat_above_35 > 0),
    
    mean_e02 =
      mean(e02_heat_above_35),
    
    median_e02 =
      median(e02_heat_above_35),
    
    max_e02 =
      max(e02_heat_above_35),
    
    .groups = "drop"
  )

e02_by_year %>%
  print(n = Inf)

e02_by_year %>%
  filter(
    counties_nonzero == 0
  )

weather_features_development %>%
  arrange(
    desc(e02_heat_above_35)
  ) %>%
  select(
    fips,
    region_name,
    year,
    e01_hot_days_30,
    e02_heat_above_35
  ) %>%
  slice_head(n = 15)

# ------------------------------------------------------------
# 6. Evaluate relationship between E01 and E02
# ------------------------------------------------------------

cor(
  weather_features_development$e01_hot_days_30,
  weather_features_development$e02_heat_above_35,
  use = "complete.obs"
)

weather_features_development %>%
  filter(
    e02_heat_above_35 > 0
  ) %>%
  summarise(
    correlation_e01_e02 =
      cor(
        e01_hot_days_30,
        e02_heat_above_35
      ),
    
    observations =
      n()
  )

# ------------------------------------------------------------
# 7. Development-period predictor correlations
# ------------------------------------------------------------

weather_correlation_matrix <-
  weather_features_development %>%
  select(
    all_of(weather_predictors)
  ) %>%
  cor(
    use = "complete.obs"
  )

round(
  weather_correlation_matrix,
  2
)

weather_correlation_table <-
  as.data.frame(weather_correlation_matrix) %>%
  rownames_to_column(
    var = "feature"
  )

weather_correlation_table

# ------------------------------------------------------------
# 8. Audit moisture-extreme features
# ------------------------------------------------------------

weather_features_development %>%
  summarise(
    e03_min =
      min(e03_longest_dry_spell),
    
    e03_median =
      median(e03_longest_dry_spell),
    
    e03_mean =
      mean(e03_longest_dry_spell),
    
    e03_max =
      max(e03_longest_dry_spell),
    
    e04_min =
      min(e04_max_5day_prcp),
    
    e04_median =
      median(e04_max_5day_prcp),
    
    e04_mean =
      mean(e04_max_5day_prcp),
    
    e04_max =
      max(e04_max_5day_prcp)
  )

# Longest dry spells
weather_features_development %>%
  arrange(
    desc(e03_longest_dry_spell)
  ) %>%
  select(
    fips,
    region_name,
    year,
    e03_longest_dry_spell
  ) %>%
  slice_head(n = 10)


# Largest 5-day precipitation totals
weather_features_development %>%
  arrange(
    desc(e04_max_5day_prcp)
  ) %>%
  select(
    fips,
    region_name,
    year,
    e04_max_5day_prcp
  ) %>%
  slice_head(n = 10)

# ------------------------------------------------------------
# 9. Save weather feature audit tables
# ------------------------------------------------------------

dir.create(
  "output/weather_feature_audit",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  development_feature_summary,
  "output/weather_feature_audit/development_feature_summary.csv"
)

write_csv(
  e02_by_year,
  "output/weather_feature_audit/e02_by_year.csv"
)

write_csv(
  weather_correlation_table,
  "output/weather_feature_audit/weather_feature_correlation_matrix.csv"
)

# ------------------------------------------------------------
# 10. Identify high predictor correlations
# ------------------------------------------------------------

high_correlation_pairs <- as.data.frame(
  as.table(weather_correlation_matrix)
) %>%
  rename(
    feature_1 = Var1,
    feature_2 = Var2,
    correlation = Freq
  ) %>%
  mutate(
    feature_1 = as.character(feature_1),
    feature_2 = as.character(feature_2)
  ) %>%
  filter(
    feature_1 < feature_2,
    abs(correlation) >= 0.80
  ) %>%
  arrange(
    desc(abs(correlation))
  )

high_correlation_pairs

write_csv(
  high_correlation_pairs,
  "output/weather_feature_audit/high_correlation_pairs.csv"
)

# ------------------------------------------------------------
# 11. Plot annual extreme-weather feature patterns
# ------------------------------------------------------------

annual_extreme_summary <- weather_features_development %>%
  group_by(year) %>%
  summarise(
    e01_hot_days_30 =
      mean(e01_hot_days_30),
    
    e02_heat_above_35 =
      mean(e02_heat_above_35),
    
    e03_longest_dry_spell =
      mean(e03_longest_dry_spell),
    
    e04_max_5day_prcp =
      mean(e04_max_5day_prcp),
    
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = -year,
    names_to = "feature",
    values_to = "statewide_mean"
  )

annual_extreme_plot <- ggplot(
  annual_extreme_summary,
  aes(
    x = year,
    y = statewide_mean
  )
) +
  geom_line() +
  geom_point() +
  facet_wrap(
    ~ feature,
    scales = "free_y",
    ncol = 2
  ) +
  labs(
    title = "Indiana Extreme-Weather Features, 2000–2021",
    subtitle = "Statewide county mean by year; development period only",
    x = "Year",
    y = "County Mean"
  ) +
  theme_minimal()

annual_extreme_plot

ggsave(
  "output/weather_feature_audit/annual_extreme_weather_features.png",
  plot = annual_extreme_plot,
  width = 10,
  height = 7,
  dpi = 300
)

# ------------------------------------------------------------
# 12. Plot W03 versus E01
# ------------------------------------------------------------

w03_e01_plot <- weather_features_development %>%
  ggplot(
    aes(
      x = w03_repro_tavg,
      y = e01_hot_days_30
    )
  ) +
  geom_point(
    alpha = 0.35
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "July Mean Temperature vs. July Hot-Day Count",
    subtitle = "Development period, 2000–2021",
    x = "July Mean Temperature (°C)",
    y = "Number of July Days with Tmax > 30°C"
  ) +
  theme_minimal()

w03_e01_plot

ggsave(
  "output/weather_feature_audit/w03_e01_relationship.png",
  plot = w03_e01_plot,
  width = 8,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# 13. Save feature-audit decision summary
# ------------------------------------------------------------

weather_feature_audit_decisions <- tibble(
  feature = c(
    "W01-W06",
    "E01",
    "E02",
    "E03",
    "E04"
  ),
  
  finding = c(
    "Conventional weather features show adequate variation and no missing values.",
    "Hot-day count shows meaningful variation but is highly correlated with W03 July mean temperature.",
    "Severe heat accumulation is sparse but nonzero in 14.2% of development county-years and is not redundant with E01.",
    "Longest dry spell shows adequate variation across county-years.",
    "Maximum 5-day precipitation shows adequate variation and coherent extreme observations."
  ),
  
  decision = c(
    "Retain",
    "Retain; evaluate multicollinearity with W03 during linear-model development.",
    "Retain",
    "Retain",
    "Retain"
  ),
  
  holdout_used_for_decision = "No"
)

weather_feature_audit_decisions

write_csv(
  weather_feature_audit_decisions,
  "output/weather_feature_audit/weather_feature_audit_decisions.csv"
)

