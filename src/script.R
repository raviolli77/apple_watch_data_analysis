# Load Packages
library(tidyverse)
library(lubridate)
library(here)

# Load functions from helper script
source(here::here("src", "helper_functions.R"))

# Load Data
anon_data <- read_csv(
  here::here("data/processed", "data.csv")
)


# Clean Data using predefined function
anon_data <- anon_data %>%
  convert_date(creationDate) %>%
  convert_date(startDate) %>%
  convert_date(endDate) %>%
  extract_date_data(creationDate)

# Create column to see the difference of time between 
# Start date and end date
anon_data <- anon_data %>%
  mutate(time_diff_mins = as.numeric(
    difftime(endDate, startDate, units = "mins")
  ))
# Exploratory Analysis

# Calories Burned per Gram by Month and Year
anon_data %>%
  group_by(months, year) %>%
  summarise(total_cal = sum(value)) %>%
  spread(key = year,
         value = total_cal, 
         fill = "None Noted")

# Visual Representation
anon_data %>%
  group_by(months, year) %>%
  summarize(total_Cal = sum(value)) %>%
  ggplot(.,
         aes(months,
             y = total_Cal,
             fill = as.factor(year))) +
  geom_bar(stat = "identity",
           colour = "#39a78e") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1)) +
  facet_wrap( ~ year) +
  labs(x = "Year",
       y = "Total",
       title = "Total Calories Burned by Month and Year") +
  scale_fill_hue(l = 40,
                 name = "Year")

# Focus on 2017 # 

anon_data17 <- anon_data %>%
  filter(year == 2017)

# Calculate missing values by date
year_ad17 <- unique(as.Date(anon_data17$creationDate))
year17 <- seq(as.Date("2017-01-01"), as.Date("2017-12-31"), by = "days")
missing_values <- year17[!year17 %in% year_ad17]

missing_values

# summary on value column
summary(anon_data17[["value"]])

# Histogram of Calories
ggplot(anon_data17, 
       aes(x = value)) + 
  geom_histogram(fill = "#39a78e", 
                 bins = 200) + 
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 
                                  max(anon_data17$value), 
                                  by = 1)) + 
  labs(x = "Calories Burned", 
       y = "Total", 
       title = "Energy Burned") 

## Exploratory Analysis by Time Intervals

anon_data17 %>%
  group_by(week_days) %>%
  summarise(avg_cal = mean(value)) %>%
  arrange(desc(avg_cal))

anon_data17 %>%
  group_by(months) %>%
  summarise(avg_cal = mean(value)) %>%
  arrange(desc(avg_cal))

anon_data17 %>%
  mutate(week_date = ceiling(day(creationDate) / 7)) %>%
  group_by(week_date) %>%
  summarise(avg_cal = mean(value)) %>%
  arrange(desc(avg_cal))


# Calendar Heat map
## Inspired by: http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html
anon_data17 %>%
  mutate(week_date = ceiling(day(creationDate) / 7)) %>%
  group_by(week_date, months, week_days) %>%
  summarise(total_cal = sum(value)) %>%
  ungroup() %>%
  ggplot(., 
         aes(week_days, week_date, fill = total_cal)) +
  geom_tile(colour = "white") + 
  facet_wrap(~months) +
  theme_bw() +
  scale_fill_gradient(name = "Total \nCalories", 
                      low = "#39a78e", high = "#a73952") + 
  labs(x = "Week of the Month", 
       y = "Weekday") + 
  scale_y_continuous(trans = "reverse") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Average Energy Burned for 2017

anon_data17 %>%
  group_by(creationDate = as.Date(creationDate)) %>%
  summarise(avg_cal = mean(value)) %>%
  ggplot(., 
         aes(x = creationDate, 
             y = avg_cal)) +
  geom_line(colour = "#39a78e") + 
  geom_smooth(se = FALSE) + 
  theme_minimal() + 
  labs(x = "Date of Activity", 
       y = "Average Calories", 
       title = "Average Energy Burned Time Series") 

# Average Energy Burned by Weekday for 2017
anon_data17 %>%
  group_by(week_days, months) %>%
  summarise(avg_cal = mean(value)) %>%
  ggplot(., 
         aes(months, avg_cal,
             group = week_days,
             colour = week_days)) + 
  geom_line(aes(colour = week_days)) + 
  theme_minimal() + 
  labs(x = "Month", 
       y = "Average Calories", 
       title = "Average Energy Burned by Weekday for 2017") + 
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1)) +
  scale_color_hue(l = 40,
                  name = "Weekday")