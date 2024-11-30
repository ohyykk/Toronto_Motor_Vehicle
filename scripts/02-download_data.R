#### Preamble ####
# Purpose: This script loads the downloaded motor vehicle datasets from Open Data Toronto
# Author: Yingke He
# Date: 25 Nov 2024
# Contact: kiki.he@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `readr` package must be installed
# - The `here` package must be installed and loaded
# Additional Information: Ensure you are working within the appropriate R project.

#### Workspace setup ####
# Load required libraries
library(readr)
library(here)

# Load the simulated crime data
crime_data <- read_csv(here("data", "01-raw_data", "theft-from-motor-vehicle.csv"))

# Verify the crime data was successfully loaded
if (exists("crime_data")) {
  message("Crime data successfully loaded.")
} else {
  stop("Failed to load the crime data. Please check the file path.")
}

# Load the simulated traffic data
traffic_data <- read_csv(here("data", "01-raw_data", "Motor Vehicle Collisions with KSI Data.csv"))

# Verify the traffic data was successfully loaded
if (exists("traffic_data")) {
  message("Traffic data successfully loaded.")
} else {
  stop("Failed to load the traffic data. Please check the file path.")
}
