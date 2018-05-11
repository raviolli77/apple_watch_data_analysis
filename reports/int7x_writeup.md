## Abstract

With the popularity of wearable ( [source](http://www.fhs.swiss/pdf/communique_170112_a.pdf) ) technology both data scientists and health professionals have found a crossroad that provides insight into a powerful data generator, the human body. With the quantity of data readily available from wearable devices many organizations and researchers have taken steps towards utilizing and understanding the vast amount of data to improve the human experience.   

Many companies have utilized wearable apps to help understand customer's health history more intimately. [Evidation Health](https://evidation.com/) has done studies which utilize longitudinal wearable technologies for predicting a binary anxiety diagnosis utilizing temporal Convolutional Neural Networks ( [source](https://evidation.com/wp-content/uploads/2017/10/observation-time-vs-performance-in-digital-phenotyping.pdf) ); being able to perform better than their baseline model (using low time granularity features see source for more information). 

Researchers in San Franciso created a semi-supervised deep learning model utilizing deep learning that can predict medical conditions with the help of wearable app data from commercial apps like FitBit and Apple Watch. ( [source](https://arxiv.org/pdf/1802.02511.pdf) ).  Utilizing Long short-term Memory (or [LSTM](http://colah.github.io/posts/2015-08-Understanding-LSTMs/)) models yielding better predictive power than baseline models (classification models not considered deep learning including Random Forest and Multi-layer Perceptron). 

Having a strong interest in the merging of data science and the human experience, wearable apps play an interesting role in the evolution of data science through:

+ the quantity of data available.
+ the ease of access of mHealth data
+ the relationship between the data and other data sources relevant to the user

Of course there are many challenges with data collection and privacy as seen with the recent controversial data breach between Facebook and Cambridge Analytica (  [source](https://www.nytimes.com/2018/03/19/technology/facebook-cambridge-analytica-explained.html) ), that can make users weary of researchers utilizing their data. Understanding the importance of wearable app within the context of medical advances can help foster the grow of artificial intelligence in the health industry. 

One of the first challenges is making sense of the vast amount of data available. Thus I aim to do some exploratory analysis utilizing data that was made available from a friend's Apple Watch. The data was anonymized and I will be focusing on exploratory analysis on one factor that was measured by the app: active energy burned. Although future iterations I would like to include other categories gathered by the watch.

## Get Data

I received the data from my friend extracting the data from their Apple Watch as an xml file. I then used a python script created by Nicholas J. Radcliffe, which parses through the xml files and creates csv files. Repo can be found [here](https://github.com/tdda/applehealthdata).

After running the script I anonymized the data and input it into the sub-directory called *data/processed* inside the parent directory. 

## Load Packages

This walkthrough focuses on `tidyverse`, `lubridate` and `ggplot2` to provide eloquent and digestable visuals to showcase *exploratory analysis* on a single person's *apple watch* data.  

Here we load the appropriate into our R environment. 

```{r}
library(tidyverse)
library(lubridate)
library(here)

here::here()
source(here::here("src", "helper_functions.R"))
```


### Console Output


```{r}
## [1] "/Users/ravi/Desktop/my_projects/apple_health_data"
```

When utilizing functions in the `here` package, we will use the currrent notation:

```{r}
  here::function_name
```

This is due to conflicts in functions that are called `here` in the `lubridate` and `here` packages. I also created a script called `helper_functions` which has 2 functions that create meta data relating to the day of the week and month (called `extract_date_data`), along with data type conversions relating to date columns (called `convert_date`). 

## Load Data

We will be loading the data with `tidyr`'s csv file reader, which will load the data into a `tibble`.  

There were a few other columns relating to the meta-data of the apple watch, but they were removed for this analysis. 

```{r}
# Load Data
anon_data <- read_csv(
    here::here("data/processed", "data.csv")
    )
```

### Console Output

```{r}
## Parsed with column specification:
## cols(
##   sourceName = col_character(),
##   type = col_character(),
##   unit = col_character(),
##   creationDate = col_datetime(format = ""),
##   startDate = col_datetime(format = ""),
##   endDate = col_datetime(format = ""),
##   value = col_double()
## )
```

## Use helper functions to extract meta data. 

```
anon_data <- anon_data %>%
  convert_date(creationDate) %>%
  convert_date(startDate) %>%
  convert_date(endDate) %>% 
  extract_date_data(creationDate)

```

The `convert_date` function converts the columns to datetime. Using pipe operators to do the function calls, this was done by creating the functions utlizing [Non Standard Evaluation](http://adv-r.had.co.nz/Computing-on-the-language.html).  

The `extract_date_data` function as mentioned earlier creates columns relating to meta data about the dates utilizing functions from `lubridate`, which include making a week day column and a month column appearing in logical order (Jan to Dec). 

## More Data Cleanage

Another transformation I included was the difference in minutes between the start date and end date of each measurement. We do this utilizing `mutate` from `dplyr`, and the function `difftime` which will find the difference in units of minutes. 

```{r}
# Find difference in start and end date in minutes
anon_data <- anon_data %>%
  mutate(time_diff_mins = as.numeric(
  difftime(endDate, startDate, units = "mins")
  )) 
```

I wanted to include this to gain insight as to how regularly were measurements done since I am not too familiar with Apple Watches or their data collection processes. 

Now let's preview the `tibble`:

```{r}
head(anon_data)
```


### Console Output

```
## # A tibble: 6 x 12
##   sourceName     type        unit  creationDate        startDate          
##   <chr>          <chr>       <chr> <dttm>              <dttm>             
## 1 Anon’s Apple … ActiveEner… kcal  2016-11-06 06:55:53 2016-11-06 05:51:32
## 2 Anon’s Apple … ActiveEner… kcal  2016-11-06 06:55:53 2016-11-06 06:51:33
## 3 Anon’s Apple … ActiveEner… kcal  2016-11-06 06:55:53 2016-11-06 06:53:36
## 4 Anon’s Apple … ActiveEner… kcal  2016-11-06 06:55:53 2016-11-06 06:54:37
## 5 Anon’s Apple … ActiveEner… kcal  2016-11-06 06:59:19 2016-11-06 06:57:52
## 6 Anon’s Apple … ActiveEner… kcal  2016-11-06 07:00:47 2016-11-06 06:58:44
## # ... with 7 more variables: endDate <dttm>, value <dbl>, tz <chr>,
## #   months <ord>, year <dbl>, week_days <ord>, time_diff_mins <dbl>
```

This will help showcase the structure of the data frame and is general good practice for other users to become familiar with the data frame. 

## Dive into data

Here I will flatten the data across years and months. This is done utilizing the `spread` function where we use year as the key and fill any values that are not present with *None Noted* to showcase the distribution of the data.


```{r}
anon_data %>%
  group_by(months, year) %>%
  summarize(total_Cal = sum(value)) %>%
  spread(key = year,
         value = total_Cal,
         fill = "None Noted")
```
| Month | 2016 | 2017 | 2018 | 
|-------|------|------|------|
| January |	None Noted | 	11516946 |	9777295 | 	
| February |	None Noted | 	10744737 | 	10750884 | 	
| March |	None Noted | 	10876301 | 	1072273 | 	
| April	| None Noted | 	13952086 | None Noted | 
| May |	None Noted |	13806328 |	None Noted | 
| June |	None Noted |	10065583 |	None Noted | 	
| July |	None Noted | 	5539308 | 	None Noted |	
| August | None Noted |	9337452	| None Noted | 
| September	| None Noted | 7876080	| None Noted | 	
| October	| None Noted |	11931943 | None Noted | 
| November | 10123599 | 10174572 | None Noted | 
| December | 10030715	| 7738922	 | None Noted | 

As we can see the person's data collection started in November 2016 and is ongoing until March 2018. Next we create a visual representation to drive the point home. 

## Visual Representation

```{r}
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
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/00_total_cal_plot.png" />

I decided to only do analysis on 2017 since that's the year with the most complete data available from my friend's apple watch, and having incomplete data collection for the other years would skew our conclusions. 


## Creating tibble for 2017

Here we will be utlizing the `filter` function to only include data which have the year column (generated from the `creationDate` column) equal to 2017 and call it `anon_data17`. 


```{r}
anon_data17 <- anon_data %>%
  filter(year == 2017)
```

## Missing Values 

Although we have data entry for all of 2017 (by months), I wanted to explore in more detail how much data (if any) is missing from our data frame as it relates to the creation date of the recordings. I created two vectors; the first includes all entries as dates from our data frame and the second includes all dates from 2017. I then compare these two vectors and see what values are not in our data frame that are in 2017 to know what dates weren't recorded by the apple watch.  


```{r}
year_ad17 <- unique(as.Date(anon_data17$creationDate))
year17 <- seq(as.Date("2017-01-01"), as.Date("2017-12-31"), by = "days")
missing_values <- year17[!year17 %in% year_ad17]


missing_values
```

### Console Output

```
##  [1] "2017-04-01" "2017-07-24" "2017-07-25" "2017-07-26" "2017-07-27"
##  [6] "2017-07-28" "2017-07-29" "2017-07-30" "2017-07-31" "2017-08-01"
## [11] "2017-08-02" "2017-08-03" "2017-08-04" "2017-12-08"
```

We can see that the missing entries include the time interval 7/24/2017 to 08/04/2017 (12 days), meaning there is a human component as to why the data is missing. We can conclude that this data is *not missing at random* so we have to be weary of any conclusions we make during this time frame. 

The reasons for this missing time range could be explained by vacation maybe or lost watch perhaps.  

### Summary Statistics

Now that we have an understanding of missing data we can go ahead and begin to explore the data. I begin by looking at the distribution of the calories burned (called `value` in the data frame) using the `summary` function. 

```{r}
summary(anon_data17$value)
```

### Console Output

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.0010  0.1180  0.2080  0.5017  0.3500 11.2990
```

This gives us great insight into some summary statistics, but often visualizing the data can provide insight that can't be deduced from summary statistics. So we visualize the distribution utilizing a histogram. 

```{r}
ggplot(anon_data17, 
         aes(value)) + 
  geom_histogram(fill = "#39a78e", 
                 bins = 200) + 
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 
                                  max(anon_data17$value), 
                                  by = 1)) + 
  labs(x = "Calories Burned", 
       y = "Total", 
       title = "Energy Burned by Month") 
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/01_energy_burned.png" />

We can see that there is some right skewness and that most of our data falls in the range between [0, 1]. 

## Data Collection by Day

I wanted to briefly look at data collection by day, so I grouped by creation date and counted the units then gave summary statistics. 

```{r}
anon_data17 %>%
  group_by(creation_date = as.Date(creationDate)) %>%
  count(unit) %>%
  ungroup() %>%
  select(n) %>% 
  summary()
# anon_data17 %>%
#   group_by(creation_date = as.Date(creationDate)) %>%
#   count(unit) %>%
#   filter(n > 900) %>%
#   arrange(desc(n))
 
```

### Console Output

```
##        n         
##  Min.   :   1.0  
##  1st Qu.: 569.0  
##  Median : 719.0  
##  Mean   : 701.5  
##  3rd Qu.: 855.0  
##  Max.   :1276.0
```

Here we can see the average and median fall around 700 instances per day. 


## Calendar Heatmap

Inspired by this [blog post](http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html), I created a calendar heatmap to showcase the total amount of calories burned across 2017 by weekday. 

```{r}
anon_data17 %>%
  mutate(week_date = ceiling(day(creationDate) / 7)) %>%
  group_by(week_date, months, week_days) %>%
  summarise(total_cal = sum(value)) %>%
  ggplot(., 
       aes(week_days, week_date, fill = total_cal)) +
  geom_tile(colour = "white") + 
  facet_wrap(~months) +
  theme_bw() +
  scale_fill_gradient(name = "Total \nCalories", 
                      low = "#39a78e", high = "#a73952") + 
  labs(x = "Week of the Month", 
       y = "Weekday") + 
  scale_y_continuous(trans = "reverse")
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/02_calendar_heatmap.png" />


## Calories and Time

Next I wanted to shift focus to a column I had created during the data cleaning section, the time difference. Here I wanted to explore the relationship between time range and the amount of calories burned. 

```{r}
ggplot(anon_data17, 
       aes(time_diff_mins, value)) + 
    geom_point(alpha = 0.10,
             fill = "#39a78e") + 
    theme_minimal() + 
    labs(x = "Time Interval (in mins.)", 
       y = "Calories Burned") 
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/03_time_cal_compare.png" />

Since the data is heavily skewed this visual doesn't give us too much insight so I proceeded to log transform both variables in hopes of understanding their relationship better. 

```{r}
ggplot(anon_data17, 
       aes(time_diff_mins, value)) + 
    geom_point(alpha = 0.10,
             fill = "#39a78e") + 
    theme_minimal() + 
    labs(x = "Time Interval in mins. (log transformation)", 
       y = "Calories Burned (log transformation)") + 
    scale_y_log10() +
    scale_x_log10() 

```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/04_time_cal_log.png" />


Some key takeaways: 

+ Data capturing is mostly done in uniform time intervals  
+ Calories burned show an increase until around the range between [2.5, 3] minutes where the calories burned start to show a decrease
+ Larger time intervals become more sporadic with respect to calories burned

## Time Frame Analysis

Here I wanted to shift focus to the time intervals, since we found some interesting relationships between time and calories. I begin by using summary on the time difference. 

```{r}
summary(anon_data17$time_diff_mins)
```

### Console Output

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.0000  1.0167  1.0167  0.9878  1.0333 60.0167
```

We can see that the data falls mostly within the 1 minute time frame, while we have a maximum value of an hour. Let's dissect the data more by grouping both by month and weekday seperately to see if there are any trends within dates as it relates to larger values for energy burned. 

#### By Month

Let's start with grouping by month.  

```{r}
anon_data17 %>%
 group_by(months) %>%
 summarise(avg_time_spent = mean(time_diff_mins)) 
```

### Console Output

```
## # A tibble: 12 x 2
##    months    avg_time_spent
##    <ord>              <dbl>
##  1 January            1.01 
##  2 February           1.01 
##  3 March              1.00 
##  4 April              1.01 
##  5 May                1.00 
##  6 June               0.996
##  7 July               1.01 
##  8 August             0.995
##  9 September          1.00 
## 10 October            0.940
## 11 November           0.945
## 12 December           0.961
```

The average for each month still gravitates around 1 minute. Now let's try by weekday and month. This time I created a visual since the output would be too large to read easily.  

```{r}
anon_data17 %>%
 group_by(week_days, months) %>%
 summarise(avg_time_spent = mean(time_diff_mins)) %>%
  ggplot(.,
         aes(week_days, avg_time_spent,
             fill = week_days)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~months) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1)) +  
  labs(x = "Weekday", 
       y = "Average Time Spent", 
       title = "Average Time by months and Weekday") + 
    scale_fill_hue(l = 40,
                 name = "Weekday")
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/04_avg_time.png" />

Again showcasing that most of our data is collected in 1 minute intervals, and there aren't any months or weekdays that show any irregularities in time intervals for data collection. 

Understanding the outliers is still difficult to understand without knowing the specs for the apple watch so more research on my part will be done to understand the data capturing process for an apple watch.
 
### Diving into the Time Difference Column

Here we go a little more in depth by looking at time frames that are larger than 30 minutes. 


```{r}
anon_data17 %>%
  filter((time_diff_mins > 30) ) %>%
  select(value, time_diff_mins) %>%
  arrange(desc(value))
```

### Console Output

```
## # A tibble: 11 x 2
##    value time_diff_mins
##    <dbl>          <dbl>
##  1 0.766           38.2
##  2 0.75            49.7
##  3 0.562           32.0
##  4 0.228           46.6
##  5 0.053           54.8
##  6 0.041           39.1
##  7 0.018           36  
##  8 0.016           54.8
##  9 0.01            60.0
## 10 0.002           55.3
## 11 0.002           40.8
```

These values don't present any values larger than 1 which is unusual. There could have been problems with how the watch performs upon reading this [article](https://support.apple.com/en-us/HT207941#heartrate). Some outside factors could have led to poor data collection, however it might be the case that during these large time intervals the user could have not been exhausting too much energy. 


## Most Data Capture by Hour

Here I wanted to conclude the dissection of the time by looking at what hours have the most data capture. This is done by converting creation date to hour using `lubridate`.

```{r}
ggplot(anon_data17, 
       aes(lubridate::hour(anon_data17$creationDate))) + 
    geom_bar(fill = '#39a78e',
             stat = 'count') + 
    theme_minimal() + 
    labs(x = 'Hour', 
         y = 'Total Count', 
         title = 'Data Capture by Hour')  +
  scale_x_continuous(breaks = seq(0, 
                                  max(lubridate::hour(anon_data17$creationDate)), 
                                  by = 1))
    
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/05_hour_dist.png" />


We can see that that data capture follows a fairly regular schedule with a significant decrease starting at hour 8 which could be when this person is starting to go to sleep (peak hour most likely between 11 and 15). 

# Calories dissected


Here I wanted to visualize the total calories burned by day, so I grouped by dates and weekday to create a visual showing a linear view for 2017. 

```{r}
anon_data17 %>% 
  group_by(creation_date = as.Date(creationDate), 
           week_days) %>% 
  summarise(burn_per_day = sum(value)) %>% 
  ggplot(., 
         aes(creation_date, burn_per_day, 
             fill = week_days)) + 
  geom_bar(stat="identity") + 
  theme_minimal() + 
  labs(x = "Creation Date", 
       y = "Calories burned by day", 
       title = "Calories by Creation Date") + 
  scale_fill_hue(l = 40,
                 name = "Weekday") 
```


<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/05_cal_by_day.png">


We don't see any obvious trends or seasonality but we can see the time frame that has missing data. Next I went a little deeper by facet wrapping by month. 

## Calories burned by weekday and month

```{r}
anon_data17 %>% 
  group_by(creation_date = as.Date(creationDate), 
           week_days, months) %>% 
  summarise(burn_per_day = sum(value)) %>%
    ggplot(., 
       aes(week_days, burn_per_day,
           fill = as.factor(week_days))) +
  geom_bar(stat = "identity") +
  facet_wrap(~ months) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1)) +  
  labs(x = "Weekday", 
       y = "Total Calories",  
       title = "Calories Burned by Weekday and Month") + 
    scale_fill_hue(l = 40,
                 name = "Weekday")
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/06_cal_by_month.png" />

We can start to see some obvious patterns like days that burn more calories within each respective month, but juxtaposing the months across weekday would give us a better comparison. 

This leads me to want to look at the data from a time series perspective so the way I'll do this is averaging the values by date then plotting the results. 

## Average Energy Burned for 2017

Before I do it by weekday, I want to first visualize as a single value by averaging energy burned by date. We will do so by grouping the data by start date then summarizing the calories burned by averaging. We utilize `geom_smooth` to showcase if there's any trend in our data set.  

```{r}
anon_data17 %>%
  group_by(creation_date = as.Date(creationDate)) %>%
  summarise(total_Cal = mean(value)) %>%
    # filter(total_Cal == max(total_Cal)) 
    # Used to view the date in which there was a spike in October
  ggplot(., 
         aes(creation_date, total_Cal)) + 
  geom_line(colour = "#39a78e") + 
  geom_smooth(se = FALSE) + 
  theme_minimal() + 
  labs(x = "Date of Activity", 
       y = "Average Calories", 
       title = "Average Energy Burned Time Series") 
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/07_cal_time_series.png" />

We can see a slow decreasing trend with a spike in average calories on October 21st. There is no obvious trends across each month, so I will create the plot that I mentioned in the previous section.  

## Average Calories by Weekday 

Here I will be creating a visual that showcases the average across the year by weekday. This can help us understand any weekly trends that might have not been obvious on the previous plot. 

```{r}
anon_data17 %>%
  group_by(week_days, year, months) %>%
  summarise(total_Cal = mean(value)) %>%
  ggplot(., 
         aes(months, total_Cal,
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
  
```

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/08_cal_time_series_weekday.png" />


We can notice some seaonality in the weekdays. As well as a decreasing trend as the year goes on. Telling us that the user's activity decreased as the year moved on, this can be helpful in recommendations to the user. We can help motivate the user to keep a steady workflow through the year if we showcase that they are starting to decrease activity later in the year. 

## Conclusion

I wanted to conclude this exploratory analysis with this understanding of the user's energy burned for 2017. Most of the analysis I did can generalize to any data science project and can help users understand what to look for and ways of extracting more from your data. We saw that data can be extracted from existing columns to allow us to create slices on our data frame. Along with utilizing various visualization techniques to produce useful and insigthful plots. 

This project is still in its early iterations and I hope to expand the analysis to the various other categories that the Apple Watch collected and see the relationship across these covariates. 

Next Steps:

+ Collect More data 
    + Time - Apple watch data that has more than 1 year
    + Different People - Collect data from different people
+ Research 
    + Healthly amount of calories burned daily 
    + Relationship between categories 
+ Shiny Dashboard
    + Create an interactive Dashboard to showcase important visuals and summary statistics for users
    + Optional choosing to allow insight into the different categories
+ Machine Learning - predictive modeling 
    + Temporal modeling 
    + Creating and understanding the relationships across categories
+ Data Storage 
    + SQL database
