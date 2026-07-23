-- ============================================================
-- BANK TRANSACTION ANALYZER
-- Author: Ishtiaque Rahman Wasee | Tokyo International University
-- Dataset: data/transactions.csv
-- Tool: SQLite (DB Browser for SQLite)
-- ============================================================

-- STEP 1: Check your data first (always do this!)
-- -------------------------------------------------------
SELECT * FROM transactions LIMIT 10;

-- STEP 2: How many transactions do we have?
-- -------------------------------------------------------
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- STEP 3: What is the total amount spent vs earned?
-- -------------------------------------------------------
SELECT transaction_type,
       COUNT(*) AS count,
       ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY transaction_type;

-- ============================================================
-- ANALYSIS 1: Spending by Category
-- Which category costs the most?
-- ============================================================
SELECT category,
       COUNT(*) AS transaction_count,
       ROUND(SUM(amount), 2) AS total_spent,
       ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
WHERE transaction_type = 'debit'
GROUP BY category
ORDER BY total_spent DESC;

-- ============================================================
-- ANALYSIS 2: Monthly Spending Trend
-- How does spending change month by month?
-- ============================================================
SELECT strftime('%Y-%m', date) AS month,
       COUNT(*) AS num_transactions,
       ROUND(SUM(amount), 2) AS monthly_total
FROM transactions
WHERE transaction_type = 'debit'
GROUP BY month
ORDER BY month;

-- ============================================================
-- ANALYSIS 3: Top 5 Merchants by Total Spend
-- Where does most money go?
-- ============================================================
SELECT merchant,
       category,
       COUNT(*) AS visits,
       ROUND(SUM(amount), 2) AS total_spent
FROM transactions
WHERE transaction_type = 'debit'
GROUP BY merchant, category
ORDER BY total_spent DESC
LIMIT 5;

-- ============================================================
-- ANALYSIS 4: Average Transaction Size by Category
-- Which category has the biggest single purchases?
-- ============================================================
SELECT category,
       ROUND(AVG(amount), 2) AS avg_transaction,
       ROUND(MIN(amount), 2) AS smallest,
       ROUND(MAX(amount), 2) AS largest
FROM transactions
WHERE transaction_type = 'debit'
GROUP BY category
ORDER BY avg_transaction DESC;

-- ============================================================
-- ANALYSIS 5: Top 10 Largest Single Transactions
-- What are the biggest individual purchases?
-- ============================================================
SELECT date,
       merchant,
       category,
       amount
FROM transactions
WHERE transaction_type = 'debit'
ORDER BY amount DESC
LIMIT 10;

-- ============================================================
-- ANALYSIS 6: Monthly Savings (Income minus Spending)
-- Am I saving money each month?
-- ============================================================
SELECT month,
       ROUND(SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END), 2) AS income,
       ROUND(SUM(CASE WHEN transaction_type = 'debit'  THEN amount ELSE 0 END), 2) AS expenses,
       ROUND(
           SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END) -
           SUM(CASE WHEN transaction_type = 'debit'  THEN amount ELSE 0 END),
       2) AS monthly_savings
FROM (
    SELECT strftime('%Y-%m', date) AS month,
           transaction_type,
           amount
    FROM transactions
) AS monthly_data
GROUP BY month
ORDER BY month;

-- ============================================================
-- ANALYSIS 7: Spending by Day of Week
-- Which day do I spend the most?
-- ============================================================
SELECT CASE strftime('%w', date)
           WHEN '0' THEN '1_Sunday'
           WHEN '1' THEN '2_Monday'
           WHEN '2' THEN '3_Tuesday'
           WHEN '3' THEN '4_Wednesday'
           WHEN '4' THEN '5_Thursday'
           WHEN '5' THEN '6_Friday'
           WHEN '6' THEN '7_Saturday'
       END AS day_of_week,
       COUNT(*) AS transactions,
       ROUND(SUM(amount), 2) AS total_spent
FROM transactions
WHERE transaction_type = 'debit'
GROUP BY day_of_week
ORDER BY day_of_week;

-- ============================================================
-- ANALYSIS 8: Category Breakdown as % of Total Spending
-- What percentage of budget goes to each category?
-- ============================================================
SELECT category,
       ROUND(SUM(amount), 2) AS total_spent,
       ROUND(
           SUM(amount) * 100.0 /
           (SELECT SUM(amount) FROM transactions WHERE transaction_type = 'debit'),
       2) AS percentage_of_total
FROM transactions
WHERE transaction_type = 'debit'
GROUP BY category
ORDER BY percentage_of_total DESC;
