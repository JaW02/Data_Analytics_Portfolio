USE mavenfuzzyfactory;

-- ANALYZING CHANNEL PORTFOLIOS

-- Pull weekly trend session volume comparison for gsearch nonbrand and bsearch nonbrand
SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS gsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) AS bsearch_sessions
FROM
    website_sessions
WHERE
    created_at > '2012-08-22'
        AND created_at < '2012-11-29'
        AND utm_source IN ('gsearch' , 'bsearch')
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

-- Pull percentage of traffic coming on mobile for bsearch & gsearch nonbrand
SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_mob_sessions
FROM
    website_sessions
WHERE
    created_at > '2012-08-22'
        AND created_at < '2012-11-30'
        AND utm_campaign = 'nonbrand'
        AND utm_source IN ('gsearch' , 'bsearch')
GROUP BY utm_source;

-- Pull nonbrand conversion rates from session to order for gsearch & bsearch, and slice the data by device type from period aug 22 - sept 18
SELECT 
    ws.device_type,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.created_at > '2012-08-22'
        AND ws.created_at < '2012-09-19'
        AND ws.utm_source in ('gsearch','bsearch')
        AND ws.utm_campaign = 'nonbrand'
GROUP BY ws.device_type , ws.utm_source;

-- Channel Portfolio Trends
-- Pull weekly session volume for gsearch and bsearch nonbrand, broken down by device since november 4th. Include
-- comparison metric to show bsearch as a percent of gsearch
SELECT 
    MIN(DATE(created_at)) as week_start_date,
    count(distinct case when device_type='desktop' AND utm_source='gsearch' then website_session_id else null end) as gsearch_desktop_sessions,
    count(distinct case when device_type='desktop' AND utm_source='bsearch' then website_session_id else null end) as bsearch_desktop_sessions,
    count(distinct case when device_type='desktop' AND utm_source='bsearch' then website_session_id else null end) /
		count(distinct case when device_type='desktop' AND utm_source='gsearch' then website_session_id else null end) as bsearch_pct_gsearch_desktop,
    count(distinct case when device_type='mobile' AND utm_source='gsearch' then website_session_id else null end) as gsearch_mobile_sessions,
    count(distinct case when device_type='mobile' AND utm_source='bsearch' then website_session_id else null end) as bsearch_mobile_sessions,
    count(distinct case when device_type='mobile' AND utm_source='bsearch' then website_session_id else null end) /
		count(distinct case when device_type='mobile' AND utm_source='gsearch' then website_session_id else null end) as bsearch_pct_gsearch_mobile
FROM
    website_sessions
WHERE
    created_at > '2012-11-04'
        AND created_at < '2012-12-22'
        AND utm_source in ('gsearch','bsearch')
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

-- Analyzing Free Channels
-- Pull organic search, direct type in, and paid brand sessions by month, and show those sessions as a % of paid search nonbrand
SELECT 
	YEAR(created_at) as yr,
    MONTH(created_at) as mnth,
    count(distinct case when utm_campaign='nonbrand' then website_session_id else null end) as nonbrand_sessions,
    count(distinct case when utm_campaign='brand' then website_session_id else null end) as brand_sessions,
    count(distinct case when utm_campaign='brand' then website_session_id else null end) /
		count(distinct case when utm_campaign='nonbrand' then website_session_id else null end) as brand_pct_of_nonbrand,
	count(distinct case when utm_source is null and http_referer is null then website_session_id else null end) as direct_sessions,
    count(distinct case when utm_source is null and http_referer is null then website_session_id else null end) / 
		count(distinct case when utm_campaign='nonbrand' then website_session_id else null end) as direct_pct_of_nonbrand,
	count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end) as organic_sessions,
    count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end) / 
		count(distinct case when utm_campaign='nonbrand' then website_session_id else null end) as organic_pct_of_nonbrand
FROM
    website_sessions
WHERE
    created_at < '2012-12-23'
Group by yr, mnth;
    