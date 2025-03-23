SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

--
SELECT 
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method;

--

SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

--

SELECT MAX(quantity) FROM walmart;

-- Business problem
-- Q.1 Find diffrent payment method and number of transaction, number of qty sold

SELECT 
	payment_method,
	COUNT(*) AS no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;


-- Q.2: Indentify the highest-rated category in each branch, displaying the branch, category
-- AVG rating

SELECT *
FROM 
	(SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank=1;



-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'Day') AS day_name,
		COUNT(*) as number_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2)
WHERE RANK = 1;


-- Q.4 Calculate the total qunatity of items sold per payment method. List payment_method and total_quantity.
SELECT 
	payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;




-- Q.5 Determine the average, minimun and maximum rating of category for each city, list of city, average_rating, min_rating and max_rating.
SELECT 
	city,
	category,
	MIN(rating) as min_rating, 
	MAX(rating) as max_rating, 
	AVG(rating) as avg_rating 
FROM walmart
GROUP BY 1, 2;


-- Q.6 Calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). 
-- List category and total_pprofit, odered form highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1;


-- Q.7 Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method.
WITH cte
AS
	(SELECT 
		branch,
		payment_method,
		COUNT(*) as total_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1,2)
SELECT *
FROM cte
WHERE rank = 1;

-- Q.8 Categorize sales into 3 group MORNING, AFTERNOOON, EVENING.
-- Find out each of the shift and number of invoices

SELECT  
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12  AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;


-- Identify 5 branch with highest decrease ratio in evevenue compare to 
-- last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart;

--2022 
WITH revenue_2022
AS
	(SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1),

revenue_2023
AS
	(SELECT
			branch,
			SUM(total) as revenue
		FROM walmart
		WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
		GROUP BY 1)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_renvenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		 ls.revenue::numeric * 100,
		 2) AS rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;



























