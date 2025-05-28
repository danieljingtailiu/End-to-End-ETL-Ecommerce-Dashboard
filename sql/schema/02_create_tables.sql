-- Create all tables for the E-Commerce Analytics database
USE ECommerceAnalytics;
GO

-- ======================
-- STAGING TABLES (Raw Data)
-- ======================

-- Raw staging table (matches our CSV/Excel structure)
CREATE TABLE staging.raw_sales (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceNo NVARCHAR(50),
    StockCode NVARCHAR(50),
    Description NVARCHAR(500),
    Quantity INT,
    InvoiceDate DATETIME2,
    UnitPrice DECIMAL(10,3),
    CustomerID NVARCHAR(50),
    Country NVARCHAR(100),
    LoadDate DATETIME2 DEFAULT GETDATE()
);

-- ======================
-- DATA WAREHOUSE TABLES (Clean Data)
-- ======================

-- Date Dimension
CREATE TABLE dw.DimDate (
    DateKey INT PRIMARY KEY,           -- Format: YYYYMMDD
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    Day INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName NVARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL DEFAULT 0,
    IsHoliday BIT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Customer Dimension
CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50) NOT NULL UNIQUE,
    Country NVARCHAR(100),
    FirstPurchaseDate DATE,
    LastPurchaseDate DATE,
    TotalOrders INT DEFAULT 0,
    TotalSpent DECIMAL(15,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    UpdatedDate DATETIME2 DEFAULT GETDATE()
);

-- Product Dimension
CREATE TABLE dw.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    StockCode NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    Category NVARCHAR(100),
    UnitPrice DECIMAL(10,3),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    UpdatedDate DATETIME2 DEFAULT GETDATE()
);

-- Sales Fact Table
CREATE TABLE dw.FactSales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    InvoiceNo NVARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,3) NOT NULL,
    TotalAmount AS (Quantity * UnitPrice) PERSISTED,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    
    -- Foreign Key Constraints
    CONSTRAINT FK_FactSales_Date FOREIGN KEY (DateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSales_Customer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSales_Product FOREIGN KEY (ProductKey) REFERENCES dw.DimProduct(ProductKey)
);

-- ======================
-- INDEXES for Performance
-- ======================

-- Staging table indexes
CREATE INDEX IX_staging_raw_sales_CustomerID ON staging.raw_sales(CustomerID);
CREATE INDEX IX_staging_raw_sales_InvoiceDate ON staging.raw_sales(InvoiceDate);
CREATE INDEX IX_staging_raw_sales_StockCode ON staging.raw_sales(StockCode);

-- Fact table indexes
CREATE INDEX IX_FactSales_DateKey ON dw.FactSales(DateKey);
CREATE INDEX IX_FactSales_CustomerKey ON dw.FactSales(CustomerKey);
CREATE INDEX IX_FactSales_ProductKey ON dw.FactSales(ProductKey);
CREATE INDEX IX_FactSales_InvoiceNo ON dw.FactSales(InvoiceNo);

-- Dimension table indexes
CREATE INDEX IX_DimCustomer_CustomerID ON dw.DimCustomer(CustomerID);
CREATE INDEX IX_DimProduct_StockCode ON dw.DimProduct(StockCode);
CREATE INDEX IX_DimDate_FullDate ON dw.DimDate(FullDate);

PRINT 'All tables created successfully!';
PRINT 'Tables created:';
PRINT '- staging.raw_sales';
PRINT '- dw.DimDate';
PRINT '- dw.DimCustomer';  
PRINT '- dw.DimProduct';
PRINT '- dw.FactSales';
PRINT 'Indexes created for optimal performance.';