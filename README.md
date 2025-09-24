# 💰 Financial Analytics Project
### 📌 Overview
This project analyzes financial performance data to provide insights into revenue, expenses, profitability, and efficiency.
It uses PostgreSQL for data management and Power BI for building interactive dashboards.

###  📂 Dataset
This project uses a single table:

transactions:
- transaction_id → unique ID (Primary Key)
- account_id → account reference
- transaction_date → date of transaction
- transaction_type → deposit or withdrawal
- amount → transaction amount (≥ 0)
- currency → transaction currency (default: USD)
- category → category of transaction (salary, rent, groceries, etc.)

### 🛠 Tools
- PostgreSQL – querying & transformations.
- Power BI – visualization & dashboarding.
- GitHub – version control & portfolio showcase.

### ❓ Key Business Questions
- What are the trends in revenue, expenses, and net profit?
- Which categories are over or under budget?
- What is the company’s profitability ratio (ROA, Net Margin)?
- How do quarterly results compare against previous years?
- Where are the biggest cost drivers?

### 📁 Repository Structure
financial-analytics/
│── README.md                # Project summary  
│── data/                    # Raw & cleaned dataset  
│── sql/                     # SQL queries & views  
│── powerbi/                  # Power BI file & exports  
│── docs/                    # Documentation, screenshots  

### ⚙️ How to Reproduce
- Create a PostgreSQL database:
- In pgAdmin → right-click Databases → Create - Database → name it hr_analytics.
- Schema & Data Import
- Run the schema script in sql/schema.sql to create the employee table, can copy [SCHEMA](sql/SCHEMA.sql).
- Import the sample dataset HR_employee.csv and HR_departments.cvs.

### 📊 Power BI Integration
- KPI cards for Revenue, Expenses, Net Profit.
- Line charts for monthly/quarterly trends.
- Actual vs Budget comparisons.
- Category breakdowns (expenses by type).

### 🖼 Images Shared



### 📑 Queries, Analysis & Insights
For detailed SQL queries and insights, see [Analysis Resume](Analysis_resume.md)


Financial Analytics Project
Overview

This project analyzes transaction data to extract insights on user behavior, spending patterns, account balances, and risk segmentation.
It demonstrates advanced SQL techniques, data modeling, and Power BI integration for visualization.

Dataset

Table used: transactions

Columns:

transaction_id (Primary Key)

account_id

transaction_date

transaction_type (Deposit / Withdrawal)

amount

currency

category

All analysis queries are performed on this dataset.

Tools

PostgreSQL – Data storage and querying

SQL (CTEs, Window Functions, Joins) – Advanced analytics

Power BI – Dashboard and visualization

Key Business Questions

How do monthly deposits and withdrawals trend over time per user?

Which categories drive the highest spending and deposits?

What are users’ minimum and maximum balances?

Are there negative balance streaks for any users?

How can users be segmented based on their financial behavior?

Which users pose higher financial risk or have retention concerns?

Detailed query analysis, business insights, and logic are documented in analysis_resume.md
.

Repository Structure
Financial-Analytics-Project/
│
├─ README.md                 # Project overview (this file)
├─ analysis_resume.md        # Detailed SQL analysis with insights
├─ transactions.sql          # Script to create & populate the transactions table
├─ ERD.png                   # Database ERD image
├─ powerbi/                  # Power BI dashboards & pbix files
└─ images/                   # Supporting images/screenshots

How to Reproduce

Create the transactions table and populate it with data using transactions.sql.

Run queries from analysis_resume.md in PostgreSQL.

Connect PostgreSQL to Power BI to visualize insights:

Import transactions or derived views.

Build charts for KPIs, balances, anomalies, and segmentation.

Database ERD

Relationships:

transactions.account_id → links deposits and withdrawals per user.

All analysis queries use this table as a single fact table, allowing multiple metrics and aggregates per user/month.

Power BI Integration

Use imported queries or the account_month_metrics view as a fact table.

Suggested visuals:

Line charts for cumulative deposits, withdrawals, and balances

Bar charts for category-level spending and income

Heatmaps for user activity and anomalies

Segmentation & risk classification tables

Filters: date, account, category, and activity type for interactive dashboards.

Images Shared

ERD: ERD.png

Power BI dashboard screenshots: images/dashboard_1.png, images/dashboard_2.png
