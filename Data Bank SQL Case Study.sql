use data_bank;


-- 1)How many different nodes make up the Data Bank network?

SELECT 
    COUNT(DISTINCT node_id) AS Unique_nodes
FROM
    customer_nodes;

-- 2) How many nodes are there in each region?
SELECT 
    region_id, COUNT(node_id) AS node_count
FROM
    customer_nodes
        INNER JOIN
    regions USING (region_id)
GROUP BY region_id;

-- 3) How many customers are divided among the regions?
SELECT 
    region_id, COUNT(DISTINCT customer_id) AS distinct_customers
FROM
    customer_nodes
        INNER JOIN
    regions USING (region_id)
GROUP BY region_id;

-- 4) Determine the total amount of transactions for each region name.
SELECT 
    region_name, SUM(txn_amount) AS 'total transaction amount'
FROM
    regions,
    customer_nodes,
    customer_transactions
WHERE
    regions.region_id = customer_nodes.region_id
        AND customer_nodes.customer_id = customer_transactions.customer_id
GROUP BY region_name;

-- 5) How long does it take on an average to move clients to a new node?

SELECT 
    ROUND(AVG(DATEDIFF(end_date, start_date)), 2) AS avg_days
FROM
    customer_nodes
WHERE
    end_date != '9999-12-31';

-- 6) What is the unique count and total amount for each transaction type?

SELECT 
    txn_type,
    COUNT(*) AS unique_count,
    SUM(txn_amount) AS total_amount
FROM
    customer_transactions
GROUP BY txn_type;

-- 7) What is the average number and size of past deposits across all customers?

SELECT 
    ROUND(COUNT(customer_id) / (SELECT 
                    COUNT(DISTINCT customer_id)
                FROM
                    customer_transactions)) AS average_deposit_amount
FROM
    customer_transactions
WHERE
    txn_type = 'deposit';

-- 8) For each month - how many Data Bank customers make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month? 

WITH transaction_count_per_month_cte AS
(SELECT 
    customer_id,
    MONTH(txn_date) AS txn_month,
    SUM(IF(txn_type = 'deposit', 1, 0)) AS deposit_count,
    SUM(IF(txn_type = 'withdrawal', 1, 0)) AS withdrawal_count,
    SUM(IF(txn_type = 'purchase', 1, 0)) AS purchase_count
FROM
    customer_transactions
GROUP BY customer_id , MONTH(txn_date))

SELECT 
    txn_month, COUNT(DISTINCT customer_id) AS customer_count
FROM
    transaction_count_per_month_cte
WHERE
    deposit_count > 1
        AND (purchase_count = 1
        OR withdrawal_count = 1)
GROUP BY txn_month;

























