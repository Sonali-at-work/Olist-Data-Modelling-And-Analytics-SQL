--Answering business problems using the Olist Data Warehouse dataset


--7. Product & Category Performance
--Problem: Identify best-selling products and categories, and products with high returns or low reviews.
--	• Objective: Improve inventory decisions, reduce returns, and enhance product quality.
--	• Dataset: products, order_items, reviews
--	• Analysis type: Descriptive & diagnostic
--	• Example Insight: “Electronics category drives 35% of revenue but has 12% negative reviews.”
with t as (
select p.product_category,count( distinct o.order_id)as order_count, sum(oi.price) as revenue_by_product, COUNT(*) AS units_sold  
from  gold.fact_orders o join gold.fact_order_items oi on o.order_id=oi.order_id 
join gold.dim_products p on oi.product_key=p.product_key 
join gold.fact_reviews r on r.order_id = o.order_id
where o.order_status='delivered' and customer_key is not null 
group by p.product_category )

select product_category,
order_count,revenue_by_product,
 -- % contribution
round(100 * revenue_by_product/sum(revenue_by_product) over(),2) as pct_revenue_product,
 -- cumulative share (Pareto)
ROUND(
    100.0 * SUM(revenue_by_product) OVER (
        ORDER BY revenue_by_product DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / SUM(revenue_by_product) OVER (), 2
) AS cumulative_pct

from t order by revenue_by_product desc



-- Top ~17 categories generate 80% of total revenue
--This is the key business insight.

--?? Business interpretation (this is what matters)
--? Insight 1 — Revenue concentration
--Very few categories drive most revenue:
--~20% categories ? 80% revenue

--Classic Pareto behavior.
--Meaning:
--?? business is dependent on few categories




