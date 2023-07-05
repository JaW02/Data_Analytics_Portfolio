USE mavenfuzzyfactory;

-- PRODUCT LEVEL SALES ANALYSIS
-- Sales Trends
SELECT 
    Year(created_at) as yr,
    Month(created_at) as mnth,
    count(distinct order_id) as number_of_sales,
    sum(price_usd) as total_revenue,
    sum(price_usd-cogs_usd) as total_margin
FROM
    orders
WHERE
    created_at < '2013-01-04'
GROUP BY yr, mnth;

-- Impact of new product launch
SELECT 
    YEAR(ws.created_at) as yr,
    MONTH(ws.created_at) as mnth,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as conv_rate,
    sum(o.price_usd) / count(distinct ws.website_session_id) as rev_per_session,
    count(distinct case when o.primary_product_id=1 then o.website_session_id else null end) as prod_one_orders,
    count(distinct case when o.primary_product_id=2 then o.website_session_id else null end) as prod_two_orders
FROM
	website_sessions ws
		left join
    orders o on o.website_session_id=ws.website_session_id
where ws.created_at between '2012-04-01' and '2013-04-05'
GROUP BY yr, mnth
;

-- USER PATHING 
create temporary table pre_product_2_launch
select
	'pre_product_2' as time_period,
    count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as sessions,
    count(distinct case when wp.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear') then wp.website_session_id else null end) as w_next_pg,
    count(distinct case when wp.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear') then wp.website_session_id else null end) /
		count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as pct_w_next_page,
	count(distinct case when wp.pageview_url='/the-original-mr-fuzzy' then wp.website_session_id else null end) as to_mrfuzzy,
    count(distinct case when wp.pageview_url='/the-original-mr-fuzzy' then wp.website_session_id else null end) /
		count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as pct_to_mrfuzzy,
	count(distinct case when wp.pageview_url='/the-forever-love-bear' then wp.website_session_id else null end) as to_lovebear,
    count(distinct case when wp.pageview_url='/the-forever-love-bear' then wp.website_session_id else null end) /
		count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as pct_to_lovebear
FRom
	-- website sessions that contain /products page
	(SELECT 
		website_session_id,
		pageview_url
	FROM
		website_pageviews
	WHERE
		created_at BETWEEN '2012-10-06' AND '2013-01-06'
		and pageview_url = '/products') as ps
	Left Join
    website_pageviews wp ON wp.website_session_id=ps.website_session_id
;
create temporary table post_product_2_launch
select
	'post_product_2' as time_period,
    count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as sessions,
    count(distinct case when wp.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear') then wp.website_session_id else null end) as w_next_pg,
    count(distinct case when wp.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear') then wp.website_session_id else null end) /
		count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as pct_w_next_page,
	count(distinct case when wp.pageview_url='/the-original-mr-fuzzy' then wp.website_session_id else null end) as to_mrfuzzy,
    count(distinct case when wp.pageview_url='/the-original-mr-fuzzy' then wp.website_session_id else null end) /
		count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as pct_to_mrfuzzy,
	count(distinct case when wp.pageview_url='/the-forever-love-bear' then wp.website_session_id else null end) as to_lovebear,
    count(distinct case when wp.pageview_url='/the-forever-love-bear' then wp.website_session_id else null end) /
		count(distinct case when wp.pageview_url='/products' then wp.website_session_id else null end) as pct_to_lovebear
from
	-- website sessions that contain /products page
	(SELECT 
		website_session_id,
		pageview_url
	FROM
		website_pageviews
	WHERE
		created_at BETWEEN '2013-01-06' and '2013-04-06'
		and pageview_url = '/products') as ps
	Left Join
    website_pageviews wp ON wp.website_session_id=ps.website_session_id;


SELECT 
    *
FROM
    pre_product_2_launch 
UNION SELECT 
    *
FROM
    post_product_2_launch
;

-- Product Conversion Funnels
-- mr fuzzy session page flags
create temporary table mr_fuzzy_session_flags
select
	mf.website_session_id,
    mf.pageview_url,
    'mr_fuzzy' as product_seen,
	-- max(case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end) as sessions,
	max(case when wp.pageview_url = '/cart' then 1 else 0 end) as to_cart,
    max(case when wp.pageview_url = '/shipping' then 1 else 0 end) as to_shipping,
    max(case when wp.pageview_url = '/billing-2' then 1 else 0 end) as to_billing,
    max(case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as to_thankyou
FROM
	(SELECT 
		website_session_id,
        website_pageview_id,
        pageview_url
	FROM
		website_pageviews
	WHERE
		created_at BETWEEN '2013-01-06' AND '2013-04-10'
		AND pageview_url='/the-original-mr-fuzzy') as mf
	LEFT JOIN
		website_pageviews wp on wp.website_session_id=mf.website_session_id
GROUP BY wp.website_session_id;

-- lovebear session page flags
create temporary table lovebear_session_flags
select
	lb.website_session_id,
    lb.pageview_url,
    'lovebear' as product_seen,
	-- MAX(case when wp.pageview_url = '/the-forever-love-bear' then 1 else 0 end) as sessions,
	MAX(case when wp.pageview_url = '/cart' then 1 else 0 end) as to_cart,
    MAX(case when wp.pageview_url = '/shipping' then 1 else 0 end) as to_shipping,
    MAX(case when wp.pageview_url in ('/billing','/billing-2') then 1 else 0 end) as to_billing,
    MAX(case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as to_thankyou
FROM
	(SELECT 
		website_session_id,
        website_pageview_id,
        pageview_url
	FROM
		website_pageviews
	WHERE
		created_at BETWEEN '2013-01-06' AND '2013-04-10'
		AND pageview_url='/the-forever-love-bear') as lb
	LEFT JOIN
		website_pageviews wp on wp.website_session_id=lb.website_session_id
GROUP BY wp.website_session_id;

create temporary table product_sessions
select
	product_seen,
    count(distinct website_session_id) as sessions,
    count(distinct case when to_cart=1 then website_session_id else null end) as to_cart,
    count(distinct case when to_shipping=1 then website_session_id else null end) as to_shipping,
    count(distinct case when to_billing=1 then website_session_id else null end) as to_billing,
    count(distinct case when to_thankyou=1 then website_session_id else null end) as to_thankyou
FROM
	mr_fuzzy_session_flags
UNION SELECT
	product_seen,
    count(distinct website_session_id) as sessions,
    count(distinct case when to_cart=1 then website_session_id else null end) as to_cart,
    count(distinct case when to_shipping=1 then website_session_id else null end) as to_shipping,
    count(distinct case when to_billing=1 then website_session_id else null end) as to_billing,
    count(distinct case when to_thankyou=1 then website_session_id else null end) as to_thankyou
FROM
	lovebear_session_flags;

-- click through rates
select
	product_seen,
    to_cart / sessions as product_ctr,
    to_shipping / to_cart as cart_ctr,
    to_billing / to_shipping as shipping_ctr,
    to_thankyou / to_billing as billing_ctr
from
	product_sessions;
    
-- CROSS-SELL ANALYSIS
-- Cross Selling Performance

-- cart sesions
create temporary table seen_cart_sessions
SELECT 
    website_pageview_id,
    website_session_id,
    pageview_url,
    case
		when created_at < '2013-09-25' then 'Pre_Cross_Sell'
        when created_at >= '2013-01-06' then 'Post_Cross_Sell'
        else null
	end as time_period
FROM
    website_pageviews 
WHERE
    created_at BETWEEN '2013-08-25' AND '2013-10-25'
    AND pageview_url='/cart';
    
select 
	cs.time_period,
    count(distinct case when wp.pageview_url='/cart' then wp.website_session_id else null end) as cart_sessions,
    count(distinct case when wp.pageview_url='/shipping' then wp.website_session_id else null end) as click_throughs,
    count(distinct case when wp.pageview_url='/shipping' then wp.website_session_id else null end) / 
	count(distinct case when wp.pageview_url='/cart' then wp.website_session_id else null end) as cart_ctr,
	sum(case when wp.pageview_url='/cart' then o.items_purchased end) / count(distinct o.order_id) as products_per_order,
    avg(o.price_usd) as aov,
    sum(case when wp.pageview_url='/cart' then o.price_usd end) / 
		count(distinct case when wp.pageview_url='/cart' then wp.website_session_id else null end) as rev_per_cart_session
from
	seen_cart_sessions cs
		left join
	website_pageviews wp on wp.website_session_id=cs.website_session_id
    and wp.website_pageview_id>=cs.website_pageview_id
		left join
	orders o on o.website_session_id=cs.website_session_id
GROUP BY cs.time_period
order by cs.time_period DESC;

-- PORTFOLIO EXPANSION ANALYSIS
SELECT 
	case
		when wp.created_at < '2013-12-12' then 'Pre_Birthday_Bear'
        when wp.created_at >= '2013-12-12' then 'Post_Birthday_Bear'
        else null
	end as time_period,
    count(distinct o.order_id) / count(distinct wp.website_session_id) as conv_rate,
    AVG(o.price_usd) as aov,
    sum(case when wp.pageview_url='/thank-you-for-your-order' then o.items_purchased end) / 
		count(distinct o.order_id) as products_per_order,
    sum(case when wp.pageview_url='/thank-you-for-your-order' then o.price_usd end) / 
		count(distinct wp.website_session_id) as revenue_per_session
FROM
    website_pageviews wp
		LEFT JOIN
	orders o on o.website_session_id=wp.website_session_id
WHERE
    wp.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY time_period
ORDER BY time_period DESC;

-- ANALYZING REFUND RATES
SELECT 
	YEAR(oi.created_at) as yr,
    MONTHNAME(oi.created_at) as mnth,
    count(distinct case when oi.product_id=1 then oi.order_item_id else null end) as p1_orders,
    count(distinct case when oi.product_id=1 then oir.order_item_refund_id else null end) /
		count(distinct case when oi.product_id=1 then oi.order_item_id else null end) as p1_refund_rate,
	count(distinct case when oi.product_id=2 then oi.order_item_id else null end) as p2_orders,
    count(distinct case when oi.product_id=2 then oir.order_item_refund_id else null end) /
		count(distinct case when oi.product_id=2 then oi.order_item_id else null end) as p2_refund_rate,
	count(distinct case when oi.product_id=3 then oi.order_item_id else null end) as p3_orders,
    count(distinct case when oi.product_id=3 then oir.order_item_refund_id else null end) /
		count(distinct case when oi.product_id=3 then oi.order_item_id else null end) as p3_refund_rate,
	count(distinct case when oi.product_id=4 then oi.order_item_id else null end) as p4_orders,
    count(distinct case when oi.product_id=4 then oir.order_item_refund_id else null end) /
		count(distinct case when oi.product_id=4 then oi.order_item_id else null end) as p4_refund_rate
FROM
    order_items oi
		left join
	order_item_refunds oir on oir.order_item_id = oi.order_item_id
WHERE
    oi.created_at < '2014-10-15'
GROUP BY yr, MONTH(oi.created_at);
