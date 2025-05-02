# Load necessary libraries
library(dplyr)    # For data manipulation
library(gmailr)   # For sending emails via Gmail
library(vroom)    # For fast reading and writing of data files

# Set the data directory from environment variables, or default to "data"
data_dir <- Sys.getenv("DATA_DIR")
if (data_dir == "") {
  data_dir <- "data" # Default to "data" if environment variable is not set
}


# Define file paths for the stocks and news data
stocks_file_path <- paste0(data_dir, '/stocks.csv')
news_file_path <- paste0(data_dir, '/news.csv')

# Read the CSV files for stocks and news data
stocks_csv <- read.csv(stocks_file_path)
news_csv <- read.csv(news_file_path)


# Clean the stocks data
stocks_clean_data <- stocks_csv %>%
  mutate(
    date = Sys.Date(),  # Add the current date as a new column
    latest = ifelse(latest < 0, NA, latest),  # Replace negative values in 'latest' with NA
    percentage = round(percentage, 2)  # Round the 'percentage' column to 2 decimal places
  )

# Save the cleaned stocks data back to the original CSV file
write.csv(stocks_clean_data, file = stocks_file_path, row.names = FALSE)


# Clean the news data by adding the current date
news_clean_data <- news_csv %>%
  mutate(date = Sys.Date()) # Add the current date as a new column

# Save the cleaned news data back to the original CSV file
write.csv(news_clean_data, file = news_file_path, row.names = FALSE)

# Format the stocks data as a string using vroom for sending in the email
stock_string <- vroom_format(
  stocks_clean_data,
  delim = "\t",   # Use tab as the delimiter
  eol = "\n",     # Use newline as the end of line character
  na = "NA",      # Represent missing values as "NA"
  col_names = FALSE,  # Do not include column names in the output
  escape = c("double", "backslash", "none"), # Escaping options
  quote = c("needed", "all", "none"), # Quote options
  bom = FALSE    # Do not include a byte order mark
)

# Format the news data as a string using vroom for sending in the email
news_string <- vroom_format(
  news_csv,
  delim = " - ",  # Use " - " as the delimiter
  eol = "\n",     # Use newline as the end of line character
  na = "NA",      # Represent missing values as "NA"
  col_names = FALSE,  # Do not include column names in the output
  escape = c("double", "backslash", "none"), # Escaping options
  quote = c("needed", "all", "none"), # Quote options
  bom = FALSE    # Do not include a byte order mark
)


# Combine the formatted stock and news data into the body of the email
mail_data <- paste0(
  'Daily Portfolio Update - ', Sys.Date(), '\n Stock Summary:\n', 
  stock_string, '\n\n Today\'s News:\n', news_string
)

# Print the email content for verification
print(mail_data)

# Configure Gmail authentication using a JSON credentials file
gm_auth_configure(path = "roopa_new_client.json")
gm_auth(email = "ryk.2001@gmail.com")

# Create the email object with recipient, sender, subject, and body content
email <- gm_mime() %>%
  gm_to("jfrancis@london.edu") %>%              # Set the recipient's email address
  gm_from("ryk.2001@gmail.com") %>%        # Set the sender's email address
  gm_subject("4326754, Assignment 2") %>%             # Set the subject of the email
  gm_text_body(mail_data)                  # Set the email body text

# Send the email using Gmail's API
gm_send_message(email)


