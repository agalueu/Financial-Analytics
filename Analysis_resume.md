-- 1. What are the Monthly Income vs Expenses for all users?
📝 Query Goal
To calculate total income and total expenses per month, helping track cash inflows and outflows over time.

⚙️ Steps / Logic

DATE_TRUNC('month', transaction_date) → groups transactions by month (ignoring day details).

CASE statements:

If transaction_type = 'Deposit', sum amounts into total_income.

If transaction_type = 'Withdrawal', sum amounts into total_expenses.

Aggregate with SUM → calculates total deposits and withdrawals for each month.

ORDER BY month → results displayed chronologically.

📊 Business Insights

Identifies monthly financial health by comparing income vs expenses.

Reveals if the company (or account) is spending more than earning.

Helps detect seasonal trends (e.g., higher expenses during certain months).

Provides a baseline for budgeting and forecasting.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)


-- 2. What are the total spent by Category?
📝 Query Goal
To calculate total spending per category, allowing identification of where the majority of withdrawals (expenses) are going.

⚙️ Steps / Logic

Filter transactions → WHERE transaction_type = 'Withdrawal' ensures only expenses are considered.

Group by category → aggregates withdrawals by expense type (e.g., Rent, Groceries, Utilities).

SUM(amount) → computes total spent per category.

ORDER BY total_spent DESC → ranks categories from highest to lowest spending.

📊 Business Insights

Shows the biggest cost drivers (e.g., Rent or Groceries).

Helps prioritize cost control strategies.

Useful for budget planning → know which categories to monitor closely.

Enables tracking of spending habits over time if combined with monthly filters.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 3. What is the highest and lowest balance per account?
📝 Query Goal
To calculate each user’s running balance over time, and identify their maximum and minimum balances, including the exact dates those occurred.

⚙️ Steps / Logic

deposits CTE → aggregates deposits per user, per month.

withdraws CTE → aggregates withdrawals per user, per month.

totals CTE →

Combines deposits & withdrawals using a FULL JOIN.

Calculates the monthly balance = deposits – withdrawals.

Uses COALESCE to handle months with only deposits or only withdrawals.

final_result CTE →

Adds a running balance with SUM(balance) OVER (PARTITION BY users ORDER BY date).

This gives cumulative account balances over time.

Final SELECT →

Uses FIRST_VALUE to pick the max running balance and its date.

Uses FIRST_VALUE to pick the min running balance and its date.

Returns one row per user with key balance milestones.

📊 Business Insights

Tracks financial health per user/account over time.

Identifies best financial positions (max balances) and worst positions (min balances).

Useful for risk assessment → users frequently hitting very low balances might be at higher risk.

Enables personalized financial advice (e.g., budgeting recommendations for users whose expenses consistently exceed income).

Forms the foundation for trend analysis dashboards in Power BI (e.g., line chart of running balance, annotated with min/max points).


Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 4. Identify accounts that had negative balances for two or more consecutive months
📝 Query Goal
To identify periods where users had two or more consecutive months with negative balances, showing when those streaks started and ended.

⚙️ Steps / Logic

deposit CTE → sums deposits per account per month.

withdraw CTE → sums withdrawals per account per month.

totals CTE → merges deposits & withdrawals with a FULL JOIN, and calculates balance = deposits - withdraws.

negatives CTE →

Brings in the previous month’s balance using LAG.

Prepares data for detecting shifts between positive and negative states.

flags CTE → marks a streak break when the balance crosses from positive to negative.

finals CTE →

Uses a running SUM(streak_break) to assign a streak ID to each negative balance period.

Final SELECT →

Filters only months with negative balances.

Groups by streak_id to find consecutive negative months.

Keeps only streaks lasting 2+ months (HAVING COUNT(*) >= 2).

Returns user, number of negative months, and the start/end dates of each streak.

📊 Business Insights

Detects users/accounts with sustained financial stress (multiple consecutive months in the red).

Helps flag customers who may need intervention (e.g., credit counseling, payment plans).

Reveals recurring risk patterns — are certain months or users more prone to consecutive deficits?

Valuable for early warning systems in financial institutions.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 5. Which category has the highest deposits and the highest withdrawals per month?.
📝 Query Goal
To identify, for each user and month, the category with the highest deposit and the category with the highest withdrawal.
This helps highlight financial priorities and spending patterns at the category level.

⚙️ Steps / Logic

deposit CTE → sums deposits per account per month, grouped by category.

withdraw CTE → sums withdrawals per account per month, grouped by category.

totals CTE → merges deposits and withdrawals per user, per category, per month using FULL JOIN, ensuring no data is lost.

ranked CTE →

Uses RANK() window function to rank deposits and withdrawals within each user/month.

deposit_rank = 1 → highest deposit category.

withdrawal_rank = 1 → highest withdrawal category.

Final SELECT → filters only the top deposit and top withdrawal categories, returning user, date, category, and amounts.

📊 Business Insights

Reveals which categories are most important for income (max deposits).

Highlights which categories drive the most expenses (max withdrawals).

Supports budgeting & expense monitoring → users can see which areas need cost control or investment focus.

Enables trend analysis → track how top categories evolve over time.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 6. Month over Month deposit/withdrawals growth per account
📝 Query Goal
To track month-over-month changes in deposits and withdrawals for each user, and calculate cumulative balances over time.
This shows both absolute and percentage growth, and helps visualize long-term trends in financial flows.

⚙️ Steps / Logic

Deposit CTEs

deposit → sum deposits per user per month.

previous_deposit → use LAG to get previous month’s deposits.

final_deposits → calculate:

absolute_deposit_change = total_deposits - previous_deposit

deposit_growth = ((total_deposits - previous_deposit) / previous_deposit) * 100

Withdrawal CTEs

withdrawal → sum withdrawals per user per month.

previous_withdrawal → use LAG to get previous month’s withdrawals.

Results CTE

FULL JOIN deposits & withdrawals by account_id and date → ensures no month is lost.

Compute:

Absolute and percentage growth for both deposits and withdrawals.

Balance Flow = total_deposits - total_withdrawal.

Final SELECT

Compute cumulative totals over time using SUM(...) OVER (PARTITION BY users ORDER BY date) for:

Cumulative Deposits

Cumulative Withdrawals

Cumulative Balance

📊 Business Insights

Measures month-over-month financial performance per user.

Detects growth trends in deposits and withdrawals.

Highlights months of strong inflows or spikes in expenses.

Provides cumulative balance trends, useful for forecasting liquidity.

Supports financial planning dashboards in Power BI with growth metrics and cumulative flows.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 7. Account activity
📝 Query Goal
To classify each user’s monthly account activity into categories such as:

Dormant → no deposits or withdrawals

Anomalous → unusually high deposits or withdrawals

High / Low Activity → based on net flow thresholds

Normal → typical activity

This helps monitor user behavior and detect outliers.

⚙️ Steps / Logic

Generate all months and accounts

months → generate all months between the first and last transaction.

account → get all distinct accounts.

account_month → cross join to ensure each account has a row for every month (even if no transactions).

Deposit & Withdrawal aggregation

deposit → sum deposits per user per month.

cumulative_d → compute cumulative deposits and average monthly deposits.

withdrawal → sum withdrawals per user per month.

cumulative_w → compute cumulative withdrawals and average monthly withdrawals.

Combine deposits & withdrawals

overall → join cumulative deposits and withdrawals to all months per account.

Compute monthly net flow, cumulative balance, and multiplier (deposits / withdrawals).

Flag unusually high deposits/withdrawals if they are > 2× average.

Activity categorization

Final CASE statement classifies each month as:

Dormant → no activity

Anomalous → unusual transactions

High Activity → net flow ≥ 1500

Low Activity → net flow < 500

Normal → all other cases

📊 Business Insights

Detects dormant accounts, high-risk anomalies, and activity patterns.

Highlights months of unusually high deposits or withdrawals → useful for fraud monitoring or marketing targeting.

Supports behavior segmentation → accounts can be categorized for personalized notifications, offers, or alerts.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 8. Segmentation / Profiling

📝 Query Goal
To classify each user/account into financial behavior segments based on their monthly transaction activity:

Dormant → mostly inactive months

Anomalous → had unusual deposits or withdrawals

Saver → more positive net months than negative

Spender → more negative net months than positive

Balanced → roughly equal positive and negative months

This helps understand user behavior patterns and informs financial strategy or targeted actions.

⚙️ Steps / Logic

Create fact table / view

account_month_metrics aggregates monthly deposits, withdrawals, net flow, cumulative balance, and flags unusual activity (Query 7 logic).

Compute metrics per user (table1)

Average monthly net flow.

Total number of months.

Number of positive vs negative months.

Number of dormant months.

Number of anomalous months (unusually high deposits or withdrawals).

Segment users

Dormant → if >50% of months have no activity.

Anomalous → if any month has flagged unusual deposits/withdrawals.

Saver → positive months > negative months.

Spender → negative months > positive months.

Balanced → equal or near-equal positive/negative months.

📊 Business Insights

Provides behavior-based segments for targeted marketing, alerts, or recommendations.

Helps identify:

Dormant users → may need re-engagement campaigns.

Savers vs Spenders → tailor financial advice or product offerings.

Anomalous users → monitor for risk/fraud.

Supports dashboarding and KPI reporting for account management teams.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

-- 9. Risk / Health Indicators
📝 Query Goal
To categorize users based on:

Risk → likelihood of financial stress or instability

Retention potential → probability of remaining active based on activity and net flow

This provides actionable insights for risk management and customer retention strategies.

⚙️ Steps / Logic

Compute monthly metrics per user (table1)

Average monthly net flow (avg_netflow).

Count total months, positive months, negative months, dormant months, anomalous months.

Retrieve latest cumulative balance (last_cumulative)

Ensures risk classification uses most recent financial position.

Combine metrics (risk_metrics)

Calculate percentages:

Negative months (%)

Anomalous months (%)

Dormant months (%)

Classify risk

High risk → >50% negative months OR >25% anomalous months OR cumulative balance < 0.

Medium risk → 20–50% negative months with positive balance.

Low risk → <20% negative months with positive balance.

Classify retention potential

Dormant → >50% months inactive.

High → avg_netflow > 800.

Low → avg_netflow < 400.

Balance → otherwise.

📊 Business Insights

Risk classification helps identify users who may need financial support, monitoring, or intervention.

Retention segmentation highlights:

Users likely to remain active.

Users at risk of inactivity (Dormant or Low retention).

Supports personalized engagement strategies for marketing, loyalty programs, or alerts.

Combines behavioral and financial metrics for a comprehensive view of user health.
