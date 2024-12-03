
#### Preamble ####
# Purpose: To analyze and visualize trends in traffic and theft data, this script includes analyses of risk index distributions, environmental predictors, temporal trends, and neighborhood-based disparities while leveraging a Bayesian model for risk analysis.
# Author: [Your Name]
# Date: [Today's Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites:
# - Required R packages installed
# - 03-clean_data.R must have been run
# - 06-model_data.R must have been run



#### Workspace setup ####
# Load libraries
library(tidyverse)
library(bayesplot)
library(arrow)
library(here)

# Load data
traffic_data <- read_parquet(here("data", "02-analysis_data", "cleaned_traffic_data.parquet"))
theft_data <- read_parquet(here("data", "02-analysis_data", "cleaned_crime_data.parquet"))
final_risk_data <- read_csv(here("data", "02-analysis_data", "final_risk_index.csv"))
risk_model <- readRDS(file = here("models/final_risk_model.rds"))



#### Chart 1 ####
# Distribution of Risk Index
ggplot(final_risk_data, aes(x = risk_index)) +
  geom_histogram(binwidth = 0.05, fill = "lightgrey", color = "darkgrey", alpha = 0.7) +
  geom_density(aes(y = ..count..), color = "red", size = 1) +
  labs(title = "Distribution of Risk Index", x = "Risk Index", y = "Frequency") +
  theme_minimal()



#### Chart 2 ####
# Risk Index by Road Conditions
merged_data <- left_join(final_risk_data, traffic_data, by = "id")

ggplot(merged_data, aes(x = road_conditions, y = risk_index, fill = road_conditions)) +
  geom_violin(alpha = 0.7) +
  scale_fill_brewer(palette = "Set3") +
  labs(title = "Risk Index by Road Conditions", x = "Road Conditions", y = "Risk Index") +
  theme_minimal()



#### Chart 3 ####
# Temporal Trends: Theft by Hour of Day
theft_by_hour <- theft_data %>%
  group_by(hour) %>%
  summarise(theft_count = n())

ggplot(theft_by_hour, aes(x = hour, y = theft_count)) +
  geom_line(color = "darkgrey", size = 1) +
  labs(title = "Theft Count by Hour of Day", x = "Hour of Day", y = "Theft Count") +
  theme_minimal()



#### Chart 4 ####
# Incidents Across Neighborhoods
neighborhood_incidents <- traffic_data %>%
  group_by(hood_158) %>%
  summarise(incident_count = n())

ggplot(neighborhood_incidents, aes(x = reorder(hood_158, -incident_count), y = incident_count)) +
  geom_bar(stat = "identity", fill = "lightgrey", color = "darkgrey", alpha = 0.7) +
  labs(title = "Incidents Across Neighborhoods", x = "Neighborhood ID", y = "Incident Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



#### Chart 5 ####
# Risk Index by Lighting Conditions
ggplot(merged_data, aes(x = lighting_conditions, y = risk_index, fill = lighting_conditions)) +
  geom_violin(alpha = 0.7) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Risk Index by Lighting Conditions", x = "Lighting Conditions", y = "Risk Index") +
  theme_minimal()



#### Model 1 ####

# Text Summary of Risk Model
summary(risk_model)

