# Helper function --------------------------------------------------

#' Convert column to datetime
#' 
#' Function created to facilitate the conversion of columns to 
#' \emph{datetime} with the ability to use in pipe operators 
#' from \code{magrittr}.
#' 
#' @param data_frame respective dataframe which contains column(s) 
#' @param col column within dataframe that will be converted to 
#' datetime utilizing \code{as_datetime} from \code{lubridate}.
#' 
#' @return Dataframe with column converted to datetime

convert_date <- function(data_frame, col_name) {
  # Tidy Evaluation in 5 minutes
  # https://www.youtube.com/watch?v=nERXS3ssntw
  var_cols <- enquo(col_name)
  var_name <- quo_name(var_cols)
  tryCatch({
    data_frame <- data_frame %>%
      mutate(!!var_name := lubridate::as_datetime(!!var_cols), 
             tz = 'America/Los_Angeles')
    data_frame
  },
  error = function(c) {
    message(paste0("Column '", var_name, "' not in correct format"))
    stop(c)
  })
}

#' Extracts datetime meta data
#' 
#' @param data_frame respective dataframe which contains column(s) 
#' @param col column within dataframe that will be utilized to extract months, year, and weekday metadata \code{lubridate::as_datetime}
#' @return Dataframe with column converted to datetime

extract_date_data <- function(data_frame, col_name){
  col_name <- enquo(col_name)
  months_list <- c("January", "February", "March", 
                   "April", "May", "June", "July", 
                   "August", "September", "October", 
                   "November", "December")
  # Make sure column is datetime
  tryCatch({
      # Extract the months and create a column
      data_frame <- data_frame %>%
        mutate(months = lubridate::month(!!col_name, label = TRUE)) %>%
        mutate(year = lubridate::year(!!col_name)) %>%
        mutate(week_days = lubridate::wday(!!col_name, label = TRUE))
      
      data_frame
      }, error = function(c){
        message(paste0("Column '", quo_name(col_name), "' not in correct format"))
        stop(c)
      })
  }


clean_data <- function(data_file){
    # Load data
    data_frame <- read_csv(
        here::here("data/raw", sprintf("%s.csv", data_file))
    )
    
    # Clean Data using predefined function
    data_frame <- data_frame %>% 
        convert_date(creationDate) %>%
        convert_date(startDate) %>%
        convert_date(endDate) %>%
        extract_date_data(creationDate) %>%
        filter(year == 2017)
    # Create column to see the difference of time between 
    # Start date and end date
    data_frame <- data_frame %>%
        mutate(time_diff_mins = as.numeric(
            difftime(endDate, startDate, units = "mins")
        ))
    data_frame
}
