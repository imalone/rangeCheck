library(shiny)

#library(ggplot2)
library(rCharts)

require(reshape2)
source('support.R')
options(RCHART_WIDTH=600)

refInput <- readInput('data/test1.csv')

shinyServer(
  function(input,output, clientData, session) {
    indata <- refInput
    # Update seed automatically based on selections.
    # Putting the update to as.integer first makes sure it can only
    # be changed to an integer.
    observe ({
      updateNumericInput(session, "seed", value=as.integer(input$seed))
    })
    observe ({
      c_which <- input$which
      c_type <- input$type
      c_date <- input$date
      updateNumericInput(session, "seed", value= {
        checkstring <- paste0(c_which,c_type)
        jointseed(input$date, checkstring)
      })
    })

    output$odate <- renderText({as.character(input$date)})
    
    datatocheck <- reactive({
      buildInput(indata,input$which)
    })
    checklist <- reactive({
      set.seed(input$seed)
      outliers(datatocheck(), input$type,
               upper.tail=input$propupper,
               lower.tail=input$proplower,
               inliers=input$propinlier)
    })
    output$checktable <- DT::renderDataTable(
      DT::datatable(checklist(), options=list(pageLength=10)))
    
    plotChecks <- reactive({
      plotdata <- datatocheck()
      checkdata <- checklist()
      plotdata$check <- ifelse (plotdata$label %in% checkdata$label,
                                "check", "no check")
      if (input$type == "vol") {
        eq <- as.formula("volB ~ volA")
        xlabel = paste(input$which, "volA/ml")
        ylabel = paste(input$which, "volB/ml")
      } else {
        eq <- as.formula("change ~ volDelta")
        xlabel = paste(input$which, "delta vol/ml")
        ylabel = paste(input$which, "change/ml")
      }
      n1 <- nPlot(eq, group="check", type="scatterChart", data=plotdata)
      n1$chart(color=c("blue","orangered"))
      n1$chart(tooltipContent = "#! function(key,x, y, e) {
          return e.point.label
                } !#")
      n1$xAxis(axisLabel=xlabel) ; n1$yAxis(axisLabel=ylabel)
      irsub <- iris
      names(irsub) <- gsub('\\.', '', names(irsub))
      #nPlot(SepalWidth ~ SepalLength, color="Species", type="scatterChart", data=irsub)
      n1
    })
    output$outplot <- renderChart2({plotChecks()})
    
    output$downloadData <- downloadHandler(
      filename = function() {
        descrip <- paste("rangecheck",input$date,input$which,input$type,
                         input$seed, sep="_")
        paste0(descrip,".csv")
      },
      content = function(file) {
        write.csv(checklist(), file)
      }
    )
    
  }
)