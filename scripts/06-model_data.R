#### Preamble ####
# Purpose: Calculate theft sub-indexes and output as CSV
# Author: Yingke He
# Date: [Insert Date]
# Contact: [Insert Email]
# License: MIT
# Pre-requisites:
# - Data cleaned using 03-clean_data.R
# - Libraries such as tidyverse must be installed

#### Workspace Setup ####
library(tidyverse)
library(here)

# Load dataset
cleaned_crime_data <- read_csv(here("data", "02-analysis_data", "cleaned_crime_data.csv"))

#### Calculate Theft Sub-Indexes ####

# 1. Hour Index
hour_index <- cleaned_crime_data %>%
  count(hour) %>%
  mutate(
    proportion = n / sum(n),
    index = proportion / 3,  # Normalize so the sum equals 1/3
    type = as.character(hour)
  ) %>%
  select(type, index)

# 2. Day of Week Index
day_index <- cleaned_crime_data %>%
  count(day_of_week) %>%
  mutate(
    proportion = n / sum(n),
    index = proportion / 3,  # Normalize so the sum equals 1/3
    type = day_of_week
  ) %>%
  select(type, index)

# 3. Premises Type Index
premises_index <- cleaned_crime_data %>%
  count(premises_type) %>%
  mutate(
    proportion = n / sum(n),
    index = proportion / 3,  # Normalize so the sum equals 1/3
    type = premises_type
  ) %>%
  select(type, index)

# Combine all indexes into one table
theft_indexes <- bind_rows(
  hour_index,
  day_index,
  premises_index
)

#### Save as CSV ####
output_path <- here("data", "02-analysis_data", "theft_indexes.csv")
write_csv(theft_indexes, output_path)

#### Define the Theft Scoring Model ####
# Create a theft scoring model function
theft_scoring_model <- list(
  hour_index = hour_index,
  day_index = day_index,
  premises_index = premises_index,
  scoring_logic = function(hour, day_of_week, premises_type) {
    # Lookup values for indexes
    hour_score <- hour_index %>% filter(type == as.character(hour)) %>% pull(index)
    day_score <- day_index %>% filter(type == day_of_week) %>% pull(index)
    premises_score <- premises_index %>% filter(type == premises_type) %>% pull(index)
    
    # Calculate total theft risk score
    total_score <- sum(hour_score, day_score, premises_score, na.rm = TRUE)
    return(total_score)
  }
)

#### Save the Theft Scoring Model ####
rds_output_path <- here("models", "theft_scoring_model.rds")
saveRDS(theft_scoring_model, rds_output_path)







# Load datasets
cleaned_traffic_data <- read_csv(here("data", "02-analysis_data", "cleaned_traffic_data.csv"))

#### Preprocess Traffic Data ####
# Add a binned time-of-day variable
cleaned_traffic_data <- cleaned_traffic_data %>%
  mutate(
    time_of_day_bin = case_when(
      time_of_day >= 0 & time_of_day < 600 ~ "Late Night",
      time_of_day >= 600 & time_of_day < 1200 ~ "Morning",
      time_of_day >= 1200 & time_of_day < 1800 ~ "Afternoon",
      time_of_day >= 1800 & time_of_day <= 2359 ~ "Evening",
      TRUE ~ "Unknown"
    )
  )

# Preprocess severity as a binary variable
cleaned_traffic_data <- cleaned_traffic_data %>%
  mutate(
    severity = case_when(
      injury == "Major" | accident_classification == "Fatal" ~ 1,  # Severe cases
      injury %in% c("Minor", "Minimal") ~ 0,                       # Non-severe cases
      TRUE ~ NA_real_                                              # NA for missing or undefined
    )
  ) %>%
  filter(!is.na(severity))  # Remove rows where severity could not be determined

# Debugging: Check the distribution of severity
cat("Distribution of severity:\n")
print(table(cleaned_traffic_data$severity))

#### Logistic Regression Model for Collision Severity ####
collision_severity_model <- glm(
  formula = severity ~ hood_158 + time_of_day_bin + traffic_control +
    visibility_conditions + lighting_conditions + road_conditions,
  family = binomial(link = "logit"),
  data = cleaned_traffic_data
)

# Summarize the model
cat("Collision Severity Model Summary:\n")
summary(collision_severity_model)

#### Add Predicted Probabilities to Traffic Data ####
# Filter traffic data for consistent training and prediction
filtered_traffic_data <- cleaned_traffic_data %>%
  filter(!is.na(severity))  # Match rows used for training

# Debugging: Check sizes for consistency
cat("Rows in filtered data (used for model training): ", nrow(filtered_traffic_data), "\n")
cat("Rows in original traffic data: ", nrow(cleaned_traffic_data), "\n")

# Generate predictions for the filtered dataset
filtered_traffic_data <- filtered_traffic_data %>%
  mutate(
    collision_probability = predict(collision_severity_model, newdata = filtered_traffic_data, type = "response")
  )

# Merge predictions back into the original dataset
cleaned_traffic_data <- cleaned_traffic_data %>%
  left_join(
    filtered_traffic_data %>%
      select(id, collision_probability),  # Ensure unique identifier is used
    by = "id"
  )

# Debugging: Check for successful merging
cat("Rows in cleaned traffic data after merging predictions: ", nrow(cleaned_traffic_data), "\n")

#### Save Model and Results ####
# Save the logistic regression model
saveRDS(collision_severity_model, here("models", "collision_severity_model.rds"))



#### Model Diagnostics ####
# Correlation between predictors (optional)
cat("Correlation matrix of numeric predictors:\n")
correlation_matrix <- cleaned_traffic_data %>%
  select(time_of_day, fatal_no) %>%  # Replace with relevant numeric predictors
  cor(use = "complete.obs")
print(correlation_matrix)


#### Save Collision Risk Scores ####
# Select relevant columns to save
collision_risk_scores <- cleaned_traffic_data %>%
  select(id, hood_158, collision_probability)

# Define output path
collision_output_path <- here("data", "02-analysis_data", "collision_risk_scores.csv")

# Save as CSV
write_csv(collision_risk_scores, collision_output_path)



#### Load Data ####
# Load theft indexes
theft_indexes <- read_csv(here("data", "02-analysis_data", "theft_indexes.csv"))

# Load theft data
cleaned_crime_data <- read_csv(here("data", "02-analysis_data", "cleaned_crime_data.csv"))

# Load traffic data with collision probabilities
cleaned_traffic_data <- read_csv(here("data", "02-analysis_data", "cleaned_traffic_data.csv"))

#### Ensure Collision Probability ####
# If collision_probability is missing, calculate it
if (!"collision_probability" %in% colnames(cleaned_traffic_data)) {
  cleaned_traffic_data <- cleaned_traffic_data %>%
    mutate(
      time_of_day_bin = case_when(
        time_of_day >= 0 & time_of_day < 600 ~ "Late Night",
        time_of_day >= 600 & time_of_day < 1200 ~ "Morning",
        time_of_day >= 1200 & time_of_day < 1800 ~ "Afternoon",
        time_of_day >= 1800 & time_of_day <= 2359 ~ "Evening",
        TRUE ~ "Unknown"
      ),
      severity = case_when(
        injury == "Major" | accident_classification == "Fatal" ~ 1,
        injury %in% c("Minor", "Minimal") ~ 0,
        TRUE ~ NA_real_
      )
    ) %>%
    filter(!is.na(severity))
  
  collision_severity_model <- glm(
    formula = severity ~ hood_158 + time_of_day_bin + traffic_control +
      visibility_conditions + lighting_conditions + road_conditions,
    family = binomial(link = "logit"),
    data = cleaned_traffic_data
  )
  
  cleaned_traffic_data <- cleaned_traffic_data %>%
    mutate(
      collision_probability = predict(collision_severity_model, newdata = ., type = "response")
    )
}

#### Calculate Theft Component ####
# Aggregate theft indexes for simplicity
hour_index <- theft_indexes %>% filter(str_detect(type, "^\\d+$"))
day_index <- theft_indexes %>% filter(type %in% c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
premises_index <- theft_indexes %>% filter(type %in% c("House", "Outside", "Commercial"))

# Add indexes to the theft data
cleaned_crime_data <- cleaned_crime_data %>%
  mutate(
    hour = as.character(hour),  # Ensure hour is a character
    hour = if_else(hour == "24", "0", hour)  # Handle 24:00 case
  ) %>%
  left_join(hour_index, by = c("hour" = "type")) %>%
  rename(hour_index = index) %>%
  left_join(day_index, by = c("day_of_week" = "type")) %>%
  rename(day_index = index) %>%
  left_join(premises_index, by = c("premises_type" = "type")) %>%
  rename(premises_index = index) %>%
  mutate(
    theft_component = hour_index + day_index + premises_index  # Sum theft sub-indexes
  )

#### Add Theft Component to Traffic Data ####
# Add the average theft component by neighborhood
theft_by_neighborhood <- cleaned_crime_data %>%
  group_by(hood_158) %>%
  summarize(avg_theft_component = mean(theft_component, na.rm = TRUE))

cleaned_traffic_data <- cleaned_traffic_data %>%
  left_join(theft_by_neighborhood, by = "hood_158") %>%
  mutate(avg_theft_component = replace_na(avg_theft_component, 0))  # Replace NA with 0

#### Calculate Final Risk Index ####
# Define weights for components
weight_collision <- 0.7
weight_theft <- 0.3

# Calculate risk index
cleaned_traffic_data <- cleaned_traffic_data %>%
  mutate(
    risk_index = weight_collision * collision_probability + weight_theft * avg_theft_component
  )

#### Save Final Risk Index ####
# Save the final dataset with the risk index
output_path <- here("data", "02-analysis_data", "final_risk_index.csv")
write_csv(cleaned_traffic_data %>% select(id, hood_158, risk_index), output_path)

#### Save the Risk Calculation Model ####
# Define the final risk model
final_risk_model <- list(
  collision_model = collision_severity_model,
  theft_indexes = theft_indexes,
  weight_collision = weight_collision,
  weight_theft = weight_theft,
  risk_calculation_logic = function(collision_probability, avg_theft_component) {
    risk_index <- weight_collision * collision_probability + weight_theft * avg_theft_component
    return(risk_index)
  }
)

# Save the final risk model as RDS
rds_output_path <- here("models", "final_risk_model.rds")
saveRDS(final_risk_model, rds_output_path)



#### End of Script ####
