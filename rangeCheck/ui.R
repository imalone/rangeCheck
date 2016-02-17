library(shiny)
library(shinyBS)
require(rCharts)

bsModalHelp <-  bsModal(
  "helpmodal", "Help", "helptoggle", size = "large",
  h3("Range Checker Help"),
  p(paste("This app selects data points for manual checking from a set of brain",
          "and ventricle volume results.")),
  p(paste("Use the 'Results to check' and 'Measure Type' to select the set of",
          "results to pick points for checking from. Either brain or lateral ventricles",
          "(vent) results sets, and either the individual volume measures (vol) or",
          "direct change measures. Points for checking are shown in the right hand",
          "panel as plots or tables, or can be downloaded as a list (see below).")),
  h4("Data point selection"),
  p(paste("The default is to choose the lowest 0.02 (2%) and highest 0.02 (2%) of",
          "the results, as well as 0.01 (1%) randomly selected from the other",
          "points. These can be adjusted by the Lower Tail Proportion,",
          "Upper Tail Proportion and Inlier Proportion controls.")),
  h4("Random inlier selection"),
  p(paste("So inliers can be selected reproducibly, a seed for random selection",
          "of inliers is automatically generated based on the date and result",
          "type and measure selections. If necessary the preparation date can",
          "be set to check what points would be selected by default on a",
          "different date. Or a particular seed can be specified directly.")),
  h4("Uploading and downloading data"),
  p(span(paste("The selected points for checking can be downloaded as a csv file",
               "with the download button. A new dataset for point selection can",
               "be provided with the upload button. It must be in csv format with",
               "a header row containing the fields: "),
               pre("label, brainA, brainB, brainchange, ventA, ventB, ventchange"),
         paste("Labels can be text, but must be unique, all other field must be",
               "numeric. Sample data can be downloaded from ")),
    a(href="https://github.com/imalone/rangeCheck/tree/master/rangeCheck/data",
      "the github repo"),".")
)

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
    fluidRow(column(width=4, 'Check date and seed',
                    textOutput('odate'), textOutput('ofile'), bsAlert('filereport')),
             column(width=8,
                    fluidRow(
             column(width=7, downloadButton('downloadData','Download'),
                    fileInput('uploadData','Upload',
                              accept="text/csv")),
             column(width=2, align="right",
                    bsButton('helptoggle','Help',icon=icon('question'),
                             style='info',type='toggle')),
             column(width=2,a(icon('github'),"GitHub",class="btn btn-default",
                              href="https://github.com/imalone/rangeCheck",
                              target="_blank"))
                    ))
    ),

    tabsetPanel(id='plottype',
                tabPanel("Static plot",value='Static',
                         plotOutput('outplotSt')),
                tabPanel("Dynamic plot",value='Dynamic',
                         p("Click on the dynamic plot to show data point labels"),
                         showOutput('outplotDy','nvd3')),
                tabPanel('Table', DT::dataTableOutput('checktable'))
    ),
    
    bsModalHelp
  )
))
