/* =====================================================================
   GOLD LAYER - Tables copied AS-IS from Silver (no calculated columns)
   Order here only matters because of the FOREIGN KEY on
   dim_campaign -> dim_platform and dim_adset -> dim_campaign.
   Everything else is independent.
   ===================================================================== */

/* CREATE GOLD DIM DATE */
DROP TABLE IF EXISTS gold.dim_date ;
CREATE TABLE gold.dim_date (
	date_id INT PRIMARY KEY Not Null,
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

INSERT INTO gold.dim_date
SELECT * FROM silver.dim_date
GO

SELECT COUNT(*) FROM gold.dim_date
/*--------------------------------------------------*/


/* CREATE GOLD DIM WAREHOUSE */
DROP TABLE IF EXISTS gold.dim_warehouse ;
CREATE TABLE gold.dim_warehouse (
	warehouse_id INT PRIMARY KEY Not Null,
	warehouse_name NVARCHAR (200) Null,
	city NVARCHAR (100) Null,
	capacity_units INT Null,
)
GO

INSERT INTO gold.dim_warehouse
SELECT * FROM silver.dim_warehouse
GO

SELECT COUNT(*) FROM gold.dim_warehouse
/*--------------------------------------------------*/


/* CREATE GOLD DIM SHIPPING */
DROP TABLE IF EXISTS gold.dim_shipping ;
CREATE TABLE gold.dim_shipping (
	shipping_id INT PRIMARY KEY Not Null,
	carrier NVARCHAR (100) Null,
	shipping_method NVARCHAR (100) Null,
	standard_delivery_days INT Null,
)
GO

INSERT INTO gold.dim_shipping
SELECT * FROM silver.dim_shipping
GO

SELECT COUNT(*) FROM gold.dim_shipping
/*--------------------------------------------------*/


/* CREATE GOLD DIM PAYMENT_METHOD */
DROP TABLE IF EXISTS gold.dim_payment_method ;
CREATE TABLE gold.dim_payment_method (
	payment_id INT PRIMARY KEY Not Null,
	method_name NVARCHAR (100) Null,
)
GO

INSERT INTO gold.dim_payment_method
SELECT * FROM silver.dim_payment_method
GO

SELECT COUNT(*) FROM gold.dim_payment_method
/*--------------------------------------------------*/


/* CREATE GOLD DIM RETURN_REASON */
DROP TABLE IF EXISTS gold.dim_return_reason ;
CREATE TABLE gold.dim_return_reason (
	reason_id INT PRIMARY KEY Not Null,
	reason_description NVARCHAR (200) Null,
)
GO

INSERT INTO gold.dim_return_reason
SELECT * FROM silver.dim_return_reason
GO

SELECT COUNT(*) FROM gold.dim_return_reason
/*--------------------------------------------------*/


/* CREATE GOLD DIM SELLER */
DROP TABLE IF EXISTS gold.dim_seller ;
CREATE TABLE gold.dim_seller (
	seller_id INT PRIMARY KEY Not Null,
	seller_name NVARCHAR (200) Null,
	seller_type NVARCHAR (50) Null,
	fulfillment_type NVARCHAR (50) Null,
	seller_rating DECIMAL(3,1) Null,
	join_date DATE Null,
	city NVARCHAR (100) Null,
)
GO

INSERT INTO gold.dim_seller
SELECT * FROM silver.dim_seller
GO

SELECT COUNT(*) FROM gold.dim_seller
/*--------------------------------------------------*/


/* CREATE GOLD DIM PLATFORM  <-- must exist before dim_campaign (FK) */
DROP TABLE IF EXISTS gold.dim_platform ;
CREATE TABLE gold.dim_platform (
	platform_id INT PRIMARY KEY Not Null,
	platform_name NVARCHAR (100) Null,
)
GO

INSERT INTO gold.dim_platform
SELECT * FROM silver.dim_platform
GO

SELECT COUNT(*) FROM gold.dim_platform
/*--------------------------------------------------*/


/* CREATE GOLD DIM CAMPAIGN  <-- references dim_platform, must come after it */
DROP TABLE IF EXISTS gold.dim_campaign ;
CREATE TABLE gold.dim_campaign (
	campaign_id INT PRIMARY KEY Not Null,
	campaign_name NVARCHAR (300) Null,
	platform_id INT Not Null,
	objective NVARCHAR (100) Null,
	start_date DATE Null,
	end_date DATE Null,
	budget_egp DECIMAL(12,2) Null,
	CONSTRAINT FK_gold_campaign_platform FOREIGN KEY (platform_id) REFERENCES gold.dim_platform(platform_id)
)
GO

INSERT INTO gold.dim_campaign
SELECT * FROM silver.dim_campaign
GO

SELECT COUNT(*) FROM gold.dim_campaign
/*--------------------------------------------------*/


/* CREATE GOLD DIM ADSET  <-- references dim_campaign, must come after it */
DROP TABLE IF EXISTS gold.dim_adset ;
CREATE TABLE gold.dim_adset (
	adset_id INT PRIMARY KEY Not Null,
	campaign_id INT Not Null,
	adset_name NVARCHAR (400) Null,
	target_age_group NVARCHAR (50) Null,
	target_gender NVARCHAR (50) Null,
	CONSTRAINT FK_gold_adset_campaign FOREIGN KEY (campaign_id) REFERENCES gold.dim_campaign(campaign_id)
)
GO

INSERT INTO gold.dim_adset
SELECT * FROM silver.dim_adset
GO

SELECT COUNT(*) FROM gold.dim_adset
/*--------------------------------------------------*/

/* =====================================================================
   GOLD LAYER - Enriched tables (calculated columns + Foreign Keys)
   Order matters here:
     1) dim_category   (self-referencing FK, needed by dim_product)
     2) dim_promotion   (needed by fact_sales FK)
     3) dim_customer    (+ customer_age)
     4) dim_product     (+ top_category_name, needs dim_category + gold.dim_seller)
     5) fact_sales       (+ profit, profit_margin_pct, net_revenue_seller)
     6) fact_marketing   (+ ctr, cvr, cpc, roas)
     7) fact_inventory   (+ days_of_supply, stock_health)
   Prerequisite from before: gold.dim_date, dim_warehouse, dim_shipping,
   dim_payment_method, dim_return_reason, dim_seller, dim_platform,
   dim_campaign, dim_adset must already exist.
   ===================================================================== */

/* CREATE GOLD DIM CATEGORY  (self-referencing FK: a child row points to its parent row) */
DROP TABLE IF EXISTS gold.dim_category ;
CREATE TABLE gold.dim_category (
	category_id INT PRIMARY KEY Not Null,
	category_name NVARCHAR (200) Null,
	parent_category_id INT Null,
	CONSTRAINT FK_gold_category_parent FOREIGN KEY (parent_category_id) REFERENCES gold.dim_category(category_id)
)
GO

INSERT INTO gold.dim_category
SELECT * FROM silver.dim_category
GO

SELECT COUNT(*) FROM gold.dim_category
/*--------------------------------------------------*/


/* CREATE GOLD DIM PROMOTION  (plain copy, needed as a FK target for fact_sales) */
DROP TABLE IF EXISTS gold.dim_promotion ;
CREATE TABLE gold.dim_promotion (
	promotion_id INT PRIMARY KEY Not Null,
	campaign_name NVARCHAR (200) Null,
	promotion_type NVARCHAR (50) Null,
	discount_percentage DECIMAL(5,2) Null,
	start_date DATE Null,
	end_date DATE Null,
	target_category NVARCHAR (200) Null,
)
GO

INSERT INTO gold.dim_promotion
SELECT * FROM silver.dim_promotion
GO

SELECT COUNT(*) FROM gold.dim_promotion
/*--------------------------------------------------*/


/* CREATE GOLD DIM CUSTOMER  (+ customer_age, calculated from birth_date) */
DROP TABLE IF EXISTS gold.dim_customer ;
CREATE TABLE gold.dim_customer (
	customer_id INT PRIMARY KEY Not Null,
	full_name NVARCHAR (200) Null,
	gender NVARCHAR (20) Null,
	birth_date DATE Null,
	customer_age INT Null,
	governorate NVARCHAR (100) Null,
	city NVARCHAR (100) Null,
	registration_date DATE Null,
	membership_tier NVARCHAR (50) Null,
	acquisition_channel NVARCHAR (100) Null,
)
GO

/* INSERT WITH CALCULATED COLUMN: customer_age */
INSERT INTO gold.dim_customer (customer_id, full_name, gender, birth_date, customer_age, governorate, city, registration_date, membership_tier, acquisition_channel)
SELECT
	customer_id,
	full_name,
	gender,
	birth_date,
	DATEDIFF(YEAR, birth_date, GETDATE())
		- CASE WHEN (MONTH(birth_date) > MONTH(GETDATE()))
			     OR (MONTH(birth_date) = MONTH(GETDATE()) AND DAY(birth_date) > DAY(GETDATE()))
			THEN 1 ELSE 0 END AS customer_age,   -- subtract 1 if birthday hasn't happened yet this year
	governorate,
	city,
	registration_date,
	membership_tier,
	acquisition_channel
FROM silver.dim_customer
GO

SELECT COUNT(*) FROM gold.dim_customer
SELECT TOP 5 customer_id, birth_date, customer_age FROM gold.dim_customer
/*--------------------------------------------------*/


/* CREATE GOLD DIM PRODUCT  (+ top_category_name, needs dim_category joined TWICE) */
DROP TABLE IF EXISTS gold.dim_product ;
CREATE TABLE gold.dim_product (
	product_id INT PRIMARY KEY Not Null,
	category_id INT Not Null,
	category_name NVARCHAR (200) Null,
	top_category_name NVARCHAR (200) Null,
	product_name NVARCHAR (300) Null,
	brand NVARCHAR (100) Null,
	unit_cost DECIMAL(12,2) Null,
	list_price DECIMAL(12,2) Null,
	launch_date DATE Null,
	primary_seller_id INT Null,
	CONSTRAINT FK_gold_product_category FOREIGN KEY (category_id) REFERENCES gold.dim_category(category_id),
	CONSTRAINT FK_gold_product_seller   FOREIGN KEY (primary_seller_id) REFERENCES gold.dim_seller(seller_id)
)
GO

/* INSERT WITH CALCULATED COLUMN: top_category_name
   dim_category joined once to get the leaf category's own name (c),
   joined a second time (parent) to climb up to the top-level category. */
INSERT INTO gold.dim_product (product_id, category_id, category_name, top_category_name, product_name, brand, unit_cost, list_price, launch_date, primary_seller_id)
SELECT
	p.product_id,
	p.category_id,
	c.category_name,
	COALESCE(parent.category_name, c.category_name) AS top_category_name,  -- if no parent, the category itself IS top-level
	p.product_name,
	p.brand,
	p.unit_cost,
	p.list_price,
	p.launch_date,
	p.primary_seller_id
FROM silver.dim_product p
JOIN silver.dim_category c      ON p.category_id = c.category_id
LEFT JOIN silver.dim_category parent ON c.parent_category_id = parent.category_id
GO

SELECT COUNT(*) FROM gold.dim_product
SELECT TOP 5 product_id, category_name, top_category_name FROM gold.dim_product
/*--------------------------------------------------*/


/* CREATE GOLD FACT SALES  (+ total_cost, profit, profit_margin_pct, net_revenue_seller) */
DROP TABLE IF EXISTS gold.fact_sales ;
CREATE TABLE gold.fact_sales (
	order_line_id INT PRIMARY KEY Not Null,
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
	total_cost DECIMAL(12,2) Null,
	profit DECIMAL(12,2) Null,
	profit_margin_pct DECIMAL(6,2) Null,
	net_revenue_seller DECIMAL(12,2) Null,
	CONSTRAINT FK_gold_sales_date       FOREIGN KEY (date_id)       REFERENCES gold.dim_date(date_id),
	CONSTRAINT FK_gold_sales_product    FOREIGN KEY (product_id)    REFERENCES gold.dim_product(product_id),
	CONSTRAINT FK_gold_sales_customer   FOREIGN KEY (customer_id)   REFERENCES gold.dim_customer(customer_id),
	CONSTRAINT FK_gold_sales_seller     FOREIGN KEY (seller_id)     REFERENCES gold.dim_seller(seller_id),
	CONSTRAINT FK_gold_sales_shipping   FOREIGN KEY (shipping_id)   REFERENCES gold.dim_shipping(shipping_id),
	CONSTRAINT FK_gold_sales_payment    FOREIGN KEY (payment_id)    REFERENCES gold.dim_payment_method(payment_id),
	CONSTRAINT FK_gold_sales_promotion  FOREIGN KEY (promotion_id)  REFERENCES gold.dim_promotion(promotion_id)
)
GO

/* INSERT WITH CALCULATED COLUMNS: needs dim_product joined for unit_cost */
INSERT INTO gold.fact_sales (order_line_id, order_id, date_id, product_id, customer_id, seller_id, shipping_id, payment_id, promotion_id, quantity, unit_price, discount_amount, total_amount, commission_amount, total_cost, profit, profit_margin_pct, net_revenue_seller)
SELECT
	f.order_line_id,
	f.order_id,
	f.date_id,
	f.product_id,
	f.customer_id,
	f.seller_id,
	f.shipping_id,
	f.payment_id,
	f.promotion_id,
	f.quantity,
	f.unit_price,
	f.discount_amount,
	f.total_amount,
	f.commission_amount,
	(f.quantity * p.unit_cost) AS total_cost,
	(f.total_amount - (f.quantity * p.unit_cost) - f.commission_amount) AS profit,
	CASE WHEN f.total_amount > 0
		THEN ROUND((f.total_amount - (f.quantity * p.unit_cost) - f.commission_amount) / f.total_amount * 100, 2)
		ELSE NULL END AS profit_margin_pct,
	(f.total_amount - f.commission_amount) AS net_revenue_seller
FROM silver.fact_sales f
JOIN silver.dim_product p ON f.product_id = p.product_id
GO

SELECT COUNT(*) FROM gold.fact_sales
SELECT TOP 5 order_line_id, total_amount, total_cost, profit, profit_margin_pct FROM gold.fact_sales
/*--------------------------------------------------*/


/* CREATE GOLD FACT MARKETING  (+ ctr, cvr, cpc, roas) */
DROP TABLE IF EXISTS gold.fact_marketing ;
CREATE TABLE gold.fact_marketing (
	marketing_id INT PRIMARY KEY Not Null,
	date_id INT Not Null,
	platform_id INT Not Null,
	campaign_id INT Not Null,
	adset_id INT Not Null,
	impressions INT Null,
	clicks INT Null,
	spend_egp DECIMAL(12,2) Null,
	conversions INT Null,
	attributed_revenue DECIMAL(12,2) Null,
	ctr DECIMAL(6,4) Null,
	cvr DECIMAL(6,4) Null,
	cpc DECIMAL(10,2) Null,
	roas DECIMAL(10,2) Null,
	CONSTRAINT FK_gold_mkt_date     FOREIGN KEY (date_id)     REFERENCES gold.dim_date(date_id),
	CONSTRAINT FK_gold_mkt_platform FOREIGN KEY (platform_id) REFERENCES gold.dim_platform(platform_id),
	CONSTRAINT FK_gold_mkt_campaign FOREIGN KEY (campaign_id) REFERENCES gold.dim_campaign(campaign_id),
	CONSTRAINT FK_gold_mkt_adset    FOREIGN KEY (adset_id)    REFERENCES gold.dim_adset(adset_id)
)
GO

/* INSERT WITH CALCULATED COLUMNS:
   ctr  = clicks / impressions        (Click-Through Rate)
   cvr  = conversions / clicks        (Conversion Rate)
   cpc  = spend / clicks              (Cost Per Click)
   roas = attributed_revenue / spend  (Return On Ad Spend) */
INSERT INTO gold.fact_marketing (marketing_id, date_id, platform_id, campaign_id, adset_id, impressions, clicks, spend_egp, conversions, attributed_revenue, ctr, cvr, cpc, roas)
SELECT
	marketing_id,
	date_id,
	platform_id,
	campaign_id,
	adset_id,
	impressions,
	clicks,
	spend_egp,
	conversions,
	attributed_revenue,
	CASE WHEN impressions > 0 THEN ROUND(CAST(clicks AS DECIMAL(12,4)) / impressions, 4) ELSE NULL END AS ctr,
	CASE WHEN clicks > 0      THEN ROUND(CAST(conversions AS DECIMAL(12,4)) / clicks, 4) ELSE NULL END AS cvr,
	CASE WHEN clicks > 0      THEN ROUND(spend_egp / clicks, 2) ELSE NULL END AS cpc,
	CASE WHEN spend_egp > 0   THEN ROUND(attributed_revenue / spend_egp, 2) ELSE NULL END AS roas
FROM silver.fact_marketing
GO

SELECT COUNT(*) FROM gold.fact_marketing
SELECT TOP 5 marketing_id, ctr, cvr, cpc, roas FROM gold.fact_marketing
/*--------------------------------------------------*/


/* CREATE GOLD FACT INVENTORY  (+ days_of_supply, stock_health) */
DROP TABLE IF EXISTS gold.fact_inventory ;
CREATE TABLE gold.fact_inventory (
	inventory_id INT PRIMARY KEY Not Null,
	week_date_id INT Not Null,
	product_id INT Not Null,
	warehouse_id INT Not Null,
	units_sold INT Null,
	units_received INT Null,
	stock_on_hand INT Null,
	reorder_level INT Null,
	stockout_flag BIT Null,
	days_of_supply DECIMAL(10,1) Null,
	stock_health NVARCHAR (20) Null,
	CONSTRAINT FK_gold_inv_date      FOREIGN KEY (week_date_id) REFERENCES gold.dim_date(date_id),
	CONSTRAINT FK_gold_inv_product   FOREIGN KEY (product_id)   REFERENCES gold.dim_product(product_id),
	CONSTRAINT FK_gold_inv_warehouse FOREIGN KEY (warehouse_id) REFERENCES gold.dim_warehouse(warehouse_id)
)
GO

/* INSERT WITH CALCULATED COLUMNS:
   days_of_supply = stock_on_hand / (units_sold per day)   -- units_sold here is WEEKLY, so divide by 7
   stock_health   = Critical if actually out of stock, Low if at/under reorder point, else Healthy */
INSERT INTO gold.fact_inventory (inventory_id, week_date_id, product_id, warehouse_id, units_sold, units_received, stock_on_hand, reorder_level, stockout_flag, days_of_supply, stock_health)
SELECT
	inventory_id,
	week_date_id,
	product_id,
	warehouse_id,
	units_sold,
	units_received,
	stock_on_hand,
	reorder_level,
	stockout_flag,
	CASE WHEN units_sold > 0 THEN ROUND(stock_on_hand / (units_sold / 7.0), 1) ELSE NULL END AS days_of_supply,
	CASE WHEN stockout_flag = 1          THEN 'Critical'
	     WHEN stock_on_hand <= reorder_level THEN 'Low'
	     ELSE 'Healthy' END AS stock_health
FROM silver.fact_inventory
GO

SELECT COUNT(*) FROM gold.fact_inventory
SELECT TOP 5 inventory_id, stock_on_hand, days_of_supply, stock_health FROM gold.fact_inventory
SELECT stock_health, COUNT(*) FROM gold.fact_inventory GROUP BY stock_health
/*--------------------------------------------------*/


/* =====================================================================
   GOLD LAYER - Last 3 tables (plain copies from Silver, with FKs)
   Run AFTER scripts 05 and 06 (needs dim_product, dim_customer,
   dim_seller, dim_date, dim_return_reason, dim_warehouse, dim_shipping
   already created in gold).

   Note on order_id / order_line_id in these 3 tables: they stay as
   plain reference numbers (Degenerate Dimensions), NOT a Foreign Key
   to gold.fact_sales - same design decision as before: these 3 facts
   stand on their own, not hard-linked to fact_sales.
   ===================================================================== */

/* CREATE GOLD FACT RETURNS */
DROP TABLE IF EXISTS gold.fact_returns ;
CREATE TABLE gold.fact_returns (
	return_id INT PRIMARY KEY Not Null,
	original_order_id INT Not Null,          -- degenerate dimension, no FK
	original_order_line_id INT Not Null,     -- degenerate dimension, no FK
	product_id INT Not Null,
	customer_id INT Not Null,
	seller_id INT Not Null,
	return_date_id INT Not Null,
	reason_id INT Not Null,
	quantity_returned INT Null,
	refund_amount DECIMAL(12,2) Null,
	days_since_purchase INT Null,
	return_status NVARCHAR (50) Null,
	CONSTRAINT FK_gold_returns_product  FOREIGN KEY (product_id)     REFERENCES gold.dim_product(product_id),
	CONSTRAINT FK_gold_returns_customer FOREIGN KEY (customer_id)    REFERENCES gold.dim_customer(customer_id),
	CONSTRAINT FK_gold_returns_seller   FOREIGN KEY (seller_id)      REFERENCES gold.dim_seller(seller_id),
	CONSTRAINT FK_gold_returns_date     FOREIGN KEY (return_date_id) REFERENCES gold.dim_date(date_id),
	CONSTRAINT FK_gold_returns_reason   FOREIGN KEY (reason_id)      REFERENCES gold.dim_return_reason(reason_id)
)
GO

INSERT INTO gold.fact_returns
SELECT * FROM silver.fact_returns
GO

SELECT COUNT(*) FROM gold.fact_returns
/*--------------------------------------------------*/


/* CREATE GOLD FACT REVIEWS */
DROP TABLE IF EXISTS gold.fact_reviews ;
CREATE TABLE gold.fact_reviews (
	review_id INT PRIMARY KEY Not Null,
	order_line_id INT Not Null,              -- degenerate dimension, no FK
	product_id INT Not Null,
	customer_id INT Not Null,
	seller_id INT Not Null,
	review_date_id INT Not Null,
	rating INT Null,
	verified_purchase BIT Null,
	CONSTRAINT FK_gold_reviews_product  FOREIGN KEY (product_id)      REFERENCES gold.dim_product(product_id),
	CONSTRAINT FK_gold_reviews_customer FOREIGN KEY (customer_id)     REFERENCES gold.dim_customer(customer_id),
	CONSTRAINT FK_gold_reviews_seller   FOREIGN KEY (seller_id)       REFERENCES gold.dim_seller(seller_id),
	CONSTRAINT FK_gold_reviews_date     FOREIGN KEY (review_date_id)  REFERENCES gold.dim_date(date_id)
)
GO

INSERT INTO gold.fact_reviews
SELECT * FROM silver.fact_reviews
GO

SELECT COUNT(*) FROM gold.fact_reviews
/*--------------------------------------------------*/


/* CREATE GOLD FACT DELIVERY  (role-playing date dimension: 3 FKs to the SAME dim_date table) */
DROP TABLE IF EXISTS gold.fact_delivery ;
CREATE TABLE gold.fact_delivery (
	delivery_id INT PRIMARY KEY Not Null,
	order_id INT Not Null,                   -- degenerate dimension, no FK
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
	CONSTRAINT FK_gold_delivery_customer      FOREIGN KEY (customer_id)        REFERENCES gold.dim_customer(customer_id),
	CONSTRAINT FK_gold_delivery_warehouse     FOREIGN KEY (warehouse_id)       REFERENCES gold.dim_warehouse(warehouse_id),
	CONSTRAINT FK_gold_delivery_shipping      FOREIGN KEY (shipping_id)        REFERENCES gold.dim_shipping(shipping_id),
	CONSTRAINT FK_gold_delivery_order_date    FOREIGN KEY (order_date_id)      REFERENCES gold.dim_date(date_id),
	CONSTRAINT FK_gold_delivery_shipped_date  FOREIGN KEY (shipped_date_id)    REFERENCES gold.dim_date(date_id),
	CONSTRAINT FK_gold_delivery_delivered_date FOREIGN KEY (delivered_date_id) REFERENCES gold.dim_date(date_id)
)
GO

INSERT INTO gold.fact_delivery
SELECT * FROM silver.fact_delivery
GO

SELECT COUNT(*) FROM gold.fact_delivery
/*--------------------------------------------------*/


/* FINAL CHECK: all 19 gold tables should now exist */
SELECT COUNT(*) AS gold_tables_count FROM sys.tables WHERE schema_id = SCHEMA_ID('gold');
SELECT name FROM sys.tables WHERE schema_id = SCHEMA_ID('gold') ORDER BY name;