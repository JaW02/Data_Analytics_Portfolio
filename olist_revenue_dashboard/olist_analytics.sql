USE olist_store;

-- STORED PROCEDURE FOR TOTAL MONTHLY REVENUE
DELIMITER //
CREATE PROCEDURE total_monthly_revenue()
BEGIN
	SELECT
		MONTHNAME(o.order_purchase_timestamp) as month_,
		ROUND(SUM(op.payment_value),2) as revenue
	FROM
		orders o
			JOIN
		order_payments op ON o.order_id = op.order_id
	WHERE o.order_status = 'delivered'
			AND YEAR(o.order_approved_at) NOT LIKE 2016
	GROUP BY month_
	ORDER BY MONTH(o.order_purchase_timestamp);
END //
DELIMITER ;

CALL total_monthly_revenue();

-- TOTAL MONTHLY REVENUE BY YEAR
SELECT 
    YEAR(o.order_purchase_timestamp) AS year_,
    MONTHNAME(o.order_purchase_timestamp) AS month_,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
    orders o
        JOIN
    order_payments op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_approved_at) NOT LIKE 2016
GROUP BY year_ , month_
ORDER BY year_ , MONTH(o.order_purchase_timestamp)
;

-- TOTAL MONTHLY REVENUE BY YEAR INCLUDING STATE
SELECT 
    YEAR(o.order_purchase_timestamp) AS year_,
    MONTHNAME(o.order_purchase_timestamp) AS month_,
    ROUND(SUM(op.payment_value), 2) AS revenue,
    c.customer_state as state
FROM
    orders o
        JOIN
    order_payments op ON o.order_id = op.order_id
		JOIN
	customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_approved_at) NOT LIKE 2016
GROUP BY year_ , month_, state
ORDER BY year_ , MONTH(o.order_purchase_timestamp), state
;

-- TOTAL MONTHLY REVENUE BY YEAR INCLUDING STATE, LAST 6 MONTHS
SELECT 
    YEAR(o.order_purchase_timestamp) AS year_,
    MONTHNAME(o.order_purchase_timestamp) AS month_,
    ROUND(SUM(op.payment_value), 2) AS revenue,
    c.customer_state as state
FROM
    orders o
        JOIN
    order_payments op ON o.order_id = op.order_id
		JOIN
	customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) LIKE 2018
GROUP BY year_ , month_, state
HAVING month_ NOT IN ('January', 'February')
ORDER BY year_ , MONTH(o.order_purchase_timestamp), state
;

-- MONTHLY REVENUE TIMESERIES
SELECT 
    o.order_purchase_timestamp AS date_,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
    orders o
        JOIN
    order_payments op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_approved_at) NOT LIKE 2016
GROUP BY YEAR(date_) , MONTH(date_)
ORDER BY date_
;

-- REVENUE TIMESERIES
SELECT 
    o.order_purchase_timestamp AS date_,
    #ROUND(SUM(op.payment_value), 2) AS revenue
    ROUND(op.payment_value, 2) AS revenue
FROM
    orders o
        JOIN
    order_payments op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_approved_at) NOT LIKE 2016
#GROUP BY DAY(date_) , HOUR(date_)
ORDER BY date_
;

-- REVENUE TIMESERIES BY STATE
SELECT 
    o.order_purchase_timestamp AS date_,
    c.customer_state AS state,
    ROUND(op.payment_value, 2) AS revenue
FROM
    orders o
        JOIN
    order_payments op ON o.order_id = op.order_id
		JOIN
	customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_approved_at) NOT LIKE 2016
#GROUP BY state
ORDER BY date_
;

-- STORED PROCEDURE FOR TOTAL QUARTERLY REVENUE
DELIMITER //
CREATE PROCEDURE total_quarterly_revenue()
BEGIN
	SELECT
		QUARTER(o.order_purchase_timestamp) as quarter_,
		ROUND(SUM(op.payment_value), 2) AS revenue
	FROM
		orders o
			JOIN
		order_payments op ON o.order_id = op.order_id
	WHERE
		o.order_status = 'delivered'
			AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
	GROUP BY quarter_
	ORDER BY quarter_;
END //
DELIMITER ;

CALL total_quarterly_revenue();
        
-- TOTAL QUARTERLY REVENUE BY YEAR
SELECT
	YEAR(o.order_purchase_timestamp) AS year_,
	QUARTER(o.order_purchase_timestamp) as quarter_,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
	orders o
		JOIN
	order_payments op ON o.order_id = op.order_id
WHERE
	o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY year_, quarter_
ORDER BY year_, quarter_
;

-- TOTAL QUARTERLY REVENUE BY YEAR & STATE
SELECT
	YEAR(o.order_purchase_timestamp) AS year_,
	QUARTER(o.order_purchase_timestamp) as quarter_,
    ROUND(SUM(op.payment_value), 2) AS revenue,
    c.customer_state AS state
FROM
	orders o
		JOIN
	order_payments op ON o.order_id = op.order_id
		JOIN
	customers c ON o.customer_id = c.customer_id
WHERE
	o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY year_, quarter_, state
ORDER BY year_, quarter_, state
;

-- 2018 QUARTERLY REVENUE PERCENTAGE DIFFERENCE
SELECT 
    qrt_2017.quarter_,
    #qrt_2017.qrt_2017_rev,
    #qrt_2018.qrt_2018_rev,
    ROUND(((qrt_2018.qrt_2018_rev - qrt_2017.qrt_2017_rev) / qrt_2017.qrt_2017_rev) * 100,
            2) AS pct_diff_2018
FROM
    (SELECT 
        QUARTER(o.order_purchase_timestamp) AS quarter_,
            ROUND(SUM(op.payment_value), 2) AS qrt_2017_rev
    FROM
        orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) = 2017
    GROUP BY YEAR(o.order_purchase_timestamp) , quarter_
    HAVING quarter_ NOT LIKE 4
    ORDER BY YEAR(o.order_purchase_timestamp) , quarter_) AS qrt_2017
        JOIN
    (SELECT 
        QUARTER(o.order_purchase_timestamp) AS quarter_,
            ROUND(SUM(op.payment_value), 2) AS qrt_2018_rev
    FROM
        orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) = 2018
    GROUP BY YEAR(o.order_purchase_timestamp) , quarter_
    HAVING quarter_ NOT LIKE 4
    ORDER BY YEAR(o.order_purchase_timestamp) , quarter_) AS qrt_2018 ON qrt_2017.quarter_ = qrt_2018.quarter_
;

-- VIEW OF PRODUCT REVENUE
CREATE VIEW product_revenue AS
    SELECT 
        temp_1.product,
        temp_1.num_orders,
        temp_1.revenue,
        ROUND(temp_1.revenue * 100 / (SELECT 
                        ROUND(SUM(op.payment_value), 2)
                    FROM
                        order_payments op
                            JOIN
                        orders o ON op.order_id = o.order_id
                    WHERE
                        o.order_status = 'delivered'
                            AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016),
                2) AS pct_revenue
    FROM
        (SELECT 
            oi.order_id,
                p.product_category_name AS product,
                COUNT(p.product_category_name) AS num_orders,
                ROUND(SUM(op.payment_value), 2) AS revenue
        FROM
            orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        JOIN order_payments op ON oi.order_id = op.order_id
        WHERE
            o.order_status = 'delivered'
                AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
        GROUP BY product
        ORDER BY revenue DESC) AS temp_1
;
SELECT * FROM product_revenue;

-- PRODUCT REVENUE BY STATE
SELECT 
    temp_1.product,
    temp_1.num_orders,
    temp_1.revenue,
    temp_1.state,
    round(temp_1.revenue * 100 / state_tot_rev.revenue, 2) AS pct_revenue
		
FROM
    (SELECT 
        oi.order_id,
            p.product_category_name AS product,
            COUNT(p.product_category_name) AS num_orders,
            ROUND(SUM(op.payment_value), 2) AS revenue,
            c.customer_state AS state
    FROM
        orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN order_payments op ON oi.order_id = op.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
    GROUP BY product, state
    ORDER BY revenue DESC) AS temp_1
		JOIN
	(SELECT 
    c.customer_state AS state,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
        JOIN
    order_payments op ON oi.order_id = op.order_id
        JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY state) as state_tot_rev on temp_1.state = state_tot_rev.state
;


-- PRODUCT REVENUE TIME SERIES
SELECT 
	o.order_purchase_timestamp as date_,
	p.product_category_name AS product,
	COUNT(p.product_category_name) AS num_orders,
	ROUND(SUM(op.payment_value), 2) AS revenue
FROM
	orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN order_payments op ON oi.order_id = op.order_id
WHERE
	o.order_status = 'delivered'
		AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY YEAR(date_), MONTH(date_), product
ORDER BY date_
;


-- REVENUE BY PAYMENT METHOD
SELECT 
    p_type.*,
    ROUND(p_type.total_revenue * 100 / (SELECT 
                    ROUND(SUM(op.payment_value), 2)
                FROM
                    order_payments op
                        INNER JOIN
                    orders o ON op.order_id = o.order_id
                WHERE
                    o.order_status = 'delivered'
                        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016),
            0) AS pct_revenue
FROM
    (SELECT 
        c.customer_state AS state,
            op.payment_type,
            ROUND(SUM(op.payment_value), 2) AS total_revenue
    FROM
        order_payments op
    INNER JOIN orders o ON op.order_id = o.order_id
    INNER JOIN customers c ON o.customer_id = c.customer_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
    GROUP BY state , op.payment_type
    ORDER BY total_revenue DESC) AS p_type
;

-- VIEW OF REVENUE BY STATE
CREATE VIEW StateRevenue AS
    SELECT 
        YEAR(o.order_purchase_timestamp) AS year_,
        c.customer_state AS state,
        COUNT(c.customer_state) AS num_orders,
        ROUND(AVG(op.payment_value), 2) AS avg_order_value,
        ROUND(SUM(op.payment_value), 2) AS revenue
    FROM
        customers c
            JOIN
        orders o ON c.customer_id = o.customer_id
            JOIN
        order_payments op ON o.order_id = op.order_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
    GROUP BY year_ , state
    ORDER BY year_ , revenue DESC
;
SELECT * FROM StateRevenue;

-- REVENUE BY STATE GEOLOCATION
SELECT 
    c.customer_state as state,
    AVG(g.geolocation_lat) as latitude,
    AVG(g.geolocation_lng) as longitude,
    COUNT(c.customer_state) AS num_orders,
    ROUND(AVG(op.payment_value), 2) AS avg_order_value,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_payments op ON o.order_id = op.order_id
		JOIN
	geolocation g on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY state
order by revenue DESC
;

-- REVENUE BY STATE TIME SERIES
SELECT 
    o.order_purchase_timestamp AS date_,
    c.customer_state AS state,
    COUNT(c.customer_state) AS num_orders,
    ROUND(AVG(op.payment_value), 2) AS avg_order_value,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_payments op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY YEAR(date_), MONTH(date_), state
ORDER BY date_
;

-- REVENUE BY STATE & PAYMENT TYPE
SELECT 
    c.customer_state as state,
    op.payment_type,
    COUNT(c.customer_state) AS num_orders,
    ROUND(AVG(op.payment_value), 2) AS avg_order_value,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_payments op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY state, op.payment_type
order by state, revenue DESC
;

-- TOP 5 REVENUE BY PRODUCT AND STATE
SELECT
	sub_spr.state,
    sub_spr.product,
    sub_spr.revenue
FROM
	(SELECT 
		spr.state,
        spr.product,
        spr.revenue,
		ROW_NUMBER() OVER(PARTITION BY spr.state ORDER BY spr.revenue DESC) as row_num
	FROM
		(SELECT 
			c.customer_state AS state,
				p.product_category_name AS product,
				ROUND(SUM(op.payment_value), 2) AS revenue
		FROM
			customers c
		JOIN orders o ON c.customer_id = o.customer_id
		JOIN order_items oi ON o.order_id = oi.order_id
		JOIN products p ON oi.product_id = p.product_id
		JOIN order_payments op ON oi.order_id = op.order_id
		WHERE
			o.order_status = 'delivered'
				AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
		GROUP BY state , product
		ORDER BY state , revenue DESC
		) AS spr) AS sub_spr
WHERE row_num <= 5
;

-- STATE REVENUE DIFFERENCE 2017/2018
SELECT 
    state_rev_2017.state,
    state_rev_2017.rev_2017,
    state_rev_2018.rev_2018,
    ROUND(state_rev_2018.rev_2018 - state_rev_2017.rev_2017, 2) AS state_rev_diff
FROM
    (SELECT 
        c.customer_state AS state,
            ROUND(SUM(op.payment_value), 2) AS rev_2017
    FROM
        customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) = 2017
    GROUP BY state) AS state_rev_2017
        JOIN
    (SELECT 
        c.customer_state AS state,
            ROUND(SUM(op.payment_value), 2) AS rev_2018
    FROM
        customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE
        o.order_status = 'delivered'
            AND YEAR(o.order_purchase_timestamp) = 2018
    GROUP BY state) AS state_rev_2018 ON state_rev_2017.state = state_rev_2018.state
ORDER BY state_rev_diff DESC
;

-- QUARTERLY ORDERS TIME SERIES
SELECT 
    o.order_purchase_timestamp AS date_,
    COUNT(o.order_id) AS num_orders,
    c.customer_state AS state
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY YEAR(date_) , QUARTER(date_), state
ORDER BY date_
;

-- ORDERS MONTHLY TIME SERIES
SELECT 
    DATE(o.order_purchase_timestamp) AS date_,
    COUNT(o.order_id) AS num_orders,
    c.customer_state AS state
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY YEAR(date_), MONTH(date_), state
ORDER BY date_
;

-- CANCELED ORDERS
SELECT 
	o.order_purchase_timestamp as date_,
    count(o.order_id) as num_orders
FROM
    orders o
WHERE o.order_status = 'canceled'
		AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY date_
ORDER BY date_
;

-- HOUR OF DAY STATE PURCHASES
SELECT 
    c.customer_state AS state,
    ROUND(AVG(HOUR(o.order_purchase_timestamp))) AS avg_purchase_hour,
    FORMAT(STDDEV_SAMP(HOUR(o.order_purchase_timestamp)),
        2) AS std_ 
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'canceled'
        AND YEAR(o.order_purchase_timestamp) NOT LIKE 2016
GROUP BY state
ORDER BY avg_purchase_hour
;
