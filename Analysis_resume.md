# 📊 Financial Transactions Analysis – Query Breakdown

---

# 1. Monthly Income vs Expenses
### 📝 Query Goal
Calculate total monthly income (deposits) and expenses (withdrawals) across all users to evaluate overall cash flow trends.

### ⚙️ Logic
- DATE_TRUNC('month') standardizes transactions into monthly periods
- Conditional aggregation separates deposits and withdrawals
- SUM calculates total inflows and outflows per month

### 📊 Business Insight
- Identifies whether users are net positive or negative over time
- Detects seasonal spending or income patterns
- Forms the foundation for financial health analysis

---

# 2. Total Spending by Category
### 📝 Query Goal
Identify which categories contribute the most to total expenses.

### ⚙️ Logic
- Filter only withdrawal transactions
- Aggregate spending by category
- Rank categories by total spend

### 📊 Business Insight
- Highlights main cost drivers (e.g., Rent, Groceries)
- Supports budgeting and cost control strategies
- Enables category-level financial optimization

---

# 3. Maximum and Minimum Balance per Account
### 📝 Query Goal
Track cumulative account balances and identify peak and lowest financial positions per user.

### ⚙️ Logic
- Aggregate deposits and withdrawals monthly
- Combine using FULL JOIN to avoid data loss
- Calculate monthly net balance
- Compute running balance using window functions
- Extract max and min balance points using FIRST_VALUE

### 📊 Business Insight
- Reveals financial stability per account
- Identifies users at risk (low balance periods)
- Provides key milestones for financial tracking

---

# 4. Consecutive Negative Balance Detection
### 📝 Query Goal
Identify users experiencing sustained financial stress through consecutive negative balance months.

### ⚙️ Logic
- Compute monthly balances
- Use LAG to compare current vs previous balance
- Flag transitions into negative territory
- Group consecutive negative periods using streak logic

### 📊 Business Insight
- Detects users with recurring financial deficits
- Supports early risk detection and intervention strategies
- Useful for credit risk and financial assistance programs

---

# 5. Top Deposit and Withdrawal Categories per Month
### 📝 Query Goal
Identify the most significant income source and the largest expense category for each user per month.

### ⚙️ Logic
- Separate deposits and withdrawals into independent datasets
- Aggregate amounts by category per month
- Rank categories using window functions
- Extract top-ranked category for each transaction type
- Combine results into a unified structure using UNION ALL

### 📊 Business Insight
- Highlights primary income drivers (e.g., Salary, Freelance)
- Identifies major spending areas (e.g., Rent, Groceries)
- Enables behavioral analysis and anomaly investigation
- Supports financial decision-making and optimization

---

# 6. Month-over-Month Growth Analysis
### 📝 Query Goal
Measure changes in deposits and withdrawals over time and evaluate growth trends per account.

### ⚙️ Logic
- Aggregate monthly deposits and withdrawals
- Use LAG to retrieve previous month values
- Calculate absolute and percentage changes
- Compute cumulative totals for long-term trends

### 📊 Business Insight
- Tracks financial growth or decline patterns
- Identifies sudden spikes or drops in activity
- Supports forecasting and financial planning

---

# 7. Account Activity Classification
### 📝 Query Goal
Categorize monthly account behavior into meaningful activity levels.

### ⚙️ Logic
- Generate complete time series (all accounts × all months)
- Compute deposits, withdrawals, and net flow
- Identify unusual activity using statistical thresholds
- Classify activity using business rules

### 📊 Activity Categories
- Dormant → no activity
- Anomalous → unusually high transactions
- High Activity → strong positive net flow
- Low Activity → low financial movement
- Normal → standard behavior

### 📊 Business Insight
- Detects inactive accounts
- Flags abnormal financial behavior
- Enables behavioral monitoring and segmentation

---

# 8. User Segmentation
### 📝 Query Goal
Classify users based on long-term financial behavior patterns.

### ⚙️ Logic
- Aggregate monthly activity metrics per user
- Compare positive vs negative months
- Identify dormant and anomalous behavior
- Assign segment labels based on rules

### 📊 Segments
- Saver → mostly positive cash flow
- Spender → mostly negative cash flow
- Balanced → mixed behavior
- Dormant → inactive
- Anomalous → irregular activity

### 📊 Business Insight
- Enables targeted financial strategies
- Supports personalization and customer profiling
- Useful for marketing and engagement campaigns

---

# 9. Risk & Retention Indicators
### 📝 Query Goal
Assess financial risk and likelihood of user retention.

### ⚙️ Logic
- Calculate behavioral ratios (negative months, anomalies, inactivity)
- Retrieve latest cumulative balance
- Classify risk based on thresholds
- Assign retention potential based on activity and net flow

### 📊 Risk Levels
- High Risk → frequent negative balances or anomalies
- Medium Risk → mixed behavior
- Low Risk → stable positive activity

### 📊 Retention Categories
- High → strong positive engagement
- Low → declining activity
- Dormant → inactive users

### 📊 Business Insight
- Supports risk management strategies
- Identifies users needing intervention
- Improves customer retention planning
