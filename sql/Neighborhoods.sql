--Q1: neighborhood_id, average_age

select a.neighborhood_id, round(avg(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM b.date_of_birth)),2) as average_age
from citizen_neighborhood_history a 
join citizen b
on a.citizen_id = b.citizen_id 
where a.move_out_date is null
group by 1
order by 2 asc 
limit 3;

Q2: state_id, citizen_growth
select b.state_id, 
sum(case when move_in_date >= CURRENT_DATE - Interval '30 day' and move_out_date is null then 1 else 0 end) as citizen_growth 
from citizen_neighborhood_history a 
join neighborhood b
on a.neighborhood_id = b.neighborhood_id 
group by 1 
having sum(case when move_in_date >= CURRENT_DATE - Interval '30 day' and move_out_date is null then 1 else 0 end) > 0
order by 1;

--Q3: citizen_id
with cte as (
select citizen_id, move_out_date, lead(move_in_date) over (partition by citizen_id order by move_in_date) as next_move_in
from citizen_neighborhood_history)
select citizen_id from cte 
where next_move_in - move_out_date > INTERVAL '7 days'
union
select citizen_id from citizen_neighborhood_history
group by citizen_id
having 
 max(move_out_date) < now() - INTERVAL '7 DAYs'
 and max(move_in_date) <  max(move_out_date); 

--Q4: avg_move_distance
with cte as (
SELECT citizen_id
, neighborhood_id, move_in_date
, lead(move_in_date) over (partition by citizen_id order by move_in_date) AS next_move_in
FROM citizen_neighborhood_history)
, cte2 as (
select a.neighborhood_id as first
, b.neighborhood_id as second
 from cte a  
 join citizen_neighborhood_history b 
 on a.citizen_id = b.citizen_id 
 and a.next_move_in = b.move_in_date
 where next_move_in is not null)
 ,cte3 as (
 select a.first, b.center_lat as old_lat, b.center_long as old_long, a.second
 , c.center_lat as new_lat, c.center_long as new_long
 from cte2 a 
 join neighborhood b 
 on a.first = b.neighborhood_id
 join neighborhood c
 on a.second = c.neighborhood_id
 where a.first <> a.second
 )
 select 
    ROUND(
        AVG(SQRT(POWER(new_lat - old_lat, 2) + POWER(new_long - old_long, 2)))::NUMERIC, 
        2
    ) AS avg_move_distance
    from cte3

--Q5: citizen_id, current_stay_duration, previous_stay_duration
with cte as (
select citizen_id, move_in_date, move_out_date
, row_number() over (partition by citizen_id order by move_in_date desc) as rk from
 citizen_neighborhood_history
 where citizen_id in 
 (select citizen_id
 from citizen_neighborhood_history
 group by citizen_id
 having count(neighborhood_id) > 1)
  order by 1)
  ,cte2 as (
  select citizen_id, rk
  , move_in_date::date as move_in_date
  , CASE WHEN move_out_date IS NULL THEN current_date else move_out_date::DATE end as move_out_date 
  from cte where rk in (1,2)
  )
  ,cte3 as (
  select citizen_id, move_out_date - move_in_date as current_stay_duration
  from cte2
  where rk = 1)
  ,cte4 as (
 select citizen_id, move_out_date - move_in_date as previous_stay_duration
  from cte2
  where rk = 2)
  select a.citizen_id, a.current_stay_duration, b.previous_stay_duration
  from cte3 a 
  join cte4 b 
  on a.citizen_id = b.citizen_id
  where a.current_stay_duration > b.previous_stay_duration
  
