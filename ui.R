library(shiny)
library(leaflet)

shinyUI(fluidPage(
  titlePanel("Map It"),
  
  sidebarLayout(
    sidebarPanel(width = 4,
      
      "This app allows for quick mapping of your United States data at the zipcode level.  Upload any file with a column called 'zip' and press the Create Map button to map your data.  As you zoom in the data table will adjust to display information on the visible observations.",
      
      br(),
      br(),      
      
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      
      checkboxInput("cluster", 
                    label = "Cluster Observations", 
                    value = TRUE),
      
      actionButton("plotMap", "Create Map"), 
      
      br(),
      br(),
      
      downloadLink('downloadData', 'Download Example Data'),
      
      br(),
      br(),
      
      htmlOutput("text")  
      
    ),
    
    mainPanel(
      leafletOutput("map"), 
      br(),
      DT::dataTableOutput('contents')
    )
  )
))