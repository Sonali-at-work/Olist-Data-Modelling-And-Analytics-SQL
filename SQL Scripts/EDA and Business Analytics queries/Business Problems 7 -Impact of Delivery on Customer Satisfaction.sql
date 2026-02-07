--Answering business problems using the Olist Data Warehouse dataset


9. Impact of Delivery on Customer Satisfaction
Problem: Does delivery delay affect customer review scores?
	• Objective: Correlate operational performance with customer satisfaction.
	• Dataset: orders, reviews
	• Analysis type: Correlation analysis
	• Example Insight: “Orders delayed >7 days receive 1.5 points lower on average in reviews.”
WITH review_per_order AS (
    SELECT 
        order_id,
        AVG(score) AS _score
    FROM gold.fact_reviews
    GROUP BY order_id
)

,t as (select o.order_id,o.diff_hours_delivered_to_estimated,
- o.diff_hours_delivered_to_estimated/24 as days_late,
r._score from 
gold.fact_orders o join gold.fact_order_items oi on oi.order_id=o.order_id
join review_per_order r on o.order_id=r.order_id
where order_status='delivered'  )

--select max(days_late),min(days_late) from t
----min is 0 and max days is 188 days
,category as (select 
case when days_late <=0 then 'On time'
when days_late <= 1 then 'minor delay'
when days_late <=3 then 'small'
when days_late <=7 then 'medium'
when days_late <=14 then 'high'
end 
as category_days_late ,_score from t)

select category_days_late ,avg(_score)as review_score from category group by category_days_late order by avg(_score) asc

Negative correlation
“Customer satisfaction declines sharply with delivery delays. Orders delivered on time receive an average rating of 4, while highly delayed deliveries receive only 1. Each delay bucket reduces ratings by ~1 point.”

