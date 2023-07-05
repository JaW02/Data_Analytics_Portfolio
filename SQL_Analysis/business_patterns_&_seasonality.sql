USE mavenfuzzyfactory;

-- SEASONALITY

-- pull monthly amd weekly volume patterns for sessions and orders
-- monthly volume
SELECT 
    Year(ws.created_at) as yr,
    MONTH(ws.created_at) as mnth,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.website_session_id) as orders
FROM
    website_sessions ws
		LEFT JOIN
	orders o on o.website_session_id=ws.website_session_id
WHERE
    ws.created_at BETWEEN '2012-01-01' AND '2013-01-01'
group by yr, mnth;

-- weekly volume
SELECT 
    min(date(ws.created_at)) as week_start_date,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.website_session_id) as orders
FROM
    website_sessions ws
		LEFT JOIN
	orders o on o.website_session_id=ws.website_session_id
WHERE
    ws.created_at BETWEEN '2012-01-01' AND '2013-01-01'
group by week(ws.created_at);

-- ANALYZE BUSINESS PATTERNS; Data For Customer Service
select
	HOUR(hv.date_) as hr,
    round(avg(case when dayname(hv.date_)='Monday' then hv.volume else null end),1) as mon,
    round(avg(case when dayname(hv.date_)='Tuesday' then hv.volume else null end),1) as Tue,
    round(avg(case when dayname(hv.date_)='Wednesday' then hv.volume else null end),1) as weds,
    round(avg(case when dayname(hv.date_)='Thursday' then hv.volume else null end),1) as thur,
    round(avg(case when dayname(hv.date_)='Friday' then hv.volume else null end),1) as fri,
    round(avg(case when dayname(hv.date_)='Saturday' then hv.volume else null end),1) as sat,
    round(avg(case when dayname(hv.date_)='Sunday' then hv.volume else null end),1) as sun
from
	(SELECT 
		created_at as date_,
		count(distinct website_session_id) as volume
	FROM
		website_sessions
	WHERE
		created_at > '2012-09-15'
			AND created_at < '2012-11-15'
	GROUP BY date(created_at), day(created_at), hour(created_at)) as hv
group by hr;

