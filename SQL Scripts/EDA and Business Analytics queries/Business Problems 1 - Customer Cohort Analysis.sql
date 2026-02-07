--Answering business problems using the Olist Data Warehouse dataset
--Olist Ecommerce: Business Problems List
--1. Customer Cohort Analysis
--Problem: How do customer cohorts behave over time based on their first purchase month?
--	• Objective: Track retention and repeat purchase patterns.
--	• Dataset: orders, customers 
--	• Analysis type: Cohort analysis & retention
--	• Example Insight: “Customers acquired in January 2025 show 40% repeat purchases after 3 months.”
	
	select * ,datediff(month,first_order,order_purchase_timestamp) as rp from(
	select customer_key,order_purchase_timestamp,
	min(order_purchase_timestamp) over(partition by customer_key )as first_order 
	 from gold.fact_orders 
	where customer_key is not null) t
	
	with t as(select customer_key ,count(distinct order_id) as order_count from gold.fact_orders
	where customer_key is not null group by customer_key)
	
	select sum(case when order_count >=2 then 1 else 0 end)*1.0/count(*) as repeat_purchase_rate 
	from t
	
	select *,case when order_count >=2 then 'Y' else 'N' end as Retention from t
	
