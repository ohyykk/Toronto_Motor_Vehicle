#### Preamble ####
# Purpose: Tests structural and descriptive aspects of cleaned crime and traffic datasets.
# Author: Yingke He
# Date: 29 November 2024
# Contact: kiki.he@mail.utoronto.ca
# License: MIT

#### Workspace setup ####
library(tidyverse)
library(testthat)
library(here)

# Load cleaned datasets
cleaned_crime_data <- read_csv(here("data", "02-analysis_data", "cleaned_crime_data.csv"))
cleaned_traffic_data <- read_csv(here("data", "02-analysis_data", "cleaned_traffic_data.csv"))

#### Tests for `cleaned_crime_data` ####
context("Tests for cleaned_crime_data")

test_that("cleaned_crime_data latitude and longitude are within valid ranges", {
  expect_true(all(cleaned_crime_data$latitude >= -90 & cleaned_crime_data$latitude <= 90, na.rm = TRUE))
  expect_true(all(cleaned_crime_data$longitude >= -180 & cleaned_crime_data$longitude <= 180, na.rm = TRUE))
})

test_that("cleaned_crime_data has unique event IDs", {
  expect_equal(nrow(cleaned_crime_data), length(unique(cleaned_crime_data$event_id)))
})

# Column validation
test_that("cleaned_crime_data has the required number of columns", {
  expect_equal(ncol(cleaned_crime_data), 13)  # Based on the cleaned crime data structure
})

# Dataframe has rows
test_that("cleaned_crime_data is not empty", {
  expect_gt(nrow(cleaned_crime_data), 0)
})

test_that("shared columns between datasets are consistent", {
  shared_columns <- intersect(colnames(cleaned_crime_data), colnames(cleaned_traffic_data))
  expect_true(length(shared_columns) > 0, info = "No shared columns between datasets.")
})

# Key columns are not empty
test_that("cleaned_crime_data key columns are not empty", {
  key_columns <- c("event_id", "division", "latitude", "longitude")
  expect_true(all(sapply(cleaned_crime_data[key_columns], function(col) all(!is.na(col)))))
})

#### Tests for `cleaned_traffic_data` ####
context("Tests for cleaned_traffic_data")



# Column validation
test_that("cleaned_traffic_data has the expected number of columns", {
  expect_equal(ncol(cleaned_traffic_data), 49)  # Adjusted to match the dataset structure
})

# Dataframe has rows
test_that("cleaned_traffic_data is not empty", {
  expect_gt(nrow(cleaned_traffic_data), 0)
})

# Ensure division column exists and is non-empty
test_that("cleaned_traffic_data has a valid division column", {
  expect_true("division" %in% colnames(cleaned_traffic_data))
  expect_true(any(!is.na(cleaned_traffic_data$division)))
})

# Test for non-empty categorical columns
test_that("cleaned_traffic_data categorical columns have non-empty values", {
  categorical_columns <- c("road_type", "vehicle_type", "division")
  expect_true(all(sapply(cleaned_traffic_data[categorical_columns], function(col) any(!is.na(col)))))
})

# Validate the presence of neighborhood-related columns
test_that("cleaned_traffic_data contains neighborhood columns", {
  neighborhood_columns <- c("hood_158", "neighborhood")
  expect_true(all(neighborhood_columns %in% colnames(cleaned_traffic_data)))
})

# Check for duplicate rows
test_that("cleaned_traffic_data has no duplicate rows", {
  expect_equal(nrow(cleaned_traffic_data), nrow(distinct(cleaned_traffic_data)))
})

# Validate column names are clean
test_that("cleaned_traffic_data column names are clean", {
  invalid_chars <- grepl("[^a-zA-Z0-9_]", colnames(cleaned_traffic_data))
  expect_false(any(invalid_chars), info = "Column names contain invalid characters.")
})

test_that("critical columns in both datasets have some non-missing values", {
  critical_crime_columns <- c("event_id", "division", "latitude", "longitude")
  critical_traffic_columns <- c("accident_id", "road_type", "division", "vehicle_type")
  
  crime_non_missing <- sapply(cleaned_crime_data[critical_crime_columns], function(col) any(!is.na(col)))
  traffic_non_missing <- sapply(cleaned_traffic_data[critical_traffic_columns], function(col) any(!is.na(col)))
  
  expect_true(all(crime_non_missing), 
              info = paste("Crime data columns with all missing values:", 
                           paste(names(crime_non_missing[!crime_non_missing]), collapse = ", ")))
  expect_true(all(traffic_non_missing), 
              info = paste("Traffic data columns with all missing values:", 
                           paste(names(traffic_non_missing[!traffic_non_missing]), collapse = ", ")))
})

# Check for the proportion of missing values in road_type and vehicle_type
test_that("cleaned_traffic_data road_type and vehicle_type columns have reasonable missing values", {
  missing_threshold <- 0.2  # Allow up to 20% missing values
  road_type_missing <- sum(is.na(cleaned_traffic_data$road_type)) / nrow(cleaned_traffic_data)
  vehicle_type_missing <- sum(is.na(cleaned_traffic_data$vehicle_type)) / nrow(cleaned_traffic_data)
  expect_true(road_type_missing <= missing_threshold, 
              info = paste("Too many missing values in road_type:", road_type_missing))
  expect_true(vehicle_type_missing <= missing_threshold, 
              info = paste("Too many missing values in vehicle_type:", vehicle_type_missing))
})

test_that("cleaned_traffic_data numeric columns have reasonable values", {
  numeric_columns <- c("invage", "fatal_no")
  expect_true(all(cleaned_traffic_data$invage >= 0 & cleaned_traffic_data$invage <= 120, na.rm = TRUE))
  expect_true(all(cleaned_traffic_data$fatal_no >= 0, na.rm = TRUE))
})

