library(dplyr)
library(tidyr)
library(shiny)
library(DT)
library(plotly)
library(ggplot2)
library(ggExtra)

source("global.R")

server <- function(input, output) {

## get data based on user input for Dashboard tab
theData <-  eventReactive(input$datasetSelector,{
    if(input$datasetSelector == 'Chronos Data'){
      return(choronsData)
    }else if(input$datasetSelector == 'Experssion Data'){
      return(expressionData)
    }else if(input$datasetSelector == 'Copy Number Data'){
      return(cnData)
    }
  })

## Render the data for dashboard table
output$queryresult <- DT::renderDataTable(theData(),server = TRUE, filter = 'top', escape=FALSE,
                                          extension='Buttons',options=list(dom='Bfrtip', buttons=list('copy','pdf','csv'),scrollX = TRUE))

## Render basic data summary for selected database
output$basicTableSummary <- renderText({paste(sprintf("Number or rows: %s",nrow(theData())),
                                              sprintf("Number of columns: %s",ncol(theData())), sep="\n")})

## Render advance summary for selected database
output$advanceTableSummary <-  renderPrint(summary(theData()))

## *******  Scatter Plot tab  ******* ## 

## Based on user input of Database + Gene it will return the data
## Data rendering is even reactive based on clicking of searchbutton
vtable <- eventReactive(input$searchbutton,{
  if(input$firstDataset == 'Chornos'){
    return(data.frame(choronsData[['Sample_ID']],choronsData[[input$vgene]]))
  }else if(input$vdataSet == 'CV'){
    return(data.frame(cnData[['Sample_ID']],cnData[[input$vgene]]))
  }else if(input$vdataSet == 'Expression'){
    return(data.frame(expressionData[['Sample_ID']],expressionData[[input$vgene]]))
  }
})

## Get first data-frame for scatter plot (Select database 1 )
firsTable <- reactive({
  if(input$firstDataset == 'Chornos'){
    return(choronsData)
  }else if(input$firstDataset == 'CV'){
    return(cnData)
  }else if(input$firstDataset == 'Expression'){
    return(expressionData)
  }
})
## Get first data-frame for scatter plot (Select database 2 )
secondTable <- reactive({
  if(input$secondDataset == 'Chornos'){
    return(choronsData)
  }else if(input$secondDataset == 'CV'){
    return(cnData)
  }else if(input$secondDataset == 'Expression'){
    return(expressionData)
  }
})

## Return data-frame based on Database provided + column to be extracted
extractData <- function(data, columnNew){
  return(cbind(data['Sample_ID'], data[columnNew]))
}

## Based on user input of database 1, database2, gene 1, gene 2 it will render the data
filteredTable <- eventReactive(input$searchbutton,{
  df1 <- data.frame(extractData(firsTable(), input$firstGene), extractData(secondTable(), input$firstGene), input$firstGene)
  df2 <- data.frame(extractData(firsTable(), input$secondGene),  extractData(secondTable(), input$secondGene), input$secondGene)
  colnames(df1) <- c('Sample_ID','fvalues', 'Sample', 'svalue', 'gene')
  colnames(df2) <- c('Sample_ID','fvalues', 'Sample', 'svalue', 'gene')
  df1 <- df1[,-c(3)]
  df2 <- df2[,-c(3)]
  bindedData <- unique(rbind(df1, df2))
  bindedData <- inner_join(bindedData, metaData, by='Sample_ID')
})

## Based on above returned data Datatable will be rendered 
 output$plotOneTable <- DT::renderDataTable(filteredTable(),server = TRUE, filter = 'top', escape=FALSE,options=list(scrollX = TRUE))
    
 ## Print table name for dashboard tab based on user input selected database
 output$datasetName <- eventReactive(input$datasetSelector,{
   sprintf("Displaying %s",input$datasetSelector)
 })
 
 ## Plotting of rendered data using renderPlotly function                                      
  output$plotOne <- renderPlotly({
    b <- ggplot(filteredTable(), aes_string(x = "fvalues", y = "svalue", colour= input$colorInput)) +
      geom_vline(xintercept = 0) + geom_vline(xintercept = 0) + geom_point() + theme_minimal()
    ggplotly(b)
  })
  
  
  ## *******  Violin Plot tab  ******* ## 
  vtable <- eventReactive(input$vsearchbutton,{
    if(input$vdataSet == 'Chornos'){
      return(data.frame(choronsData[['Sample_ID']],choronsData[[input$vgene]]))
    }else if(input$vdataSet == 'CV'){
      return(data.frame(cnData[['Sample_ID']],cnData[[input$vgene]]))
    }else if(input$vdataSet == 'Expression'){
      return(data.frame(expressionData[['Sample_ID']],expressionData[[input$vgene]]))
    }
  })
  
  reactiveTable <- eventReactive(input$vsearchbutton,{
    reactiveData <- vtable()
    colnames(reactiveData) <- c('Sample_ID','cvalues')
    reactiveData <- inner_join(reactiveData, data.frame(metaData[c(input$vgroup, "Sample_ID")]), by='Sample_ID')
    reactiveData <- data.frame(reactiveData %>% group_by(input$vgroup))
    return(reactiveData)
  })
  
  output$vplotOneTable <-  DT::renderDataTable(reactiveTable(),server = TRUE, filter = 'top', escape=FALSE)
  
  output$vplotOne <- renderPlot({
    if (is.null(reactiveTable()))
      return(NULL) 
    d <- reactiveTable() %>% group_by(input$vgroup) %>%
      ggplot(aes_string(x =input$vgroup , y = "cvalues", fill=input$vgroup)) + coord_flip() + 
      geom_violin(alpha = 0.8) +
      geom_jitter(position = position_jitter(seed = 0.05, width = 0.1), alpha=0.2) +
      theme(legend.position = "none")
      plot(d,  height = 400, width = 600 )
   })
  

## *******  Extra Plot tab -> Distribution Plot ******* ##
  
  distrubtionData <- eventReactive(input$dsearchbutton,{
    if(input$distributeData == 'Chronos Data'){
      return(choronsData)
    }else if(input$distributeData == 'Experssion Data'){
      return(expressionData)
    }else if(input$distributeData == 'Copy Number Data'){
      return(cnData)
    }
  })
  
  output$distributionTable <-  DT::renderDataTable(distrubtionData(),server = TRUE, filter = 'top', escape=FALSE,options=list(scrollX = TRUE))
  
  output$distributionPlot <- renderPlot({
    ggplot(distrubtionData(), aes_string(input$dgene)) +
      geom_histogram(binwidth=0.01) + xlab(input$dgene) + ylab(sprintf("%s values",input$distributeData)) +
      ggtitle('Distribution values for selected gene')
  })
  
  ## *******  Extra Plot tab -> Marginal Plot ******* ##
  
  marginalData <- eventReactive(input$dsearchbutton,{
    return(data.frame(cbind(distrubtionData()[input$dgene]), metaData[input$marginalColumn]))
  })
  

  output$marginalPlot <- renderPlot({
  p2 <- ggplot(data = marginalData(),
               mapping = aes_string(x = input$dgene, y = input$marginalColumn,
                             colour = input$marginalColumn)) +
    geom_point() +
    geom_smooth(method = "loess") +
    labs(x = "Weekly Learning Time", y = "Science Scores") +
    theme_bw() + coord_flip()+
    theme(legend.position = "bottom",
          legend.title = element_blank())
  
  p2 <- ggMarginal(p2, type = "density", groupColour = TRUE, groupFill = TRUE)
  p2
  })
  
  ### addtional filter
  filtered_table <- reactive({
    req(input$plotOneTable_rows_all)
    filteredTable()[input$plotOneTable_rows_all, ]  
  })
  
  output$filterdDataPlot <-  renderPlotly({
    b <- ggplot(filtered_table(), aes_string(x = "fvalues", y = "svalue", colour= input$colorInput)) +
      geom_vline(xintercept = 0) + geom_vline(xintercept = 0) + geom_point() + theme_minimal()
    ggplotly(b)
  })
  
  

}
