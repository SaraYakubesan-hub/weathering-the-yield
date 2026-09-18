# ============================================================
# USDA NASS Corn Yield Historical Coverage Audit
# Senior Thesis
#
# Purpose:
# Evaluate the completeness and consistency of Indiana
# county-level corn grain yield data from 2000 through 2025.
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. Load raw USDA NASS data
# ------------------------------------------------------------

usda_raw <- read_csv(
  "data/raw/IN_CornYield_AllYears.csv",
  show_col_types = FALSE
)

# Inspect the dataset
dim(usda_raw)
names(usda_raw)
glimpse(usda_raw)

# ------------------------------------------------------------
# 2. Inspect the contents of the raw USDA file
# ------------------------------------------------------------

# Check the full year range
range(usda_raw$Year, na.rm = TRUE)

# Examine the distinct values in fields that define the
# type of USDA record contained in the file
usda_raw %>%
  count(Period, sort = TRUE)

usda_raw %>%
  count(`Geo Level`, sort = TRUE)

usda_raw %>%
  count(Commodity, sort = TRUE)

usda_raw %>%
  count(`Data Item`, sort = TRUE)

usda_raw %>%
  count(Domain, sort = TRUE)

# Check state information
usda_raw %>%
  count(State, `State ANSI`, sort = TRUE)

# Examine the number of raw records by year
usda_raw %>%
  count(Year) %>%
  arrange(Year)

# ------------------------------------------------------------
# 3. Restrict data to proposed study period: 2000-2025
# ------------------------------------------------------------

usda_2000_2025 <- usda_raw %>%
  filter(
    Year >= 2000,
    Year <= 2025
  )

# Basic dimensions
dim(usda_2000_2025)

# Raw record count by year
raw_year_counts <- usda_2000_2025 %>%
  count(Year, name = "raw_records") %>%
  arrange(Year)

print(raw_year_counts, n = Inf)

# ------------------------------------------------------------
# 4. Examine county identifiers
# ------------------------------------------------------------

county_id_audit <- usda_2000_2025 %>%
  summarise(
    total_records = n(),
    valid_county_ansi = sum(!is.na(`County ANSI`)),
    missing_county_ansi = sum(is.na(`County ANSI`))
  )

county_id_audit

usda_2000_2025 %>%
  filter(is.na(`County ANSI`)) %>%
  count(County, sort = TRUE)

county_coverage_by_year <- usda_2000_2025 %>%
  group_by(Year) %>%
  summarise(
    raw_records = n(),
    county_records = sum(!is.na(`County ANSI`)),
    other_records = sum(is.na(`County ANSI`)),
    unique_counties = n_distinct(`County ANSI`[!is.na(`County ANSI`)]),
    .groups = "drop"
  ) %>%
  arrange(Year)

print(county_coverage_by_year, n = Inf)

county_code_check <- usda_2000_2025 %>%
  filter(!is.na(`County ANSI`)) %>%
  distinct(`County ANSI`, County) %>%
  count(`County ANSI`, name = "county_names") %>%
  filter(county_names > 1)

county_code_check

# ------------------------------------------------------------
# 5. Create clean county-level audit dataset
# ------------------------------------------------------------

usda_county <- usda_2000_2025 %>%
  filter(!is.na(`County ANSI`)) %>%
  mutate(
    fips = paste0(
      sprintf("%02d", as.integer(`State ANSI`)),
      `County ANSI`
    )
  )

# Verify number of unique counties represented at least once
n_distinct(usda_county$fips)

# ------------------------------------------------------------
# 6. Examine longitudinal coverage by county
# ------------------------------------------------------------

county_longitudinal_coverage <- usda_county %>%
  group_by(fips, County) %>%
  summarise(
    years_available = n_distinct(Year),
    first_year = min(Year),
    last_year = max(Year),
    .groups = "drop"
  ) %>%
  arrange(desc(years_available), County)

print(county_longitudinal_coverage, n = Inf)

county_longitudinal_coverage %>%
  summarise(
    counties = n(),
    min_years = min(years_available),
    q1_years = quantile(years_available, 0.25),
    median_years = median(years_available),
    mean_years = mean(years_available),
    q3_years = quantile(years_available, 0.75),
    max_years = max(years_available)
  )

county_longitudinal_coverage %>%
  count(years_available, name = "number_of_counties") %>%
  arrange(desc(years_available))

county_longitudinal_coverage <- county_longitudinal_coverage %>%
  mutate(
    coverage_percent = years_available / 26 * 100,
    coverage_group = case_when(
      years_available == 26 ~ "Complete (26 years)",
      years_available >= 23 ~ "High (23-25 years)",
      years_available >= 18 ~ "Moderate (18-22 years)",
      TRUE ~ "Low (<18 years)"
    )
  )

county_longitudinal_coverage %>%
  count(coverage_group) %>%
  arrange(desc(coverage_group))

county_longitudinal_coverage %>%
  arrange(years_available, County) %>%
  select(
    fips,
    County,
    years_available,
    coverage_percent,
    first_year,
    last_year,
    coverage_group
  ) %>%
  print(n = Inf)

# ------------------------------------------------------------
# 7. Check for duplicate county-year records
# ------------------------------------------------------------

duplicate_county_years <- usda_county %>%
  count(fips, County, Year) %>%
  filter(n > 1)

duplicate_county_years

# ------------------------------------------------------------
# 8. Identify missing county-year combinations
# ------------------------------------------------------------

# Create a complete grid of all 92 counties and all 26 years
all_county_years <- expand_grid(
  fips = sort(unique(usda_county$fips)),
  Year = 2000:2025
)

# Add county names
county_lookup <- usda_county %>%
  distinct(fips, County)

# Identify whether yield is available for each county-year
county_year_presence <- all_county_years %>%
  left_join(county_lookup, by = "fips") %>%
  left_join(
    usda_county %>%
      select(fips, Year, Value),
    by = c("fips", "Year")
  ) %>%
  mutate(
    yield_available = !is.na(Value)
  )

# Overall expected versus available county-years
county_year_presence %>%
  summarise(
    possible_county_years = n(),
    available_county_years = sum(yield_available),
    missing_county_years = sum(!yield_available),
    percent_available = mean(yield_available) * 100
  )

# ------------------------------------------------------------
# 9. Coverage during proposed final test period: 2022-2025
# ------------------------------------------------------------

test_period_coverage <- county_year_presence %>%
  filter(Year >= 2022) %>%
  group_by(Year) %>%
  summarise(
    counties_available = sum(yield_available),
    counties_missing = sum(!yield_available),
    percent_available = mean(yield_available) * 100,
    .groups = "drop"
  )

test_period_coverage

county_test_coverage <- county_year_presence %>%
  filter(Year >= 2022) %>%
  group_by(fips, County) %>%
  summarise(
    test_years_available = sum(yield_available),
    .groups = "drop"
  ) %>%
  arrange(test_years_available, County)

county_test_coverage %>%
  count(test_years_available)

county_test_coverage %>%
  filter(test_years_available < 4) %>%
  print(n = Inf)

missing_years_by_county <- county_year_presence %>%
  filter(!yield_available) %>%
  group_by(fips, County) %>%
  summarise(
    missing_years = paste(Year, collapse = ", "),
    number_missing = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(number_missing), County)

print(missing_years_by_county, n = Inf)

# ------------------------------------------------------------
# 10. Save USDA coverage audit results
# ------------------------------------------------------------

# Create output folder for data-quality audit if it does not exist
dir.create(
  "output/data_coverage_audit",
  recursive = TRUE,
  showWarnings = FALSE
)

# Annual USDA county coverage
write_csv(
  county_coverage_by_year,
  "output/data_coverage_audit/usda_coverage_by_year.csv"
)

# Longitudinal coverage for each county
write_csv(
  county_longitudinal_coverage,
  "output/data_coverage_audit/usda_coverage_by_county.csv"
)

# Coverage during proposed 2022-2025 test period
write_csv(
  test_period_coverage,
  "output/data_coverage_audit/usda_test_period_coverage.csv"
)

# Number of test years available for each county
write_csv(
  county_test_coverage,
  "output/data_coverage_audit/usda_test_coverage_by_county.csv"
)

# Specific missing years for counties with incomplete coverage
write_csv(
  missing_years_by_county,
  "output/data_coverage_audit/usda_missing_years_by_county.csv"
)

# ------------------------------------------------------------
# 11. Create overall USDA audit summary
# ------------------------------------------------------------

usda_audit_summary <- tibble(
  measure = c(
    "Study period",
    "Indiana counties represented",
    "Possible county-year observations",
    "Available county-year observations",
    "Missing county-year observations",
    "Overall coverage percent",
    "Counties with complete 26-year coverage",
    "Counties with at least 23 years",
    "Counties with all four proposed test years"
  ),
  result = c(
    "2000-2025",
    as.character(n_distinct(usda_county$fips)),
    as.character(nrow(county_year_presence)),
    as.character(sum(county_year_presence$yield_available)),
    as.character(sum(!county_year_presence$yield_available)),
    sprintf("%.1f%%", mean(county_year_presence$yield_available) * 100),
    as.character(sum(county_longitudinal_coverage$years_available == 26)),
    as.character(sum(county_longitudinal_coverage$years_available >= 23)),
    as.character(sum(county_test_coverage$test_years_available == 4))
  )
)

usda_audit_summary

write_csv(
  usda_audit_summary,
  "output/data_coverage_audit/usda_audit_summary.csv"
)
