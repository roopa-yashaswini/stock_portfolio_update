# Load necessary libraries
library(httr)        # For making HTTP requests
library(jsonlite)    # For JSON handling
library(tidyverse)   # For data manipulation and visualization
library(RSQLite)     # For SQLite database interaction
library(writexl)     # For writing Excel files

# Set the data directory from environment variables, or default to "data"
data_dir <- Sys.getenv("DATA_DIR")
if (data_dir == "") {
  data_dir <- "data" # Default to "data" if the environment variable is not set
}

# Set the database name from environment variables, or default to "recent_stocks_news.db"
db_name <- Sys.getenv("DB_NAME")
if (db_name == "") {
  db_name <- "recent_stocks_news.db" # Default to this database name if not provided
}

# Define file paths for stocks and news CSV files
stocks_file_path <- paste0(data_dir, '/stocks.csv')
news_file_path <- paste0(data_dir, '/news.csv')

# Read the stocks and news data from the CSV files
stocks_csv <- read.csv(stocks_file_path)
news_csv <- read.csv(news_file_path)

# Reorder columns in the data frames to move the 'date' column before other columns
stocks_csv <- stocks_csv %>% relocate(date, .before = symbol)
news_csv <- news_csv %>% relocate(date, .before = headline)

# Establish a connection to the SQLite database
con <- dbConnect(SQLite(), dbname = db_name)

# Create the 'stocks' table if it does not already exist
dbExecute(con, "
 CREATE TABLE IF NOT EXISTS stocks (
  date DATETIME,      -- The date of the stock data
  symbol TEXT,        -- The stock symbol
  company TEXT,       -- The company name
  latest FLOAT,       -- The latest stock price
  percentage FLOAT,   -- The percentage change in stock price
  PRIMARY KEY(date, symbol) -- Composite primary key on date and symbol
 )
")

# Create the 'news' table if it does not already exist
dbExecute(con, "
 CREATE TABLE IF NOT EXISTS news (
  date DATETIME,   -- The date of the news article
  headline TEXT,   -- The headline of the news article
  link TEXT        -- The URL link to the news article
 )
")

# Insert the stocks data into the 'stocks' table, appending it to existing data
dbWriteTable(
  conn = con,
  name = "stocks",
  value = stocks_csv,
  append = TRUE,    # Append to the existing table instead of overwriting
  row.names = FALSE # Do not include row names in the database
)

# Insert the news data into the 'news' table, appending it to existing data
dbWriteTable(
  conn = con,
  name = "news",
  value = news_csv,
  append = TRUE,    # Append to the existing table instead of overwriting
  row.names = FALSE # Do not include row names in the database
)

# Query the database to retrieve all records from the 'stocks' table
stocks_query <- dbGetQuery(con, "SELECT * FROM stocks")

# Query the database to retrieve all records from the 'news' table
news_query <- dbGetQuery(con, "SELECT * FROM news")

# Print the results of the queries to the console
print(stocks_query)
print(news_query)

# Close the connection to the database
dbDisconnect(con)
