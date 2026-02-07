--Answering business problems using the Olist Data Warehouse dataset


--6. Delivery Performance Analysis
--Problem: Which sellers or regions experience the longest delivery times?
--	• Objective: Identify logistics bottlenecks and improve delivery efficiency.
--	• Dataset: orders, sellers, geolocation
--	• Analysis type: Diagnostic, geospatial
--	• Example Insight: “Orders to the North region take 20% longer than the national average.”

select s.seller_state,
count(distinct oi.order_id) as total_orders,
sum(o.Flag_delivered_after_estimated)as total_late_deliveries, 
ROUND(100.0 * SUM(o.Flag_delivered_after_estimated) / COUNT(*), 2) AS late_pct
from gold.fact_order_items oi 
join gold.fact_orders o on oi.order_id=o.order_id
join gold.dim_sellers s on oi.seller_key=s.seller_key
where order_status='delivered' 
group by s.seller_state




