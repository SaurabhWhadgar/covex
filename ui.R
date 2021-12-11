library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(ggplot2)
library(ggExtra)
library(dplyr)
library(tidyr)

ui <- dashboardPage(
  dashboardHeader(title = "Elucidata-CoVEx",
    dropdownMenu(
      type = "notifications",             
      icon = icon("question-circle"),
      badgeStatus = NULL,
      headerText = "Help Guide",
      ## Notification tab to put information about the database or notifications
      notificationItem("How to Use", icon = icon("file"),
                       href = "https://docs.google.com/presentation/d/1Bysdji-_bBaLtmxPrcJfWaufW6Uuzfbyyq1u0O3d3nI/edit?usp=sharing"),
      notificationItem("Author: Saurabh Whadgar", icon = icon("file"),
                       href = "https://github.com/saurabhwhadgar")
    ),
     dropdownMenu(
        type = "messages", 
        badgeStatus = NULL,
        headerText = "See also:",
        messageItem(
          from = "Admin",
          message = "CoVEx protoype is ready")
      )
  ),
  dashboardSidebar(
    ## Selector to choose the database for display
    selectInput("datasetSelector", label = "Choose Dataset",
                               choices = c("Chronos Data", "Copy Number Data","Experssion Data"),
                               selected = "Chronos Data"),
     sidebarMenu(
       menuItem("Home", tabName = "dashboard",selected = TRUE),
       menuItem("Scatter Plot", tabName = "splotting",selected = FALSE),
       menuItem("Violin Plot", tabName = "vplotting",selected = FALSE),
       menuItem("Extra Plot", tabName = "extraPlotting",selected = FALSE))),
  dashboardBody( 
    tabItems(
      tabItem(tabName = "dashboard",
        fluidPage(
          fluidRow(
            box(title = textOutput("datasetName"), status = "warning", solidHeader = TRUE,width=12,
                collapsible = TRUE, DT::dataTableOutput("queryresult"))
          ),
          fluidRow(
            box(title ="Basic Table Summary", status = "warning", solidHeader = TRUE,width=12,
                collapsible = TRUE, verbatimTextOutput("basicTableSummary"))
          ),
          fluidRow(
            box(title ="Adavance Table Sumamry", status = "warning", solidHeader = TRUE,width=12,
                collapsible = TRUE,collapsed = FALSE, verbatimTextOutput("advanceTableSummary"))
          )
        )
      ),
      tabItem(
        tabName = "splotting",
        h2("Scatter Plot"),
        fluidRow(
          box(width = 4,solidHeader = TRUE,
              selectInput(inputId = 'firstDataset',
                          label = 'Select First Dataset',
                          choices = c("Chornos","CV", "Expression")),
              selectInput(inputId = 'firstGene',
                          label = 'Select First Gene To Plot',
                          choices = unique(colnames(choronsData[,-1])))
          ),
          box(width = 4,solidHeader = TRUE,
              selectInput(inputId = 'secondDataset',
                          label = 'Select Second Dataset',
                          choices = c("Chornos","CV", "Expression")),
              selectInput(inputId = 'secondGene',
                          label = 'Select Second Gene to Plot',
                          choices = unique(colnames(choronsData[,-1])))
          ),
          box(width = 4,height=180, title = "Search Database",solidHeader = TRUE, status = "info",
              selectInput(inputId = 'colorInput',
                          label = 'Select Color By',
                          choices = unique(c('name',colnames(metaData[,-1])))),
              actionButton("searchbutton","SUBMIT"))
          ),
      fluidRow(
        box(plotlyOutput("plotOne"),width = 12),
        box(DT::dataTableOutput("plotOneTable"), width = 12)
      )
    ),
      tabItem(
        tabName = "vplotting",
        h2("Violin Plot"),
        fluidRow(
          box(width = 6,
              selectInput(inputId = 'vdataSet',
                          label = 'Select Dataset',
                          choices = c("Chornos","CV", "Expression")),
              selectInput(inputId = 'vgene',
                          label = 'Select Gene To Plot',
                          choices = unique(colnames(choronsData[,-1])))
          ),
          box(width = ,height=180, title = "Plot Data",
              selectInput(inputId = 'vgroup',
                          label = 'Select value to group the data',
                          choices = unique(colnames(metaData[,-1]))),
              actionButton("vsearchbutton","SUBMIT"))
        ),
        fluidRow(
          box(title = "Violin Plot", status = "success", solidHeader = FALSE,
              collapsible = TRUE,plotOutput("vplotOne",   width = "100%", height = "600px"), width=12),
          box(title = 'Filterd Data', width = 12, DT::dataTableOutput("vplotOneTable"))
          )
      ),
    tabItem(
      tabName = "extraPlotting",
      h2("Extra Plot"),
      fluidRow(
        box(width = 6,
            selectInput(inputId = 'distributeData',
                        label = 'Select Dataset',
                        choices = c("Chronos Data", "Copy Number Data","Experssion Data")),
            selectInput(inputId = 'dgene',
                        label = 'Select Gene To Plot',
                        choices = unique(colnames(choronsData[,-1])))
        ),
        box(width = 6 ,height=180, title = "Distribution Data",
            selectInput(inputId = 'marginalColumn',
                        label = 'Select Column to Group By',
                        choices = unique(colnames(metaData[,-1]))),
            actionButton("dsearchbutton","SUBMIT"))
      ),
      fluidRow(
        ## Marginal plot for to showcase distribution of values for selected gene by group
        box(title = "Marginal Plot Across the Group", status = "success", solidHeader = FALSE,
            collapsible = TRUE,plotOutput("marginalPlot",   width = "100%"), width=12)),
      ## Distribution plot for to showcase distribution of values for selected gene across the samples
      fluidRow(
        box(title = "Distribution Plot of Values for Selected Gene", status = "info", solidHeader = FALSE,
            collapsible = TRUE,plotOutput("distributionPlot",  width = "100%"), width=12)
      )

    )
  )
  )
)
