-- Check customer dimension quality
SELECT TOP 10 
    CustomerID, Country, TotalOrders, TotalSpent, IsActive
FROM dw.DimCustomer 
ORDER BY TotalSpent DESC;

-- Check product dimension quality  
SELECT Category, COUNT(*) as ProductCount
FROM dw.DimProduct
GROUP BY Category
ORDER BY ProductCount DESC;

-- Verify no duplicates
SELECT COUNT(*) as TotalCustomers, COUNT(DISTINCT CustomerID) as UniqueCustomers
FROM dw.DimCustomer;

SELECT COUNT(DISTINCT StockCode) as UniqueProduct From staging.raw_sales