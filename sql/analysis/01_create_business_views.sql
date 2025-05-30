-- Create Business Analysis Views
USE ECommerceAnalytics;
GO

-- ======================
-- SALES SUMMARY VIEW
-- ======================

CREATE OR ALTER VIEW dw.vw_SalesSummary AS
SELECT 
    f.DateKey,
    d.FullDate,
    d.Year,
    d.Month,
    d.MonthName,
    d.Quarter,
    c.CustomerID,
    c.Country,
    p.StockCode,
    p.Description as ProductDescription,
    p.Category,
    f.InvoiceNo,
    f.Quantity,
    f.UnitPrice,
    f.TotalAmount,
    CASE 
        WHEN f.TotalAmount >= 100 THEN 'High Value'
        WHEN f.TotalAmount >= 50 THEN 'Medium Value'
        ELSE 'Low Value'
    END as TransactionCategory
FROM dw.FactSales f
    INNER JOIN dw.DimDate d ON f.DateKey = d.DateKey
    INNER JOIN dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
    INNER JOIN dw.DimProduct p ON f.ProductKey = p.ProductKey;
GO

-- ======================
-- MONTHLY SALES SUMMARY
-- ======================

CREATE OR ALTER VIEW dw.vw_MonthlySales AS
SELECT 
    d.Year,
    d.Month,
    d.MonthName,
    COUNT(*) as TransactionCount,
    COUNT(DISTINCT f.CustomerKey) as UniqueCustomers,
    COUNT(DISTINCT f.ProductKey) as UniqueProducts,
    SUM(f.TotalAmount) as TotalRevenue,
    AVG(f.TotalAmount) as AvgTransactionValue,
    SUM(f.Quantity) as TotalQuantitySold
FROM dw.FactSales f
    INNER JOIN dw.DimDate d ON f.DateKey = d.DateKey
GROUP BY d.Year, d.Month, d.MonthName;
GO

-- ======================
-- CUSTOMER ANALYSIS VIEW
-- ======================

CREATE OR ALTER VIEW dw.vw_CustomerAnalysis AS
SELECT 
    c.CustomerKey,
    c.CustomerID,
    c.Country,
    c.FirstPurchaseDate,
    c.LastPurchaseDate,
    c.TotalOrders,
    c.TotalSpent,
    c.IsActive,
    DATEDIFF(DAY, c.FirstPurchaseDate, c.LastPurchaseDate) as CustomerLifespanDays,
    CASE 
        WHEN c.TotalSpent >= 1000 THEN 'VIP'
        WHEN c.TotalSpent >= 500 THEN 'Premium'
        WHEN c.TotalSpent >= 100 THEN 'Regular'
        ELSE 'New'
    END as CustomerSegment,
    -- Calculate metrics from fact table
    fact_stats.TransactionCount,
    fact_stats.AvgOrderValue,
    fact_stats.LastTransactionDate
FROM dw.DimCustomer c
    LEFT JOIN (
        SELECT 
            CustomerKey,
            COUNT(*) as TransactionCount,
            AVG(TotalAmount) as AvgOrderValue,
            MAX(DateKey) as LastTransactionDate
        FROM dw.FactSales
        GROUP BY CustomerKey
    ) fact_stats ON c.CustomerKey = fact_stats.CustomerKey;
GO

-- ======================
-- PRODUCT PERFORMANCE VIEW
-- ======================

CREATE OR ALTER VIEW dw.vw_ProductPerformance AS
SELECT 
    p.ProductKey,
    p.StockCode,
    p.Description,
    p.Category,
    p.UnitPrice,
    COALESCE(fact_stats.TotalQuantitySold, 0) as TotalQuantitySold,
    COALESCE(fact_stats.TotalRevenue, 0) as TotalRevenue,
    COALESCE(fact_stats.TransactionCount, 0) as TransactionCount,
    COALESCE(fact_stats.UniqueCustomers, 0) as UniqueCustomers,
    COALESCE(fact_stats.AvgQuantityPerTransaction, 0) as AvgQuantityPerTransaction,
    COALESCE(fact_stats.FirstSaleDate, 0) as FirstSaleDate,
    COALESCE(fact_stats.LastSaleDate, 0) as LastSaleDate,
    CASE 
        WHEN fact_stats.TotalRevenue >= 1000 THEN 'Top Performer'
        WHEN fact_stats.TotalRevenue >= 500 THEN 'Good Performer'
        WHEN fact_stats.TotalRevenue >= 100 THEN 'Average Performer'
        WHEN fact_stats.TotalRevenue > 0 THEN 'Low Performer'
        ELSE 'No Sales'
    END as PerformanceCategory
FROM dw.DimProduct p
    LEFT JOIN (
        SELECT 
            ProductKey,
            SUM(Quantity) as TotalQuantitySold,
            SUM(TotalAmount) as TotalRevenue,
            COUNT(*) as TransactionCount,
            COUNT(DISTINCT CustomerKey) as UniqueCustomers,
            AVG(CAST(Quantity AS DECIMAL(10,2))) as AvgQuantityPerTransaction,
            MIN(DateKey) as FirstSaleDate,
            MAX(DateKey) as LastSaleDate
        FROM dw.FactSales
        GROUP BY ProductKey
    ) fact_stats ON p.ProductKey = fact_stats.ProductKey;
GO

-- Test the views
PRINT 'Testing created views...';

SELECT 'Sales Summary' as ViewName, COUNT(*) as RecordCount FROM dw.vw_SalesSummary
UNION ALL
SELECT 'Monthly Sales', COUNT(*) FROM dw.vw_MonthlySales  
UNION ALL
SELECT 'Customer Analysis', COUNT(*) FROM dw.vw_CustomerAnalysis
UNION ALL
SELECT 'Product Performance', COUNT(*) FROM dw.vw_ProductPerformance;

PRINT 'Business analysis views created successfully!';