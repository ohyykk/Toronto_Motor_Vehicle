#### Preamble ####
# Purpose: Simulates a dataset of traffic accidents, including details on road conditions,
# vehicle types, impacts, and injury outcomes, with geographical information for each incident.
# Author: Yingke He
# Date: 25 Nov 2024
# Contact: kiki.he@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed.
# Additional Information: Ensure that you are working within the appropriate R project directory.


#### Workspace setup ####
library(tidyverse)
library(conflicted)
set.seed(304)

#### Simulate Crime Report Data ####
# Defining divisions and location types
divisions <- c("D51", "D42", "D55")
location_types <- c("Single Home, House", "Parking Lots", "Commercial Area")
offences <- c("Theft From Motor Vehicle Under", "Break and Enter", "Assault")
mci_categories <- c("NonMCI", "MCI")
years <- 2013:2024
months <- month.name
days <- 1:31

# Generate crime report data
crime_data <- tibble(
  EVENT_UNIQUE_ID = paste0("GO-", sample(10000000:99999999, 100, replace = TRUE)),
  REPORT_DATE = as.Date(sample(seq(as.Date("2013-01-01"), as.Date("2024-12-31"), by = "day"), 100, replace = TRUE)),
  OCC_DATE = as.Date(sample(seq(as.Date("2013-01-01"), as.Date("2024-12-31"), by = "day"), 100, replace = TRUE)),
  REPORT_YEAR = year(REPORT_DATE),
  REPORT_MONTH = months[month(REPORT_DATE)],
  REPORT_DAY = day(REPORT_DATE),
  OCC_YEAR = year(OCC_DATE),
  OCC_MONTH = months[month(OCC_DATE)],
  OCC_DAY = day(OCC_DATE),
  DIVISION = sample(divisions, 100, replace = TRUE),
  LOCATION_TYPE = sample(location_types, 100, replace = TRUE),
  OFFENCE = sample(offences, 100, replace = TRUE),
  MCI_CATEGORY = sample(mci_categories, 100, replace = TRUE),
  HOOD_158 = sample(1:140, 100, replace = TRUE),
  LONG_WGS84 = runif(100, -79.5, -79.2),
  LAT_WGS84 = runif(100, 43.6, 43.8)
)

#### Simulate Traffic Accident Data ####
# Defining accident details
road_classes <- c("Major Arterial", "Minor Arterial", "Collector")
conditions <- c("Clear", "Rainy", "Snowy", "Cloudy")
light_conditions <- c("Daylight", "Dark", "Dawn")
vehicle_types <- c("Automobile", "Motorcycle", "Truck", "Bicycle")
injury_types <- c("Fatal", "Non-Fatal Injury", "No Injury")

# Generate traffic accident data
traffic_data <- tibble(
  ACCNUM = sample(100000:999999, 100, replace = TRUE),
  DATE = as.Date(sample(seq(as.Date("2013-01-01"), as.Date("2024-12-31"), by = "day"), 100, replace = TRUE)),
  ROAD_CLASS = sample(road_classes, 100, replace = TRUE),
  VISIBILITY = sample(conditions, 100, replace = TRUE),
  LIGHT = sample(light_conditions, 100, replace = TRUE),
  RDSFCOND = sample(c("Dry", "Wet", "Icy"), 100, replace = TRUE),
  VEHTYPE = sample(vehicle_types, 100, replace = TRUE),
  IMPACTYPE = sample(c("Approaching", "Intersection", "Rear-end"), 100, replace = TRUE),
  INJURY = sample(injury_types, 100, replace = TRUE),
  LAT_WGS84 = runif(100, -79.5, -79.2),
  LONG_WGS84 = runif(100, 43.6, 43.8)
)

#### Save Simulated Data ####
write_csv(crime_data, "data/00-simulated_data/simulate_crime_data.csv")
write_csv(traffic_data, "data/00-simulated_data/simulate_traffic_data.csv")
