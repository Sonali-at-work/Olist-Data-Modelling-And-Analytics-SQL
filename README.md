
# Data Modelling and Analytics Project 
  
This project demonstrates SQL Development,Dimensional Modeling , Analytics & Reporting  using dataset Olist E-Commerce dataset.

## 📌 Dataset Used Olist Brazillian E-Commerce dataset

The raw data has 9 tables/csv
1. olist_customers_dataset ingestion
2. olist_geolocation_dataset
3. olist_order_items_dataset
4. olist_order_payments_dataset
5. olist_order_reviews_dataset
6. olist_orders_dataset
7. olist_products_dataset
8. olist_sellers_dataset
9. product_category_name_transalation

##  Repository Structure

```text
datasets/        → Source data
scripts/         → SQL scripts (ETL, modeling, QA)
docs/            → Architecture & data dictionary
tests/           → Data quality checks
README.md        → Project overview

data-warehouse-project/
│
├── datasets/
│   └── Raw datasets used for the project.
│
├── docs/
│   ├── etl.drawio                  # Project documentation and architecture details
│   ├── data_architecture.drawio    # Draw.io file showing the project’s architecture
│   ├── data_catalog.md             # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio            # Draw.io file for the data flow diagram
│   ├── data_models.drawio          # Draw.io file for data models (star schema)
│   └── naming_conventions.md       # Consistent naming guidelines for tables, columns, and files
│
├── SQL scripts/
│   ├── Bronze- Raw data Loading/                        # Scripts for extracting and loading raw data/ Data Ingestion 
│   │    └── DDL_Script_Creating_Tables_and_Loading_Data
│   │
│   ├── Silver- Data Cleaning and Data Standardization/  # Scripts for cleaning and transforming data
│   │    ├──DDL_Script .sql
│   │    ├──Script_quality_checks_on_data .sql
│   │    ├──Stored Procedure for data Cleaning .sql
│   │    └──Tableas available and reationship between them .png
│   │
│   └── Gold- Data Modelling(Dimension and facts)/      # Scripts for creating analytical models
│        ├──Creating Fact and Dimension Tables .sql
│        ├──Quality checks on the data Model created
│        └──Schema.png
│
├── README.md                       # Project overview and instructions
├── LICENSE                         # License information for the repository
├── .gitignore                      # Files and directories to be ignored by Git
└── requirements.txt                # Dependencies and requirements for the project
```

## 📌 Methodology

### 1️⃣ Bronze -Raw Ingestion /Raw Data Loading
### 2️⃣ Silver -Cleaned and transformed data
              - Create tables structure for each table.
              - Loading data from bronze layer in this layer.
              - Performed quality checks on columns of each tables to know the anomalies transformations 
                needed.
              - Based on these observations of quality checks
              - Written a Stored Procedure that takes raw data from bronze 
              - tranforms data and stores in the table structures created in this layer.
### 3️⃣ Gold   - Data Modeling 
              - Business-ready fact and dimension tables in form of views
              - Galaxy schema
              - Checks referntial integrity ,whether is maintained or not in the data model(Galaxy Schema) 
                created
### 4️⃣ Analytics & Reporting
              - Sql -based analysis, Exploratory Data analysis
              - Answering Business KPIs/Problems
              - In all a combination of 7 business insights and problems are answered  after building
                Data Model
              - Analytical queries optimized for performance
---
## Data Modeling
<img src="SQL Scripts/Gold- Data Modelling (Dimensions and Facts)/Schema.png" width="600" height="500">


Overview

The Gold layer follows a dimensional modeling approach optimized for analytical and reporting use cases.
The model is designed using a Fact Constellation (Galaxy Schema), where multiple fact tables exist at different grains and share conformed dimensions.

This approach supports:
Flexible analysis at order, order-item, payment, and review levels
Clear separation of business entities (dimensions) and measurable events (facts)

## Design Principles Applied In Data Modelling

- Clear grain definition for every fact table.
- Surrogate keys used for analytical stability.
- Business keys preserved for traceability.
- No dimension-to-dimension joins.
- Referential integrity validated via data quality checks
- Optimized for BI tools and SQL-based analytics

### Schema Type

Fact Constellation (Galaxy Schema)
The model contains:
- 3 Dimension tables
- 4 Fact tables

Shared dimensions reused across multiple facts
This is intentionally not a single star schema, because the business processes operate at different granularities.

## Dimension Tables
Dimensions store descriptive attributes and use surrogate keys for analytical joins.

### 1. gold.dim_customers

- Grain: One row per customer
- Surrogate Key: customer_key
- Business Key: customer_id
- Attributes: Customer identifiers, Geographic details (city, state, zip)
- Used by: fact_orders

### 2. gold.dim_products

- Grain: One row per product
- Surrogate Key: product_key
- Business Key: product_id
- Attributes: Product category, Physical characteristics (weight, dimensions), Metadata for product analysis
- Used by: fact_order_items

### 3. gold.dim_sellers

- Grain: One row per seller
- Surrogate Key: seller_key
- Business Key: seller_id
- Attributes: Seller location, Geographic enrichment using aggregated geolocation data
- Used by: fact_order_items

## Fact Tables

Fact tables store transactional and event-level data.
Each fact table maintains a clearly defined grain and references dimensions via surrogate keys where applicable.

### 1. gold.fact_orders

- Grain: One row per order
- Purpose: Tracks order lifecycle and delivery performance
- Keys: order_id (degenerate dimension), customer_key (FK to dim_customers)
- Measures / Indicators: Order status, Timestamps (purchase, approval, delivery), Delivery delay flags and duration metrics
- Connected to: Customers, Payments, Reviews, Order items

### 2. gold.fact_order_items

- Grain: One row per order item
- Purpose: Captures line-level sales and logistics details
- Keys: order_id, order_item_id, product_key (FK), seller_key (FK)
- Measures: Item price, Freight value, Shipping limit date
- This table represents the core sales fact of the model.

### 3. gold.fact_payments

- Grain: One row per payment record per order
- Purpose: Captures payment behavior and methods
- Keys: order_id
- Measures / Attributes: Payment type, Installments, Payment value, Payment sequence
- Connected to: fact_orders via order_id

### 4. gold.fact_reviews

- Grain: One row per review (1 order_id has many reviews in reviews tbl) -- 1:M Relationship
- Purpose: Captures customer feedback and satisfaction
- Keys: review_id, order_id
- Measures / Attributes: Review score, Comments, Review creation and response timestamps
- Connected to: fact_orders via order_id

### Relationships & Grain Alignment

Orders act as a central business process linking:
Customers ,
Order items ,
Payments ,
Reviews.
Order items connect products and sellers at the most detailed transactional level.
Dimensions are never joined directly to each other — joined only through facts.
Surrogate keys are used only in dimensions and facts, never in the Silver layer.

## Using created Model to answer : 
## Business Problems & Insights

### 2. Customer Lifetime Value (LTV)
   
- Problem: Not all customers contribute equally to revenue, but marketing efforts treat them the same. We need to identify high-value customers for loyalty programs and marketing prioritization.
- Objective: What is the historical lifetime value of customers and which segments generate the most revenue?
- Analysis type: LTV calculation	
```	
	with t as (select o.customer_key,sum(oi.price)as LTV 
	            from gold.fact_orders o 
	            join gold.fact_order_items oi on o.order_id=oi.order_id
	            where order_status='delivered' and customer_key is not null
	             group by o.customer_key )

	,segmented as (
	select *,ntile(5) over (order by LTV desc) customer_segment from t)
	
	select customer_segment,
           count(customer_key) as customer_count_in_that_segment
	       ,sum(LTV) as revenue_per_segment,
           round(100 * sum(LTV)/(sum(sum(LTV)) over()),2) as pct_revenue
          from segmented group by customer_segment
```
<img src="Docs/output Screenshot- LTV.png" width="600" height="500">

#### Insights: Ntile divided customers into 5 segments each having 20 % customers. Based on output screeenshot 20% of customers contribute to ~ 56 % of total revenue.These
#### customers are ideal for loyalty programs and marketing prioritization

### 3. Forecasting Orders and Revenue 
- Problem: Unpredictable demand makes it difficult to plan inventory, staffing, and logistics. Predict future monthly orders and revenue to optimize inventory and staffing.
- Objective: Support operational planning and supply chain management.
   
```	
with t as (select  year(order_purchase_timestamp) as year ,
                   month(order_purchase_timestamp)as month,sum(price) as revenue
                   from gold.fact_orders ojoin gold.fact_order_items oi
                   on o.order_id=oi.order_id
                   where order_status='delivered'
                   group by month(order_purchase_timestamp), year(order_purchase_timestamp) 
            )

,growth as (select *,
            lag(revenue) over(order by year,month ) as previous_month_revenue
                 from t)

select avg(pct_growth_from_previous_month) as growth_rate from (
                        select *,
                               (revenue-previous_month_revenue)/NULLIF(previous_month_revenue, 0) as pct_growth_from_previous_month
                               from growth )s

```
<img src="Docs/Forecasting sales and Revenue.png" width="300" height="300">

#### Insights: Ntile divided customers into 5 segments each having 20 % customers. Based on output screeenshot 20% of customers contribute to ~ 56 % of total revenue.

### 4. Regional Sales Analysis
- Problem: Which regions/states generate the highest revenue and number of orders?
- Objective: Optimize marketing campaigns and logistics in high-performing regions.
- Analysis type: Descriptive, geospatial
```
with t as (
           select c.customer_state,
                  count(distinct o.order_id)as no_of_orders,
                  sum(oi.price) as revenue
                  from gold.fact_orders o
                  join gold.fact_order_items oi
                  on o.order_id=oi.order_id 
                  join gold.dim_customers c
                  on o.customer_key =c.customer_key
                  where order_status='delivered' and o.customer_key is not null 
                  group by c.customer_state  )

select *,
        100 * revenue/sum(revenue) over () as pct_revenue
        from t order by pct_revenue desc
```
<img src="Docs/output Screenshot- Regional Sales Analysis.png" width="600" height="500">

#### Insights:  Based on output screeenshot Sao Paulo and Rio De Janeiro contribute 50 % of total Revenue .
#### Optimize marketing campaigns and logistics in Sao Paulo and Rio De Janeiro will hellp increase in revenue 
#### Moreover the one's that are behind could also be made more inclusive in revenue generation.

### 5. Product & Category Performance
- Problem: Identify best-selling products and categories, and products with high returns or low reviews.
- Objective: Improve inventory decisions, reduce returns, and enhance product quality.
```
with t as (
          select p.product_category,
                  count( distinct o.order_id)as order_count,
                  sum(oi.price) as revenue_by_product,
                 COUNT(*) AS units_sold  
         from  gold.fact_orders o
                   join gold.fact_order_items oi on o.order_id=oi.order_id 
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
```
<img src="Docs/output Screenshot- Product and category performance..png" width="600" height="500">

#### Insights:  Based on output column cumulative_pct in screeenshot Out of 72 categories ,top 18 categories 
####            generate 80% of total revenue.
### - Classic Pareto behavior: business is dependent on few categories. Very few categories drive most revenue.


### 6. Delivery Performance Analysis
Problem: Which sellers or regions experience the longest delivery times? Identify logistics bottlenecks and improve delivery efficiency
	• Objective: Which sellers or regions experience the longest delivery times?
	• Example Insight: “Orders to the North region take 20% longer than the national average.”
```
select 
    s.seller_state,
    count(distinct oi.order_id) as total_orders,
    sum(o.flag_delivered_after_estimated) as total_late_deliveries,
    round(
        100.0 * sum(o.flag_delivered_after_estimated) 
        / count(distinct oi.order_id), 
    2) as late_pct
from gold.fact_order_items oi
join gold.fact_orders o on oi.order_id = o.order_id
join gold.dim_sellers s on oi.seller_key = s.seller_key
where order_status = 'delivered'
group by s.seller_state
order by late_pct desc;
```
<img src="Docs/output Screenshot- Delivery Performance Analysis ..png" width="600" height="500">

#### Insights : 
#### • MA shows highest late rate (23%), but low order volume (168) → low business impact
#### • SP contributes 2,567 late deliveries (largest absolute number) → primary bottleneck
#### • RJ and PR also show moderate delays with high volume

#### Business Recommendation:

#### • Focus logistics optimization on SP warehouses
#### • We can further investigate seller SLA compliance in RJ/PR

### 7. Impact of Delivery on Customer Satisfaction
- Problem: Does delivery delay affect customer review scores?
- Objective: Correlate operational performance with customer satisfaction.
- Analysis type: Correlation analysis
```
with review_per_order AS (
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

select category_days_late ,
       avg(_score)as review_score
       from category
       group by category_days_late
       order by avg(_score) asc
```
<img src="Docs/output Screenshot- Impact Of delivery on performance.png" width="600" height="500">

#### Insights : Negative correlation “Customer satisfaction declines sharply with delivery delays.
#### Orders delivered on time receive an average rating of 4, while highly delayed deliveries receive only 1.
####  Each delay bucket reduces ratings by ~1 point.”



