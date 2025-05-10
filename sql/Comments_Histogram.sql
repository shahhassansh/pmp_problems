-- Q1: age_segment, avg_comments_per_person
with cte as (
SELECT a.person_id, b.age, a.comment_id
from comments a
join persons b 
on a.person_id = b.person_id)
select 
case when age between 0 and 18 then '0-18'
when age between 19 and 25 then '19-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 60 then '46-60'
else '60+' end as age_segment, round(count(*)*1.0/ count(distinct person_id),2) as avg_comments_per_person
from cte
group by 1;

-- Q2: page_type, average
select page_type, round(avg(page_views),2) as average 
from posts
group by 1
order by 2 desc;

-- Q3: age_segment, month, total_comments
with cte as (
SELECT b.age, a.comment_id, TO_CHAR(a.date, 'YYYY-MM') as month
from comments a
join persons b 
on a.person_id = b.person_id
where DATE_PART('year', a.date) = 2023
), cte2 as (
select 
case when age between 0 and 18 then '0-18'
when age between 19 and 25 then '19-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 60 then '46-60'
else '60+' end as age_segment, month, count(*) as total_comments,
row_number() over(partition by 
month
order by count(*) desc) as rk
from cte
group by 1,2
order by 2,4 desc)
select age_segment, month, total_comments
from cte2 
where rk in (1,2)
order by 2,3 desc

-- Q4: person_id, first_name, last_name, total_comments
with cte as (
select person_id, count(*) as total_comments
from comments 
where post_id in (

SELECT post_id
from posts 
group by post_id
order by sum(page_views)  desc
limit 8 )
group by 1)
,cte2 as (
select a.person_id, b.first_name, b.last_name, a.total_comments
, rank() over (order by total_comments desc) as rk
from cte a
join persons b 
on a.person_id = b.person_id)
select person_id, first_name, last_name, total_comments
from cte2 
where rk <= 3

-- Q5: person_id, first_name, last_name, year_over_year_increase
with cte as (
select person_id, post_id, comment_id, date, row_number() over (partition by person_id,post_id order by date asc) as rk
from comments 
),
cte2 as (
select person_id, comment_id, date
from cte 
where rk = 1),
cte_2023 as (
select person_id, count(*) as total_comments from cte2 where DATE_PART('year', date) = 2023
group by 1
), cte_2024 as (
select person_id, count(*) total_comments from cte2 where DATE_PART('year', date) = 2024
group by 1
)
select a.person_id, round((b.total_comments - a.total_comments) * 1.0/(a.total_comments),2) as year_over_year_increase
from cte_2023 a
join cte_2024 b 
on a.person_id = b.person_id
order by 2 desc
limit 3

