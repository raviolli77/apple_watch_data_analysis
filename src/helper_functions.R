# Helper function --------------------------------------------------

#' Convert column to datetime
#' 
#' @param data_frame respective dataframe which contains column(s) 
#' @param col column within dataframe that will be converted to datetime utilizing \code{lubridate::as_datetime}
#' @return Dataframe with column converted to datetime

convert_date <- function(data_frame, col_name){
  # Tidy Evaluation in 5 minutes
  # https://www.youtube.com/watch?v=nERXS3ssntw
  var_cols <- enquo(col_name)
  var_name <- quo_name(var_cols)
  
  data_frame <- data_frame %>% 
      mutate(!!var_name := lubridate::as_datetime(!! var_cols) )
  # data_frame$col: AVOID THIS SYNTAX
  return(data_frame)
}

#' Extracts datetime meta data
#' 
#' @param data_frame respective dataframe which contains column(s) 
#' @param col column within dataframe that will be utilized to extract months, year, and weekday metadata \code{lubridate::as_datetime}
#' @return Dataframe with column converted to datetime

clean_data <- function(data_frame, col_name){
  col_name <- enquo(col_name)
  months_list <- c("January", "February", "March", 
                   "April", "May", "June", "July", 
                   "August", "September", "October", 
                   "November", "December")
  
  # Extract the months and create a column
  data_frame <- data_frame %>% 
    mutate(months = months(!!col_name)) %>%
    mutate(year = lubridate::year(!!col_name)) %>%
    mutate(week_days = lubridate::wday(!!col_name, label = TRUE))
  data_frame[["months"]] <- ordered(data_frame[["months"]], 
                                    levels = months_list)
  return(data_frame)
}
















