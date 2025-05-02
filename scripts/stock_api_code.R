# Load necessary libraries
library(httr)        # For making HTTP requests
library(jsonlite)    # For JSON parsing
library(tidyverse)   # For data manipulation and visualization
library(dplyr)       # For data manipulation functions
library(stringr)     # For string manipulation
library(rvest)       # For web scraping
library(xml2)        # For working with XML data


# Set the data directory, using an environment variable if available
data_dir <- Sys.getenv("DATA_DIR")
if (data_dir == "") {
  data_dir <- "data" # Default to "data" if the environment variable is not set
}
dir.create(data_dir, showWarnings = FALSE) # Create the directory if it does not exist

# Reading the API key for accessing the stock data from environment variables
access_key <- Sys.getenv("STOCK_ACCESS_KEY")

# Define the stock symbols and corresponding company names
symbols1 <- c(
  "BARC", # Barclays PLC
  "HSBA", # HSBC Holdings PLC
  "LSEG", # London Stock Exchange Group
  "MKS",  # Marks and Spencer Group PLC
  "LLOY"  # Lloyds Banking Group PLC
)

companies <- c(
  "Barclays PLC",
  "HSBC Holdings PLC",
  "London Stock Exchange Group",
  "Marks and Spencer Group PLC",
  "Lloyds Banking Group PLC"
)


# Function to fetch stock details for a given symbol
get_stock_details <- function(symbol, access_key) {
  # Define the dates for which to fetch stock data (latest and previous)
  date <- Sys.Date() - 1
  prev_date <- Sys.Date() - 2
  
  # Construct the API URL for fetching daily time series data
  base_url <- paste0('https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=', symbol, '.LON&apikey=', access_key)
  print(base_url) # Print the URL for debugging purposes
  
  # Make the API request
  response <- GET(url = base_url)
  
  # Check if the request was successful (status code 200)
  if (response$status_code != 200) {
    stop("Failed to retrieve stock data") # Stop execution if the request fails
  }
  
  # Parse the response content
  content <- content(response)
  
  # Extract daily time series data from the response
  data <- content[2]$`Time Series (Daily)`
  stock_data <- as.data.frame(do.call(rbind, data))
  
  dates <- rownames(stock_data)
  rownames(stock_data) <- NULL
  stock_data$date = dates
  
  latest_close <- stock_data[1,4]
  previous_day_close <- stock_data[2,4]
  
  # Calculate the percentage change between the latest and previous close prices
  percentage <- ((as.numeric(previous_day_close) - as.numeric(latest_close)) / as.numeric(latest_close)) * 100
  
  # Return a list containing the stock symbol, latest close price, and percentage change
  list(
    symbol = symbol, 
    latest = as.numeric(latest_close),
    percentage = percentage
  )
}

# Fetch stock data for each symbol and combine the results into a data frame
stock_data <- map_df(symbols, ~ {
  Sys.sleep(1) # Pause for 1 second to respect API rate limits
  stock_info <- get_stock_details(.x, access_key) # Get stock details for the current symbol
  
  return(as_tibble(stock_info)) # Convert the list to a tibble (data frame)
})

# Combine the stock data with company names and rearrange the columns
total <- bind_cols(company = companies, stock_data) %>% relocate(symbol, .before = company)

# Print the combined data
print(total)


# Save the combined data to a CSV file
file_path <- paste0(data_dir, '/stocks.csv')
write.csv(total, file = file_path, row.names = FALSE) # Write data to CSV without row names
