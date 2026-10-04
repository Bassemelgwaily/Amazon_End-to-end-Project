CREATE OR ALTER PROCEDURE bronze.BulkInsert AS 
BEGIN

    -- dim_date
    TRUNCATE TABLE bronze.dim_date;

    BULK INSERT bronze.dim_date
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_date.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_customer
    TRUNCATE TABLE bronze.dim_customer;

    BULK INSERT bronze.dim_customer
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_customer.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_product
    TRUNCATE TABLE bronze.dim_product;

    BULK INSERT bronze.dim_product
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_product.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_category
    TRUNCATE TABLE bronze.dim_category;

    BULK INSERT bronze.dim_category
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_category.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_seller
    TRUNCATE TABLE bronze.dim_seller;

    BULK INSERT bronze.dim_seller
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_seller.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_warehouse
    TRUNCATE TABLE bronze.dim_warehouse;

    BULK INSERT bronze.dim_warehouse
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_warehouse.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_shipping
    TRUNCATE TABLE bronze.dim_shipping;

    BULK INSERT bronze.dim_shipping
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_shipping.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_payment_method
    TRUNCATE TABLE bronze.dim_payment_method;

    BULK INSERT bronze.dim_payment_method
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_payment_method.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
   

    -- dim_promotion
    TRUNCATE TABLE bronze.dim_promotion;

    BULK INSERT bronze.dim_promotion
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_promotion.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_return_reason
    TRUNCATE TABLE bronze.dim_return_reason;

    BULK INSERT bronze.dim_return_reason
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_return_reason.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_platform
    TRUNCATE TABLE bronze.dim_platform;

    BULK INSERT bronze.dim_platform
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_platform.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_campaign
    TRUNCATE TABLE bronze.dim_campaign;

    BULK INSERT bronze.dim_campaign
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_campaign.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- dim_adset
    TRUNCATE TABLE bronze.dim_adset;

    BULK INSERT bronze.dim_adset
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\dim_adset.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- fact_returns
    TRUNCATE TABLE bronze.fact_returns;

    BULK INSERT bronze.fact_returns
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\fact_returns.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- fact_reviews
    TRUNCATE TABLE bronze.fact_reviews;

    BULK INSERT bronze.fact_reviews
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\fact_reviews.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- fact_marketing
    TRUNCATE TABLE bronze.fact_marketing;

    BULK INSERT bronze.fact_marketing
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\fact_marketing.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- fact_inventory
    TRUNCATE TABLE bronze.fact_inventory;

    BULK INSERT bronze.fact_inventory
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\fact_inventory.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- fact_delivery
    TRUNCATE TABLE bronze.fact_delivery;

    BULK INSERT bronze.fact_delivery
    FROM 'D:\Big Projects\Amazon\amazon_egypt_dwh_dataset\fact_delivery.csv'
    WITH (
        FORMAT          = 'CSV',
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a',
        CODEPAGE        = '65001',
        TABLOCK
    );
    

    -- Row counts check
    SELECT 'fact_sales' AS tbl, COUNT(*) AS n FROM bronze.fact_sales
    UNION ALL
    SELECT 'dim_date' AS tbl, COUNT(*) AS n FROM bronze.dim_date
    UNION ALL
    SELECT 'dim_customer' AS tbl, COUNT(*) AS n FROM bronze.dim_customer
    UNION ALL
    SELECT 'dim_product' AS tbl, COUNT(*) AS n FROM bronze.dim_product
    UNION ALL
    SELECT 'dim_category' AS tbl, COUNT(*) AS n FROM bronze.dim_category
    UNION ALL
    SELECT 'dim_seller' AS tbl, COUNT(*) AS n FROM bronze.dim_seller
    UNION ALL
    SELECT 'dim_warehouse' AS tbl, COUNT(*) AS n FROM bronze.dim_warehouse
    UNION ALL
    SELECT 'dim_shipping' AS tbl, COUNT(*) AS n FROM bronze.dim_shipping
    UNION ALL
    SELECT 'dim_payment_method' AS tbl, COUNT(*) AS n FROM bronze.dim_payment_method
    UNION ALL
    SELECT 'dim_promotion' AS tbl, COUNT(*) AS n FROM bronze.dim_promotion
    UNION ALL
    SELECT 'dim_return_reason' AS tbl, COUNT(*) AS n FROM bronze.dim_return_reason
    UNION ALL
    SELECT 'dim_platform' AS tbl, COUNT(*) AS n FROM bronze.dim_platform
    UNION ALL
    SELECT 'dim_campaign' AS tbl, COUNT(*) AS n FROM bronze.dim_campaign
    UNION ALL
    SELECT 'dim_adset' AS tbl, COUNT(*) AS n FROM bronze.dim_adset
    UNION ALL
    SELECT 'fact_returns' AS tbl, COUNT(*) AS n FROM bronze.fact_returns
    UNION ALL
    SELECT 'fact_reviews' AS tbl, COUNT(*) AS n FROM bronze.fact_reviews
    UNION ALL
    SELECT 'fact_marketing' AS tbl, COUNT(*) AS n FROM bronze.fact_marketing
    UNION ALL
    SELECT 'fact_inventory' AS tbl, COUNT(*) AS n FROM bronze.fact_inventory
    UNION ALL
    SELECT 'fact_delivery' AS tbl, COUNT(*) AS n FROM bronze.fact_delivery;
    

END