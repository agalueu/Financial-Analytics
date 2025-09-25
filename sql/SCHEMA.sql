DROP TABLE IF EXISTS transactions;

CREATE TABLE IF NOT EXISTS transactions (
transaction_id SERIAL PRIMARY KEY,
account_id INT NOT NULL,
transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
transaction_type TEXT NOT NULL,
amount DECIMAL (15,2),  CHECK (amount >= 0),
currency VARCHAR (5) DEFAULT 'usd',
category TEXT
);


INSERT INTO transactions (account_id, transaction_date, transaction_type, amount, currency, category)
VALUES 
(1001, '2025-01-02', 'Deposit', 2500, 'USD', 'Salary'),
(1002, '2025-01-03', 'Withdrawal', 150, 'USD', 'Groceries'),
(1003, '2025-01-05', 'Deposit', 1200, 'USD', 'Freelance'),
(1001, '2025-01-07', 'Withdrawal', 300, 'USD', 'Rent'),
(1002, '2025-01-10', 'Withdrawal', 50, 'USD', 'Transport'),
(1003, '2025-01-12', 'Deposit', 500, 'USD', 'Investment'),
(1001, '2025-01-15', 'Withdrawal', 200, 'USD', 'Utilities'),
(1002, '2025-01-18', 'Deposit', 1800, 'USD', 'Salary'),
(1003, '2025-01-20', 'Withdrawal', 100, 'USD', 'Entertainment'),
(1001, '2025-01-22', 'Deposit', 700, 'USD', 'Freelance'),
(1002, '2025-01-25', 'Withdrawal', 400, 'USD', 'Rent'),
(1003, '2025-01-28', 'Deposit', 300, 'USD', 'Investment'),
(1001, '2025-01-30', 'Withdrawal', 150, 'USD', 'Groceries'),
(1001, '2025-02-02', 'Deposit', 3500, 'USD', 'Salary'),
(1002, '2025-02-03', 'Withdrawal', 250, 'USD', 'Groceries'),
(1003, '2025-03-05', 'Deposit', 1800, 'USD', 'Freelance'),
(1001, '2025-05-07', 'Withdrawal', 900, 'USD', 'Rent'),
(1001, '2025-06-07', 'Withdrawal', 500, 'USD', 'Rent'),
(1002, '2025-04-10', 'Withdrawal', 50, 'USD', 'Transport'),
(1003, '2025-03-12', 'Deposit', 500, 'USD', 'Investment'),
(1001, '2025-02-15', 'Withdrawal', 700, 'USD', 'Utilities'),
(1002, '2025-04-18', 'Deposit', 3800, 'USD', 'Salary'),
(1003, '2025-04-20', 'Withdrawal', 200, 'USD', 'Entertainment'),
(1001, '2025-03-22', 'Deposit', 1700, 'USD', 'Freelance'),
(1002, '2025-04-25', 'Withdrawal', 5700, 'USD', 'Rent'),
(1002, '2025-05-03', 'Withdrawal', 3250, 'USD', 'Groceries'),
(1003, '2025-03-28', 'Deposit', 2300, 'USD', 'Investment'),
(1001, '2025-04-30', 'Withdrawal', 750, 'USD', 'Groceries');
