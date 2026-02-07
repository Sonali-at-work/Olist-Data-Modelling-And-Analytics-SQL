--Answering business problems using the Olist Data Model
	
--2. Customer Lifetime Value (LTV)
--Problem: What is the historical lifetime value of customers and which segments generate the most revenue?
--	• Objective: Identify high-value customers for loyalty programs and marketing prioritization.
--	• Dataset: orders, order_items, customers
--	• Analysis type: LTV calculation
--	• Example Insight: “Top 20% of customers contribute 75% of total revenue.”
	
	with t as (select o.customer_key,sum(oi.price)as LTV from gold.fact_orders o  join gold.fact_order_items oi on o.order_id=oi.order_id
	where order_status='delivered' and customer_key is not null
	group by o.customer_key )
	
	,segmented as (
	select *,ntile(5) over (order by LTV desc) customer_segment from t)
	
	select customer_segment,count(customer_key) as customer_count_in_that_segment
	,sum(LTV) as revenue_per_segment,round(100 * sum(LTV)/(sum(sum(LTV)) over()),2) as pct_revenue from segmented group by customer_segment
	

