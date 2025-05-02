# 📈 Automated Daily Stock Portfolio Update Pipeline (FTSE 100)

## 🎯 Objective

This project builds an **automated ETL (Extract, Transform, Load) pipeline** for a portfolio of five popular UK stocks from the **FTSE 100 index**. The pipeline:

- Gathers stock prices via API
- Scrapes relevant news articles from UK financial sites
- Cleans and integrates the data
- Sends a daily **email update** at 6 AM
- Saves each update into a **database for archival**
- Automates the entire process using **Bash and cron**

---

## 🪙 Portfolio Selection

Five popular UK companies from the FTSE 100 were selected. Example stocks:
- HSBC Holdings (HSBA)
- BP plc (BP)
- Unilever (ULVR)
- Tesco (TSCO)
- GlaxoSmithKline (GSK)

---

## 📡 Data Acquisition

### 🔢 Stock Prices via API
- **APIs Used**: YFinance
- Fetched daily open, close, high, low, and percent change for each stock.

### 📰 News Articles via Web Scraping
- **Sources**: BBC Business, The Guardian Business
- Scraped 5–10 relevant financial headlines per day related to the stocks or UK economy.
- Includes title + hyperlink per article.

---

## 🧹 Data Processing

### 🔧 Cleaning
- Handled missing values, normalized formats, and ensured consistency across APIs and websites.

### 🔗 Integration
Combined stock and news data into a structured format:

```
Daily Portfolio Update - 2024-10-22
 Stock Summary:
BARC    Barclays PLC    242.25  1.18    2024-10-22
HSBA    HSBC Holdings PLC       680.6   -0.38   2024-10-22
LSEG    London Stock Exchange Group     10535   -0.43   2024-10-22
MKS     Marks and Spencer Group PLC     385.9   1.27    2024-10-22
LLOY    Lloyds Banking Group PLC        62.18   -0.51   2024-10-22


 Today's News:
"Stocks to watch: Tesla, Lloyds, L'Oréal, Coca-Cola and Unilever" https://uk.finance.yahoo.com/news/tesla-lloyds-loreal-coca-cola-unilever-stocks-to-watch-160729628.html 2024-10-22
"Best savings accounts that offer above-inflation rates, 18 October" https://uk.finance.yahoo.com/news/best-savings-accounts-above-inflation-rates-050002978.html 2024-10-22
"Artificial Intelligence and Trust to Reshape Healthcare by 2035, HSBC Report Charts Path to Innovation" https://uk.finance.yahoo.com/news/artificial-intelligence-trust-reshape-healthcare-160000653.html 2024-10-22
"HSBC expands Nova Credit partnership" https://www.retailbankerinternational.com/news/hsbc-expands-nova-credit-partnership/ 2024-10-22
"LSEG Fires Staffer After Video Shows Him Following a Black Teen" https://uk.finance.yahoo.com/news/lseg-fires-staffer-video-shows-204743892.html 2024-10-22
"Pound hits two-year high against euro" https://uk.finance.yahoo.com/news/pound-hits-two-high-against-170652048.html 2024-10-22
"Should Value Investors Buy Marks and Spencer Group (MAKSY) Stock?" https://uk.finance.yahoo.com/news/value-investors-buy-marks-spencer-134013116.html 2024-10-22
"Third of households buy groceries from M&S" https://uk.finance.yahoo.com/news/third-households-buy-groceries-m-121434935.html 2024-10-22
"Stocks to watch: Tesla, Lloyds, L'Oréal, Coca-Cola and Unilever" https://uk.finance.yahoo.com/news/tesla-lloyds-loreal-coca-cola-unilever-stocks-to-watch-160729628.html 2024-10-22
"The best stocks to buy in the UK, according to Barclays" https://uk.finance.yahoo.com/news/stocks-to-buy-in-uk-barclays-112746348.html 2024-10-22
```

---

## 📬 Email Delivery

- **Tools**: `mailR`, `blastula`, or command-line tools (`mail`, `sendmail`)
- Sends a formatted summary email daily at 6 AM.
- Includes both stock summaries and clickable news links.

### 🕒 Email Schedule
- **Daily**: Sent automatically at 6 AM to user inbox

---

## 🗃 Database Storage

- **Schema** includes:
  - `date`, `stock_name`, `price`, `daily_change`, `headline`, `url`
- Data from each daily update is inserted into the database using `RPostgreSQL` or `RSQLite`.

---

## 🛠️ Automation Pipeline

### 🔁 Bash Script
Automates all components:
1. API Access Script
2. Web Scraping Script
3. Data Processing Script
4. Database Storage Script
5. Sends email
6. Logs errors and output

### ⏱ Cron Jobs
Scheduled using `cron`:
- Daily script run at **6:00 AM**

---

## 📦 Folder Structure

```
.
├── run_pipeline.sh              # Main Bash script
├── scripts/
│   ├── 1_api_fetch.R
│   ├── 2_news_scrape.R
│   ├── 3_process_data.R
│   └── 4_store_data.R
├── logs/
├── data/
└── README.md
```

---
 
