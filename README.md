# 💳 Financial Transactions Analysis

## 📌 Overview
This project analyzes financial transaction data to evaluate user behavior, cash flow trends, risk exposure, and account activity patterns.

The dataset simulates real-world banking activity, including deposits and withdrawals across multiple users, enabling the construction of analytical metrics typically used in financial analytics and fintech environments.

---

## 🎯 Objectives
- Track income vs expenses over time
- Analyze spending behavior by category
- Monitor account balances and detect financial stress
- Identify anomalous activity patterns
- Segment users based on financial behavior
- Assess financial risk and retention potential

---

## 🗂️ Data Model
Single fact table:

**transactions**
- transaction_id (PK)
- account_id
- transaction_date
- transaction_type (Deposit / Withdrawal)
- amount
- currency
- category

---

## ⚙️ Key Features & Analysis

### 📊 Financial Performance
- Monthly income vs expenses
- Category-level spending analysis

### 💰 Balance Tracking
- Running balance per account
- Identification of maximum and minimum balance points

### ⚠️ Risk Detection
- Consecutive negative balance periods
- High-risk user identification

### 📈 Growth Analysis
- Month-over-month deposit & withdrawal trends
- Cumulative financial flow tracking

### 🔍 Behavioral Analytics
- Account activity classification:
  - Dormant
  - Normal
  - High Activity
  - Anomalous

### 🧠 Customer Segmentation
- Saver vs Spender classification
- Behavioral profiling based on transaction patterns

### 🚨 Risk & Retention Modeling
- Risk levels:
  - High / Medium / Low
- Retention categories:
  - High / Low / Dormant

---

## 🏗️ Data Engineering Concepts Used
- Common Table Expressions (CTEs)
- Window Functions (LAG, SUM OVER, RANK)
- Time Series Analysis
- Data Imputation using COALESCE
- FULL JOIN for data completeness
- Analytical View Creation (`account_month_metrics`)

---

## 📊 Tools Used
- PostgreSQL
- SQL

---

## ⚠️ Notes
- Dataset is synthetic and created for analytical purposes
- Focus is on analytical logic rather than production-level normalization
- View `account_month_metrics` acts as a reusable fact table for advanced analytics

---

## 🚀 Key Takeaways
- Built a complete financial analytics workflow from raw transactions to risk modeling
- Applied advanced SQL techniques for time-series and behavioral analysis
- Designed scalable logic for real-world financial monitoring systems
