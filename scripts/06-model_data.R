#### Preamble ####
# Purpose: To build and save a Bayesian regression model using cleaned crime or traffic data.
# Author: Yingke He
# Date: 29 November 2024
# Contact: kiki.he@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Required packages installed
# - Cleaned datasets (`cleaned_crime_data.csv` and `cleaned_traffic_data.csv`) available
# - Test script successfully run to ensure data quality

#### Workspace setup ####
# Load necessary libraries
library(tidyverse)
library(rstanarm)
library(here)

# Load data (adjust based on the dataset you're modeling)
crime_data <- read_csv(here("data", "02-analysis_data", "cleaned_crime_data.csv"))
traffic_data <- read_csv(here("data", "02-analysis_data", "cleaned_traffic_data.csv"))

# Example: Using traffic data for the model
# Modify the formula and variables based on your research question
model_data <- traffic_data %>%
  filter(!is.na(road_type), !is.na(accident_id), !is.na(injury)) %>%  # Ensure no missing values in key columns
  mutate(
    injury = as.numeric(as.factor(injury))  # Convert injury to numeric (e.g., severity levels)
  )

#### Model data ####
# Define a Bayesian regression model for predicting injuries based on other variables
traffic_model <- stan_glm(
  formula = injury ~ road_type + accident_id + vehicle_type,  # Example formula
  data = model_data,
  family = gaussian(),  # Change family if needed (e.g., binomial for binary outcomes)
  prior = normal(location = 0, scale = 2.5, autoscale = TRUE),  # Prior for coefficients
  prior_intercept = normal(location = 0, scale = 2.5, autoscale = TRUE),  # Prior for intercept
  prior_aux = exponential(rate = 1, autoscale = TRUE),  # Prior for auxiliary parameters
  seed = 304  # Set a random seed for reproducibility
)

#### Save model ####
# Save the trained model to an RDS file
saveRDS(
  traffic_model,
  file = here("models", "traffic_model.rds")
)

# Print a summary of the model
print(summary(traffic_model))