# 💳 Financial Transactions Analysis

## 📌 Overview

This project analyzes transactional financial data to evaluate **cash flow dynamics, behavioral patterns, and risk exposure** at the account level.

The dataset simulates real-world banking activity and demonstrates how raw transaction data can be transformed into **decision-ready financial insights** using SQL.

---

## 🎯 Business Objectives

* Evaluate income vs expense trends over time.
* Identify key spending drivers.
* Monitor account-level financial health.
* Detect anomalous and risky behavior.
* Segment users based on financial patterns.
* Support retention and risk strategies.

---

## 🗂️ Data Model

### Fact Table: `transactions`

| Column           | Description                   |
| ---------------- | ----------------------------- |
| transaction_id   | Unique transaction identifier |
| account_id       | Customer account              |
| transaction_date | Transaction date              |
| transaction_type | Deposit or Withdrawal         |
| amount           | Transaction value             |
| currency         | Transaction currency          |
| category         | Transaction classification    |

---

## ⚙️ Analytical Layers

### 1. Financial Performance

* Monthly income vs expenses.
* Net cash flow trends.

### 2. Spending Behavior

* Expense distribution by category.
* Identification of major cost drivers.

### 3. Balance Analysis

* Monthly and cumulative balances.
* Peak and lowest financial positions.

### 4. Risk Detection

* Consecutive negative balance periods.
* Early identification of financial stress.

### 5. Growth Analysis

* Month-over-month changes.
* Deposit and withdrawal growth rates.

### 6. Activity Monitoring

Accounts are classified into:

* Dormant.
* Normal.
* High Activity.
* Low Activity.
* Anomalous.

### 7. Segmentation

Users are categorized as:

* Saver.
* Spender.
* Balanced.
* Dormant.
* Anomalous.

### 8. Risk & Retention Modeling

* Risk levels: High / Medium / Low.
* Retention signals based on financial behavior.

---

## 🧠 Data Engineering Techniques

* Common Table Expressions (CTEs)
* Window Functions (`LAG`, `SUM OVER`, `RANK`)
* Time-series modeling
* Data gap handling using `FULL JOIN` + `COALESCE`
* Analytical view creation: `account_month_metrics`

---

## 📊 Tools Used

* PostgreSQL.
* SQL.

---

## 📐 Key Design Decision

A reusable analytical layer (`account_month_metrics`) was created to:

* Avoid repeated computation.
* Standardize time-series metrics.
* Serve as a foundation for segmentation and risk modeling.

This approach mimics a **fact table in a dimensional model**, enabling scalable and modular analysis.

---

## ⚠️ Notes

* Dataset is synthetic and created for demonstration purposes.
* Focus is on analytical logic rather than production-level constraints.
* Monthly aggregation is used as the primary grain.

---

## 🚀 Key Takeaways

* Built an end-to-end financial analytics workflow.
* Transformed transactional data into behavioral insights.
* Applied advanced SQL techniques for time-series analysis.
* Designed reusable structures for scalable analytics.
