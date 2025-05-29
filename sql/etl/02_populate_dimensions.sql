-- Populate Customer and Product Dimensions
USE ECommerceAnalytics;
GO

-- ======================
-- CUSTOMER DIMENSION
-- ======================

PRINT 'Populating Customer Dimension...';

-- Temporarily disable the foreign key constraint on FactSales that references DimCustomer
-- You MUST use the exact foreign key name you found. (e.g., FK_FactSales_Customer)
ALTER TABLE dw.FactSales NOCHECK CONSTRAINT FK_FactSales_Customer;

-- Clear existing data using DELETE FROM
DELETE FROM dw.DimCustomer;

-- Insert customers with aggregated metrics
INSERT INTO dw.DimCustomer (
    CustomerID,
    Country,
    FirstPurchaseDate,
    LastPurchaseDate,
    TotalOrders,
    TotalSpent
)
SELECT
    CustomerID,
    -- Aggregated Country: Choose one if a customer has multiple.
    MIN(Country) as Country, -- Picks the alphabetically first country if a customer appears in multiple
    MIN(CAST(InvoiceDate AS DATE)) as FirstPurchaseDate,
    MAX(CAST(InvoiceDate AS DATE)) as LastPurchaseDate,
    COUNT(DISTINCT InvoiceNo) as TotalOrders,
    ROUND(SUM(Quantity * UnitPrice), 2) as TotalSpent
FROM staging.raw_sales
WHERE CustomerID IS NOT NULL
    AND CustomerID != ''
GROUP BY CustomerID; -- Corrected: Grouping only by CustomerID

-- Update IsActive flag (customers who purchased in last 365 days from max date)
DECLARE @MaxDate DATE = (SELECT MAX(CAST(InvoiceDate AS DATE)) FROM staging.raw_sales);

UPDATE dw.DimCustomer
SET IsActive = CASE
    WHEN DATEDIFF(DAY, LastPurchaseDate, @MaxDate) <= 365 THEN 1
    ELSE 0
END;

-- Re-enable and check the foreign key constraint on FactSales for DimCustomer
ALTER TABLE dw.FactSales WITH CHECK CHECK CONSTRAINT FK_FactSales_Customer;

PRINT 'Customer Dimension completed.';
SELECT COUNT(*) as CustomerCount FROM dw.DimCustomer;

---
-- ======================
-- PRODUCT DIMENSION
-- ======================

PRINT 'Populating Product Dimension...';

-- Temporarily disable the foreign key constraint on FactSales that references DimProduct
-- You MUST use the exact foreign key name you found for DimProduct. (e.g., FK_FactSales_Product)
ALTER TABLE dw.FactSales NOCHECK CONSTRAINT FK_FactSales_Product;

-- Clear existing data using DELETE FROM
DELETE FROM dw.DimProduct;

-- Insert products with basic categorization
INSERT INTO dw.DimProduct (
    StockCode,
    Description,
    Category,
    UnitPrice
)
SELECT
    StockCode,
    MIN(Description) as Description, -- Aggregated Description for the DimProduct table
    -- Apply aggregate function to Description in the CASE statement for Category
    CASE
        WHEN UPPER(MIN(Description)) LIKE '%CHRISTMAS%' OR UPPER(MIN(Description)) LIKE '%XMAS%' THEN 'Christmas'
        WHEN UPPER(MIN(Description)) LIKE '%BIRTHDAY%' THEN 'Birthday'
        WHEN UPPER(MIN(Description)) LIKE '%WEDDING%' THEN 'Wedding'
        WHEN UPPER(MIN(Description)) LIKE '%VINTAGE%' OR UPPER(MIN(Description)) LIKE '%ANTIQUE%' THEN 'Vintage'
        WHEN UPPER(MIN(Description)) LIKE '%KITCHEN%' OR UPPER(MIN(Description)) LIKE '%COOK%' THEN 'Kitchen'
        WHEN UPPER(MIN(Description)) LIKE '%GARDEN%' OR UPPER(MIN(Description)) LIKE '%PLANT%' THEN 'Garden'
        WHEN UPPER(MIN(Description)) LIKE '%LIGHT%' OR UPPER(MIN(Description)) LIKE '%LAMP%' THEN 'Lighting'
        WHEN UPPER(MIN(Description)) LIKE '%BAG%' OR UPPER(MIN(Description)) LIKE '%BASKET%' THEN 'Storage'
        WHEN UPPER(MIN(Description)) LIKE '%CARD%' OR UPPER(MIN(Description)) LIKE '%PAPER%' THEN 'Stationery'
        WHEN UPPER(MIN(Description)) LIKE '%TOY%' OR UPPER(MIN(Description)) LIKE '%GAME%' THEN 'Toys'
        WHEN UPPER(MIN(Description)) LIKE '%JEWELLERY%' OR UPPER(MIN(Description)) LIKE '%NECKLACE%' OR UPPER(MIN(Description)) LIKE '%BRACELET%' THEN 'Jewellery'
        WHEN UPPER(MIN(Description)) LIKE '%CANDLE%' OR UPPER(MIN(Description)) LIKE '%FRAGRANCE%' THEN 'Home Fragrance'
        WHEN UPPER(MIN(Description)) LIKE '%FABRIC%' OR UPPER(MIN(Description)) LIKE '%TEXTILE%' THEN 'Textiles'
        WHEN UPPER(MIN(Description)) LIKE '%METAL%' OR UPPER(MIN(Description)) LIKE '%STEEL%' OR UPPER(MIN(Description)) LIKE '%IRON%' THEN 'Metal Items'
        ELSE 'General Merchandise'
    END as Category,
    AVG(UnitPrice) as UnitPrice   -- Average price for products with multiple price points
FROM staging.raw_sales
WHERE StockCode IS NOT NULL
    AND StockCode != ''
    AND Description IS NOT NULL
    AND Description != ''
GROUP BY StockCode; -- Corrected: Grouping only by StockCode

-- Re-enable and check the foreign key constraint on FactSales for DimProduct
ALTER TABLE dw.FactSales WITH CHECK CHECK CONSTRAINT FK_FactSales_Product;

PRINT 'Product Dimension completed.';
SELECT COUNT(*) as ProductCount FROM dw.DimProduct;

-- Show category distribution
SELECT
    Category,
    COUNT(*) as ProductCount,
    AVG(UnitPrice) as AvgPrice
FROM dw.DimProduct
GROUP BY Category
ORDER BY ProductCount DESC;

PRINT 'Dimension population completed successfully!';