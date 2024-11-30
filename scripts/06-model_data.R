#### Preamble ####
# Purpose: To build and save a logistic regression model that combines traffic and crime data to predict injury severity.
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites: 
# - Required packages must be installed.
# - Cleaned traffic and crime datasets must be available in Parquet format.

#### Workspace setup ####
# Load libraries
library(tidyverse)
library(arrow)
library(here)

# Load datasets
traffic_data <- read_parquet(here("data", "02-analysis_data", "cleaned_traffic_data.parquet"))
crime_data <- read_parquet(here("data", "02-analysis_data", "cleaned_crime_data.parquet"))

#### Prepare data ####
# Aggregate features from crime_data for spatial join with traffic_data
crime_aggregated <- crime_data |>
  mutate(
    latitude_bin = round(latitude, 3),  # Group crimes by latitude bins
    longitude_bin = round(longitude, 3) # Group crimes by longitude bins
  ) |>
  group_by(latitude_bin, longitude_bin) |>
  summarise(
    crime_count = n(),  # Total crimes in the area
    avg_offense_severity = mean(as.numeric(factor(offense)), na.rm = TRUE),  # Average severity of offenses
    .groups = "drop"
  )

# Prepare traffic data and join with aggregated crime data
traffic_model_data <- traffic_data |>
  mutate(
    injury_severity_binary = ifelse(impactype %in% c("Fatal", "Severe"), 1, 0),  # Binary outcome for severe injuries
    road_class = factor(road_class),
    vehtype = factor(vehtype),
    latitude_bin = round(latitude, 3),
    longitude_bin = round(longitude, 3)
  ) |>
  left_join(crime_aggregated, by = c("latitude_bin", "longitude_bin")) |>
  mutate(
    crime_count = replace_na(crime_count, 0),  # Replace missing crime data with 0
    avg_offense_severity = replace_na(avg_offense_severity, 0)  # Replace missing severity with 0
  ) |>
  select(injury_severity_binary, road_class, vehtype, latitude, longitude, crime_count, avg_offense_severity) |>
  drop_na()

#### Model data ####
# Logistic regression model
combined_model <- glm(
  formula = injury_severity_binary ~ vehtype + road_class + latitude + longitude + crime_count + avg_offense_severity,
  data = traffic_model_data,
  family = binomial()
)

#### Save model ####
# Save the model to the models directory
saveRDS(
  combined_model,
  file = here("models", "combined_logistic_model.rds")
)

#### Evaluate model ####
# Print summary of the model
summary(combined_model)

# Calculate pseudo R-squared and AIC
library(pscl)
pseudo_r2 <- pR2(combined_model)
print(pseudo_r2)

# Plot predicted probabilities
traffic_model_data <- traffic_model_data |>
  mutate(predicted_prob = predict(combined_model, type = "response"))

ggplot(traffic_model_data, aes(x = predicted_prob, fill = factor(injury_severity_binary))) +
  geom_histogram(binwidth = 0.05, position = "dodge") +
  labs(title = "Predicted Probability of Severe Injury", x = "Predicted Probability", fill = "Severe Injury") +
  theme_minimal()
