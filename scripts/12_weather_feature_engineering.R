# ============================================================
# Weather Feature Engineering
# Senior Thesis
#
# Purpose:
# Create the literature-supported conventional and extreme
# weather predictors defined in the Methodology Decision Table.
#
# Conventional weather features:
# W01-W06
#
# Extreme-weather features:
# E01-E04
#
# Study period: 2000-2025
#
# IMPORTANT:
# Feature definitions and thresholds were established before
# final model evaluation. The 2022-2025 holdout will not be
# used to alter these definitions.
# ============================================================


library(tidyverse)
library(lubridate)
library(EpiNOAA)

# ------------------------------------------------------------
# 1. Download one test year
# ------------------------------------------------------------

test_year <- 2000

weather_test_raw <- read_nclimgrid_epinoaa(
  beginning_date = paste0(test_year, "-04-01"),
  end_date = paste0(test_year, "-09-30"),
  spatial_res = "cty",
  states = "IN",
  counties = "all"
)

# ------------------------------------------------------------
# 2. Clean test-year NOAA data
# ------------------------------------------------------------

weather_test <- weather_test_raw %>%
  filter(
    STATUS == "scaled"
  ) %>%
  mutate(
    # Use UTC conversion established in NOAA coverage audit
    date = as.Date(date, tz = "UTC"),
    
    # Ensure geographic identifier remains a 5-digit string
    fips = sprintf(
      "%05d",
      as.integer(fips)
    ),
    
    # Convert weather variables to numeric
    tmax = readr::parse_number(as.character(tmax)),
    tmin = readr::parse_number(as.character(tmin)),
    tavg = readr::parse_number(as.character(tavg)),
    prcp = readr::parse_number(as.character(prcp)),
    
    # Calendar fields used during feature engineering
    year = year(date),
    month = month(date),
    day = day(date)
  ) %>%
  select(
    fips,
    region_name,
    date,
    year,
    month,
    day,
    tmax,
    tmin,
    tavg,
    prcp
  ) %>%
  arrange(
    fips,
    date
  )

# ------------------------------------------------------------
# 3. Verify cleaned test-year weather data
# ------------------------------------------------------------

# Dimensions and structure
dim(weather_test)
glimpse(weather_test)

# County coverage
n_distinct(weather_test$fips)

# Date coverage
range(weather_test$date)
n_distinct(weather_test$date)

# Missing weather values
weather_test %>%
  summarise(
    missing_tmax = sum(is.na(tmax)),
    missing_tmin = sum(is.na(tmin)),
    missing_tavg = sum(is.na(tavg)),
    missing_prcp = sum(is.na(prcp))
  )

# Confirm one record per county-date
weather_test %>%
  count(
    fips,
    date
  ) %>%
  filter(n != 1)

# Examine numeric ranges
weather_test %>%
  summarise(
    min_tmax = min(tmax, na.rm = TRUE),
    max_tmax = max(tmax, na.rm = TRUE),
    
    min_tmin = min(tmin, na.rm = TRUE),
    max_tmin = max(tmin, na.rm = TRUE),
    
    min_tavg = min(tavg, na.rm = TRUE),
    max_tavg = max(tavg, na.rm = TRUE),
    
    min_prcp = min(prcp, na.rm = TRUE),
    max_prcp = max(prcp, na.rm = TRUE)
  )

# Check for clearly implausible weather values
weather_test %>%
  summarise(
    negative_prcp = sum(prcp < 0, na.rm = TRUE),
    tmax_below_tmin = sum(tmax < tmin, na.rm = TRUE)
  )

# ------------------------------------------------------------
# 4. Verify feature-window day counts
# ------------------------------------------------------------

window_day_check <- weather_test %>%
  group_by(
    fips,
    region_name,
    year
  ) %>%
  summarise(
    t01_days = sum(month %in% c(5, 6)),
    t02_days = sum(month == 7),
    t03_days = sum(month %in% c(8, 9)),
    .groups = "drop"
  )

# Check expected day counts
window_day_check %>%
  count(
    t01_days,
    t02_days,
    t03_days
  )

# ------------------------------------------------------------
# 5. Engineer conventional weather features W01-W06
# ------------------------------------------------------------

conventional_weather_test <- weather_test %>%
  group_by(
    fips,
    region_name,
    year
  ) %>%
  summarise(
    
    # W01: Early-season mean temperature
    # T01 = May 1 through June 30
    w01_early_tavg =
      mean(
        tavg[month %in% c(5, 6)]
      ),
    
    # W02: Early-season total precipitation
    w02_early_prcp =
      sum(
        prcp[month %in% c(5, 6)]
      ),
    
    # W03: Reproductive-period mean temperature
    # T02 = July 1 through July 31
    w03_repro_tavg =
      mean(
        tavg[month == 7]
      ),
    
    # W04: Reproductive-period total precipitation
    w04_repro_prcp =
      sum(
        prcp[month == 7]
      ),
    
    # W05: Grain-fill mean temperature
    # T03 = August 1 through September 30
    w05_grainfill_tavg =
      mean(
        tavg[month %in% c(8, 9)]
      ),
    
    # W06: Grain-fill total precipitation
    w06_grainfill_prcp =
      sum(
        prcp[month %in% c(8, 9)]
      ),
    
    .groups = "drop"
  )

# ------------------------------------------------------------
# 6. Verify conventional weather features
# ------------------------------------------------------------

# Expected: 92 rows, one per Indiana county
dim(conventional_weather_test)

# Confirm one row per county-year
conventional_weather_test %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

# Check for missing engineered features
conventional_weather_test %>%
  summarise(
    missing_w01 = sum(is.na(w01_early_tavg)),
    missing_w02 = sum(is.na(w02_early_prcp)),
    missing_w03 = sum(is.na(w03_repro_tavg)),
    missing_w04 = sum(is.na(w04_repro_prcp)),
    missing_w05 = sum(is.na(w05_grainfill_tavg)),
    missing_w06 = sum(is.na(w06_grainfill_prcp))
  )

# Examine feature ranges
conventional_weather_test %>%
  summarise(
    w01_min = min(w01_early_tavg),
    w01_max = max(w01_early_tavg),
    
    w02_min = min(w02_early_prcp),
    w02_max = max(w02_early_prcp),
    
    w03_min = min(w03_repro_tavg),
    w03_max = max(w03_repro_tavg),
    
    w04_min = min(w04_repro_prcp),
    w04_max = max(w04_repro_prcp),
    
    w05_min = min(w05_grainfill_tavg),
    w05_max = max(w05_grainfill_tavg),
    
    w06_min = min(w06_grainfill_prcp),
    w06_max = max(w06_grainfill_prcp)
  )

# Preview several counties
conventional_weather_test %>%
  print(n = 10)

# ------------------------------------------------------------
# 7. Manually verify one county
# ------------------------------------------------------------

adams_manual_check <- weather_test %>%
  filter(
    fips == "18001"
  ) %>%
  summarise(
    manual_w01 =
      mean(tavg[month %in% c(5, 6)]),
    
    manual_w02 =
      sum(prcp[month %in% c(5, 6)]),
    
    manual_w03 =
      mean(tavg[month == 7]),
    
    manual_w04 =
      sum(prcp[month == 7]),
    
    manual_w05 =
      mean(tavg[month %in% c(8, 9)]),
    
    manual_w06 =
      sum(prcp[month %in% c(8, 9)])
  )

adams_manual_check

conventional_weather_test %>%
  filter(
    fips == "18001"
  )

# ------------------------------------------------------------
# 8. Define helper functions for extreme-weather features
# ------------------------------------------------------------

# Return the longest consecutive run of TRUE values.
# Used for E03: longest consecutive dry spell.
longest_true_run <- function(x) {
  
  runs <- rle(x)
  
  if (any(runs$values)) {
    max(runs$lengths[runs$values])
  } else {
    0
  }
}


# Return the maximum precipitation accumulated across
# any consecutive rolling window of the specified length.
# Used for E04: maximum 5-day precipitation.
max_rolling_sum <- function(x, window = 5) {
  
  if (length(x) < window) {
    return(NA_real_)
  }
  
  cumulative <- c(0, cumsum(x))
  
  rolling_sums <-
    cumulative[(window + 1):length(cumulative)] -
    cumulative[1:(length(cumulative) - window)]
  
  max(rolling_sums)
}

# ------------------------------------------------------------
# 9. Verify extreme-feature window day counts
# ------------------------------------------------------------

extreme_window_day_check <- weather_test %>%
  group_by(
    fips,
    region_name,
    year
  ) %>%
  summarise(
    july_days = sum(month == 7),
    july_august_days = sum(month %in% c(7, 8)),
    may_july_days = sum(month %in% c(5, 6, 7)),
    .groups = "drop"
  )

extreme_window_day_check %>%
  count(
    july_days,
    july_august_days,
    may_july_days
  )

# ------------------------------------------------------------
# 10. Engineer extreme-weather features E01-E04
# ------------------------------------------------------------

extreme_weather_test <- weather_test %>%
  group_by(
    fips,
    region_name,
    year
  ) %>%
  summarise(
    
    # E01: Reproductive-period hot-day count
    # Number of July days with Tmax > 30°C
    e01_hot_days_30 =
      sum(
        tmax[month == 7] > 30
      ),
    
    # E02: Reproductive-period extreme heat accumulation
    # Accumulated degrees above 35°C during July
    e02_heat_above_35 =
      sum(
        pmax(
          tmax[month == 7] - 35,
          0
        )
      ),
    
    # E03: Longest consecutive dry spell
    # Maximum run of Jul-Aug days with precipitation < 1 mm
    e03_longest_dry_spell =
      longest_true_run(
        prcp[month %in% c(7, 8)] < 1
      ),
    
    # E04: Maximum rolling 5-day precipitation
    # Calculated across May 1 through July 31
    e04_max_5day_prcp =
      max_rolling_sum(
        prcp[month %in% c(5, 6, 7)],
        window = 5
      ),
    
    .groups = "drop"
  )

# ------------------------------------------------------------
# 11. Verify extreme-weather features
# ------------------------------------------------------------

# Expected: 92 rows, one per county-year
dim(extreme_weather_test)

# Confirm one row per county-year
extreme_weather_test %>%
  count(
    fips,
    year
  ) %>%
  filter(n != 1)

# Check for missing values
extreme_weather_test %>%
  summarise(
    missing_e01 = sum(is.na(e01_hot_days_30)),
    missing_e02 = sum(is.na(e02_heat_above_35)),
    missing_e03 = sum(is.na(e03_longest_dry_spell)),
    missing_e04 = sum(is.na(e04_max_5day_prcp))
  )

# Examine feature ranges
extreme_weather_test %>%
  summarise(
    e01_min = min(e01_hot_days_30),
    e01_max = max(e01_hot_days_30),
    
    e02_min = min(e02_heat_above_35),
    e02_max = max(e02_heat_above_35),
    
    e03_min = min(e03_longest_dry_spell),
    e03_max = max(e03_longest_dry_spell),
    
    e04_min = min(e04_max_5day_prcp),
    e04_max = max(e04_max_5day_prcp)
  )

# Check whether E02 varies in the test year
extreme_weather_test %>%
  summarise(
    counties_with_hot_days_30 =
      sum(e01_hot_days_30 > 0),
    
    counties_with_heat_above_35 =
      sum(e02_heat_above_35 > 0)
  )

# ------------------------------------------------------------
# 12. Manually verify extreme features for Adams County
# ------------------------------------------------------------

adams_extreme_manual <- weather_test %>%
  filter(
    fips == "18001"
  ) %>%
  summarise(
    
    manual_e01 =
      sum(
        tmax[month == 7] > 30
      ),
    
    manual_e02 =
      sum(
        pmax(
          tmax[month == 7] - 35,
          0
        )
      ),
    
    manual_e03 =
      longest_true_run(
        prcp[month %in% c(7, 8)] < 1
      ),
    
    manual_e04 =
      max_rolling_sum(
        prcp[month %in% c(5, 6, 7)],
        window = 5
      )
  )

adams_extreme_manual

extreme_weather_test %>%
  filter(
    fips == "18001"
  )

# ------------------------------------------------------------
# 13. Combine conventional and extreme weather features
# ------------------------------------------------------------

weather_features_test <- conventional_weather_test %>%
  left_join(
    extreme_weather_test %>%
      select(
        -region_name
      ),
    by = c(
      "fips",
      "year"
    )
  )

dim(weather_features_test)

weather_features_test %>%
  print(n = 10)

# ------------------------------------------------------------
# 14. Create output folders for full weather features
# ------------------------------------------------------------

dir.create(
  "output/weather_features",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "output/weather_features/by_year",
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# 15. Define function to engineer one year of weather features
# ------------------------------------------------------------

engineer_weather_year <- function(yr) {
  
  cat("\nProcessing year:", yr, "\n")
  
  # -----------------------------
  # Download daily NOAA data
  # -----------------------------
  
  weather_raw <- read_nclimgrid_epinoaa(
    beginning_date = paste0(yr, "-04-01"),
    end_date = paste0(yr, "-09-30"),
    spatial_res = "cty",
    states = "IN",
    counties = "all"
  )
  
  
  # -----------------------------
  # Clean using validated rules
  # -----------------------------
  
  weather_clean <- weather_raw %>%
    filter(
      STATUS == "scaled"
    ) %>%
    mutate(
      date = as.Date(date, tz = "UTC"),
      
      fips = sprintf(
        "%05d",
        as.integer(fips)
      ),
      
      tmax = readr::parse_number(as.character(tmax)),
      tmin = readr::parse_number(as.character(tmin)),
      tavg = readr::parse_number(as.character(tavg)),
      prcp = readr::parse_number(as.character(prcp)),
      
      year = lubridate::year(date),
      month = lubridate::month(date)
    ) %>%
    select(
      fips,
      region_name,
      date,
      year,
      month,
      tmax,
      tmin,
      tavg,
      prcp
    ) %>%
    arrange(
      fips,
      date
    )
  
  
  # -----------------------------
  # Basic integrity checks
  # -----------------------------
  
  if (n_distinct(weather_clean$fips) != 92) {
    stop(
      paste(
        "Unexpected county count in year",
        yr
      )
    )
  }
  
  if (n_distinct(weather_clean$date) != 183) {
    stop(
      paste(
        "Unexpected date count in year",
        yr
      )
    )
  }
  
  if (
    any(
      is.na(
        weather_clean %>%
        select(tmax, tmin, tavg, prcp)
      )
    )
  ) {
    stop(
      paste(
        "Missing weather values detected in year",
        yr
      )
    )
  }
  
  
  # -----------------------------
  # Engineer W01-W06 and E01-E04
  # -----------------------------
  
  weather_features <- weather_clean %>%
    group_by(
      fips,
      region_name,
      year
    ) %>%
    summarise(
      
      # W01: May-June mean temperature
      w01_early_tavg =
        mean(
          tavg[month %in% c(5, 6)]
        ),
      
      # W02: May-June total precipitation
      w02_early_prcp =
        sum(
          prcp[month %in% c(5, 6)]
        ),
      
      # W03: July mean temperature
      w03_repro_tavg =
        mean(
          tavg[month == 7]
        ),
      
      # W04: July total precipitation
      w04_repro_prcp =
        sum(
          prcp[month == 7]
        ),
      
      # W05: August-September mean temperature
      w05_grainfill_tavg =
        mean(
          tavg[month %in% c(8, 9)]
        ),
      
      # W06: August-September total precipitation
      w06_grainfill_prcp =
        sum(
          prcp[month %in% c(8, 9)]
        ),
      
      # E01: July days with Tmax > 30°C
      e01_hot_days_30 =
        sum(
          tmax[month == 7] > 30
        ),
      
      # E02: July accumulated degrees above 35°C
      e02_heat_above_35 =
        sum(
          pmax(
            tmax[month == 7] - 35,
            0
          )
        ),
      
      # E03: Longest Jul-Aug dry spell
      e03_longest_dry_spell =
        longest_true_run(
          prcp[month %in% c(7, 8)] < 1
        ),
      
      # E04: Maximum rolling 5-day precipitation
      # across May-July
      e04_max_5day_prcp =
        max_rolling_sum(
          prcp[month %in% c(5, 6, 7)],
          window = 5
        ),
      
      .groups = "drop"
    )
  
  
  # -----------------------------
  # Verify one row per county
  # -----------------------------
  
  if (nrow(weather_features) != 92) {
    stop(
      paste(
        "Unexpected feature-row count in year",
        yr
      )
    )
  }
  
  
  # -----------------------------
  # Save completed year
  # -----------------------------
  
  write_csv(
    weather_features,
    paste0(
      "output/weather_features/by_year/weather_features_",
      yr,
      ".csv"
    )
  )
  
  cat(
    "Completed year:",
    yr,
    "-",
    nrow(weather_features),
    "county rows\n"
  )
  
  return(weather_features)
}

# Compare the function output with the manually tested output
all.equal(
  weather_features_test %>%
    arrange(fips),
  weather_2000_function_test %>%
    arrange(fips)
)

# ------------------------------------------------------------
# 16. Engineer weather features for all study years
# ------------------------------------------------------------

study_years <- 2000:2025

weather_features_list <- list()

for (yr in study_years) {
  
  weather_features_list[[as.character(yr)]] <-
    engineer_weather_year(yr)
  
  # Clean memory after each year
  gc()
}

# ------------------------------------------------------------
# 17. Combine annual weather feature datasets
# ------------------------------------------------------------

weather_features_all <- bind_rows(
  weather_features_list
) %>%
  arrange(
    fips,
    year
  )

dim(weather_features_all)

range(weather_features_all$year)

n_distinct(weather_features_all$fips)

weather_features_all %>%
  count(year) %>%
  print(n = Inf)

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
# 18. Save complete weather-feature dataset
# ------------------------------------------------------------

write_csv(
  weather_features_all,
  "output/weather_features/indiana_weather_features_2000_2025.csv"
)

saveRDS(
  weather_features_all,
  "output/weather_features/indiana_weather_features_2000_2025.rds"
)
