library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("So very shiny"),
  sidebarPanel(
    h3('Sidebar text'),
    dateInput('date','Preparation date'),
    selectInput("which", label="Results to check",
                choices = list("brain", "vent"), selected="brain"),
    selectInput("type", label="Measure type",
                choices = list("change", "vol"), selected="change"),
    p('Seed'), textOutput('oseed'),
    downloadButton('downloadData','Download')
  ),
  mainPanel(
    h3('Main Panel text'),
    p('Date'), verbatimTextOutput('odate')
    #plotOutput('testPlot')
    #showOutput('testPlot','nvd3') # vs plotOutput
  )
))
