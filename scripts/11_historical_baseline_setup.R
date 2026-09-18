# ============================================================
# Final Historical Baseline Setup
# Senior Thesis
#
# Purpose:
# Prepare the development dataset for the final historical
# baseline after selecting previous-year yield (lag-1) as the
# recent-yield predictor.
#
# The lag-1 feature was selected using pre-2022 rolling-origin
# validation on identical comparison observations.
#
# Development validation remains 2012-2021.
# The 2022-2025 final holdout is not used here.
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. Load and prepare USDA yield data
# ------------------------------------------------------------

usda_raw <- read_csv(
  "data/raw/IN_CornYield_AllYears.csv",
  show_col_types = FALSE
)

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
    fips = paste0(
      sprintf("%02d", as.integer(`State ANSI`)),
      sprintf("%03d", as.integer(`County ANSI`))
    ),
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
# 2. Create complete pre-2022 county-year panel
# ------------------------------------------------------------

county_lookup <- yield_history %>%
  distinct(fips, county) %>%
  arrange(fips)

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
  arrange(fips, year)

# ------------------------------------------------------------
# 3. Create selected recent-yield feature
# ------------------------------------------------------------

lag1_development <- development_panel %>%
  group_by(fips) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    lag1_yield = lag(corn_yield, 1)
  ) %>%
  ungroup()

final_baseline_sample <- lag1_development %>%
  filter(
    year >= 2001,
    !is.na(corn_yield),
    !is.na(lag1_yield)
  ) %>%
  mutate(
    year_centered = year - 2000
  )

# ------------------------------------------------------------
# 4. Verify final lag-1 development sample
# ------------------------------------------------------------

dim(final_baseline_sample)

range(final_baseline_sample$year)

n_distinct(final_baseline_sample$fips)

final_baseline_sample %>%
  group_by(year) %>%
  summarise(
    observations = n(),
    counties = n_distinct(fips),
    .groups = "drop"
  ) %>%
  print(n = Inf)

county_baseline_coverage <- final_baseline_sample %>%
  distinct(fips, county) %>%
  arrange(fips)

county_lookup %>%
  filter(
    !fips %in% county_baseline_coverage$fips
  )

# ------------------------------------------------------------
# 5. Verify final rolling-origin fold structure
# ------------------------------------------------------------

validation_years <- 2012:2021

final_fold_audit <- map_dfr(
  validation_years,
  function(validation_year) {
    
    training_data <- final_baseline_sample %>%
      filter(year < validation_year)
    
    validation_data <- final_baseline_sample %>%
      filter(year == validation_year)
    
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
  final_fold_audit,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 6. Save final historical baseline setup
# ------------------------------------------------------------

dir.create(
  "output/historical_baseline",
  recursive = TRUE,
  showWarnings = FALSE
)

# Final lag-1 development sample
write_csv(
  final_baseline_sample,
  "output/historical_baseline/final_lag1_development_sample.csv"
)

# Rolling-origin fold structure
write_csv(
  final_fold_audit,
  "output/historical_baseline/final_rolling_fold_audit.csv"
)

# Counties represented in the baseline sample
write_csv(
  county_baseline_coverage,
  "output/historical_baseline/baseline_county_coverage.csv"
)

# County or counties unable to support the selected lag-1 baseline
excluded_baseline_counties <- county_lookup %>%
  filter(
    !fips %in% county_baseline_coverage$fips
  )

write_csv(
  excluded_baseline_counties,
  "output/historical_baseline/excluded_baseline_counties.csv"
)

# ------------------------------------------------------------
# 7. Inspect yield history for counties excluded from baseline
# ------------------------------------------------------------

excluded_county_history <- development_panel %>%
  filter(
    fips %in% excluded_baseline_counties$fips
  ) %>%
  select(
    fips,
    county,
    year,
    corn_yield
  )

print(
  excluded_county_history,
  n = Inf
)

