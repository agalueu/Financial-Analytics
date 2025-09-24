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
