-- Q1: product_name, week (in year-week format), avg_price

select b.name as product_name, TO_CHAR(a.purchase_date, 'YYYY-IW')  as week, avg(a.price) as  avg_price
from purchase a 
join product b 
on a.product_id = b.product_id
WHERE a.purchase_date >= CURRENT_DATE - INTERVAL '14 days'  -- Filter for the last 2 weeks
group by 1,2;  

-- Q2: manufacturer_name, total_quantity_sold
SELECT c.name as manufacturer_name, sum(a.quantity) as total_quantity_sold
FROM purchase a
join product b 
on a.product_id = b.product_id
join manufacturer c 
on b.manufacturer_id = c.manufacturer_id
where a.purchase_date >= CURRENT_DATE - INTERVAL '30 days'
group by 1;

--Q3: manufacturer_name, product_id, product_name, market_share
SELECT c.name as manufacturer_name, a.product_id, b.name as product_name, 
round(sum(a.quantity)*100.0/(select sum(quantity) from purchase),2) as market_share
FROM purchase a
join product b 
on a.product_id = b.product_id
join manufacturer c 
on b.manufacturer_id = c.manufacturer_id
group by 1,2,3
order by 1;

-- Q4: customer_id, most_expensive_id, least_expensive_id, price_difference
with cte as (
SELECT customer_id, max(price) max_price, min(price) as min_price, max(price) - min(price) as price_difference
from purchase
group by 1
order by 1
)
select distinct a.customer_id, b.product_id as most_expensive_id, c.product_id as least_expensive_id, a.price_difference
from cte a 
join purchase b 
on a.customer_id = b.customer_id
and b.price = a.max_price
join purchase c
on a.customer_id = c.customer_id
and c.price = a.min_price

-- Q5: customer_id, total_savings
with cte as (
select TO_CHAR(purchase_date, 'YYYY-MM') as month, b.name as product_name, min(price) as cheapest_price
from purchase a 
join product b 
on a.product_id = b.product_id
group by 1,2
),
cte2 as (
select b.customer_id, TO_CHAR(purchase_date, 'YYYY-MM') as month, a.name as product_name, b.price, b.quantity
from product a 
join purchase b 
on a.product_id = b.product_id
)
select a.customer_id, sum(a.quantity * a.price- a.quantity * b.cheapest_price) as total_savings
from cte2 a 
join cte b 
on a.month = b.month 
and a.product_name = b.product_name
group by 1;
