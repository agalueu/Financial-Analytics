/* =========================================================
   1. FINANCIAL PERFORMANCE
   ========================================================= */
SELECT 	DATE_TRUNC('month', transaction_date)::date AS month,
    	SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE 0 END) AS total_income,
    	SUM(CASE WHEN transaction_type = 'Withdrawal' THEN amount ELSE 0 END) AS total_expenses
FROM transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;

/* =========================================================
   2. SPENDING BEHAVIOR
   ========================================================= */
SELECT category, SUM(amount) AS total_spent
FROM transactions
WHERE transaction_type = 'Withdrawal'
GROUP BY category
ORDER BY total_spent DESC;

/* =========================================================
   3. BALANCE ANALYSIS
   ========================================================= */
WITH deposits AS (
    SELECT  account_id,
            DATE_TRUNC('month', transaction_date)::date AS date,
            SUM(amount) AS total_deposits
    FROM transactions
    WHERE transaction_type = 'Deposit'
    GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),
withdraws AS (
    SELECT  account_id,
            DATE_TRUNC('month', transaction_date)::date AS date,
            SUM(amount) AS total_withdrawal
    FROM transactions
    WHERE transaction_type = 'Withdrawal'
    GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),
totals AS (
    SELECT  COALESCE(d.account_id, w.account_id) AS users, 
            COALESCE(d.date, w.date) AS date,
            COALESCE(total_deposits, 0) AS total_deposits,
            COALESCE(total_withdrawal, 0) AS total_withdrawal,
            COALESCE(total_deposits, 0) - COALESCE(total_withdrawal, 0) AS balance
    FROM withdraws w
    FULL JOIN deposits d 
      ON w.account_id = d.account_id AND w.date = d.date
),
final_result AS (
    SELECT  *,
            SUM(balance) OVER (PARTITION BY users ORDER BY date) AS running_balance
    FROM totals
)
SELECT DISTINCT
       users AS "User",
       FIRST_VALUE(running_balance) OVER (PARTITION BY users ORDER BY running_balance DESC) AS "Max Balance",
       FIRST_VALUE(date) OVER (PARTITION BY users ORDER BY running_balance DESC) AS "Max Balance date",
       FIRST_VALUE(running_balance) OVER (PARTITION BY users ORDER BY running_balance ASC) AS "Min Balance",
       FIRST_VALUE(date) OVER (PARTITION BY users ORDER BY running_balance ASC) AS "Min balance date"
FROM final_result
ORDER BY users;

/* =========================================================
   4. RISK DETENTION
   ========================================================= */
WITH deposit AS (
	SELECT account_id, DATE_TRUNC('month', transaction_date)::date AS date, SUM(amount) AS deposits
	FROM transactions
	WHERE transaction_type = 'Deposit'
	GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

withdraw AS (
	SELECT account_id, DATE_TRUNC('month', transaction_date)::date AS date, SUM(amount) AS withdraws
	FROM transactions
	WHERE transaction_type = 'Withdrawal'
	GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

totals AS (
	SELECT  COALESCE(d.account_id, w.account_id) AS users,
			COALESCE(d.date, w.date) AS date,
			COALESCE(deposits, 0) AS deposits,
			COALESCE(withdraws, 0) AS withdraws,
			COALESCE(deposits, 0) - COALESCE(withdraws, 0) AS balance
	FROM deposit d
	FULL JOIN withdraw w ON d.account_id = w.account_id
					AND d.date = w.date
),

negatives AS (
	SELECT  users, date, balance, 
			COALESCE(LAG(balance) OVER (PARTITION BY users ORDER BY date), 0) AS previous_balance
	FROM totals

),

flags AS (
	SELECT  users, date, balance, 
			CASE --THIS ONLY CHANGE FROM 0 TO 1 WHEN BALANCE CHANGE FROM + TO - OR VICEVERSA
                  WHEN balance < 0 AND  previous_balance >= 0 THEN 1
                  ELSE 0
               END AS streak_break
	FROM negatives
),

finals AS (
	SELECT  users, date, balance,
			SUM(streak_break) OVER (PARTITION BY users ORDER BY date) AS streak_id
	FROM flags
)

SELECT  users AS "User",
		COUNT(*) AS "Negative Months",
		MIN(date) AS "Start month",
		MAX(date) AS "End month"
FROM finals
WHERE balance < 0
GROUP BY users, streak_id
HAVING COUNT(*) >= 2
ORDER BY users, "Start month";

/* =========================================================
   5. CATEGORY INSIGHTS
   ========================================================= */
WITH deposit AS (
    SELECT 
        account_id,
        DATE_TRUNC('month', transaction_date)::date AS date,
        category,
        SUM(amount) AS total_deposit
    FROM transactions
    WHERE transaction_type = 'Deposit'
    GROUP BY account_id, DATE_TRUNC('month', transaction_date), category
),

withdrawal AS (
    SELECT 
        account_id,
        DATE_TRUNC('month', transaction_date)::date AS date,
        category,
        SUM(amount) AS total_withdrawal
    FROM transactions
    WHERE transaction_type = 'Withdrawal'
    GROUP BY account_id, DATE_TRUNC('month', transaction_date), category
),

ranked_deposits AS (
    SELECT *,
           RANK() OVER (PARTITION BY account_id, date ORDER BY total_deposit DESC) AS rnk
    FROM deposit
),

ranked_withdrawals AS (
    SELECT *,
           RANK() OVER (PARTITION BY account_id, date ORDER BY total_withdrawal DESC) AS rnk
    FROM withdrawal
)

-- Final result
SELECT 
    account_id,
    date,
    category,
    total_deposit,
    NULL AS total_withdrawal,
    'Top Deposit' AS metric
FROM ranked_deposits
WHERE rnk = 1

UNION ALL

SELECT 
    account_id,
    date,
    category,
    NULL,
    total_withdrawal,
    'Top Withdrawal' AS metric
FROM ranked_withdrawals
WHERE rnk = 1
ORDER BY account_id, date;

/* =========================================================
   6. GROWTH ANALYSIS
   ========================================================= */
--ON DEPOSITS
WITH deposit AS (
SELECT  account_id,
		DATE_TRUNC('month', transaction_date)::date AS date,
		SUM(amount) AS total_deposits 
FROM transactions
WHERE transaction_type = 'Deposit'
GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

previous_deposit AS (
	SELECT  account_id,
			date,
			total_deposits,
			LAG(total_deposits) OVER (PARTITION BY account_id ORDER BY date) AS previous_deposit
	FROM deposit
),

final_deposits AS(
	SELECT  account_id,
			date,
			total_deposits,
			previous_deposit,
			total_deposits - previous_deposit AS absolute_deposit_change,
			ROUND((total_deposits - previous_deposit)/NULLIF(previous_deposit, 0) * 100, 2) AS deposit_growth
	FROM previous_deposit
),
-- ON WITHDRAWALS
withdrawal AS (
SELECT  account_id,
		DATE_TRUNC('month', transaction_date)::date AS date,
		SUM(amount) AS total_withdrawal
FROM transactions
WHERE transaction_type = 'Withdrawal'
GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

previous_withdrawal AS (
	SELECT  account_id,
			date,
			total_withdrawal,
			LAG(total_withdrawal) OVER (PARTITION BY account_id ORDER BY date) AS previous_withdrawal
	FROM withdrawal
),

results AS (
	SELECT  COALESCE(pw.account_id, fd.account_id) AS users,
			COALESCE(pw.date, fd.date) AS date,
			COALESCE(total_deposits, 0) AS "Total Deposits",
			COALESCE(previous_deposit, 0) AS "Previous Deposit",
			COALESCE(absolute_deposit_change, 0) AS "Absolute Deposit Change",
			COALESCE(deposit_growth, 0) AS "Deposit Growth",
			COALESCE(total_withdrawal, 0) AS "Total Withdrawal",
			COALESCE(previous_withdrawal, 0) AS "Previous Withdrawal",
			COALESCE(total_withdrawal - previous_withdrawal, 0) AS "Absolute Withdrawal Change",
			COALESCE(ROUND((total_withdrawal - previous_withdrawal)/NULLIF(previous_withdrawal, 0) * 100, 2), 0) AS "Withdrawal Growth",
			COALESCE(total_deposits, 0) - COALESCE(total_withdrawal, 0) AS "Balance Flow"
	FROM previous_withdrawal pw
	FULL JOIN final_deposits fd ON pw.account_id = fd.account_id
								AND pw.date = fd.date
) /*Its important to do the join for account and date because if we dont do it this way we can lose data for those month
  that don't have either deposit or withdrawals*/

SELECT  users AS "User",
		date AS "Date",
		"Total Deposits",
		"Absolute Deposit Change",
		"Deposit Growth",
		"Total Withdrawal",
		"Absolute Withdrawal Change",
		"Withdrawal Growth",
		"Balance Flow",
		SUM("Total Deposits") OVER (PARTITION BY users ORDER BY date) AS "Cumulative Deposits",
		SUM("Total Withdrawal") OVER (PARTITION BY users ORDER BY date) AS "Cumulative Withdrawals",
		SUM("Balance Flow") OVER (PARTITION BY users ORDER BY date) AS "Cumulative Balance"
FROM results;

/* =========================================================
   7. ACTIVITY CLASSIFICATION
   ========================================================= */
WITH months AS(
	SELECT generate_series(
		(SELECT MIN(DATE_TRUNC('month', transaction_date)) FROM transactions),
		(SELECT MAX(DATE_TRUNC('month', transaction_date)) FROM transactions),
		interval '1 month'
)::date AS date
),

account AS (
	SELECT DISTINCT account_id FROM transactions
),

account_month AS (
	SELECT a.account_id, m.date
	FROM account a
	CROSS JOIN months m
	ORDER BY a.account_id, m.date
),
--ON deposits
deposit AS (
	SELECT  account_id,
			DATE_TRUNC('month',	transaction_date)::date AS date,
			SUM(amount) AS total_deposits
	FROM transactions
	WHERE transaction_type = 'Deposit'
	GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

cumulative_d AS (
	SELECT  *,
			SUM(total_deposits) OVER (PARTITION BY account_id ORDER BY date) AS cumulative_deposit,
			AVG(total_deposits) OVER (PARTITION BY account_id) AS avg_deposit
	FROM deposit
),

--ON withdrawal
withdrawal AS (
	SELECT  account_id,
			DATE_TRUNC('month',	transaction_date)::date AS date,
			SUM(amount) AS total_withdrawals
	FROM transactions
	WHERE transaction_type = 'Withdrawal'
	GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

cumulative_w AS (
	SELECT  *,
			SUM(total_withdrawals) OVER (PARTITION By account_id ORDER BY date) AS cumulative_withdrawal,
			AVG(total_withdrawals) OVER (PARTITION BY account_id) AS avg_withdrawal
	FROM withdrawal
),

overall AS (
	SELECT  am.account_id AS users,
			am.date AS date,
			COALESCE(total_deposits, 0) AS total_deposits,
			COALESCE(cumulative_deposit, 0) AS cumulative_deposit,
			COALESCE(total_withdrawals, 0) AS total_withdrawals,
			COALESCE(cumulative_withdrawal, 0) AS cumulative_withdrawal,
			COALESCE(total_deposits, 0) - COALESCE(total_withdrawals, 0) AS monthly_net_flow,
			SUM(COALESCE(total_deposits, 0) - COALESCE(total_withdrawals, 0))
	   			 OVER (PARTITION BY am.account_id ORDER BY am.date) AS cumulative_balance,
			COALESCE(ROUND(total_deposits/NULLIF(total_withdrawals, 0), 2), 0) AS multiplier,
			CASE
				WHEN total_deposits > 2 * avg_deposit THEN 'Unusually High deposit'
				ELSE 'Not a high deposit'
			END AS deposit_flag,
			CASE
				WHEN total_withdrawals > 2 * avg_withdrawal THEN 'Unusually High Withdrawal'
				ELSE 'Not a high withdrawal'
			END AS withdrawal_flag
	FROM account_month am
	LEFT JOIN cumulative_d cd ON am.account_id = cd.account_id
								AND am.date = cd.date
	LEFT JOIN cumulative_w cw ON am.account_id = cw.account_id
								AND am.date = cw.date
)

SELECT  *,
		CASE
	    WHEN total_deposits = 0 AND total_withdrawals = 0 THEN 'Dormant'
	    WHEN deposit_flag = 'Unusually High deposit' OR withdrawal_flag = 'Unusually High Withdrawal' THEN 'Anomalous'
	    WHEN monthly_net_flow >= 1500 THEN 'High Activity'
	    WHEN monthly_net_flow < 500 THEN 'Low Activity'
	    ELSE 'Normal'
END AS activity_category
FROM overall;

/* =========================================================
   CREATING A VIEW
   ========================================================= */
/*For the purpose of do things easier i will make a new table (VIEW) and use that as a fact table in order to not use the
same script over and over again*/
CREATE OR REPLACE VIEW account_month_metrics AS 
WITH months AS(
	SELECT generate_series(
		(SELECT MIN(DATE_TRUNC('month', transaction_date)) FROM transactions),
		(SELECT MAX(DATE_TRUNC('month', transaction_date)) FROM transactions),
		interval '1 month'
)::date AS date
),

account AS (
	SELECT DISTINCT account_id FROM transactions
),

account_month AS (
	SELECT a.account_id, m.date
	FROM account a
	CROSS JOIN months m
	ORDER BY a.account_id, m.date
),
--ON deposits
deposit AS (
	SELECT  account_id,
			DATE_TRUNC('month',	transaction_date)::date AS date,
			SUM(amount) AS total_deposits
	FROM transactions
	WHERE transaction_type = 'Deposit'
	GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

cumulative_d AS (
	SELECT  *,
			SUM(total_deposits) OVER (PARTITION BY account_id ORDER BY date) AS cumulative_deposit,
			AVG(total_deposits) OVER (PARTITION BY account_id) AS avg_deposit
	FROM deposit
),

--ON withdrawal
withdrawal AS (
	SELECT  account_id,
			DATE_TRUNC('month',	transaction_date)::date AS date,
			SUM(amount) AS total_withdrawals
	FROM transactions
	WHERE transaction_type = 'Withdrawal'
	GROUP BY account_id, DATE_TRUNC('month', transaction_date)
),

cumulative_w AS (
	SELECT  *,
			SUM(total_withdrawals) OVER (PARTITION By account_id ORDER BY date) AS cumulative_withdrawal,
			AVG(total_withdrawals) OVER (PARTITION BY account_id) AS avg_withdrawal
	FROM withdrawal
),

overall AS (
	SELECT  am.account_id AS users,
			am.date AS date,
			COALESCE(total_deposits, 0) AS total_deposits,
			COALESCE(cumulative_deposit, 0) AS cumulative_deposit,
			COALESCE(total_withdrawals, 0) AS total_withdrawals,
			COALESCE(cumulative_withdrawal, 0) AS cumulative_withdrawal,
			COALESCE(total_deposits, 0) - COALESCE(total_withdrawals, 0) AS monthly_net_flow,
			SUM(COALESCE(total_deposits, 0) - COALESCE(total_withdrawals, 0))
	   			 OVER (PARTITION BY am.account_id ORDER BY am.date) AS cumulative_balance,
			COALESCE(ROUND(total_deposits/NULLIF(total_withdrawals, 0), 2), 0) AS multiplier,
			CASE
				WHEN total_deposits > 2 * avg_deposit THEN 'Unusually High deposit'
				ELSE 'Not that high deposit'
			END AS deposit_flag,
			CASE
				WHEN total_withdrawals > 2 * avg_withdrawal THEN 'Unusually High Withdrawal'
				ELSE 'Not that high withdrawal'
			END AS withdrawal_flag
	FROM account_month am
	LEFT JOIN cumulative_d cd ON am.account_id = cd.account_id
								AND am.date = cd.date
	LEFT JOIN cumulative_w cw ON am.account_id = cw.account_id
								AND am.date = cw.date
)

SELECT  *,
		CASE
	    WHEN total_deposits = 0 AND total_withdrawals = 0 THEN 'Dormant'
	    WHEN deposit_flag = 'Unusually High deposit' OR withdrawal_flag = 'Unusually High Withdrawal' THEN 'Anomalous'
	    WHEN monthly_net_flow >= 1500 THEN 'High Activity'
	    WHEN monthly_net_flow < 500 THEN 'Low Activity'
	    ELSE 'Normal'
END AS activity_category
FROM overall
;

/* =========================================================
   8. SEGMENTATION
   ========================================================= */
WITH flag_table AS (
	SELECT  users,
			ROUND(AVG(monthly_net_flow), 2) AS avg_netflow,
			COUNT (*) AS number_of_month,
			COUNT (*) FILTER(WHERE monthly_net_flow > 0) AS number_of_positives,
			COUNT (*) FILTER(WHERE monthly_net_flow < 0) AS number_of_negatives,
			COUNT (*) FILTER(WHERE total_deposits = 0 AND total_withdrawals = 0) AS number_of_dormant,
			COUNT (*) FILTER(WHERE deposit_flag = 'Unusually High deposit' OR withdrawal_flag = 'Unusually High Withdrawal') AS number_of_anomalous
	FROM account_month_metrics
	GROUP BY users
)

SELECT 	users,
		CASE
			WHEN number_of_dormant::DECIMAL/NULLIF(number_of_month, 0) * 100 > 50 THEN 'Dormant'
			WHEN number_of_anomalous > 0 THEN 'Anomalous'
			WHEN number_of_positives > number_of_negatives THEN 'Saver'
			WHEN number_of_positives < number_of_negatives THEN 'Spender'
			ELSE 'Balanced'
		END AS segment
FROM flag_table;

/* =========================================================
   9. RISK & RETENTION
   ========================================================= */
/*For this example im going to take this statements
High risk: mostly negative net flow months, or many anomalous months, or low cumulative balance.
Medium risk: mixed behavior, some negative months or occasional anomalies.
Low risk: mostly positive net flow, few anomalies, stable balance.*/
WITH flag_table AS (
	SELECT  users,
			ROUND(AVG(monthly_net_flow), 2) AS avg_netflow,
			COUNT (*) AS number_of_month,
			COUNT (*) FILTER(WHERE monthly_net_flow > 0) AS number_of_positives,
			COUNT (*) FILTER(WHERE monthly_net_flow < 0) AS number_of_negatives,
			COUNT (*) FILTER(WHERE total_deposits = 0 AND total_withdrawals = 0) AS number_of_dormant,
			COUNT (*) FILTER(WHERE deposit_flag = 'Unusually High deposit' OR withdrawal_flag = 'Unusually High Withdrawal') AS number_of_anomalous
	FROM account_month_metrics
	GROUP BY users
),

last_cumulative AS (
  SELECT DISTINCT ON (users)
         users,
         cumulative_balance
  FROM account_month_metrics
  ORDER BY users, date DESC
),

risk_metrics AS (
	SELECT  ft.users AS users, 
			avg_netflow,
			ROUND(number_of_negatives/number_of_month::DECIMAL * 100, 2) AS perc_negative_month,
			ROUND(number_of_anomalous/number_of_month::DECIMAL * 100, 2) AS perc_anomalous_month,
			ROUND(number_of_dormant/number_of_month::DECIMAL * 100, 2) AS perc_dormant_month,
			cumulative_balance
	FROM flag_table ft
	JOIN last_cumulative lc ON ft.users = lc.users
)

SELECT  users,
		avg_netflow,
		perc_negative_month,
		perc_anomalous_month,
		cumulative_balance,
		CASE
			WHEN perc_negative_month > 50 OR perc_anomalous_month > 25 OR cumulative_balance < 0 THEN 'High risk'
			WHEN perc_negative_month BETWEEN 20 AND 50 AND cumulative_balance >= 0 THEN 'Medium risk'
			WHEN perc_negative_month < 20 AND cumulative_balance > 0 THEN 'Low risk'
		END AS risk,
		CASE 
			WHEN perc_dormant_month > 50 THEN 'Dormant'
			WHEN avg_netflow > 800 THEN 'High'
			WHEN avg_netflow < 400 THEN 'Low'
			ELSE 'Balance'
		END AS retention
FROM risk_metrics;
