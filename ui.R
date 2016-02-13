library(shiny)
library(shinyBS)
require(rCharts)

shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "rotate45.css")
  ),
  
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
    fluidRow(column(width=4, 'Check data', textOutput('odate')),
              column(width=3, downloadButton('downloadData','Download')),
             column(width=3,actionButton('helptoggle','Help',icon=icon('question')))
    ),

    bsModal("helpmodal", "Help", "helptoggle", size = "large",
            "Some help here please!"),

    tabsetPanel(id='plottype',
                tabPanel('Dynamic', showOutput('outplotDy','nvd3')),
                tabPanel('Static', plotOutput('outplotSt'))
    ),
    

    DT::dataTableOutput('checktable')
  )
))
