-- Advanced Business Intelligence Queries
USE ECommerceAnalytics;
GO

PRINT '==============================================';
PRINT 'BUSINESS INTELLIGENCE ANALYSIS REPORT';
PRINT 'Generated: ' + CONVERT(VARCHAR(20), GETDATE(), 120);
PRINT '==============================================';

-- ======================
-- 1. REVENUE ANALYSIS
-- ======================

PRINT '';
PRINT '1. REVENUE ANALYSIS';
PRINT '-------------------';

-- Overall business metrics
SELECT 
    'Total Revenue' as Metric,
    '$' + FORMAT(SUM(TotalAmount), 'N2') as Value
FROM dw.FactSales
UNION ALL
SELECT 
    'Total Transactions',
    FORMAT(COUNT(*), 'N0')
FROM dw.FactSales
UNION ALL
SELECT 
    'Unique Customers',
    FORMAT(COUNT(DISTINCT CustomerKey), 'N0')
FROM dw.FactSales
UNION ALL
SELECT 
    'Unique Products Sold',
    FORMAT(COUNT(DISTINCT ProductKey), 'N0')
FROM dw.FactSales
UNION ALL
SELECT 
    'Average Order Value',
    '$' + FORMAT(AVG(TotalAmount), 'N2')
FROM dw.FactSales;

-- Monthly revenue trend
PRINT '';
PRINT 'Monthly Revenue Trend (Last 12 Months):';
SELECT TOP 12
    MonthName + ' ' + CAST(Year AS VARCHAR) as Month,
    '$' + FORMAT(TotalRevenue, 'N2') as Revenue,
    FORMAT(TransactionCount, 'N0') as Transactions,
    '$' + FORMAT(AvgTransactionValue, 'N2') as AvgOrderValue
FROM dw.vw_MonthlySales
ORDER BY Year DESC, Month DESC;

-- ======================
-- 2. CUSTOMER ANALYSIS  
-- ======================

PRINT '';
PRINT '2. CUSTOMER ANALYSIS';
PRINT '--------------------';

-- Customer segmentation
SELECT 
    CustomerSegment,
    COUNT(*) as CustomerCount,
    FORMAT(AVG(TotalSpent), 'C2') as AvgLifetimeValue,
    FORMAT(SUM(TotalSpent), 'C2') as TotalRevenue,
    FORMAT(AVG(TotalOrders), 'N1') as AvgOrders
FROM dw.vw_CustomerAnalysis
GROUP BY CustomerSegment
ORDER BY AVG(TotalSpent) DESC;

-- Top customers by revenue
PRINT '';
PRINT 'Top 10 Customers by Revenue:';
SELECT TOP 10
    CustomerID,
    Country,
    FORMAT(TotalSpent, 'C2') as TotalSpent,
    TotalOrders,
    FORMAT(TotalSpent/TotalOrders, 'C2') as AvgOrderValue,
    CustomerSegment
FROM dw.vw_CustomerAnalysis
ORDER BY TotalSpent DESC;

-- Customer retention analysis
PRINT '';
PRINT 'Customer Activity Status:';
SELECT 
    IsActive,
    CASE WHEN IsActive = 1 THEN 'Active (Last 365 Days)' ELSE 'Inactive (>365 Days)' END as Status,
    COUNT(*) as CustomerCount,
    FORMAT(AVG(TotalSpent), 'C2') as AvgLifetimeValue
FROM dw.DimCustomer
GROUP BY IsActive
ORDER BY IsActive DESC;

-- ======================
-- 3. PRODUCT ANALYSIS
-- ======================

PRINT '';
PRINT '3. PRODUCT ANALYSIS';
PRINT '-------------------';

-- Category performance
SELECT 
    Category,
    COUNT(*) as ProductCount,
    FORMAT(SUM(TotalRevenue), 'C2') as TotalRevenue,
    FORMAT(AVG(TotalRevenue), 'C2') as AvgRevenuePerProduct,
    SUM(TotalQuantitySold) as TotalQuantitySold
FROM dw.vw_ProductPerformance
WHERE TotalRevenue > 0
GROUP BY Category
ORDER BY SUM(TotalRevenue) DESC;

-- Top performing products
PRINT '';
PRINT 'Top 10 Products by Revenue:';
SELECT TOP 10
    StockCode,
    LEFT(Description, 50) + '...' as Description,
    Category,
    FORMAT(TotalRevenue, 'C2') as TotalRevenue,
    TotalQuantitySold,
    TransactionCount,
    PerformanceCategory
FROM dw.vw_ProductPerformance
ORDER BY TotalRevenue DESC;

-- Product performance distribution
PRINT '';
PRINT 'Product Performance Distribution:';