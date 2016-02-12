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
                 step=1, min = - .Machine$integer.max, max= .Machine$integer.max),
    radioButtons('plottype',"Plot type", inline=TRUE,
                 c("Dynamic","Static"), selected="Dynamic")
  ),
  mainPanel(
    h3('Check data', textOutput('odate')),

    downloadButton('downloadData','Download'),

    conditionalPanel(condition="input.plottype == 'Dynamic'",
                     showOutput('outplotDy','nvd3')),
    conditionalPanel(condition="input.plottype == 'Static'",
                     plotOutput('outplotSt')),
    
    DT::dataTableOutput('checktable')
  )
))
