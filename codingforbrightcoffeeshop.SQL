-- cleaned data(did not work and I am using the raw data)
SELECT
    transaction_id,
    transaction_date,
    TRY_CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) AS unit_price_fixed,
    transaction_qty,
    (TRY_CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) * transaction_qty) AS total_amount,
    CASE 
        WHEN HOUR(TO_TIME(transaction_time)) < 7 THEN 'Before 7AM'
        WHEN HOUR(TO_TIME(transaction_time)) BETWEEN 7 AND 9 THEN '7AM - 10AM (Morning Rush)'
        WHEN HOUR(TO_TIME(transaction_time)) BETWEEN 10 AND 12 THEN '10AM - 1PM (Lunch)'
        WHEN HOUR(TO_TIME(transaction_time)) BETWEEN 13 AND 16 THEN '1PM - 4PM (Afternoon)'
        WHEN HOUR(TO_TIME(transaction_time)) > 16 THEN 'After 4PM'
        ELSE 'Other'
    END AS transaction_time_bucket,
    TO_TIME(transaction_time) as original_time,
    product_category,
    product_type,
    product_detail,
    store_location
FROM brightcoffeeanalysis.brightcoffee.coffee;

--Top revenue drivers
SELECT 
    product_type, 
    SUM(unit_price * transaction_qty) AS total_revenue
FROM brightcoffeeanalysis.brightcoffee.coffee
GROUP BY product_type
ORDER BY total_revenue DESC;

--Peak operational hours--
SELECT 
    CASE 
        WHEN HOUR(TO_TIME(transaction_time)) < 7 THEN 'Before 7AM'
        WHEN HOUR(TO_TIME(transaction_time)) BETWEEN 7 AND 9 THEN '7AM - 10AM (Morning Rush)'
        WHEN HOUR(TO_TIME(transaction_time)) BETWEEN 10 AND 12 THEN '10AM - 1PM (Lunch)'
        WHEN HOUR(TO_TIME(transaction_time)) BETWEEN 13 AND 16 THEN '1PM - 4PM (Afternoon)'
        WHEN HOUR(TO_TIME(transaction_time)) > 16 THEN 'After 4PM'
        ELSE 'Other'
    END AS transaction_time_bucket,
    COUNT(transaction_id) AS total_transactions,
    SUM(TRY_CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) * transaction_qty) AS total_revenue
FROM BRIGHTCOFFEEANALYSIS.BRIGHTCOFFEE.COFFEE
GROUP BY 1 
ORDER BY total_revenue DESC;


--Sales Volume (Best Selling Categories)
SELECT 
    product_category, 
    SUM(transaction_qty) AS total_units_sold
FROM brightcoffeeanalysis.brightcoffee.coffee
GROUP BY product_category
ORDER BY total_units_sold DESC;

--Weekday vs. Weekend Performance
SELECT 
    DAYNAME(transaction_date) AS day_of_week,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(TRY_CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) * transaction_qty) AS total_revenue,
    AVG(TRY_CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) * transaction_qty) AS average_order_value
FROM brightcoffeeanalysis.brightcoffee.coffee
GROUP BY DAYNAME(transaction_date), DAYOFWEEK(transaction_date)
ORDER BY DAYOFWEEK(transaction_date);

--SALES PER STORE
SELECT 
    store_location,
    SUM(TRY_CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) * transaction_qty) AS total_revenue
FROM brightcoffeeanalysis.brightcoffee.coffee
GROUP BY store_location
ORDER BY total_revenue DESC;
