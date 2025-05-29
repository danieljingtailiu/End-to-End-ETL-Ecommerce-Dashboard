-- Smart Date Dimension Population
USE ECommerceAnalytics;
GO

-- Check if table is already populated
DECLARE @RecordCount INT;
SELECT @RecordCount = COUNT(*) FROM dw.DimDate;

IF @RecordCount = 0
BEGIN
    PRINT 'Date dimension is empty. Populating...';
    
    -- Generate dates for the range we need
    DECLARE @StartDate DATE = '2010-01-01';
    DECLARE @EndDate DATE = '2025-12-31';
    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO dw.DimDate (
            DateKey,
            FullDate,
            Year,
            Quarter,
            Month,
            MonthName,
            Day,
            DayOfWeek,
            DayName,
            IsWeekend,
            IsHoliday
        )
        VALUES (
            CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
            @CurrentDate,
            YEAR(@CurrentDate),
            DATEPART(QUARTER, @CurrentDate),
            MONTH(@CurrentDate),
            DATENAME(MONTH, @CurrentDate),
            DAY(@CurrentDate),
            DATEPART(WEEKDAY, @CurrentDate),
            DATENAME(WEEKDAY, @CurrentDate),
            CASE 
                WHEN DATEPART(WEEKDAY, @CurrentDate) IN (1, 7) THEN 1 
                ELSE 0 
            END,
            0
        );
        
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END;

    -- Update holidays
    UPDATE dw.DimDate SET IsHoliday = 1 
    WHERE (Month = 12 AND Day = 25)
       OR (Month = 1 AND Day = 1)
       OR (Month = 7 AND Day = 4);

    PRINT 'Date dimension populated successfully!';
END
ELSE
BEGIN
    PRINT CONCAT('Date dimension already contains ', @RecordCount, ' records. Skipping population.');
END;

-- Show results either way
SELECT 
    COUNT(*) as TotalDates,
    MIN(FullDate) as StartDate,
    MAX(FullDate) as EndDate,
    SUM(CASE WHEN IsWeekend = 1 THEN 1 ELSE 0 END) as WeekendDays,
    SUM(CASE WHEN IsHoliday = 1 THEN 1 ELSE 0 END) as Holidays
FROM dw.DimDate;