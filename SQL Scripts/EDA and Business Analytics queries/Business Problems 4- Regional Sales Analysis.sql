--Answering business problems using the Olist Data Warehouse dataset


--6. Regional Sales Analysis
--Problem: Which regions/states generate the highest revenue and number of orders?
--	• Objective: Optimize marketing campaigns and logistics in high-performing regions.
--	• Dataset: customers, orders, geolocation
--	• Analysis type: Descriptive, geospatial
--	• Example Insight: “São Paulo and Rio de Janeiro contribute 50% of total revenue.”
with t as (
select c.customer_state,count(distinct o.order_id)as no_of_orders,
sum(oi.price) as revenue from gold.fact_orders o join gold.fact_order_items oi on o.order_id=oi.order_id join
gold.dim_customers c on o.customer_key =c.customer_key
where order_status='delivered' and o.customer_key is not null 
group by c.customer_state  )

select *,100 * revenue/sum(revenue) over () as pct_revenue from t order by pct_revenue desc



