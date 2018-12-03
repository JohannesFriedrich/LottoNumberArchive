library(tidyverse)
library(rvest)
library(jsonlite)

write_json <- function(df, path, df_type = "rows", raw_type = "mongo"){
  
  df %>% 
    toJSON(dataframe = df_type, raw = raw_type) %>%
    write_lines(path)
}

##### SCRAP DATA #####

## Get data

year <- seq(1955, 2018)
url <- paste0("https://www.lottozahlenonline.de/statistik/beide-spieltage/lottozahlen-auflistung.php?j=",
              year)

#Reading the HTML code from the website

data <- lapply(1:length(url), function(x) {
  
  data <- read_html(url[x])
  
  print(year[x])
  
  date <- data %>% 
    html_nodes('.lz_datum') %>% 
    html_text() %>% 
    paste0(".",year[x])
  
  numbers <- data %>% 
    html_nodes(".quadrat2") %>% 
    html_text() %>% 
    tail(-1) %>% ## remove first element
    as.integer()
  
  #####
  
  index_start <- seq(1, length(numbers), 6) 
  index_end <-   seq(6, length(numbers), 6) 
  
  numbers_date <- lapply(1:length(index_start), function(x){
    
    return(numbers[index_start[x]:index_end[x]])
    
  })
  
  superzahl <- data %>% 
    html_nodes(".quadrat_zz") %>% 
    html_text() %>% 
    as.integer()
  
  if(year[x] == 1991) superzahl <- c(rep(NA,48), superzahl)
  
  df_numbers <- tibble(
    Datum = date)
  
  df_numbers$Lottozahlen <- numbers_date
  
  if(is_empty(superzahl)) superzahl <- NA
  
  df_numbers$Superzahl <- superzahl
  
  return(df_numbers)
  
})

df_data <- map_df(data, ~.x)


## Add id coloumn

df_data <- df_data  %>%
  mutate(id = row_number()) %>% 
  select(id, Datum, Lottozahlen, Superzahl)



## Write data as json

json <- toJSON(df_data, pretty = T, auto_unbox = T)
write_json(df_data, "Lottonumbers_complete.json")