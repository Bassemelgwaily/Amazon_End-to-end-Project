/* Create silver dim Adset table */ 
Drop table if exists Silver.dim_adset;
CREATE TABLE Silver.dim_adset (
	adset_id int PRIMARY KEY Not Null,
	campaign_id int Not Null,
	adset_name nvarchar(255) Null,
	target_age_group nvarchar(255) Null,
	target_gender nvarchar(255) Null ,

);
go

/* Insert data after cleaning and transformation data type*/
Insert into Silver.dim_adset (adset_id, campaign_id, adset_name, target_age_group, target_gender)
SELECT 
	Try_CAST(adset_id AS int) AS adset_id,
	Try_CAST(campaign_id AS int) AS campaign_id,
	adset_name,
	target_age_group,
	target_gender
FROM bronze.dim_adset;

/*Check for any null values in the primary key column*/
Select * from Silver.dim_adset; 
SELECT COUNT(*) FROM silver.dim_adset;  
SELECT * FROM silver.dim_adset WHERE adset_id IS NULL OR campaign_id IS NULL;

/* -----------------------------------------------------------------------------------------*/

/* Create Silver dim campaign Table */
DROP TABLE IF EXISTS Silver.dim_campaign;
CREATE TABLE Silver.dim_campaign (
      campaign_id int PRIMARY KEY Not Null ,
	  campaign_name NVARCHAR (300) Null ,
	  platform_id INT Not Null ,
	  objective NVARCHAR (100),
	  Start_date date null ,
	  end_date date null,
	  budget_egp decimal(12,2)
)
GO

/* INSERT DATA AFTER AND TRANSFORMATION */
INSERT INTO Silver.dim_campaign(campaign_id,campaign_name,platform_id,objective,Start_date,end_date,budget_egp)
SELECT 
TRY_CAST(campaign_id AS int ) AS campaign_id,
         campaign_name,
		 TRY_CAST(platform_id AS int) AS platform_id,
		 objective,
		 TRY_CAST(start_date AS DATE ) as start_date,
		 TRY_CAST(end_date AS DATE	) AS end_date,
		 TRY_CAST(budget_egp AS DECIMAL(12,2)) AS budget_egp
FROM bronze.dim_campaign

/* CHECK silver Table */
Select count(*) from silver.dim_campaign
SELECT * FROM Silver.dim_campaign 
Where campaign_id IS NULL OR platform_id IS NULL 

-----------------------------------------------------------------------------------------*/
/* CREATE SILVER DIM CATEGORY TABLE */
DROP TABLE IF EXISTS silver.dim_category ;
CREATE TABLE silver.dim_category(
     category_id int PRIMARY KEY Not Null ,
	 category_name NVARCHAR (200) Null,
	 parent_category_id int Null 
)
GO 

/* INSERT DATA AFTER CLEANING AND TRANSFORMATION */
INSERT INTO silver.dim_category(category_id,category_name,parent_category_id)
SELECT
     TRY_CAST(category_id AS INT) AS category_id,
	 category_name,
	 TRY_CAST(parent_category_id AS INT) AS parent_category_id
FROM bronze.dim_category

/*CHECK SILVER TABLE */
SELECT * FROM silver.dim_category

/*---------------------------------------------------------------------------------------*/
/* CREATE SILVER DIM PLATFORM */
 DROP TABLE IF EXISTS silver.dim_platform;
 CREATE TABLE silver.dim_platform (
       platform_id int Not Null,
	   platform_name NVARCHAR (100) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_platform( platform_id,platform_name)
SELECT
   TRY_CAST(platform_id as INT ) as platform_id ,
   platform_name
FROM bronze.dim_platform
 

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_platform
SELECT platform_id , platform_name FROM silver.dim_platform
where platform_id is null or platform_name is null
/*---------------------------------------------------------------------------------------*/

/* CREATE SILVER DIM DATE */
DROP TABLE IF EXISTS silver.dim_date ;
CREATE TABLE silver.dim_date (
	date_id INT Not Null,
	full_date DATE Not Null,
	[day] INT Null,
	[month] INT Null,
	month_name NVARCHAR (20) Null,
	[quarter] INT Null,
	[year] INT Null,
	day_name NVARCHAR (20) Null,
	is_weekend BIT Null,
	is_holiday_season BIT Null,
	holiday_name NVARCHAR (100) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_date( date_id,full_date,[day],[month],month_name,[quarter],[year],day_name,is_weekend,is_holiday_season,holiday_name)
SELECT
	TRY_CAST(date_id as INT ) as date_id ,
	TRY_CAST(full_date as DATE ) as full_date ,
	TRY_CAST([day] as INT ) as [day] ,
	TRY_CAST([month] as INT ) as [month] ,
	month_name ,
	TRY_CAST([quarter] as INT ) as [quarter] ,
	TRY_CAST([year] as INT ) as [year] ,
	day_name ,
	CASE WHEN is_weekend = 'True' THEN 1 WHEN is_weekend = 'False' THEN 0 END ,
	CASE WHEN is_holiday_season = 'True' THEN 1 WHEN is_holiday_season = 'False' THEN 0 END ,
	NULLIF(holiday_name,'')
FROM bronze.dim_date

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_date
SELECT date_id , full_date FROM silver.dim_date where date_id is null or full_date is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM CUSTOMER */
DROP TABLE IF EXISTS silver.dim_customer ;
CREATE TABLE silver.dim_customer (
	customer_id INT Not Null,
	full_name NVARCHAR (200) Null,
	gender NVARCHAR (20) Null,
	birth_date DATE Null,
	governorate NVARCHAR (100) Null,
	city NVARCHAR (100) Null,
	registration_date DATE Null,
	membership_tier NVARCHAR (50) Null,
	acquisition_channel NVARCHAR (100) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_customer( customer_id,full_name,gender,birth_date,governorate,city,registration_date,membership_tier,acquisition_channel)
SELECT
	TRY_CAST(customer_id as INT ) as customer_id ,
	full_name ,
	gender ,
	TRY_CAST(birth_date as DATE ) as birth_date ,
	governorate ,
	city ,
	TRY_CAST(registration_date as DATE ) as registration_date ,
	membership_tier ,
	acquisition_channel
FROM bronze.dim_customer

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_customer
SELECT customer_id , full_name FROM silver.dim_customer where customer_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM SELLER */
DROP TABLE IF EXISTS silver.dim_seller ;
CREATE TABLE silver.dim_seller (
	seller_id INT Not Null,
	seller_name NVARCHAR (200) Null,
	seller_type NVARCHAR (50) Null,
	fulfillment_type NVARCHAR (50) Null,
	seller_rating DECIMAL(3,1) Null,
	join_date DATE Null,
	city NVARCHAR (100) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_seller( seller_id,seller_name,seller_type,fulfillment_type,seller_rating,join_date,city)
SELECT
	TRY_CAST(seller_id as INT ) as seller_id ,
	seller_name ,
	seller_type ,
	fulfillment_type ,
	TRY_CAST(seller_rating as DECIMAL(3,1) ) as seller_rating ,
	TRY_CAST(join_date as DATE ) as join_date ,
	city
FROM bronze.dim_seller

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_seller
SELECT seller_id , seller_name FROM silver.dim_seller where seller_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM PRODUCT */
-- must run AFTER dim_category and dim_seller (both already created)
DROP TABLE IF EXISTS silver.dim_product ;
CREATE TABLE silver.dim_product (
	product_id INT Not Null,
	category_id INT Not Null,
	product_name NVARCHAR (300) Null,
	brand NVARCHAR (100) Null,
	unit_cost DECIMAL(12,2) Null,
	list_price DECIMAL(12,2) Null,
	launch_date DATE Null,
	primary_seller_id INT Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_product( product_id,category_id,product_name,brand,unit_cost,list_price,launch_date,primary_seller_id)
SELECT
	TRY_CAST(product_id as INT ) as product_id ,
	TRY_CAST(category_id as INT ) as category_id ,
	product_name ,
	brand ,
	TRY_CAST(unit_cost as DECIMAL(12,2) ) as unit_cost ,
	TRY_CAST(list_price as DECIMAL(12,2) ) as list_price ,
	TRY_CAST(launch_date as DATE ) as launch_date ,
	TRY_CAST(primary_seller_id as INT ) as primary_seller_id
FROM bronze.dim_product

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_product
SELECT product_id , category_id FROM silver.dim_product where product_id is null or category_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM WAREHOUSE */
DROP TABLE IF EXISTS silver.dim_warehouse ;
CREATE TABLE silver.dim_warehouse (
	warehouse_id INT Not Null,
	warehouse_name NVARCHAR (200) Null,
	city NVARCHAR (100) Null,
	capacity_units INT Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_warehouse( warehouse_id,warehouse_name,city,capacity_units)
SELECT
	TRY_CAST(warehouse_id as INT ) as warehouse_id ,
	warehouse_name ,
	city ,
	TRY_CAST(capacity_units as INT ) as capacity_units
FROM bronze.dim_warehouse

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_warehouse
SELECT warehouse_id , warehouse_name FROM silver.dim_warehouse where warehouse_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM SHIPPING */
DROP TABLE IF EXISTS silver.dim_shipping ;
CREATE TABLE silver.dim_shipping (
	shipping_id INT Not Null,
	carrier NVARCHAR (100) Null,
	shipping_method NVARCHAR (100) Null,
	standard_delivery_days INT Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_shipping( shipping_id,carrier,shipping_method,standard_delivery_days)
SELECT
	TRY_CAST(shipping_id as INT ) as shipping_id ,
	carrier ,
	shipping_method ,
	TRY_CAST(standard_delivery_days as INT ) as standard_delivery_days
FROM bronze.dim_shipping

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_shipping
SELECT shipping_id , carrier FROM silver.dim_shipping where shipping_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM PAYMENT_METHOD */
DROP TABLE IF EXISTS silver.dim_payment_method ;
CREATE TABLE silver.dim_payment_method (
	payment_id INT Not Null,
	method_name NVARCHAR (100) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_payment_method( payment_id,method_name)
SELECT
	TRY_CAST(payment_id as INT ) as payment_id ,
	method_name
FROM bronze.dim_payment_method

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_payment_method
SELECT payment_id , method_name FROM silver.dim_payment_method where payment_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM PROMOTION */
DROP TABLE IF EXISTS silver.dim_promotion ;
CREATE TABLE silver.dim_promotion (
	promotion_id INT Not Null,
	campaign_name NVARCHAR (200) Null,
	promotion_type NVARCHAR (50) Null,
	discount_percentage DECIMAL(5,2) Null,
	start_date DATE Null,
	end_date DATE Null,
	target_category NVARCHAR (200) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_promotion( promotion_id,campaign_name,promotion_type,discount_percentage,start_date,end_date,target_category)
SELECT
	TRY_CAST(promotion_id as INT ) as promotion_id ,
	campaign_name ,
	promotion_type ,
	TRY_CAST(discount_percentage as DECIMAL(5,2) ) as discount_percentage ,
	TRY_CAST(start_date as DATE ) as start_date ,
	TRY_CAST(end_date as DATE ) as end_date ,
	target_category
FROM bronze.dim_promotion

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_promotion
SELECT promotion_id , campaign_name FROM silver.dim_promotion where promotion_id is null
/*--------------------------------------------------*/


/* CREATE SILVER DIM RETURN_REASON */
DROP TABLE IF EXISTS silver.dim_return_reason ;
CREATE TABLE silver.dim_return_reason (
	reason_id INT Not Null,
	reason_description NVARCHAR (200) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.dim_return_reason( reason_id,reason_description)
SELECT
	TRY_CAST(reason_id as INT ) as reason_id ,
	reason_description
FROM bronze.dim_return_reason

/* CHECK DATA */
SELECT COUNT(*) FROM silver.dim_return_reason
SELECT reason_id , reason_description FROM silver.dim_return_reason where reason_id is null
/*--------------------------------------------------*/



/* =====================================================================
   FACT TABLES - run only after ALL 13 dimensions exist (the 4 you
   already built: platform, adset, campaign, category + the 9 above)
   ===================================================================== */

/* CREATE SILVER FACT SALES */
DROP TABLE IF EXISTS silver.fact_sales ;
CREATE TABLE silver.fact_sales (
	order_line_id INT Not Null,
	order_id INT Not Null,
	date_id INT Not Null,
	product_id INT Not Null,
	customer_id INT Not Null,
	seller_id INT Not Null,
	shipping_id INT Not Null,
	payment_id INT Not Null,
	promotion_id INT Null,
	quantity INT Null,
	unit_price DECIMAL(12,2) Null,
	discount_amount DECIMAL(12,2) Null,
	total_amount DECIMAL(12,2) Null,
	commission_amount DECIMAL(12,2) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.fact_sales( order_line_id,order_id,date_id,product_id,customer_id,seller_id,shipping_id,payment_id,promotion_id,quantity,unit_price,discount_amount,total_amount,commission_amount)
SELECT
	TRY_CAST(order_line_id as INT ) as order_line_id ,
	TRY_CAST(order_id as INT ) as order_id ,
	TRY_CAST(date_id as INT ) as date_id ,
	TRY_CAST(product_id as INT ) as product_id ,
	TRY_CAST(customer_id as INT ) as customer_id ,
	TRY_CAST(seller_id as INT ) as seller_id ,
	TRY_CAST(shipping_id as INT ) as shipping_id ,
	TRY_CAST(payment_id as INT ) as payment_id ,
	TRY_CAST(promotion_id as INT ) as promotion_id ,   -- blank '' becomes NULL (no promo that day)
	TRY_CAST(quantity as INT ) as quantity ,
	TRY_CAST(unit_price as DECIMAL(12,2) ) as unit_price ,
	TRY_CAST(discount_amount as DECIMAL(12,2) ) as discount_amount ,
	TRY_CAST(total_amount as DECIMAL(12,2) ) as total_amount ,
	TRY_CAST(commission_amount as DECIMAL(12,2) ) as commission_amount
FROM bronze.fact_sales

/* CHECK DATA */
SELECT COUNT(*) FROM silver.fact_sales
SELECT order_line_id , order_id FROM silver.fact_sales where order_line_id is null or order_id is null
/*--------------------------------------------------*/


/* CREATE SILVER FACT RETURNS */
DROP TABLE IF EXISTS silver.fact_returns ;
CREATE TABLE silver.fact_returns (
	return_id INT Not Null,
	original_order_id INT Not Null,
	original_order_line_id INT Not Null,
	product_id INT Not Null,
	customer_id INT Not Null,
	seller_id INT Not Null,
	return_date_id INT Not Null,
	reason_id INT Not Null,
	quantity_returned INT Null,
	refund_amount DECIMAL(12,2) Null,
	days_since_purchase INT Null,
	return_status NVARCHAR (50) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.fact_returns( return_id,original_order_id,original_order_line_id,product_id,customer_id,seller_id,return_date_id,reason_id,quantity_returned,refund_amount,days_since_purchase,return_status)
SELECT
	TRY_CAST(return_id as INT ) as return_id ,
	TRY_CAST(original_order_id as INT ) as original_order_id ,
	TRY_CAST(original_order_line_id as INT ) as original_order_line_id ,
	TRY_CAST(product_id as INT ) as product_id ,
	TRY_CAST(customer_id as INT ) as customer_id ,
	TRY_CAST(seller_id as INT ) as seller_id ,
	TRY_CAST(return_date_id as INT ) as return_date_id ,
	TRY_CAST(reason_id as INT ) as reason_id ,
	TRY_CAST(quantity_returned as INT ) as quantity_returned ,
	TRY_CAST(refund_amount as DECIMAL(12,2) ) as refund_amount ,
	TRY_CAST(days_since_purchase as INT ) as days_since_purchase ,
	return_status
FROM bronze.fact_returns

/* CHECK DATA */
SELECT COUNT(*) FROM silver.fact_returns
SELECT return_id , original_order_id FROM silver.fact_returns where return_id is null
/*--------------------------------------------------*/


/* CREATE SILVER FACT REVIEWS */
DROP TABLE IF EXISTS silver.fact_reviews ;
CREATE TABLE silver.fact_reviews (
	review_id INT Not Null,
	order_line_id INT Not Null,
	product_id INT Not Null,
	customer_id INT Not Null,
	seller_id INT Not Null,
	review_date_id INT Not Null,
	rating INT Null,
	verified_purchase BIT Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.fact_reviews( review_id,order_line_id,product_id,customer_id,seller_id,review_date_id,rating,verified_purchase)
SELECT
	TRY_CAST(review_id as INT ) as review_id ,
	TRY_CAST(order_line_id as INT ) as order_line_id ,
	TRY_CAST(product_id as INT ) as product_id ,
	TRY_CAST(customer_id as INT ) as customer_id ,
	TRY_CAST(seller_id as INT ) as seller_id ,
	TRY_CAST(review_date_id as INT ) as review_date_id ,
	TRY_CAST(rating as INT ) as rating ,
	CASE WHEN verified_purchase = 'True' THEN 1 WHEN verified_purchase = 'False' THEN 0 END
FROM bronze.fact_reviews

/* CHECK DATA */
SELECT COUNT(*) FROM silver.fact_reviews
SELECT review_id , product_id FROM silver.fact_reviews where review_id is null
/*--------------------------------------------------*/


/* CREATE SILVER FACT MARKETING */
DROP TABLE IF EXISTS silver.fact_marketing ;
CREATE TABLE silver.fact_marketing (
	marketing_id INT Not Null,
	date_id INT Not Null,
	platform_id INT Not Null,
	campaign_id INT Not Null,
	adset_id INT Not Null,
	impressions INT Null,
	clicks INT Null,
	spend_egp DECIMAL(12,2) Null,
	conversions INT Null,
	attributed_revenue DECIMAL(12,2) Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.fact_marketing( marketing_id,date_id,platform_id,campaign_id,adset_id,impressions,clicks,spend_egp,conversions,attributed_revenue)
SELECT
	TRY_CAST(marketing_id as INT ) as marketing_id ,
	TRY_CAST(date_id as INT ) as date_id ,
	TRY_CAST(platform_id as INT ) as platform_id ,
	TRY_CAST(campaign_id as INT ) as campaign_id ,
	TRY_CAST(adset_id as INT ) as adset_id ,
	TRY_CAST(impressions as INT ) as impressions ,
	TRY_CAST(clicks as INT ) as clicks ,
	TRY_CAST(spend_egp as DECIMAL(12,2) ) as spend_egp ,
	TRY_CAST(conversions as INT ) as conversions ,
	TRY_CAST(attributed_revenue as DECIMAL(12,2) ) as attributed_revenue
FROM bronze.fact_marketing

/* CHECK DATA */
SELECT COUNT(*) FROM silver.fact_marketing
SELECT marketing_id , campaign_id FROM silver.fact_marketing where marketing_id is null
/*--------------------------------------------------*/


/* CREATE SILVER FACT INVENTORY */
DROP TABLE IF EXISTS silver.fact_inventory ;
CREATE TABLE silver.fact_inventory (
	inventory_id INT Not Null,
	week_date_id INT Not Null,
	product_id INT Not Null,
	warehouse_id INT Not Null,
	units_sold INT Null,
	units_received INT Null,
	stock_on_hand INT Null,
	reorder_level INT Null,
	stockout_flag BIT Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.fact_inventory( inventory_id,week_date_id,product_id,warehouse_id,units_sold,units_received,stock_on_hand,reorder_level,stockout_flag)
SELECT
	TRY_CAST(inventory_id as INT ) as inventory_id ,
	TRY_CAST(week_date_id as INT ) as week_date_id ,
	TRY_CAST(product_id as INT ) as product_id ,
	TRY_CAST(warehouse_id as INT ) as warehouse_id ,
	TRY_CAST(units_sold as INT ) as units_sold ,
	TRY_CAST(units_received as INT ) as units_received ,
	TRY_CAST(stock_on_hand as INT ) as stock_on_hand ,
	TRY_CAST(reorder_level as INT ) as reorder_level ,
	CASE WHEN stockout_flag = 'True' THEN 1 WHEN stockout_flag = 'False' THEN 0 END
FROM bronze.fact_inventory

/* CHECK DATA */
SELECT COUNT(*) FROM silver.fact_inventory
SELECT inventory_id , product_id FROM silver.fact_inventory where inventory_id is null
/*----------------------------------------------------------------------------------*/

/* CREATE SILVER FACT DELIVERY */
DROP TABLE IF EXISTS silver.fact_delivery ;
CREATE TABLE silver.fact_delivery (
	delivery_id INT Not Null,
	order_id INT Not Null,
	customer_id INT Not Null,
	warehouse_id INT Not Null,
	shipping_id INT Not Null,
	order_date_id INT Not Null,
	shipped_date_id INT Not Null,
	delivered_date_id INT Not Null,
	distance_km DECIMAL(10,2) Null,
	shipping_cost DECIMAL(10,2) Null,
	delivery_duration_days INT Null,
	on_time_flag BIT Null,
)
GO

/* INSERT DATA AFTER CLEANING FROM BRONZE TABLE */

INSERT INTO silver.fact_delivery( delivery_id,order_id,customer_id,warehouse_id,shipping_id,order_date_id,shipped_date_id,delivered_date_id,distance_km,shipping_cost,delivery_duration_days,on_time_flag)
SELECT
	TRY_CAST(delivery_id as INT ) as delivery_id ,
	TRY_CAST(order_id as INT ) as order_id ,
	TRY_CAST(customer_id as INT ) as customer_id ,
	TRY_CAST(warehouse_id as INT ) as warehouse_id ,
	TRY_CAST(shipping_id as INT ) as shipping_id ,
	TRY_CAST(order_date_id as INT ) as order_date_id ,
	TRY_CAST(shipped_date_id as INT ) as shipped_date_id ,
	TRY_CAST(delivered_date_id as INT ) as delivered_date_id ,
	TRY_CAST(distance_km as DECIMAL(10,2) ) as distance_km ,
	TRY_CAST(shipping_cost as DECIMAL(10,2) ) as shipping_cost ,
	TRY_CAST(delivery_duration_days as INT ) as delivery_duration_days ,
	CASE WHEN on_time_flag = 'True' THEN 1 WHEN on_time_flag = 'False' THEN 0 END
FROM bronze.fact_delivery

/* CHECK DATA */
SELECT COUNT(*) FROM silver.fact_delivery
SELECT delivery_id , order_id FROM silver.fact_delivery where delivery_id is null
/*--------------------------------------------------*/