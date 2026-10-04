
-- ---------------------------------------------------------------------
-- 1) Schemas (one per layer)
-- ---------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver') EXEC('CREATE SCHEMA silver');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')   EXEC('CREATE SCHEMA gold');
GO

-- ---------------------------------------------------------------------
-- 2) Bronze - Dimension tables
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.dim_date;
CREATE TABLE bronze.dim_date (
    date_id             NVARCHAR(50),
    full_date           NVARCHAR(50),
    [day]               NVARCHAR(50),
    [month]             NVARCHAR(50),
    month_name          NVARCHAR(50),
    [quarter]           NVARCHAR(50),
    [year]              NVARCHAR(50),
    day_name            NVARCHAR(50),
    is_weekend          NVARCHAR(50),
    is_holiday_season   NVARCHAR(50),
    holiday_name        NVARCHAR(100)
);

DROP TABLE IF EXISTS bronze.dim_customer;
CREATE TABLE bronze.dim_customer (
    customer_id         NVARCHAR(50),
    full_name           NVARCHAR(200),
    gender              NVARCHAR(50),
    birth_date          NVARCHAR(50),
    governorate         NVARCHAR(100),
    city                NVARCHAR(100),
    registration_date   NVARCHAR(50),
    membership_tier     NVARCHAR(50),
    acquisition_channel NVARCHAR(100)
);

DROP TABLE IF EXISTS bronze.dim_product;
CREATE TABLE bronze.dim_product (
    product_id          NVARCHAR(50),
    category_id         NVARCHAR(50),
    product_name        NVARCHAR(300),
    brand               NVARCHAR(100),
    unit_cost           NVARCHAR(50),
    list_price          NVARCHAR(50),
    launch_date         NVARCHAR(50),
    primary_seller_id   NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.dim_category;
CREATE TABLE bronze.dim_category (
    category_id         NVARCHAR(50),
    category_name       NVARCHAR(200),
    parent_category_id  NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.dim_seller;
CREATE TABLE bronze.dim_seller (
    seller_id           NVARCHAR(50),
    seller_name         NVARCHAR(200),
    seller_type         NVARCHAR(50),
    fulfillment_type    NVARCHAR(50),
    seller_rating       NVARCHAR(50),
    join_date           NVARCHAR(50),
    city                NVARCHAR(100)
);

DROP TABLE IF EXISTS bronze.dim_warehouse;
CREATE TABLE bronze.dim_warehouse (
    warehouse_id        NVARCHAR(50),
    warehouse_name      NVARCHAR(200),
    city                NVARCHAR(100),
    capacity_units      NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.dim_shipping;
CREATE TABLE bronze.dim_shipping (
    shipping_id             NVARCHAR(50),
    carrier                 NVARCHAR(100),
    shipping_method         NVARCHAR(100),
    standard_delivery_days  NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.dim_payment_method;
CREATE TABLE bronze.dim_payment_method (
    payment_id          NVARCHAR(50),
    method_name         NVARCHAR(100)
);

DROP TABLE IF EXISTS bronze.dim_promotion;
CREATE TABLE bronze.dim_promotion (
    promotion_id        NVARCHAR(50),
    campaign_name       NVARCHAR(200),
    promotion_type      NVARCHAR(50),
    discount_percentage NVARCHAR(50),
    start_date          NVARCHAR(50),
    end_date            NVARCHAR(50),
    target_category     NVARCHAR(200)
);

DROP TABLE IF EXISTS bronze.dim_return_reason;
CREATE TABLE bronze.dim_return_reason (
    reason_id           NVARCHAR(50),
    reason_description  NVARCHAR(200)
);

DROP TABLE IF EXISTS bronze.dim_platform;
CREATE TABLE bronze.dim_platform (
    platform_id         NVARCHAR(50),
    platform_name       NVARCHAR(100)
);

DROP TABLE IF EXISTS bronze.dim_campaign;
CREATE TABLE bronze.dim_campaign (
    campaign_id         NVARCHAR(50),
    campaign_name       NVARCHAR(300),
    platform_id         NVARCHAR(50),
    objective           NVARCHAR(100),
    start_date          NVARCHAR(50),
    end_date            NVARCHAR(50),
    budget_egp          NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.dim_adset;
CREATE TABLE bronze.dim_adset (
    adset_id            NVARCHAR(50),
    campaign_id         NVARCHAR(50),
    adset_name          NVARCHAR(400),
    target_age_group    NVARCHAR(50),
    target_gender       NVARCHAR(50)
);

-- ---------------------------------------------------------------------
-- 3) Bronze - Fact tables
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.fact_sales;
CREATE TABLE bronze.fact_sales (
    order_line_id       NVARCHAR(50),
    order_id            NVARCHAR(50),
    date_id             NVARCHAR(50),
    product_id          NVARCHAR(50),
    customer_id         NVARCHAR(50),
    seller_id           NVARCHAR(50),
    shipping_id         NVARCHAR(50),
    payment_id          NVARCHAR(50),
    promotion_id        NVARCHAR(50),
    quantity            NVARCHAR(50),
    unit_price          NVARCHAR(50),
    discount_amount     NVARCHAR(50),
    total_amount        NVARCHAR(50),
    commission_amount   NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.fact_returns;
CREATE TABLE bronze.fact_returns (
    return_id               NVARCHAR(50),
    original_order_id       NVARCHAR(50),
    original_order_line_id  NVARCHAR(50),
    product_id              NVARCHAR(50),
    customer_id             NVARCHAR(50),
    seller_id               NVARCHAR(50),
    return_date_id          NVARCHAR(50),
    reason_id               NVARCHAR(50),
    quantity_returned       NVARCHAR(50),
    refund_amount           NVARCHAR(50),
    days_since_purchase     NVARCHAR(50),
    return_status           NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.fact_reviews;
CREATE TABLE bronze.fact_reviews (
    review_id           NVARCHAR(50),
    order_line_id       NVARCHAR(50),
    product_id          NVARCHAR(50),
    customer_id         NVARCHAR(50),
    seller_id           NVARCHAR(50),
    review_date_id      NVARCHAR(50),
    rating              NVARCHAR(50),
    verified_purchase   NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.fact_marketing;
CREATE TABLE bronze.fact_marketing (
    marketing_id        NVARCHAR(50),
    date_id             NVARCHAR(50),
    platform_id         NVARCHAR(50),
    campaign_id         NVARCHAR(50),
    adset_id            NVARCHAR(50),
    impressions         NVARCHAR(50),
    clicks              NVARCHAR(50),
    spend_egp           NVARCHAR(50),
    conversions         NVARCHAR(50),
    attributed_revenue  NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.fact_inventory;
CREATE TABLE bronze.fact_inventory (
    inventory_id        NVARCHAR(50),
    week_date_id        NVARCHAR(50),
    product_id          NVARCHAR(50),
    warehouse_id        NVARCHAR(50),
    units_sold          NVARCHAR(50),
    units_received      NVARCHAR(50),
    stock_on_hand       NVARCHAR(50),
    reorder_level       NVARCHAR(50),
    stockout_flag       NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.fact_delivery;
CREATE TABLE bronze.fact_delivery (
    delivery_id             NVARCHAR(50),
    order_id                NVARCHAR(50),
    customer_id             NVARCHAR(50),
    warehouse_id            NVARCHAR(50),
    shipping_id             NVARCHAR(50),
    order_date_id           NVARCHAR(50),
    shipped_date_id         NVARCHAR(50),
    delivered_date_id       NVARCHAR(50),
    distance_km             NVARCHAR(50),
    shipping_cost           NVARCHAR(50),
    delivery_duration_days  NVARCHAR(50),
    on_time_flag            NVARCHAR(50)
);
GO

