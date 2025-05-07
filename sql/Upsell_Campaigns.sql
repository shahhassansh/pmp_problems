-- Write your query here

-- Q1
select cast(avg(date_end::DATE - date_start::DATE) as int) as average_duration_days
from campaign;

--Q2
with cte as (
select a.*,b.upsell_campaign_id 
from  transaction a
join campaign b
on a.transaction_date between b.date_start and b.date_end)
select upsell_campaign_id, count(distinct user_id) as eligible_users_with_purchase
from cte
 where user_id in (select user_id from "user" where is_eligible_for_upsell_campaign = TRUE)
group by 1;

-- Q3
with cte as (
select product_id, sum(quantity) as quantity_during_campaign
from transaction a
join campaign b
on transaction_date between date_start and date_end
group by 1),
cte2 as (
select product_id, sum(quantity) as quantity_outside_campaign
from transaction where transaction_date not in (
select transaction_date 
from transaction a
join campaign b
on transaction_date between date_start and date_end)
group by 1)
select coalesce(a.product_id,b.product_id) as product_id
, coalesce(quantity_during_campaign,0) quantity_during_campaign
, coalesce(quantity_outside_campaign,0) quantity_outside_campaign
, (coalesce(quantity_during_campaign,0) - coalesce(quantity_outside_campaign,0)) as quantity_increase
, rank() over (order by (coalesce(quantity_during_campaign,0) - coalesce(quantity_outside_campaign,0)) desc) as rank
from cte a 
full outer join cte2 b
on a.product_id = b.product_id;

-- Q4
with cte as (
 SELECT product_id, transaction_date, quantity FROM transaction
 WHERE user_id in (select user_id from "user" where is_eligible_for_upsell_campaign = True)
),
cte2 as (
select b.upsell_campaign_id, product_id, sum(quantity) as total_quantity_sold
from cte a
join campaign b
on a.transaction_date between b.date_start and b.date_end
group by 1,2),
cte3 as (
select upsell_campaign_id,max(total_quantity_sold) as total_quantity_sold
from cte2
group by 1)
select a.upsell_campaign_id, min(a.product_id) as product_id, a.total_quantity_sold
from cte2 a 
join cte3 b 
on a.upsell_campaign_id = b.upsell_campaign_id and a.total_quantity_sold = b.total_quantity_sold
group by 1,3;

-- Q5
with cte as (
SELECT 'a' as dum, SUM(quantity) AS quantity
FROM transaction a
JOIN campaign b 
ON a.transaction_date between b.date_start and b.date_end),
cte2 as (
select 'a' as dum, SUM(quantity) AS quantity
FROM transaction 
where transaction_date not in 
(select transaction_date
FROM transaction a
JOIN campaign b 
ON a.transaction_date between b.date_start and b.date_end )
)
select (a.quantity - b.quantity) as quantity_increase, round((a.quantity - b.quantity)*100.0/(b.quantity),1)

from cte a
join cte2 b 
on a.dum = b.dum;

