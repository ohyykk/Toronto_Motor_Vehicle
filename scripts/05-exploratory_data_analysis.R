#### Preamble ####
# Purpose: Models the relationship between traffic data variables to predict injury severity.
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites: 
# - The `rstanarm` package must be installed.
# - Cleaned datasets must exist in the specified locations.
# Additional Information: Ensure that `rstanarm` is set up correctly.

#### Workspace setup ####
library(tidyverse)
library(rstanarm)
library(here)

#### Read data ####
# Load cleaned traffic data
traffic_data <- read_parquet(here("data", "02-analysis_data", "cleaned_traffic_data.parquet"))

#### Prepare data ####
# Filter and transform traffic_data for modeling
traffic_model_data <- traffic_data |>
  mutate(
    injury_severity_numeric = case_when(
      impactype == "Fatal" ~ 3,
      impactype == "Severe" ~ 2,
      impactype == "Minor" ~ 1,
      TRUE ~ 0
    ),
    speeding_numeric = 0  # Placeholder for speeding
  ) |>
  select(injury_severity_numeric, speeding_numeric, latitude, longitude, vehtype, road_class) |>
  drop_na()

#### Model data ####
# Bayesian logistic regression for predicting injury severity
injury_model <-
  stan_glm(
    formula = injury_severity_numeric ~ speeding_numeric + vehtype + road_class + latitude + longitude,
    data = traffic_model_data,
    family = gaussian(),  # Change to an appropriate family if injury severity is ordinal
    prior = normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_intercept = normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_aux = exponential(rate = 1, autoscale = TRUE),
    seed = 853
  )

#### Save model ####
saveRDS(
  injury_model,
  file = here("models", "injury_model.rds")
)
