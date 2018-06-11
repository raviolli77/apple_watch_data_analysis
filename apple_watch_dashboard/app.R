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

if (!file.exists(here::here("data/processed/rds_files", "ActiveEnergyBurned.rds"))) {
    ActiveEnergyBurned <- readRDS(here::here("rds_files", "ActiveEnergyBurned.rds"))
    print("using alternate")
} else {
    ActiveEnergyBurned <- readRDS(here::here("data/processed/rds_files", "ActiveEnergyBurned.rds"))
}

if (!file.exists(here::here("data/processed/rds_files", "BasalEnergyBurned.rds"))) {
    BasalEnergyBurned <- readRDS(here::here("rds_files", "BasalEnergyBurned.rds"))
    print("using alternate")
} else {
    BasalEnergyBurned <- readRDS(here::here("data/processed/rds_files", "BasalEnergyBurned.rds"))
}

if (!file.exists(here::here("data/processed/rds_files", "StepCount.rds"))) {
    StepCount <- readRDS(here::here("rds_files", "StepCount.rds"))
    print("using alternate")
} else {
    StepCount <- readRDS(here::here("data/processed/rds_files", "StepCount.rds"))
}

if (!file.exists(here::here("data/processed/rds_files", "DistanceWalkingRunning.rds"))) {
    DistanceWalkingRunning <- readRDS(here::here("rds_files", "DistanceWalkingRunning.rds"))
    print("using alternate")
} else {
    DistanceWalkingRunning <- readRDS(here::here("data/processed/rds_files", "DistanceWalkingRunning.rds"))
}

if (!file.exists(here::here("data/processed/rds_files", "FlightsClimbed.rds"))) {
    FlightsClimbed <- readRDS(here::here("rds_files", "FlightsClimbed.rds"))
    print("using alternate")
} else {
    FlightsClimbed <- readRDS(here::here("data/processed/rds_files", "FlightsClimbed.rds"))
}

if (!file.exists(here::here("data/processed/rds_files", "HeartRate.rds"))) {
    HeartRate <- readRDS(here::here("rds_files", "HeartRate.rds"))
    print("using alternate")
} else {
    HeartRate <- readRDS(here::here("data/processed/rds_files", "HeartRate.rds"))
}

clrs <- c("#ffffff", "#9cd3c6", "#74c1af",
          "#39a78e", "#277463", "#164238", 
          "#0b211c")

selectionOptions <- list("active_energy" = ActiveEnergyBurned,
                         "basal_energy" = BasalEnergyBurned, 
                         "step_count" = StepCount, 
                         "dist_walk_run" = DistanceWalkingRunning,
                         "flights_climbed" = FlightsClimbed, 
                         "heart_rate" = HeartRate)

titleOptions <- list("active_energy" = "Active Energy \nBurned",
                     "basal_energy" = "Basal Energy \nBurned", 
                     "step_count" = "Step Count", 
                     "dist_walk_run" = "Distance Walking \nand Running",
                     "flights_climbed" = "Flights Climbed", 
                     "heart_rate" = "Heart Rate")

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
            tabBox(
                id = "tabset1", 
                tabPanel(
                    "Missing Days by Month", 
                    dataTableOutput("metrics_table") 
                    ),
                tabPanel(
                    "Missing Days by Weekday", 
                         dataTableOutput("weekday_table"))
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
    output$metrics_table <- renderDataTable({
        my_input = input$category
        brks = seq(0, 30, 6)
        datatable(selectionOptions[[my_input]] %>%
                      create_data_frame_metrics(), 
                  options = list(pageLength = 8)) %>%
            formatStyle(c("Missing Days"), backgroundColor = styleInterval(brks, clrs))
    }) 
    output$weekday_table <- renderDataTable({
        my_input = input$category
        brks = seq(0, 10, 2)
        datatable(selectionOptions[[my_input]] %>%
                      calculate_missing_by_week(), 
                  options = list(pageLength = 8)) %>%
            formatStyle(c("Sun", "Mon", "Tue", 
                          "Wed", "Thu", "Fri", "Sat"), backgroundColor = styleInterval(brks, clrs))
    })
    output$time_series <- renderPlotly({
        my_input = input$category
        selectionOptions[[my_input]] %>% 
            create_time_series(value, unitOptions[[my_input]], titleOptions[[my_input]])
    })
    output$time_series_weekly <- renderPlotly({
        my_input = input$category
        selectionOptions[[my_input]] %>%
            create_time_series_weekly(value, unitOptions[[my_input]], titleOptions[[my_input]])
    })
}

# Run the application 
shinyApp(ui = ui, server = server)