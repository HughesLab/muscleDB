output$plot1 <- renderPlot({
  filteredData = collect(filterData())
  
  ggplot(filteredData, aes(x= tissue, y=expr)) + 
    geom_bar(stat = "identity") +
    facet_wrap(~transcript)
})