# ============================================================
# 09_yield_history_availability_audit.R
#
# Senior Thesis:
# Weathering the Yield: Predicting Indiana Corn Yield
# with Growing-Season Weather Extremes
#
# Purpose:
# Evaluate the availability of recent historical corn yield
# information for Indiana county-year observations.
#
# This audit will help determine whether lagged yield and/or
# a short trailing yield average are practical predictors for
# the historical baseline model.
#
# IMPORTANT:
# This audit focuses on the pre-2022 development period.
# The 2022-2025 final holdout will not be used to select the
# historical yield feature definition.
# ============================================================


# -----------------------------
# 1. Load packages
# -----------------------------

library(tidyverse)

# ------------------------------------------------------------
# 2. Load and prepare USDA county-level corn yield data
# ------------------------------------------------------------

# Load raw USDA NASS corn yield data
usda_raw <- read_csv(
  "data/raw/IN_CornYield_AllYears.csv",
  show_col_types = FALSE
)

# Keep county-level corn grain yield records for the
# full proposed study period.
yield_history <- usda_raw %>%
  filter(
    Year >= 2000,
    Year <= 2025,
    `Geo Level` == "COUNTY",
    Commodity == "CORN",
    `Data Item` == "CORN, GRAIN - YIELD, MEASURED IN BU / ACRE",
    !is.na(`County ANSI`)
  ) %>%
  mutate(
    # Construct 5-digit county FIPS:
    # Indiana state FIPS = 18 plus 3-digit county ANSI code
    fips = paste0(
      sprintf("%02d", as.integer(`State ANSI`)),
      sprintf("%03d", as.integer(`County ANSI`))
    ),
    
    # Convert USDA Value field to numeric yield.
    # parse_number() will handle values stored as character text.
    corn_yield = parse_number(as.character(Value))
  ) %>%
  select(
    fips,
    county = County,
    year = Year,
    corn_yield
  ) %>%
  arrange(fips, year)

# ------------------------------------------------------------
# 3. Verify cleaned yield-history dataset
# ------------------------------------------------------------

# Check dimensions and structure
dim(yield_history)
glimpse(yield_history)

# Check year range
range(yield_history$year, na.rm = TRUE)

# Check number of counties
n_distinct(yield_history$fips)

# Check whether any yield values failed to convert to numeric
sum(is.na(yield_history$corn_yield))

# Check for duplicate county-year observations
yield_history %>%
  count(fips, county, year) %>%
  filter(n > 1)

# Preview first several records
yield_history %>%
  print(n = 20)

# ------------------------------------------------------------
# 4. Create complete pre-2022 county-year development panel
# ------------------------------------------------------------

# Create one lookup table containing the 92 Indiana counties.
county_lookup <- yield_history %>%
  distinct(fips, county) %>%
  arrange(fips)

# Create every possible county-year combination for the
# pre-2022 development period.
development_panel <- expand_grid(
  fips = county_lookup$fips,
  year = 2000:2021
) %>%
  left_join(
    county_lookup,
    by = "fips"
  ) %>%
  left_join(
    yield_history %>%
      filter(year <= 2021) %>%
      select(fips, year, corn_yield),
    by = c("fips", "year")
  ) %>%
  mutate(
    yield_available = !is.na(corn_yield)
  ) %>%
  arrange(fips, year)

# ------------------------------------------------------------
# 5. Verify development-period panel
# ------------------------------------------------------------

# Expected dimensions:
# 92 counties x 22 years = 2,024 county-year combinations
dim(development_panel)

# Confirm county and year coverage
n_distinct(development_panel$fips)

range(development_panel$year)

# Summarize observed and missing yield outcomes
development_panel %>%
  summarise(
    possible_county_years = n(),
    observed_yield_count = sum(yield_available),
    missing_yield_count = sum(!yield_available),
    percent_available = mean(yield_available) * 100
  )

# Examine annual availability
development_coverage_by_year <- development_panel %>%
  group_by(year) %>%
  summarise(
    counties_available = sum(yield_available),
    counties_missing = sum(!yield_available),
    percent_available = mean(yield_available) * 100,
    .groups = "drop"
  )

print(development_coverage_by_year, n = Inf)

# ------------------------------------------------------------
# 6. Create historical yield lag variables
# ------------------------------------------------------------

development_lags <- development_panel %>%
  group_by(fips) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    # Yield from each of the previous three calendar years
    lag1_yield = lag(corn_yield, 1),
    lag2_yield = lag(corn_yield, 2),
    lag3_yield = lag(corn_yield, 3),
    
    # Availability of individual prior-year yields
    lag1_available = !is.na(lag1_yield),
    lag2_available = !is.na(lag2_yield),
    lag3_available = !is.na(lag3_yield),
    
    # Count how many of the previous three years have yield data
    prior_3yr_count =
      lag1_available +
      lag2_available +
      lag3_available,
    
    # Candidate historical-feature availability
    all_3_prior_available = prior_3yr_count == 3,
    at_least_2_of_3_available = prior_3yr_count >= 2
  ) %>%
  ungroup()

# ------------------------------------------------------------
# 7. Inspect lag calculations
# ------------------------------------------------------------

development_lags %>%
  select(
    fips,
    county,
    year,
    corn_yield,
    lag1_yield,
    lag2_yield,
    lag3_yield,
    prior_3yr_count
  ) %>%
  filter(fips == "18001") %>%
  print(n = Inf)

# ------------------------------------------------------------
# 8. Audit historical-feature availability for observed outcomes
# ------------------------------------------------------------

observed_development <- development_lags %>%
  filter(yield_available)

# Audit availability of previous-year yield
# 2000 is excluded because 1999 falls outside the study period.

lag1_audit <- observed_development %>%
  filter(year >= 2001) %>%
  summarise(
    eligible_observations = n(),
    lag1_available_count = sum(lag1_available),
    lag1_missing_count = sum(!lag1_available),
    percent_available = mean(lag1_available) * 100
  )

lag1_audit

# Audit availability of yield information from the
# previous three calendar years.
# Start in 2003 because this is the first year for which
# 2000, 2001, and 2002 can all serve as prior years.

trailing_history_audit <- observed_development %>%
  filter(year >= 2003) %>%
  summarise(
    eligible_observations = n(),
    
    all_3_available_count = sum(all_3_prior_available),
    all_3_percent = mean(all_3_prior_available) * 100,
    
    at_least_2_of_3_count =
      sum(at_least_2_of_3_available),
    
    at_least_2_of_3_percent =
      mean(at_least_2_of_3_available) * 100
  )

trailing_history_audit

# ------------------------------------------------------------
# 9. Compare historical-feature availability over the same
#    eligible development observations
# ------------------------------------------------------------

common_history_audit <- observed_development %>%
  filter(year >= 2003) %>%
  summarise(
    eligible_observations = n(),
    
    lag1_available_count = sum(lag1_available),
    lag1_percent = mean(lag1_available) * 100,
    
    all_3_available_count = sum(all_3_prior_available),
    all_3_percent = mean(all_3_prior_available) * 100,
    
    at_least_2_of_3_count =
      sum(at_least_2_of_3_available),
    
    at_least_2_of_3_percent =
      mean(at_least_2_of_3_available) * 100
  )

common_history_audit

# ------------------------------------------------------------
# 10. Examine historical-feature availability by year
# ------------------------------------------------------------

history_availability_by_year <- observed_development %>%
  filter(year >= 2003) %>%
  group_by(year) %>%
  summarise(
    observed_outcomes = n(),
    
    lag1_available_count = sum(lag1_available),
    lag1_percent = mean(lag1_available) * 100,
    
    all_3_available_count = sum(all_3_prior_available),
    all_3_percent = mean(all_3_prior_available) * 100,
    
    at_least_2_of_3_count =
      sum(at_least_2_of_3_available),
    
    at_least_2_of_3_percent =
      mean(at_least_2_of_3_available) * 100,
    
    .groups = "drop"
  )

print(history_availability_by_year, n = Inf)

# ------------------------------------------------------------
# 11. Create candidate trailing yield-history feature
# ------------------------------------------------------------

development_history_features <- development_lags %>%
  mutate(
    # Mean of the previous three calendar-year yields.
    # The feature is retained only when at least two of
    # the three prior yields are observed.
    trailing_3yr_mean = if_else(
      prior_3yr_count >= 2,
      rowMeans(
        cbind(
          lag1_yield,
          lag2_yield,
          lag3_yield
        ),
        na.rm = TRUE
      ),
      NA_real_
    )
  )

# ------------------------------------------------------------
# 12. Verify flexible trailing-history calculation
# ------------------------------------------------------------

development_history_features %>%
  filter(
    yield_available,
    year >= 2003,
    prior_3yr_count == 2
  ) %>%
  select(
    fips,
    county,
    year,
    corn_yield,
    lag1_yield,
    lag2_yield,
    lag3_yield,
    prior_3yr_count,
    trailing_3yr_mean
  ) %>%
  print(n = 20)

# ------------------------------------------------------------
# 13. Compare availability of remaining history candidates
# ------------------------------------------------------------

candidate_overlap <- observed_development %>%
  filter(year >= 2003) %>%
  mutate(
    trailing_mean_available = prior_3yr_count >= 2
  ) %>%
  count(
    lag1_available,
    trailing_mean_available,
    name = "observations"
  ) %>%
  arrange(desc(lag1_available), desc(trailing_mean_available))

candidate_overlap

candidate_overlap_summary <- observed_development %>%
  filter(year >= 2003) %>%
  mutate(
    trailing_mean_available = prior_3yr_count >= 2
  ) %>%
  summarise(
    eligible_observations = n(),
    
    both_available =
      sum(lag1_available & trailing_mean_available),
    
    lag1_only =
      sum(lag1_available & !trailing_mean_available),
    
    trailing_mean_only =
      sum(!lag1_available & trailing_mean_available),
    
    neither_available =
      sum(!lag1_available & !trailing_mean_available)
  )

candidate_overlap_summary

# ------------------------------------------------------------
# 14. Create historical-feature availability summary
# ------------------------------------------------------------

history_feature_summary <- tibble(
  feature = c(
    "Previous-year yield (lag-1)",
    "Strict 3-year trailing history",
    "Flexible 3-year trailing history (at least 2 of 3)"
  ),
  
  eligible_observations = c(
    common_history_audit$eligible_observations,
    common_history_audit$eligible_observations,
    common_history_audit$eligible_observations
  ),
  
  available_observations = c(
    common_history_audit$lag1_available_count,
    common_history_audit$all_3_available_count,
    common_history_audit$at_least_2_of_3_count
  ),
  
  percent_available = c(
    common_history_audit$lag1_percent,
    common_history_audit$all_3_percent,
    common_history_audit$at_least_2_of_3_percent
  ),
  
  methodology_status = c(
    "Retain as candidate",
    "Retire from further consideration",
    "Retain as candidate"
  )
)

history_feature_summary

# ------------------------------------------------------------
# 15. Save historical-feature audit results
# ------------------------------------------------------------

dir.create(
  "output/yield_history_audit",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  history_feature_summary,
  "output/yield_history_audit/history_feature_availability_summary.csv"
)

write_csv(
  history_availability_by_year,
  "output/yield_history_audit/history_feature_availability_by_year.csv"
)

write_csv(
  candidate_overlap,
  "output/yield_history_audit/history_candidate_overlap.csv"
)

write_csv(
  candidate_overlap_summary,
  "output/yield_history_audit/history_candidate_overlap_summary.csv"
)

# ------------------------------------------------------------
# 16. Plot historical-feature availability by year
# ------------------------------------------------------------

history_availability_plot_data <- history_availability_by_year %>%
  select(
    year,
    lag1_percent,
    all_3_percent,
    at_least_2_of_3_percent
  ) %>%
  pivot_longer(
    cols = -year,
    names_to = "feature",
    values_to = "percent_available"
  ) %>%
  mutate(
    feature = recode(
      feature,
      lag1_percent = "Previous-year yield",
      all_3_percent = "All 3 previous years",
      at_least_2_of_3_percent = "At least 2 of previous 3 years"
    )
  )

history_availability_plot <- ggplot(
  history_availability_plot_data,
  aes(
    x = year,
    y = percent_available,
    linetype = feature,
    group = feature
  )
) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  scale_x_continuous(
    breaks = seq(2003, 2021, by = 2)
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 10)
  ) +
  labs(
    title = "Availability of Historical Yield Features",
    subtitle = "Indiana county-level corn yield observations, 2003–2021",
    x = "Year",
    y = "Feature availability (%)",
    linetype = "Historical feature"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom"
  )

history_availability_plot

ggsave(
  "output/yield_history_audit/history_feature_availability_by_year.png",
  plot = history_availability_plot,
  width = 9,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# 17. Create common sample for baseline feature comparison
# ------------------------------------------------------------

common_baseline_sample <- development_history_features %>%
  filter(
    yield_available,
    year >= 2003,
    lag1_available,
    !is.na(trailing_3yr_mean)
  )

# Verify expected number of observations
dim(common_baseline_sample)

# Check year range
range(common_baseline_sample$year)

# Check number of counties represented
n_distinct(common_baseline_sample$fips)

# ------------------------------------------------------------
# 18. Audit candidate first validation years
# ------------------------------------------------------------

candidate_first_validation_years <- c(
  2008,
  2009,
  2010,
  2011,
  2012
)

validation_start_audit <- map_dfr(
  candidate_first_validation_years,
  function(validation_year) {
    
    training_data <- common_baseline_sample %>%
      filter(year < validation_year)
    
    validation_data <- common_baseline_sample %>%
      filter(year == validation_year)
    
    tibble(
      first_validation_year = validation_year,
      
      # Initial training period
      first_training_year = min(training_data$year),
      last_training_year = max(training_data$year),
      number_training_years =
        n_distinct(training_data$year),
      
      # Initial training sample size
      training_observations = nrow(training_data),
      training_counties =
        n_distinct(training_data$fips),
      
      # First validation-year sample size
      validation_observations = nrow(validation_data),
      validation_counties =
        n_distinct(validation_data$fips),
      
      # Number of annual validation folds available
      # through the end of development period
      total_validation_years =
        2021 - validation_year + 1
    )
  }
)

validation_start_audit

# ------------------------------------------------------------
# 19. Examine county representation for candidate starts
# ------------------------------------------------------------

county_training_depth_audit <- map_dfr(
  candidate_first_validation_years,
  function(validation_year) {
    
    common_baseline_sample %>%
      filter(year < validation_year) %>%
      group_by(fips, county) %>%
      summarise(
        county_training_observations = n(),
        .groups = "drop"
      ) %>%
      summarise(
        first_validation_year = validation_year,
        counties_in_training = n(),
        min_obs_per_county =
          min(county_training_observations),
        median_obs_per_county =
          median(county_training_observations),
        mean_obs_per_county =
          mean(county_training_observations),
        max_obs_per_county =
          max(county_training_observations)
      )
  }
)

county_training_depth_audit

# ------------------------------------------------------------
# 20. Identify counties absent from common baseline sample
# ------------------------------------------------------------

counties_missing_from_common_sample <- county_lookup %>%
  filter(
    !fips %in% unique(common_baseline_sample$fips)
  )

counties_missing_from_common_sample

print(
  validation_start_audit,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 21. Audit county representation across rolling-origin folds
# ------------------------------------------------------------

rolling_fold_county_audit <- map_dfr(
  candidate_first_validation_years,
  function(first_validation_year) {
    
    map_dfr(
      first_validation_year:2021,
      function(validation_year) {
        
        training_data <- common_baseline_sample %>%
          filter(year < validation_year)
        
        validation_data <- common_baseline_sample %>%
          filter(year == validation_year)
        
        training_fips <- unique(training_data$fips)
        validation_fips <- unique(validation_data$fips)
        
        unseen_fips <- setdiff(
          validation_fips,
          training_fips
        )
        
        tibble(
          first_validation_year = first_validation_year,
          validation_year = validation_year,
          training_observations = nrow(training_data),
          validation_observations = nrow(validation_data),
          training_counties = n_distinct(training_data$fips),
          validation_counties = n_distinct(validation_data$fips),
          unseen_validation_counties = length(unseen_fips)
        )
      }
    )
  }
)

print(
  rolling_fold_county_audit,
  n = Inf
)

rolling_start_summary <- rolling_fold_county_audit %>%
  group_by(first_validation_year) %>%
  summarise(
    number_of_folds = n(),
    folds_with_unseen_counties =
      sum(unseen_validation_counties > 0),
    total_unseen_county_occurrences =
      sum(unseen_validation_counties),
    minimum_training_observations =
      min(training_observations),
    minimum_validation_observations =
      min(validation_observations),
    .groups = "drop"
  )

rolling_start_summary

# ------------------------------------------------------------
# 22. Save rolling-origin validation audit
# ------------------------------------------------------------

write_csv(
  validation_start_audit,
  "output/yield_history_audit/validation_start_audit.csv"
)

write_csv(
  rolling_start_summary,
  "output/yield_history_audit/rolling_validation_start_summary.csv"
)

# ------------------------------------------------------------
# 23. Save common sample for baseline feature comparison
# ------------------------------------------------------------

write_csv(
  common_baseline_sample,
  "output/yield_history_audit/common_baseline_comparison_sample.csv"
)
