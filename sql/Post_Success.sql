-- Q1: user_type, total_successful_posts
select b.user_type, sum(case when a.is_successful_post is True then 1 else 0 end) as total_successful_posts
from post a
join "user" b 
on a.user_id = b.user_id
where post_date >= CURRENT_DATE - INterval '28 day'
group by 1

-- Q2: interface, total_posts, successful_posts, success_rate
select interface, count(post_id) as total_posts, 
sum(case when is_successful_post is True then 1 else 0 end) as successful_posts,
round(sum(case when is_successful_post is True then 1 else 0 end) * 100.0 / count(post_id),2) as success_rate
from (
SELECT * FROM post
WHERE interface like '%lite%'
) a
group by 1

-- Q3: user_id, total_posts, success_rate
with cte as (
select count(post_id)*1.0/(select count(distinct user_id) from post) avg_post_per_user
from post)
,cte2 as (
select avg(case when is_successful_post is True then 1 else 0 end) as avg_success_rate
from post)
select user_id, count(post_id) as total_posts, round(avg(case when is_successful_post is True then 1 else 0 end)*100.0,2) as success_rate
from post 
group by user_id
having count(post_id) > (select avg_post_per_user from cte)
and avg(case when is_successful_post is True then 1 else 0 end) < (select avg_success_rate from cte2)

-- Q4: young_adult_success_rate, non_young_adult_success_rate, success_rate_difference
with cte as (
select a.user_id, case when a.is_successful_post is True then 1 else 0 end as is_successful_post, 
case when b.age <19 then 'young_adult' else 'non_young_adult' end age_group
from post a 
join "user" b 
on a.user_id = b.user_id)
, cte2 as (
select age_group, round(avg(is_successful_post) * 100.0,2) success_rate
from cte
group by 1
), cte3 as (
select 'x' as dummy, success_rate from cte2 where age_group = 'young_adult'
), cte4 as (
select 'x' as dummy, success_rate from cte2 where age_group = 'non_young_adult'
)
select a.success_rate as young_adult_success_rate, b.success_rate as non_young_adult_success_rate, a.success_rate -b.success_rate  as success_rate_difference
from cte3 a 
join cte4 b
on a.dummy = b.dummy;

-- Q5:user_id, success_rate, and successful_posts_streak
with cte0 as (
select user_id, round(avg(case when is_successful_post is True then 1 else 0 end)*100.0,2) as success_rate
from post
group by 1
), cte as (
select user_id, post_date, 
case when is_successful_post is True then 1 else 0 end as is_successful_post,
row_number() over (partition by user_id order by post_date) as rk
from post),
cte2 as (
select user_id, max(rk) as m
from cte
group by 1
)
, cte3 as (
select user_id, max(rk) as m2
from cte
where is_successful_post = 0
group by 1
)
,cte4 as (
select a.user_id, (m - coalesce(m2,0)) as successful_posts_streak
from cte2 a
full outer join cte3 b 
on a.user_id = b.user_id
order by 1)
select a.user_id, b.success_rate, a.successful_posts_streak
from cte4 a 
join cte0 b 
on a.user_id = b.user_id; 
