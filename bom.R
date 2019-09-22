library(tidyverse)
library(magrittr)
library(rvest) # parsing of html/xml files

# load in the csv
gauge_info <- read.csv("bom_rainfall_gauges.csv") 

unique_region <- levels(gauge_info$Sub_Region)

for(region in 1:length(unique_region)){
  
  # gauge_sub is the full df subsetted by sub_region
  gauge_sub <- subset(gauge_info, Sub_Region == toString(unique_region[region])) 

  # creating directories for each region
  paste("./rainfall/", toString(unique_region[region]), sep = "") %>%
    tolower(.) %>%
    dir.create(.)
  
  # creating list of unique gauges out of the four columns 
  unique_list <- with(gauge_sub, c(Rainfall.Station_PRIMARY, 
                                       Rainfall.Station_EXTRA.NEARBY, 
                                       Rainfall.Station_UPSTREAM.1ST, 
                                       Rainfall.Station_UPSTREAM.2ND)) %>%
                na.omit %>%
                unique
  
  for (station in 1:length(unique_list)){
    
    scrape_url <- paste("http://www.bom.gov.au/jsp/ncc/cdio/weatherData/av?p_nccObsCode=136&p_display_type=dailyDataFile&p_startYear=&p_c=&p_stn_num=", toString(unique_list[station]), sep ="")
    
    # obtaining the html tag(?) containing the download link
    tag_html <- read_html(scrape_url) %>% html_nodes('.downloads') %>% html_children()
    tag_string <- toString(tag_html[2])
    
    # regex to extract link from tag
    extr_link <- gsub("<li><a href=\"", "", tag_string) %>% # start tag
      gsub(" title=\"Data file for daily rainfall data for all years\">All years of data</a></li>\n", "", .) %>% # end tag
      gsub("&amp;", "&", .) %>% # ampisand
      gsub("\"", "", .) # extra quotation at the end
    
    # construct full download url
    download_url <- paste("http://www.bom.gov.au", sep = "", extr_link)
    
    zip_path <- paste("./rainfall/", tolower(toString(unique_region[region])), "/IDCJAC0009_", toString(unique_list[station]), "_1800.zip", sep = "")
    unzip_path <- paste("./rainfall/", tolower(toString(unique_region[region])), "/", toString(unique_list[station]), sep = "")
    
    # download.file()
    download.file(url = download_url, destfile = zip_path, mode = "wb")
    
    # unzip()
    # Warning message: In unzip(zipfile = zip_path, exdir = unzip_path): error 1 in extracting from zip file (unsure where this occurs)
    unzip(zipfile = zip_path, exdir = unzip_path) 
    
    # remove zip
    file.remove(zip_path)
  }
}