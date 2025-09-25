# 💰 Financial Analytics Project
### 📌 Overview
This project analyzes transaction data to extract insights on user behavior, spending patterns, account balances, and risk segmentation.
It demonstrates advanced SQL techniques, data modeling, and Power BI integration for visualization.

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

**All analysis queries are performed on this dataset.**

### 🛠 Tools
- PostgreSQL – querying & transformations.
- Power BI – visualization & dashboarding.
- GitHub – version control & portfolio showcase.

### ❓ Key Business Questions
- How do monthly deposits and withdrawals trend over time per user? [Deposits vs Withdrawals](images/deposit_balance_expences.png).
- Which categories drive the highest spending and deposits? [Expences by category](images/deposit_balance_expences.png)
- What are users’ minimum and maximum balances? [Max/Min Balance](images/deposit_balance_expences.png)
- Are there negative balance streaks for any users? [Negative streaks](images/consecutive_negative_balance.png)
- How can users be segmented based on their financial behavior? [Segmentation](images/segmentation.png)
- Which users pose higher financial risk or have retention concerns? [Risk](images/risk.png)

Detailed query analysis, and logic are documented in [Analysis resume](sql/Analysis_resume.sql).

### 📁 Repository Structure
Financial-Analytics-Project/
│
├─ README.md                 # Project overview (this file)
├─ analysis_resume.md        # Detailed SQL analysis with insights
├─ sql                       # Script to create & populate the transactions table
└─ images/                   # Supporting images/screenshots

### ⚙️ How to Reproduce
- Create a PostgreSQL database:
- In pgAdmin → right-click Databases → Create - Database → name it hr_analytics.
- Schema & Data Import:
    * Run the schema script in sql/schema.sql to create the employee table, can copy [SCHEMA](sql/SCHEMA.sql).
- Sample queries are aviliable in [Analysis](sql/Analysis.sql).

### Database ERD
Relationships:
  - transactions.account_id → links deposits and withdrawals per user.

All analysis queries use this table as a single fact table, allowing multiple metrics and aggregates per user/month.

### 📊 Power BI Integration
- KPI cards for Revenue, Expenses, Net Profit.
- Line charts for monthly/quarterly trends.
- Actual vs Budget comparisons.
- Category breakdowns (expenses by type).

    Sample dashboard ... [Overall Chart](images/overall_chart.png) & [Continue Overall Chart](images/overall_chart_2.png)

### 📑 Queries, Analysis & Insights
For detailed SQL queries and insights, see [Analysis Resume](Analysis_resume.md)
