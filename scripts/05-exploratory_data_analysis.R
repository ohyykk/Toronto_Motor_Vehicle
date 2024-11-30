#### Preamble ####
# Purpose: To explore and visualize trends in crime and traffic datasets, including spatial distributions, temporal patterns, and relationships between key variables, while leveraging models for posterior predictive checks.
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites:
# - Required packages must be installed
# - Cleaning scripts for both datasets must have been run
# - Bayesian model for traffic accidents must have been created and saved



#### Workspace setup ####
# Load libraries
library(tidyverse)
library(ggplot2)
library(bayesplot)
library(here)

# Load data
crime_data <- read_csv(here("data", "02-analysis_data", "cleaned_crime_data.csv"))
traffic_data <- read_csv(here("data", "02-analysis_data", "cleaned_traffic_data.csv"))

# Load model
traffic_model <- readRDS(file = here::here("models", "traffic_model.rds"))



#### Chart 1 ####
# Distribution of Crimes by Division
ggplot(crime_data, aes(x = division)) +
  geom_bar(fill = "lightblue", color = "darkblue", alpha = 0.7) +
  labs(title = "Crime Distribution by Division", x = "Division", y = "Number of Crimes") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



#### Chart 2 ####
# Traffic Accidents Over Time
traffic_data <- traffic_data %>%
  mutate(report_date = as.Date(report_date, format = "%Y-%m-%d")) %>%
  filter(!is.na(report_date))  # Remove rows with invalid dates

accidents_per_date <- traffic_data %>%
  group_by(report_date) %>%
  summarise(num_accidents = n())

ggplot(accidents_per_date, aes(x = report_date, y = num_accidents)) +
  geom_line(color = "darkred", linewidth = 1) +  # Updated to use 'linewidth'
  labs(title = "Traffic Accidents Over Time", x = "Date", y = "Number of Accidents") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




#### Chart 3 ####
# Crime Hotspots (Latitude vs. Longitude)
ggplot(crime_data, aes(x = longitude, y = latitude)) +
  geom_point(color = "darkgrey", alpha = 0.5) +
  labs(title = "Crime Hotspots", x = "Longitude", y = "Latitude") +
  theme_minimal()



#### Chart 4 ####
# Injury Severity by Vehicle Type
traffic_data <- traffic_data %>%
  mutate(injury_factor = as.factor(injury))

ggplot(traffic_data, aes(x = vehicle_type, fill = injury_factor)) +
  geom_bar(position = "fill", color = "black", alpha = 0.7) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Injury Severity by Vehicle Type", x = "Vehicle Type", y = "Proportion of Severity Levels") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



#### Chart 5 ####
# Traffic Accidents by Road Type
ggplot(traffic_data, aes(x = road_type)) +
  geom_bar(fill = "orange", color = "darkorange", alpha = 0.7) +
  labs(title = "Traffic Accidents by Road Type", x = "Road Type", y = "Number of Accidents") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



#### Model 1 ####
# Posterior Predictive Check for Traffic Model
pp_check(traffic_model) +
  ggtitle("Posterior Predictive Check for Traffic Model")



#### Model 2 ####
# Text Summary of Traffic Model
summary(traffic_model)
