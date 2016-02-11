library(shiny)
require(rCharts)

shinyUI(pageWithSidebar(
  headerPanel("Range checker demo"),
  sidebarPanel(
    h3('Settings'),
    dateInput('date','Preparation date'),
    selectInput("which", label="Results to check",
                choices = list("brain", "vent"), selected="brain"),
    selectInput("type", label="Measure type",
                choices = list("change", "vol"), selected="change"),
    numericInput("proplower", label="Lower tail proportion",
                 value=0.02, step=0.005, min=0, max=0.5),
    numericInput("propupper", label="Upper tail proportion",
                 value=0.02, step=0.005, min=0, max=0.5),
    numericInput("propinlier", label="Inlier proportion",
                 value=0.01, step=0.005, min=0, max=0.5),
    numericInput("seed", label="Seed for checks", value=0,
                 step=1, min = - .Machine$integer.max, max= .Machine$integer.max)
  ),
  mainPanel(
    h3('Check data', textOutput('odate')),
    downloadButton('downloadData','Download'),

    showOutput('outplot','nvd3'),
    #plotOutput('outplot'),
    
    DT::dataTableOutput('checktable')
  )
))
