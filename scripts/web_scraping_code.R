# Load necessary libraries
library(httr)        # For making HTTP requests
library(jsonlite)    # For JSON parsing
library(tidyverse)   # For data manipulation and visualization
library(RSQLite)     # For interacting with SQLite databases
library(dplyr)       # For data manipulation functions
library(stringr)     # For string manipulation
library(rvest)       # For web scraping HTML content
library(xml2)        # For handling XML data

# Set the data directory from environment variables, or default to "data"
data_dir <- Sys.getenv("DATA_DIR")
if (data_dir == "") {
  data_dir <- "data" # Default value if environment variable is not set
}

# Define a list of stock symbols for which to fetch news
symbols <- c(
  "BARC", # Barclays PLC
  "HSBA", # HSBC Holdings PLC
  "LSEG", # London Stock Exchange Group
  "MKS",  # Marks and Spencer Group PLC
  "LLOY"  # Lloyds Banking Group PLC
)


# Function to get the latest news for a given stock symbol
get_latest_news <- function(stock) {
  # Construct the Yahoo Finance URL for the stock's news page
  base_url <- paste0('https://uk.finance.yahoo.com/quote/', stock, '.L/news/')
  
  # Fetch the webpage using GET request with a user-agent header to mimic a browser
  yahoo_response <- tryCatch({
    GET(base_url, user_agent("Mozilla/5.0"))
  }, error = function(e) {
    # If an error occurs during the request, print a message and return NULL
    message("Error fetching URL: ", base_url)
    return(NULL)
  })
  
  # Parse the HTML content of the response
  yahoo_webpage <- read_html(content(yahoo_response, as = "text", encoding = "UTF-8"))
  
  # Extract the news article links using the appropriate CSS selector
  links <- yahoo_webpage %>% 
    html_nodes("#nimbus-app > section > section > section > article > section.mainContent.yf-tnbau3 > section > div > div > div > div > ul > li > section > div > a") %>% 
    html_attr("href")
  
  # Extract the news article headlines using the appropriate CSS selector
  titles <- yahoo_webpage %>% 
    html_nodes("#nimbus-app > section > section > section > article > section.mainContent.yf-tnbau3 > section > div > div > div > div > ul > li > section > div > a > h3") %>% 
    html_text()
  
  # Create a data frame with the first two news headlines and their corresponding links
  df <- data.frame(headline = titles[1:2], link = links[1:2])
  
  # Return the data frame
  return(df)
}


# Fetch the latest news for each stock symbol and combine the results into a data frame
news_data <- map_df(symbols, ~ {
  Sys.sleep(1) # Pause for 1 second to respect rate limits
  news_info <- get_latest_news(.x) # Get news for the current stock symbol
  
  return(as_tibble(news_info)) # Convert the result to a tibble (data frame)
})

# Print the combined news data
print(news_data)


# Save the combined news data to a CSV file
file_path <- paste0(data_dir, '/news.csv')
write.csv(news_data, file = file_path, row.names = FALSE) # Write data to CSV without row names
