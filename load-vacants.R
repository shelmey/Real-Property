# Created 2020-06-05 - Sam Helmey

### Load required packages ###
library(sf)
library(dplyr)
library(geojsonsf)

### parameters ###

vacants.url <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/Realproperty/MapServer/0/query?where=VACIND='Y'&resultoffset=<<offset>>&outFields=*&outSR=4269&f=geojson"

### end parameters ###

# There's a limit of 1000 to query results, so here's a function to page through results and get them all.

paginate <- function(in.url){
  # Offset is which how many results to skip
  offset = 0
  # replace the offset token in the url string 
  url <- sub("<<offset>>",offset, in.url)
  # Read the raw json
  raw <- readLines(url)
  # convert to polygons simple feature
  SF <- geojson_sf(raw)
  bound <- SF 
  # Are there more than 1000 results?
  more <- nrow(SF)==1000
# change offset if there are more than 1000 results. Read the next ones and repeat until we've read all ofthem
    while (more) {
    offset <- offset + 1000
    url <- sub("<<offset>>",offset, in.url)
    raw <- readLines(url)
    SF <- geojson_sf(raw)
    # Append
    bound <- rbind(bound, SF)
    # Still more?
    more <- nrow(SF)==1000
  } 
  return(bound)
}

# Read all the vacants as a shapefile
vacants <- paginate(vacants.url)

# formatting
vacants <- vacants %>%
  mutate(STRUCTAREA = as.numeric(STRUCTAREA))

### Summarize ###

# Counts by owner name and address
owner.summary <- 
  vacants %>% 
  st_set_geometry(NULL) %>% 
  group_by(OWNER_1, MAILTOADD) %>% 
  summarize(Count = n())%>%
  arrange(desc(Count))
  
# Counts by owner name
owners <- table(vacants$OWNER_1) %>%
  as.data.frame() %>%
  arrange(desc(Freq)) %>%
  transmute(OWNER_1 = as.character(Var1), 
            Count = Freq)

# Counts by owner address
addresses <- table(vacants$MAILTOADD) %>%
  as.data.frame() %>%
  arrange(desc(Freq))%>% 
  transmute(MAILTOADD = as.character(Var1), 
            Count = Freq)

# Vacants whose owner name contains "CITY"
# - some of these are probably annoyingly named LLCs
city.owned <- vacants %>%
  filter(grepl("CITY",OWNER_1)) %>% arrange(desc(STRUCTAREA))

### Outputs ###

# owner.summary %>% write.csv(paste0("Owner Summary ", lubridate::today(), ".csv"), row.names = F)
# owners %>% write.csv(paste0("Owner Counts ", lubridate::today(), ".csv"), row.names = F)
# addresses %>% write.csv(paste0("Address Counts ", lubridate::today(), ".csv"), row.names = F)
