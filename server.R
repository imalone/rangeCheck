library(shiny)

#library(ggplot2)
#library(rCharts)

require(reshape2)
source('support.R')

refInput <- readInput('data/test1.csv')

shinyServer(
  function(input,output) {
    output$odate <- renderPrint({input$date})
    
    
    
    output$downloadData <- downloadHandler(
      filename = function() { "sample.csv"},
      content = function(file) {
        write.csv(refInput, file)
      }
    )
    
    output$oseed <- reactive({
      checkstring <- paste0(input$which,input$type)
      jointseed(input$date, checkstring)
    })
    
    if(0){
    output$testPlot <- renderChart2({ # vs renderPlot
      # #      ggplot(aes(x=Sepal.Length,y=Sepal.Width, colour=Species),
      # #                                 data=iris) + geom_point()
      irsub <- iris
      names(irsub) <- gsub('\\.', '', names(irsub))
      #      r1<-rPlot(Sepal.Width ~ Sepal.Length, color="Species", type="point", data=iris)
      #r1<-rPlot(SepalWidth ~ SepalLength, color="Species", type="point", data=irsub)
      r1<-nPlot(SepalWidth ~ SepalLength, color="Species", type="scatterChart", data=irsub)
      r1$chart(tooltipContent = "#! function(key,x, y, e) {
          return 'x: ' + x + 's: ' + e.point.Species
                } !#")
      #r1<-rPlot(SepalLength ~ SepalWidth | Species, data = irsub, color = 'Species', type = 'point')
      return(r1)
      #irsub<-iris
      #names(irsub) = gsub("\\.", "", names(irsub))
      #rPlot(SepalLength ~ SepalWidth | Species, data = irsub, color = 'Species', type = 'point')
      
    })
    }
  }
)