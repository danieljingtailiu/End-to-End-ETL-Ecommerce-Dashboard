USE ECommerceAnalytics;
GO

-- Check data was loaded
SELECT COUNT(*) as TotalRecords FROM staging.raw_sales;

-- Look at sample data
SELECT TOP 10 * FROM staging.raw_sales ORDER BY InvoiceDate DESC;

-- Check data quality
SELECT 
    COUNT(*) as TotalRecords,
    COUNT(DISTINCT CustomerID) as UniqueCustomers,
    COUNT(DISTINCT StockCode) as UniqueProducts,
    COUNT(DISTINCT Country) as UniqueCountries,
    MIN(InvoiceDate) as EarliestDate,
    MAX(InvoiceDate) as LatestDate,
    SUM(Quantity * UnitPrice) as TotalRevenue
FROM staging.raw_sales;

-- Check for any data issues
SELECT 
    'Missing CustomerID' as Issue,
    COUNT(*) as Count
FROM staging.raw_sales 
WHERE CustomerID IS NULL OR CustomerID = ''
UNION ALL
SELECT 
    'Zero Quantity',
    COUNT(*)
FROM staging.raw_sales 
WHERE Quantity <= 0
UNION ALL
SELECT 
    'Zero Unit Price',
    COUNT(*)
FROM staging.raw_sales 
WHERE UnitPrice <= 0;