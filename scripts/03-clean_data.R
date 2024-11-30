#### Preamble ####
# Purpose: Cleans the raw crime and traffic datasets for further analysis and saves them in Parquet format.
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `janitor`, `jsonlite`, and `arrow` packages must be installed.
# Additional Information: Ensure the datasets are available in the specified locations.

#### Workspace setup ####
# Load required libraries

library(tidyverse)
library(janitor)
library(here)
library(jsonlite)
library(arrow)

# Ensure required directories exist
dir.create(here("data", "02-analysis_data"), recursive = TRUE, showWarnings = FALSE)

#### Define Valid Values ####
# Define valid divisions and offenses for validation
valid_divisions <- c("D51", "D42", "D32", "D31", "D41")  # Update with actual valid values
valid_offenses <- c("Theft From Motor Vehicle Under", "Other Theft", "Fraud")  # Update with actual valid values



#### Clean crime_data ####
# Load raw crime data
crime_data <- read_csv(here("data", "01-raw_data", "theft-from-motor-vehicle.csv"))

# Cleaning process for crime_data
cleaned_crime_data <- crime_data |>
  janitor::clean_names() |>  # Standardize column names
  mutate(
    report_date = as.Date(report_date, format = "%Y-%m-%d"),
    occ_date = as.Date(occ_date, format = "%Y-%m-%d"),
    lat_wgs84 = as.numeric(lat_wgs84),
    long_wgs84 = as.numeric(long_wgs84)
  ) |>
  filter(
    !is.na(event_unique_id) & 
      !is.na(report_date) & 
      !is.na(division) & 
      !is.na(offence) & 
      !is.na(lat_wgs84) & 
      !is.na(long_wgs84)  # Remove rows with missing critical fields
  ) |>
  filter(
    lat_wgs84 >= -90 & lat_wgs84 <= 90,  # Validate latitude
    long_wgs84 >= -180 & long_wgs84 <= 180  # Validate longitude
  ) |>
  mutate(
    division = str_trim(division),  # Remove extra spaces
    division = toupper(division),  # Standardize casing
    offence = str_trim(offence)  # Remove extra spaces
  ) |>
  filter(division %in% valid_divisions) |>  # Ensure valid division codes
  filter(offence %in% valid_offenses) |>  # Ensure valid offense categories
  distinct(event_unique_id, .keep_all = TRUE) |>  # Ensure unique event IDs
  select(
    event_unique_id, report_date, occ_date, division, location_type, 
    premises_type, offence, mci_category, hood_158, long_wgs84, lat_wgs84
  ) |>  # Select relevant columns
  rename(
    event_id = event_unique_id,
    report = report_date,
    occurrence = occ_date,
    location = location_type,
    offense = offence,
    latitude = lat_wgs84,
    longitude = long_wgs84
  )

# Save cleaned crime data as Parquet
write_csv(cleaned_crime_data, here("data", "02-analysis_data", "cleaned_crime_data.csv"))



#### Clean traffic_data ####
# Load raw traffic data
traffic_data <- read_csv(here("data", "01-raw_data", "Motor Vehicle Collisions with KSI Data.csv"))

# Remove the geometry column if it exists
if ("geometry" %in% colnames(traffic_data)) {
  traffic_data <- traffic_data %>% select(-geometry)
}

# Clean column names to ensure they are consistent and usable
traffic_data <- traffic_data %>% 
  janitor::clean_names() %>%  # Standardize column names
  rename_with(~ gsub("\\.+", "_", .), everything()) %>%  # Replace dots with underscores
  rename_with(~ gsub("[^a-zA-Z0-9_]", "", .), everything())  # Remove non-alphanumeric characters

# Remove duplicates
traffic_data <- traffic_data %>% distinct()

# Handle missing values (e.g., replace 'None' with NA)
traffic_data <- traffic_data %>% 
  mutate(across(where(is.character), ~ na_if(., "None")))

# Convert columns to appropriate types
traffic_data <- traffic_data %>% 
  mutate(
    invage = as.numeric(invage),  # Convert age to numeric
    injury = as.factor(injury)    # Convert injury to categorical
  )

# Rename columns for consistency with cleaned crime data
traffic_data <- traffic_data %>% 
  rename(
    accident_id = accnum,  # Accident ID
    report_date = date,    # Date of the report
    time_of_day = time,    # Time of the accident
    street_primary = street1,  # Primary street
    street_secondary = street2,  # Cross street
    road_type = road_class,     # Type of road
    accident_location = accloc, # Location of the accident
    traffic_control = traffctl, # Traffic control at the location
    visibility_conditions = visibility,  # Visibility during the accident
    lighting_conditions = light,  # Lighting conditions
    road_conditions = rdsfcond,  # Road surface conditions
    accident_classification = acclass,  # Accident classification
    impact_type = impactype,  # Type of impact
    vehicle_type = vehtype,   # Vehicle type
    maneuver = manoeuver,     # Maneuver involved
    driver_action = drivact,  # Driver's action
    driver_condition = drivcond,  # Driver's condition
    neighborhood = neighbourhood_158,  # Neighborhood (modern)
    division = division       # Division involved
  )

# Validate latitude and longitude (if present)
if ("latitude" %in% names(traffic_data) & "longitude" %in% names(traffic_data)) {
  traffic_data <- traffic_data %>% 
    filter(
      latitude >= -90 & latitude <= 90, 
      longitude >= -180 & longitude <= 180
    )
}

# Save cleaned dataset as CSV
write_csv(traffic_data, here("data", "02-analysis_data", "cleaned_traffic_data.csv"))

# Print a summary of the cleaned dataset
print(summary(traffic_data))
