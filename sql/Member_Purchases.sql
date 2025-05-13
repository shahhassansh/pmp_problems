-- Q1: product_id, product_name, total_quantity_purchased
select a.product_id, c.name as product_name, sum(a.quantity) as total_quantity_purchased
from  "transaction" a
join customer b 
on a.user_id = b.customer_id
join product c 
on a.product_id = c.product_id
where is_member = TRUE
group by 1,2
order by 3 desc
limit 3

-- q2: product_category, average_price
select a.product_category, round(avg(a.price),2) as average_price
from product a 
join transaction b 
on a.product_id = b.product_id
where b.created_at >= CURRENT_DATE - Interval '30 DAYS'
group by 1; 

-- Q3: customer_id, member_name, product_id, product_name
with cte as (
select a.user_id as customer_id, b.name as member_name, a.product_id, c.name as product_name, sum(quantity) as total_quantity_purchased
from "transaction" a 
join customer b 
on a.user_id = b.customer_id
join product c 
on a.product_id = c.product_id
where b.is_member = TRUE
group by 1,2,3,4),
cte2 as ( 
select a.customer_id, a.member_name, a.product_id, a.product_name, row_number() over (partition by a.customer_id, a.member_name order by total_quantity_purchased desc) rk
from cte a)
select a.customer_id, a.member_name, a.product_id, a.product_name
from cte2  a
where rk = 1

-- Q4: product_category, non_member_product, member_product, price_diff
-- with cte as (
select a.quantity, b.is_member, c.price, c.product_category, c.name as product_name
from "transaction" a
join customer b 
on a.user_id = b.customer_id
join product c 
on a.product_id = c.product_id
),
cte2 as (
select product_category, product_name, price
, sum(case when is_member = FALSE then quantity else 0 end) as non_member_n
, sum(case when is_member = TRUE then quantity else 0 end) as member_n
from cte 
group by 1,2,3
), 
cte3 as (
select product_category, product_name, price, 
row_number() over (partition by product_category order by member_n desc) rk1,
row_number() over (partition by product_category order by non_member_n desc) rk2
from cte2)
, cte4 as (
select product_category, product_name as member_product, price
from cte3
where rk1 = 1)
, cte5 as (
select product_category, product_name as non_member_product, price
from cte3
where rk2 = 1)
select a.product_category, member_product, non_member_product, a.price - b.price as price_diff
from cte4 a 
join cte5 b
on a.product_category = b.product_category

-- Q5:product_id, product_name, quantity_8_to_4_weeks_ago, quantity_4_to_0_weeks_ago, percentage_increase
with cte as (
select a.product_id, b.name as product_name
, sum(case when created_at < CURRENT_DATE - Interval '28 days' and created_at >= CURRENT_DATE - Interval '56 days'then quantity else 0 end) as quantity_8_to_4_weeks_ago
, sum(case when created_at >= CURRENT_DATE - Interval '28 days' then quantity else 0 end) as quantity_4_to_0_weeks_ago
from "transaction" a
join product b
on a.product_id = b.product_id
group by 1,2)
select product_id, product_name,quantity_8_to_4_weeks_ago,quantity_4_to_0_weeks_ago,  round((quantity_4_to_0_weeks_ago - quantity_8_to_4_weeks_ago)*100.0/quantity_8_to_4_weeks_ago,2) as percentage_increase
from cte
where quantity_4_to_0_weeks_ago > quantity_8_to_4_weeks_ago

