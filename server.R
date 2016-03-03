library(shiny)
library(zipcode)
library(leaflet)

# helper functions
'%ni%' <- Negate('%in%')

# load example data
example <- read.csv("example.csv", row.names = NULL)

# load zipcode data which will be used to geocoded data at zipcode level
data(zipcode)

shinyServer(function(input, output) {
  
# read user supplied data into data()
data <- reactive({    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
df <- read.csv(inFile$datapath)

# clean zipcodes 
df$zip <- clean.zipcodes(df$zip)

# join lat/lon data onto user supplied data
df <- merge(df, zipcode, by = 'zip', all.x = TRUE, all.y = FALSE)

return(df)
})
  

# create initial data table using supplied data 
output$contents <- DT::renderDataTable({data()}, rownames = FALSE)

# create leaflet map when users clicks create map button
observeEvent(input$plotMap, {
output$map <- renderLeaflet({
  
# cluster observations
  if(input$cluster==TRUE){
    
    leaflet(height = 3000) %>%
      #addProviderTiles("CartoDB.Positron") %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>%
      setView(-95.396050, 39.532776, zoom = 3) %>%
       addCircleMarkers(data = data(), ~longitude, ~latitude,  
                       group = "group1", clusterOptions = markerClusterOptions()) 
  }else{
    
    leaflet(height = 3000) %>%
      #addProviderTiles("CartoDB.Positron") %>% 
      addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>%
      setView(-95.396050, 39.532776, zoom = 3) %>%
      addCircleMarkers(data = data(), ~jitter(longitude, factor = .01), ~jitter(latitude, factor = .01), radius = 5, stroke = FALSE, fillOpacity = 0.5)  
    
  }
  
})
})


# create df of only obs in bounds of map
alumniInBounds <- reactive({
  
  if (is.null(input$map_bounds))
    return(data()[FALSE,])
  
  bounds <- input$map_bounds
  latRng <- range(bounds$north, bounds$south)
  lngRng <- range(bounds$east, bounds$west)
  
  subset(data(),
         latitude >= latRng[1] & latitude <= latRng[2] &
           longitude >= lngRng[1] & longitude <= lngRng[2]) 
  
})

# sum up in bounds obs for display in text
output$text <- renderUI({
  str1 <- paste(" Visible Observations:", prettyNum(nrow(alumniInBounds()), big.mark=','))
  HTML(paste(str1, sep = '<br/>'))
})


# create data table of visible obs
observeEvent(input$plotMap, {
  output$contents <- DT::renderDataTable({alumniInBounds()}, rownames = FALSE)
  })

# download example data
output$downloadData <- downloadHandler(
  filename = function() {
    paste('data-example', Sys.Date(), '.csv', sep='')
  },
  content = function(con) {
    write.csv(example, con)
  }
)
  

}) # end of server 