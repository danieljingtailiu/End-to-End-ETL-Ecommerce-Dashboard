-- Populate Sales Fact Table
USE ECommerceAnalytics;
GO

PRINT 'Populating Sales Fact Table...';

-- Clear existing data
TRUNCATE TABLE dw.FactSales;

-- Insert sales facts with proper dimension keys
INSERT INTO dw.FactSales (
    DateKey,
    CustomerKey,
    ProductKey,
    InvoiceNo,
    Quantity,
    UnitPrice
)
SELECT 
    CONVERT(INT, FORMAT(s.InvoiceDate, 'yyyyMMdd')) as DateKey,
    c.CustomerKey,
    p.ProductKey,
    s.InvoiceNo,
    s.Quantity,
    s.UnitPrice
FROM staging.raw_sales s
    INNER JOIN dw.DimCustomer c ON s.CustomerID = c.CustomerID
    INNER JOIN dw.DimProduct p ON s.StockCode = p.StockCode
    INNER JOIN dw.DimDate d ON CONVERT(INT, FORMAT(s.InvoiceDate, 'yyyyMMdd')) = d.DateKey
WHERE s.CustomerID IS NOT NULL 
    AND s.CustomerID != ''
    AND s.StockCode IS NOT NULL 
    AND s.StockCode != ''
    AND s.Quantity > 0
    AND s.UnitPrice > 0;

-- Check results
PRINT 'Sales Fact Table populated successfully!';

SELECT 
    COUNT(*) as TotalSalesRecords,
    MIN(DateKey) as EarliestSale,
    MAX(DateKey) as LatestSale,
    SUM(TotalAmount) as TotalRevenue,
    AVG(TotalAmount) as AvgOrderValue
FROM dw.FactSales;

-- Check for any orphaned records (shouldn't be any with INNER JOINs)
SELECT 
    'Missing Date Keys' as Issue,
    COUNT(*) as Count
FROM dw.FactSales f
    LEFT JOIN dw.DimDate d ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL
UNION ALL
SELECT 
    'Missing Customer Keys',
    COUNT(*)
FROM dw.FactSales f
    LEFT JOIN dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL
UNION ALL
SELECT 
    'Missing Product Keys',
    COUNT(*)
FROM dw.FactSales f
    LEFT JOIN dw.DimProduct p ON f.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;

PRINT 'Data warehouse ETL process completed!';