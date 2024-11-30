#### Preamble ####
# Purpose: Tests the cleaned motor vehicle datasets (saved as Parquet files) to ensure data quality and consistency.
# Author: Yingke He
# Date: 25 Nov 2024
# Contact: kiki.he@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `testthat` and `arrow` packages must be installed.
# Additional Information: Ensure the cleaned data files exist in the specified locations.

#### Workspace setup ####
library(tidyverse)
library(testthat)
library(here)
suppressWarnings(library(arrow))


# Load cleaned datasets
cleaned_crime_data <- read_parquet(here("data", "02-analysis_data", "cleaned_crime_data.parquet"))
cleaned_traffic_data <- read_parquet(here("data", "02-analysis_data", "cleaned_traffic_data.parquet"))

#### Tests for `cleaned_crime_data` ####
context("Tests for cleaned_crime_data")

# Column validation
test_that("cleaned_crime_data has expected columns", {
  expected_columns <- c("event_id", "report", "occurrence", "division", "location", 
                        "premises_type", "offense", "mci_category", "hood_158", 
                        "longitude", "latitude")
  expect_equal(colnames(cleaned_crime_data), expected_columns)
})

# No missing values
test_that("cleaned_crime_data has no missing values", {
  expect_true(all(!is.na(cleaned_crime_data)))
})

# Valid geographic coordinates
test_that("cleaned_crime_data latitude and longitude are valid", {
  expect_true(all(cleaned_crime_data$latitude >= -90 & cleaned_crime_data$latitude <= 90))
  expect_true(all(cleaned_crime_data$longitude >= -180 & cleaned_crime_data$longitude <= 180))
})

# Non-empty strings in critical columns
test_that("cleaned_crime_data critical columns are non-empty strings", {
  expect_false(any(cleaned_crime_data$division == "" | 
                     cleaned_crime_data$location == "" | 
                     cleaned_crime_data$premises_type == ""))
})

# Unique event IDs
test_that("cleaned_crime_data has unique event IDs", {
  expect_equal(nrow(cleaned_crime_data), length(unique(cleaned_crime_data$event_id)))
})

# Offense column contains meaningful values
test_that("cleaned_crime_data offense column is not empty and contains valid values", {
  valid_offenses <- c("Theft From Motor Vehicle Under", "Other Theft", "Fraud")  # Example offenses
  expect_true(all(cleaned_crime_data$offense %in% valid_offenses))
})

#### Tests for `cleaned_traffic_data` ####
context("Tests for cleaned_traffic_data")

# Column validation
test_that("cleaned_traffic_data has expected columns", {
  expected_columns <- c("accident_id", "date", "road_class", "vehtype", "impactype", 
                        "road_condition", "latitude", "longitude")
  expect_equal(colnames(cleaned_traffic_data), expected_columns)
})

# No missing values
test_that("cleaned_traffic_data has no missing values", {
  expect_true(all(!is.na(cleaned_traffic_data)))
})

# Valid geographic coordinates
test_that("cleaned_traffic_data latitude and longitude are valid", {
  expect_true(all(cleaned_traffic_data$latitude >= -90 & cleaned_traffic_data$latitude <= 90))
  expect_true(all(cleaned_traffic_data$longitude >= -180 & cleaned_traffic_data$longitude <= 180))
})

# Non-empty strings in critical columns
test_that("cleaned_traffic_data critical columns are non-empty strings", {
  expect_false(any(cleaned_traffic_data$road_class == "" | 
                     cleaned_traffic_data$impactype == "" | 
                     cleaned_traffic_data$vehtype == ""))
})

# Unique accident IDs
test_that("cleaned_traffic_data has unique accident IDs", {
  expect_equal(nrow(cleaned_traffic_data), length(unique(cleaned_traffic_data$accident_id)))
})

# Valid road_class and vehtype
test_that("cleaned_traffic_data road_class and vehtype values are valid", {
  valid_road_classes <- c("Major Arterial", "Local Street")  # Example valid road classes
  valid_vehicle_types <- c("Automobile", "Motorcycle", "Truck", "Bicycle")  # Example valid vehicle types
  expect_true(all(cleaned_traffic_data$road_class %in% valid_road_classes))
  expect_true(all(cleaned_traffic_data$vehtype %in% valid_vehicle_types))
})

# Date column is within valid range
test_that("cleaned_traffic_data date column contains realistic values", {
  expect_true(all(cleaned_traffic_data$date >= as.Date("2000-01-01") & 
                    cleaned_traffic_data$date <= Sys.Date()))
})

#### Additional Integrity Checks ####
context("Integrity checks for both datasets")

# No duplicated rows in datasets
test_that("No duplicated rows in cleaned_crime_data", {
  expect_equal(nrow(cleaned_crime_data), nrow(distinct(cleaned_crime_data)))
})
test_that("No duplicated rows in cleaned_traffic_data", {
  expect_equal(nrow(cleaned_traffic_data), nrow(distinct(cleaned_traffic_data)))
})
