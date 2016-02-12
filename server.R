library(shiny)

library(ggplot2)
library(rCharts)

require(reshape2)
source('support.R')
options(RCHART_WIDTH=600)

source("debounce.R")

refInput <- readInput('data/test1.csv')

shinyServer(
  function(input,output, clientData, session) {
    indata <- refInput

    # See README.md for this debounce function, from Joe Cheng at RStudio
    dbtime <- 150
    debounceseed <- debounce(input$seed, dbtime)
    debouncepropupper <- debounce(input$propupper, dbtime)
    debounceproplower <- debounce(input$proplower, dbtime)
    debouncepropinlier <- debounce(input$propinlier, dbtime)

    # To hold either dynamic or static plots.
    reactplot <- reactiveValues()

    # Funny stuff about suspend / resume to ensure the first observe (desired
    # default) gets the final say when page first loads. Similarly reactseed
    # insulates the seed value in use from the debounced seed input and the
    # automatic seed input (as calendar choice doesn't get past debounce).
    reactseed <- reactiveValues()
    seedup <- observe ({
      c_which <- input$which
      c_type <- input$type
      c_date <- input$date
      checkstring <- paste0(c_which,c_type)
      newseed <- jointseed(c_date, checkstring)
      updateNumericInput(session, "seed", value= newseed)
      reactseed$seed <- newseed
    }, suspended = TRUE)

    observe ({
      seedup$resume()
        newseed <- as.integer(debounceseed())
        reactseed$seed <- newseed
    })

    output$odate <- renderText({paste(as.character(input$date), reactseed$seed)})

    datatocheck <- reactive({
      buildInput(indata,input$which)
    })

    checklist <- reactive({
      set.seed(reactseed$seed)
      outliers(datatocheck(), input$type,
               upper.tail=debouncepropupper(),
               lower.tail=debounceproplower(),
               inliers=debouncepropinlier())
    })
    output$checktable <- DT::renderDataTable(
      DT::datatable(checklist(), options=list(pageLength=10)))
    
    # Update plots. An observer is used because we either want
    # to update the rChart or the ggplot, but no point doing both.
    observe ({
      plotdata <- datatocheck()
      checkdata <- checklist()
      plotdata$check <- ifelse (plotdata$label %in% checkdata$label,
                                "check", "no check")
      # This seems crazy, but d3 is sensitive to row order for how it
      # assigns the group colours
      plotdata <- plotdata[order(plotdata$check),]
      if (input$type == "vol") {
        eq <- as.formula("volB ~ volA")
        xlabel = paste(input$which, "volA/ml")
        ylabel = paste(input$which, "volB/ml")
        eqa=aes(volA,volB, colour=check)
      } else {
        eq <- as.formula("change ~ volDelta")
        xlabel = paste(input$which, "delta vol/ml")
        ylabel = paste(input$which, "change/ml")
        eqa=aes(volDelta,change, colour=check)
      }
      n1 <- nPlot(eq, group="check", type="scatterChart", data=plotdata)
      n1$chart(color=c("orangered","blue"))
      n1$chart(tooltipContent = "#! function(key,x, y, e) {
          return e.point.label
                } !#")
      n1$xAxis(axisLabel=xlabel) ; n1$yAxis(axisLabel=ylabel)
      if (input$plottype == "Dynamic") {
        reactplot$n1 <- n1
      } else {
        g1 <- ggplot(plotdata,mapping=eqa,data=plotdata)+geom_point()
        reactplot$g1 <- g1
      }
    })

    output$outplotDy <- renderChart2(reactplot$n1)
    output$outplotSt <- renderPlot(reactplot$g1)

    output$downloadData <- downloadHandler(
      filename = function() {
        descrip <- paste("rangecheck",input$date,input$which,input$type,
                         reactseed$seed, sep="_")
        paste0(descrip,".csv")
      },
      content = function(file) {
        write.csv(checklist(), file)
      }
    )
    
  }
)