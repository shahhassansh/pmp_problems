-- Q1 : avg_ride_duration
SELECT round(AVG(EXTRACT(EPOCH FROM (end_dt - start_dt)) / 60),2)
from ride
where distance > 20;

-- Q2: ride_region, success_rate
SELECT ride_region, round((SUM(case when is_completed = True then 1 else 0 end)*100.0)/count(*),2) as success_rate
from ride
group by 1;

-- Q3: driver_id, name

with cte as (
SELECT driver_id, sum(distance) as total_distance, sum(case when is_completed = TRUE THEN 1 ELSE 0 END) as total_rides
from ride 
where start_dt >= CURRENT_DATE - INTERVAL '30 days'
group by 1
), cte2 as (
SELECT driver_id, sum(distance) as total_distance, sum(case when is_completed = TRUE THEN 1 ELSE 0 END) as total_rides
from ride
where start_dt >= CURRENT_DATE - INTERVAL '60 days' and start_dt < CURRENT_DATE - INTERVAL '30 days'
group by 1),
CTE3 AS (
select a.driver_id, a.total_distance as ct, a.total_rides as cr, b.total_distance as pt, b.total_rides as pr
from cte a 
join cte2 b 
on a.driver_id = b.driver_id)
select a.driver_id, b.name as driver_name from cte3 a
join driver b 
on a.driver_id = b.driver_id
where ct < pt and cr > pr;

-- Q4: passenger_id, best_driver_id, ride_region, ride_count
with cte as (
select a.driver_id, ride_region, driver_rating_cumulative
from ride a 
join driver b 
on a.driver_id = b.driver_id 
)
, cte2 as (
select ride_region, max(driver_rating_cumulative) as best_rating 
from cte group by 1
)
,cte3 as ( 
select distinct a.driver_id as best_driver_id, a.ride_region
from cte a
join cte2 b 
on a.ride_region = b.ride_region
and a.driver_rating_cumulative = b.best_rating
)
select a.passenger_id, b.best_driver_id, b.ride_region, count(*) as ride_count
from ride a 
join cte3 b 
on a.driver_id = b.best_driver_id 
and a.ride_region = b.ride_region
where a.start_dt >= CURRENT_DATE - INTERVAL '30 days'
group by 1,2,3;

-- Q5: Ride_region, success_rate
with cte as (
SELECT driver_id, Ride_region, case when is_completed = True then 1 else 0 end as is_completed
, LAG(case when is_completed = True then 1 else 0 end) over (partition by driver_id, Ride_region order by start_dt) as prev_is_completed
from ride)
select ride_region, round(sum(is_completed)*100.0/ count(*),2)
from cte 
where prev_is_completed = 1
group by ride_region

