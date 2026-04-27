DROP TABLE IF EXISTS transactions;

CREATE TABLE IF NOT EXISTS transactions (
transaction_id SERIAL PRIMARY KEY,
account_id INT NOT NULL,
transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
transaction_type TEXT NOT NULL CHECK (transaction_type IN ('Deposit','Withdrawal')),
amount DECIMAL (15,2) NOT NULL CHECK (amount >= 0),
currency VARCHAR (5) NOT NULL DEFAULT 'USD',
category TEXT
);
