### Map Vacants ###

# Run load-vacants to getthe data for this into your R environment 

library(leaflet)

pal <- colorNumeric(
  palette = "Blues",
  domain = city.owned$STRUCTAREA)

map <- leaflet() %>%
  addTiles(group = "Google Satellite Imagery", urlTemplate = "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G", attribution = 'Google') %>%
  addTiles(group = "Google Street Map", urlTemplate = "https://mt0.google.com/vt/lyrs=m&hl=en&src=app&x={x}&y={y}&z={z}&s=G", attribution = 'Google') %>%
  addPolygons(group = "Vacants",
              data = vacants,
              fill = ~pal(STRUCTAREA),
              popup = ~paste(FULLADDR, "<br>",
                             format(STRUCTAREA, big.mark = ","), "<br>",
                             OWNER_1,"<br>",
                             MAILTOADD)) %>%
  addLayersControl(baseGroups = c("Google Satellite Imagery","Google Street Map"), overlayGroups = c("Vacants") )

# map  

