library(tidyverse)
library(lubridate)

if (!file.exists(here::here("data/processed/rds_files", "year_week_2017.rds"))) {
    year_week_17 <- readRDS(here::here("rds_files", "year_week_2017.rds"))
    print("using alternate")
} else {
    year_week_17 <- readRDS(here::here("data/processed/rds_files", "year_week_2017.rds"))
}

#' Calculate Missing days by Month
#' 
#' Function groups data frame by month and captures the missing days 
#' for each month. Assumes data frame has correct structuring for 
#' function to work. 
#' 
#' @param data_frame respective dataframe which contains column(s).
#' 
#' @return Dataframe with months and days missing from said month.
create_data_frame_metrics <- function(data_frame){
    data_frame %>%
        group_by(months) %>%
        mutate(captured_dates = length(unique(as.Date(creationDate)))) %>%
        mutate(missing_days = days_in_month(creationDate) - captured_dates) %>%
        ungroup() %>%
        count(months, missing_days) %>%
        select("Month" = months, "Missing Days" = missing_days)
}

#' Calculate Missing days by Month and weekday
#' 
#' Function groups data frame by month and weekday then captures the missing days 
#' for each weekday of the different months. Assumes data frame has correct structuring for 
#' function to work. 
#' 
#' @param data_frame respective dataframe which contains column(s).
#' 
#' @return Dataframe with months and weekdays missing from said month.
calculate_missing_by_week <- function(data_frame) {
    data_frame %>%
        group_by(months, week_days, my_date = as.Date(creationDate)
             ) %>%
    count(week_days) %>%
    ungroup() %>%
    count(months, week_days) %>%
    select(months, week_days, my_weekdays = nn) %>%
    inner_join(year_week_17, by = c("week_days", "months")) %>%
    ungroup() %>% 
    mutate(missing_weekdays = total_weekdays - my_weekdays) %>%
    select(months, week_days, missing_weekdays) %>%
    spread(key = week_days, 
           value = missing_weekdays,
           fill = 0) %>%
    select(Month = months, Sun, Mon, Tue, Wed, Thu, Fri, Sat)
}

#' Calendar heatmap 
#' 
#' Function calculates the week of a entry (i.e. January 1st would land on week 1
#' and January 31st would land on week 4) then groups by this field, day of the week
#' (i.e. Monday or Friday), and month to create heatmap that showcases the total 
#' category by day. Similar to github's commit heatmap calendar.  
#'  
#' @param data_frame respective dataframe which contains column(s).
#' @param col_name respective datetime column used to calculate the week 
#' in the month.
#' @param value respective column containing the value of category (i.e. calories
#' burned, miles ran/walked).
#' @param  covariate Name of the previous value to input into the plot legend.  
#' 
#' @return calendar heatmap created with \code{ggplot2} 
create_heatmap <- function(data_frame, col_name, value, covariate){
    var_cols <- enquo(col_name)
    value_cols <- enquo(value)
    
    data_frame %>%
        mutate(week_date = ceiling(day(!!var_cols) / 7)) %>%
        group_by(week_date, months, week_days) %>%
        summarise(total_value = sum(!!value_cols)) %>%
        ungroup() %>%
        ggplot(., 
               aes(week_days, week_date, fill = total_value)) +
        geom_tile(colour = "white") + 
        facet_wrap(~months) +
        theme_bw() +
        scale_fill_gradient(name = covariate, 
                            low = "#39a78e", high = "#a73952") + 
        labs(x = "Week of the Month", 
             y = "Weekday") + 
        scale_y_continuous(trans = "reverse") + 
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#' Generates time series of average value per day
#' 
#' Function aggregates data by day and calculates average for each respective date. 
#' Then utilizing \code{ggplot2} creates a time series plot with a loess regresssion
#' line to help showcase trend.   
#'  
#' @param data_frame respective dataframe which contains column(s).
#' @param col_name respective datetime column used to calculate the week 
#' in the month.
#' @param value respective column containing the value of category (i.e. calories
#' burned, miles ran/walked).
#' @param  covariate Name of the previous value to input into the plot legend.  
#' 
#' @return calendar heatmap created with \code{ggplot2} 
create_time_series <- function(data_frame, col_name, value_name, covariate){
    var_cols <- enquo(col_name)
    data_frame %>%
        group_by(creationDate = as.Date(creationDate)) %>%
        summarise(avg_value = mean(!!var_cols)) %>%
        ungroup() %>%
        ggplot(., 
               aes(x = creationDate, 
                   y = avg_value)) +
        geom_area(fill = "#39a78e",
                  alpha = 0.80) + 
        geom_smooth(se = FALSE, 
                    colour = "#a73952",
                    method = "loess") + 
        theme_minimal() + 
        scale_x_date(date_labels="%b",date_breaks  ="1 month") + 
        theme(axis.text.x = element_text(angle = 45)) + 
        labs(x = "Date of Activity (2017)", 
             y = sprintf("Average %s", value_name),  
             title = sprintf("Average %s over Time for 2017", covariate)) 
}

create_time_series_weekly <- function(data_frame, col_name, value_name, covariate){
    var_cols <- enquo(col_name)
    data_frame %>%
        group_by(week_days, year, months) %>%
        summarise(avg_value = mean(!!var_cols)) %>%
        ungroup() %>%
        ggplot(.,
               aes(months, avg_value,
                   group = week_days,
                   colour = week_days)) +
        geom_line(aes(colour = week_days),
                  na.rm = TRUE) +
        theme_minimal() +
        labs(x = "Month",
             y = sprintf("Average %s", value_name),  
             title = sprintf("Average %s by Weekday for 2017", covariate)) +
        theme(axis.text.x = element_text(angle = 45,
                                         hjust = 1)) +
        scale_color_hue(l = 40,
                        name = "Weekday")
}

# ICE BOX
# year17 <- seq(as.Date("2017-01-01"), as.Date("2017-12-31"), by = "days")

# year_week_17 <- tibble(year17) %>%
#    mutate(week_days = wday(year17, label = TRUE), 
#           months = month(year17, label = TRUE)) %>%
#    group_by(week_days, months) %>%
#    count() %>%
#    ungroup() %>%
#    select(week_days, months, total_weekdays = n)
