-- Create E-Commerce Analytics Database

-- Drop database if it exists (for development)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ECommerceAnalytics')
BEGIN
    ALTER DATABASE ECommerceAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ECommerceAnalytics;
END
GO

-- Create new database
CREATE DATABASE ECommerceAnalytics;
GO

-- Use the database
USE ECommerceAnalytics;
GO

-- Create schemas for organization
CREATE SCHEMA staging;  -- For raw, unprocessed data
GO
CREATE SCHEMA dw;       -- For clean, processed data warehouse tables
GO

PRINT 'Database ECommerceAnalytics created successfully!';
PRINT 'Schemas created: staging, dw';