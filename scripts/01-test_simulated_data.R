#### Preamble ####
# Purpose: Tests the structure and validity of the simulated motor vehicle datasets 
# (`crime_data` and `traffic_data`).
# Author: Yingke He
# Date: 25 Nov 2024
# Contact: kiki.he@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` and `here` packages must be installed and loaded
# - The datasets `crime_data.csv` and `traffic_data.csv` must exist in `data/00-simulated_data`

#### Workspace setup ####
library(tidyverse)
library(here)

# Load the datasets
crime_data <- read_csv(here("data", "00-simulated_data", "simulate_crime_data.csv"))
traffic_data <- read_csv(here("data", "00-simulated_data", "simulate_traffic_data.csv"))

# Test if the datasets were successfully loaded
if (exists("crime_data") && exists("traffic_data")) {
  message("Test Passed: Both datasets were successfully loaded.")
} else {
  stop("Test Failed: One or both datasets could not be loaded.")
}

#### Test `crime_data` ####
message("\nTesting `crime_data` dataset...")

# Test if the dataset has at least 100 rows
if (nrow(crime_data) >= 100) {
  message("Test Passed: The `crime_data` dataset has at least 100 rows.")
} else {
  stop("Test Failed: The `crime_data` dataset has fewer than 100 rows.")
}

# Test if the dataset has the expected columns
expected_columns_crime <- c("EVENT_UNIQUE_ID", "REPORT_DATE", "OCC_DATE", "DIVISION",
                            "LOCATION_TYPE", "OFFENCE", "MCI_CATEGORY", "HOOD_158",
                            "LONG_WGS84", "LAT_WGS84")
if (all(expected_columns_crime %in% colnames(crime_data))) {
  message("Test Passed: The `crime_data` dataset contains all expected columns.")
} else {
  stop("Test Failed: The `crime_data` dataset is missing some expected columns.")
}

# Test if all `DIVISION` values are non-empty
if (all(crime_data$DIVISION != "")) {
  message("Test Passed: The `DIVISION` column in `crime_data` contains no empty values.")
} else {
  stop("Test Failed: The `DIVISION` column in `crime_data` contains empty values.")
}

# Test if there are any missing values in the dataset
if (all(!is.na(crime_data))) {
  message("Test Passed: The `crime_data` dataset contains no missing values.")
} else {
  stop("Test Failed: The `crime_data` dataset contains missing values.")
}

#### Test `traffic_data` ####
message("\nTesting `traffic_data` dataset...")

# Test if the dataset has at least 100 rows
if (nrow(traffic_data) >= 100) {
  message("Test Passed: The `traffic_data` dataset has at least 100 rows.")
} else {
  stop("Test Failed: The `traffic_data` dataset has fewer than 100 rows.")
}

# Test if the dataset has the expected columns
expected_columns_traffic <- c("ACCNUM", "DATE", "ROAD_CLASS", "VISIBILITY", "LIGHT",
                              "RDSFCOND", "VEHTYPE", "IMPACTYPE", "INJURY", "LAT_WGS84", "LONG_WGS84")
if (all(expected_columns_traffic %in% colnames(traffic_data))) {
  message("Test Passed: The `traffic_data` dataset contains all expected columns.")
} else {
  stop("Test Failed: The `traffic_data` dataset is missing some expected columns.")
}

# Test if all `VEHTYPE` values are valid
valid_vehicle_types <- c("Automobile", "Motorcycle", "Truck", "Bicycle")
if (all(traffic_data$VEHTYPE %in% valid_vehicle_types)) {
  message("Test Passed: The `VEHTYPE` column in `traffic_data` contains only valid values.")
} else {
  stop("Test Failed: The `VEHTYPE` column in `traffic_data` contains invalid values.")
}

# Test if there are any missing values in the dataset
if (all(!is.na(traffic_data))) {
  message("Test Passed: The `traffic_data` dataset contains no missing values.")
} else {
  stop("Test Failed: The `traffic_data` dataset contains missing values.")
}

# Test if the `INJURY` column has at least two unique values
if (n_distinct(traffic_data$INJURY) >= 2) {
  message("Test Passed: The `INJURY` column in `traffic_data` contains at least two unique values.")
} else {
  stop("Test Failed: The `INJURY` column in `traffic_data` contains less than two unique values.")
}

message("\nAll tests completed.")
