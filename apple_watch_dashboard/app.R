#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(here)

if (!file.exists(here::here("apple_watch_dashboard", "global_vars.R"))) {
    source(here::here("global_vars.R"))
    print("using alternate")
} else {
    source(here::here("apple_watch_dashboard", "global_vars.R"))
}

# Load data frames
if (!file.exists(here::here("data/processed/rds_files", "ActiveEnergyBurned.rds"))) {
    # Receive file names available in directory
    file_names <- dir(path = here::here("rds_files"), pattern = '*.rds')

    # Add full path to file names
    files <- paste0(here::here("rds_files/"), file_names)

    # Read all files into a list utilizing purrr
    my_data <- files %>%
        purrr::map(readRDS)

    # set names and remove the `.rds` section of the strings
    names(my_data) <- file_names %>%
        str_replace(".rds", "")
} else {
    # Receive file names available in directory
    file_names <- dir(path = here::here("apple_watch_dashboard/rds_files"), pattern = "*.rds")

    # Add full path to file names
    files <- paste0(here::here("apple_watch_dashboard/rds_files/"), file_names)

    # Read all files into a list utilizing purrr
    my_data <- files %>%
        purrr::map(readRDS)

    # set names and remove the `.rds` section of the strings
    names(my_data) <- file_names %>%
        str_replace(".rds", "")
}

# Define colors for plotting 
clrs <- c("#d7ede8", "#9cd3c6", "#74c1af",
          "#39a78e", "#277463", "#164238",
          "#0b211c")

# More colors
more_clrs <- c("#f2d9df", "#ca637a", "#ba3f5b",
               "#943349", "#6e2636", "#230c11",
               "#060203")

# List containing respective dataframe
selectionOptions <- list("active_energy" = my_data[["ActiveEnergyBurned"]],
                         "basal_energy" = my_data[["BasalEnergyBurned"]],
                         "step_count" = my_data[["StepCount"]],
                         "dist_walk_run" = my_data[["DistanceWalkingRunning"]],
                         "flights_climbed" = my_data[["FlightsClimbed"]],
                         "heart_rate" = my_data[["HeartRate"]])

# Options for titles in plots
titleOptions <- list("active_energy" = "Active Energy \nBurned",
                     "basal_energy" = "Basal Energy \nBurned",
                     "step_count" = "Step Count",
                     "dist_walk_run" = "Distance Walking \nand Running",
                     "flights_climbed" = "Flights Climbed",
                     "heart_rate" = "Heart Rate")

# Options for 
unitOptions <- list("active_energy" = "Calories",
                     "basal_energy" = "Calories",
                     "step_count" = "Steps",
                     "dist_walk_run" = "Miles",
                     "flights_climbed" = "Elevation Change",
                     "heart_rate" = "Count per Minute")

# App
ui <- dashboardPage(
    dashboardHeader(title = "Apple Watch Dashboard",
                    titleWidth = 450),
    dashboardSidebar(
        # Add options to side bar
        sidebarMenu(
            menuItem(
                selectInput("category", "Choose Category:",
                        c("Active Energy Burned" = "active_energy",
                          "Basal Energy Burned" = "basal_energy",
                          "Step Count" = "step_count",
                          "Distance Walking and Running" = "dist_walk_run",
                          "Flights Climbed" = "flights_climbed",
                          "Heart Rate" = "heart_rate"))
                ),
            tags$ul(
                    tags$li("Heatmap gives a view of the year emphasizing the intensity of the chosen metric. A gradient view is created where red means more and green is less."),
                    tags$li("The tables shows the number of days in the month and weekday where data was not captured.
                                Be mindful of this when interpretting the various plots."),
                    tags$li("The time series plot (bottom left) takes the average value for the date the data was captured.
This provides insight into any trend across 2017, using ", a(href="http://r-statistics.co/Loess-Regression-With-R.html", "loess"), "regression."),
                    tags$li("The time series plot (bottom right) is very similar to the other time series plot except it gives a break down by weekday.
                                This allows the user to see any seasonal trends to the data category."))
            )
        ),
    dashboardBody(
        # Aesthetical stuff related to CSS
        tags$head(tags$style(HTML('
        /* logo */
        .skin-blue .main-header .logo {
                                  background-color: #006b6f;
                                  font-family: Courier;
                                  }
        /* navbar (rest of the header) */
        .skin-blue .main-header .navbar {
                                  background-color: #00868B;
                                  }
        /* Wrapping list in sidebar */
        .sidebar-menu > ul {
                                  white-space: normal;
                                  padding-right: 30px;
                                  }'))),
        # First Row
        fluidRow(
            # Box for heatmap plot
            box(
                plotOutput("heatmap")
                ),
            # Box containing data table with missing date recordings
            box(
                dataTableOutput("weekday_table")
                )
            ),
        # Begin new row
        fluidRow(
            # Box for plotly time series plot
            box(
                plotlyOutput("time_series")
                ),
            # Box for plotly weekly time series plot
            box(
                plotlyOutput("time_series_weekly")
                )
            )
        )
    )

# Define server logic required to render plots and table
server <- function(input, output) {
    output$heatmap <- renderPlot({
        my_input = input$category
        selectionOptions[[my_input]] %>%
            create_heatmap(creationDate, value, titleOptions[[my_input]])
    })
    output$weekday_table <- renderDataTable({
        my_input = input$category
        brks = seq(0, 5, 1)
        other_brks = seq(0, 30, 6)
        datatable(selectionOptions[[my_input]] %>%
                      calculate_missing_by_week(),
                  options = list(pageLength = 8)) %>%
            formatStyle(c("Sun", "Mon", "Tue",
                          "Wed", "Thu", "Fri", "Sat"), backgroundColor = styleInterval(brks, clrs)) %>%
            formatStyle(c("Total Missing"), backgroundColor = styleInterval(other_brks, more_clrs),
                        color = "white", fontWeight = "bold")
    })
    output$time_series <- renderPlotly({
        my_input = input$category
        if (my_input == "heart_rate") {
            selectionOptions[[my_input]] %>%
                ggplot(.,
                   aes(creationDate, value)) +
                geom_line(colour = "#39a78e",
                          alpha = 0.80,
                          na.rm = TRUE) +
                theme_minimal() +
                theme(axis.text.x = element_text(angle = 45)) +
                labs(x = "Date of Activity (2017)",
                     y = "Heart Rate",
                     title = "Heart Rate over Time for 2017")
        } else {
            selectionOptions[[my_input]] %>%
                create_time_series(value, unitOptions[[my_input]], titleOptions[[my_input]])
        }

    })
    output$time_series_weekly <- renderPlotly({
        my_input = input$category
        selectionOptions[[my_input]] %>%
            create_time_series_weekly(value, unitOptions[[my_input]], titleOptions[[my_input]])
    })
}

# Run the application
shinyApp(ui = ui, server = server)
