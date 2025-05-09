-- Q1: user_id, friend_count
select user_id, count(distinct friend_id) as friend_count
from friend
group by 1
order by 2 desc
limit 5;

-- Q2: country
SELECT b.country
from friend a
join "user" b
on a.user_id = b.user_id
join "user" c
on a.friend_id = c.user_id
group by 1
having sum( case when c.gender = 'Female' then 1 else 0 end) > sum( case when c.gender = 'Male' then 1 else 0 end);

-- Q3: country, page_id, follower_count
with cte as (
SELECT b.country, a.page_id, count(distinct a.user_id) as follower_count
from pages_followed a
join "user" b
on a.user_id = b.user_id
group by 1,2
), cte2 as (
select country,page_id,follower_count, rank() over (partition by country  order by follower_count desc)  rk
from cte)
select country,page_id,follower_count from cte2
where rk = 1

-- Q4: user_id, recommended_page
with cte as (
select a.user_id, a.friend_id,  b.page_id
from friend a
join pages_followed b 
on a.friend_id = b.user_id
where a.user_id in (2,6,9)
and concat(a.user_id,b.page_id) not in (select concat(user_id, page_id) from pages_followed)
order by 1
), cte2 as (
    select user_id, page_id, count(distinct friend_id) as cf, rank() over (partition by user_id order by count(distinct friend_id) desc) rk
from cte
group by 1,2)
select user_id, page_id as recommended_page from cte2
where rk = 1

-- Q5: user_id, recommended_page
with cte as ( 
select a.user_id, a.friend_id, b.friend_id as ff
from friend a 
join friend b 
on a.friend_id = b.user_id
where a.user_id in (1,2,3,4,5)
), cte2 as (
select a.user_id, b.page_id
from cte as a 
join pages_followed b
on a.friend_id = b.user_id
union all
select a.user_id, b.page_id
from cte as a 
join pages_followed b
on a.ff = b.user_id
), cte3 as (
select a.user_id, a.page_id, count(*) cnt
from cte2 a
where concat(a.user_id, a.page_id) not in (select concat(user_id, page_id) from pages_followed)
group by 1,2),
cte4 as (
select user_id, page_id, rank() over (partition by user_id order by cnt desc) as rk
from cte3)
select user_id, page_id
from cte4 
where rk = 1

