# ============================================================
# NOAA nClimGrid Historical Coverage Audit
# Senior Thesis
#
# Purpose:
# Evaluate the availability and consistency of county-level
# daily weather data needed for the Indiana corn-yield study.
#
# Initial audit years: 2000, 2010, 2020, 2025
# ============================================================

library(tidyverse)
library(lubridate)
library(EpiNOAA)

# Years selected to examine coverage across the proposed
# 2000-2025 study period
audit_years <- c(2000, 2010, 2020, 2025)

audit_years


# ------------------------------------------------------------
# 1. Download representative audit years
# ------------------------------------------------------------

noaa_audit_list <- list()

for (yr in audit_years) {
  
  cat("Downloading year:", yr, "\n")
  
  noaa_audit_list[[as.character(yr)]] <- read_nclimgrid_epinoaa(
    beginning_date = paste0(yr, "-04-01"),
    end_date = paste0(yr, "-09-30"),
    spatial_res = "cty",
    states = "IN",
    counties = "all"
  )
}

# Combine the four years into one audit dataset
noaa_audit <- bind_rows(
  noaa_audit_list,
  .id = "download_year"
)

# Basic inspection
dim(noaa_audit)
names(noaa_audit)
glimpse(noaa_audit)

# ------------------------------------------------------------
# 2. Check record counts by audit year
# ------------------------------------------------------------

noaa_audit %>%
  count(download_year)

# Check STATUS behavior across years
noaa_audit %>%
  count(download_year, STATUS) %>%
  arrange(download_year, STATUS)

# Check number of unique Indiana counties per year
noaa_audit %>%
  group_by(download_year) %>%
  summarise(
    unique_counties = n_distinct(fips),
    .groups = "drop"
  )

# Check date range returned for each year
noaa_audit %>%
  mutate(
    date_parsed = as.Date(
      ymd_hms(date, tz = "America/New_York"),
      tz = "UTC"
    )
  ) %>%
  group_by(download_year) %>%
  summarise(
    first_date = min(date_parsed, na.rm = TRUE),
    last_date = max(date_parsed, na.rm = TRUE),
    unique_dates = n_distinct(date_parsed),
    .groups = "drop"
  )

# ------------------------------------------------------------
# 3. Check missing weather values
# ------------------------------------------------------------

noaa_audit %>%
  group_by(download_year) %>%
  summarise(
    missing_tmax = sum(is.na(tmax)),
    missing_tmin = sum(is.na(tmin)),
    missing_tavg = sum(is.na(tavg)),
    missing_prcp = sum(is.na(prcp)),
    .groups = "drop"
  )

# ------------------------------------------------------------
# 4. Verify date/time handling
# ------------------------------------------------------------

# Inspect the stored timezone information
attr(noaa_audit$date, "tzone")

# Compare several ways of converting the timestamp to a date
noaa_audit %>%
  filter(download_year == "2000") %>%
  select(date) %>%
  distinct() %>%
  arrange(date) %>%
  slice(c(1:3, (n() - 2):n()))

date_conversion_check <- noaa_audit %>%
  filter(download_year == "2000") %>%
  mutate(
    date_default = as.Date(date),
    date_utc = as.Date(date, tz = "UTC"),
    date_eastern = as.Date(date, tz = "America/New_York")
  ) %>%
  summarise(
    default_first = min(date_default),
    default_last = max(date_default),
    default_n = n_distinct(date_default),
    
    utc_first = min(date_utc),
    utc_last = max(date_utc),
    utc_n = n_distinct(date_utc),
    
    eastern_first = min(date_eastern),
    eastern_last = max(date_eastern),
    eastern_n = n_distinct(date_eastern)
  )

date_conversion_check

# ------------------------------------------------------------
# 5. Verify weather-variable numeric conversion
# ------------------------------------------------------------

noaa_numeric_check <- noaa_audit %>%
  mutate(
    tmax_num = readr::parse_number(tmax),
    tmin_num = readr::parse_number(tmin),
    tavg_num = readr::parse_number(tavg),
    prcp_num = readr::parse_number(prcp)
  )

noaa_numeric_check %>%
  group_by(download_year, STATUS) %>%
  summarise(
    records = n(),
    missing_tmax = sum(is.na(tmax_num)),
    missing_tmin = sum(is.na(tmin_num)),
    missing_tavg = sum(is.na(tavg_num)),
    missing_prcp = sum(is.na(prcp_num)),
    .groups = "drop"
  )

problems(noaa_numeric_check)

noaa_audit %>%
  summarise(
    nonnumeric_tmax = sum(is.na(readr::parse_number(tmax))),
    nonnumeric_tmin = sum(is.na(readr::parse_number(tmin))),
    nonnumeric_tavg = sum(is.na(readr::parse_number(tavg))),
    nonnumeric_prcp = sum(is.na(readr::parse_number(prcp)))
  )

noaa_audit %>%
  filter(STATUS == "scaled") %>%
  mutate(date_clean = as.Date(date, tz = "UTC")) %>%
  count(download_year, fips, date_clean) %>%
  filter(n != 1)

# ------------------------------------------------------------
# 6. Audit NOAA coverage for all years: 2000-2025
# ------------------------------------------------------------

full_audit_years <- 2000:2025

noaa_coverage_results <- list()
noaa_status_results <- list()

for (yr in full_audit_years) {
  
  cat("Auditing year:", yr, "\n")
  
  yr_data <- read_nclimgrid_epinoaa(
    beginning_date = paste0(yr, "-04-01"),
    end_date = paste0(yr, "-09-30"),
    spatial_res = "cty",
    states = "IN",
    counties = "all"
  )
  
  # Record statuses returned for the year
  noaa_status_results[[as.character(yr)]] <- yr_data %>%
    count(STATUS, name = "records") %>%
    mutate(year = yr) %>%
    select(year, STATUS, records)
  
  # Keep scaled records for coverage audit
  yr_scaled <- yr_data %>%
    filter(STATUS == "scaled") %>%
    mutate(
      date_clean = as.Date(date, tz = "UTC"),
      tmax_num = readr::parse_number(tmax),
      tmin_num = readr::parse_number(tmin),
      tavg_num = readr::parse_number(tavg),
      prcp_num = readr::parse_number(prcp)
    )
  
  # Summarize coverage for the year
  noaa_coverage_results[[as.character(yr)]] <- yr_scaled %>%
    summarise(
      year = yr,
      records = n(),
      unique_counties = n_distinct(fips),
      unique_dates = n_distinct(date_clean),
      first_date = min(date_clean, na.rm = TRUE),
      last_date = max(date_clean, na.rm = TRUE),
      missing_tmax = sum(is.na(tmax_num)),
      missing_tmin = sum(is.na(tmin_num)),
      missing_tavg = sum(is.na(tavg_num)),
      missing_prcp = sum(is.na(prcp_num)),
      duplicate_county_dates =
        sum(duplicated(paste(fips, date_clean)))
    )
  
  # Remove large yearly objects before moving to next year
  rm(yr_data, yr_scaled)
  gc()
}

# Combine annual results
noaa_coverage_by_year <- bind_rows(noaa_coverage_results)
noaa_status_by_year <- bind_rows(noaa_status_results)

print(noaa_coverage_by_year, n = Inf)
print(noaa_status_by_year, n = Inf)

noaa_coverage_by_year %>%
  select(year, duplicate_county_dates) %>%
  print(n = Inf)

# ------------------------------------------------------------
# 7. Save NOAA coverage audit results
# ------------------------------------------------------------

write_csv(
  noaa_coverage_by_year,
  "output/data_coverage_audit/noaa_coverage_by_year.csv"
)

write_csv(
  noaa_status_by_year,
  "output/data_coverage_audit/noaa_status_by_year.csv"
)

# ------------------------------------------------------------
# 8. Create overall NOAA audit summary
# ------------------------------------------------------------

noaa_audit_summary <- tibble(
  measure = c(
    "Study period audited",
    "Growing-season period",
    "Years audited",
    "Counties represented each year",
    "Daily dates represented each year",
    "Scaled records per year",
    "Missing temperature values",
    "Missing precipitation values",
    "Years containing prelim records"
  ),
  result = c(
    "2000-2025",
    "April 1-September 30",
    "26",
    "92",
    "183",
    "16,836",
    "0",
    "0",
    "2025 only"
  )
)

noaa_audit_summary

write_csv(
  noaa_audit_summary,
  "output/data_coverage_audit/noaa_audit_summary.csv"
)
