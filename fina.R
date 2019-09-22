library(tidyverse)
library(magrittr)
library(rvest)
library(httr)
library(curl)

# defining columns of the output dataframe
output_df <- setNames(data.frame(matrix(ncol = 16, nrow = 0)), 
                      c("Year", "Event", "Country", "Gender", "Sub-Event", "Date", "Sub-Sub-Event", 
                        "Rank", "Heat Rank", "Family name", "First name", "Country", "Time", "Time Behind", 
                        "RT", "Points"))

# insert events as arrays in this list - note: everything must match the website ~~exactly~~
event_list <- list(c(2019, "18th FINA World Championships 2019", "Republic of Korea"),
                   c(2017, "FINA/airweave Swimming World Cup 2017", "Singapore"))

## --- OPTION 1: MANUALLY CONSTRUCT URL --- ##

for (event in 1:length(event_list)){
  year <- event_list[[event]][1]
  event_name <- event_list[[event]][2]
  country_name <- event_list[[event]][3]
  
  reformat_event_name <- gsub(pattern = " ", replacement = "%20", x = event_name)
  reformat_country_name <- gsub(pattern = " ", replacement = "%20", x = country_name)
 
  search_url <- paste("https://www.fina.org/results?f[]=discipline_tid:45&f[]=year:", year, "&f[]=gms_event_name:", 
               reformat_event_name, "&f[]=gms_event_country_name:", reformat_country_name, sep = "")
  
  # (this can probably be condensed with pipes -- revisit later)
  read_search_url <- read_html(search_url) %>% html_nodes(".results-table")
  url_extract <- xml_attrs(xml_child(xml_child(xml_child(read_search_url[[1]], 1), 2), 1))[["data-href"]]
  event_url <- paste("https://www.fina.org", url_extract, sep = "")
  
  read_event_url <- read_html(event_url) %>% html_nodes("td") %>% html_text(., trim = TRUE) %>% toString()
  read_event_url <- gsub("\n", "", read_event_url)
  read_event_url <- gsub("  ", "", read_event_url)
  read_event_url <- gsub("GenderEventDate", "", read_event_url)
  read_event_url <- gsub("WomenWomen", "\nWomen ", read_event_url)
  
  # still drafting ~~~~~~~
  # index <- 1
  # keep_going <- TRUE 
  # while (keep_going == TRUE){
  #   tryCatch(
  #     { individual event extract
  #       
  #       store the event url somewhere
  #       increment index by 1},
  #     { error catch
  #       keep_going = FALSE}
  #   )
  # }
  # 
  # 
  # 
  # # do (this) while it still exists
  # # check for the events that do not contain 'relay' or 'medley'
  # # find the url for the results link
  # # read results link
  # # get results for 1st, 3rd and 8th
  # 
  # places <- c(1,3,8) # we only care about 1st, 3rd, and 8th place
  
  
  
  # 
}

## --- OPTION 2: CREATE SESSION --- ##

write.csv(output_df, file = "fina_data_scrape.csv")
