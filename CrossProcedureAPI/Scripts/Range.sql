CREATE PROCEDURE [dbo].[Range]
    @SchemaName NVARCHAR(100),
    @ViewName NVARCHAR(200),
    @InputData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate JSON input
    IF ISJSON(@InputData) = 0
    BEGIN
        PRINT 'Invalid JSON input.'
        RETURN;
    END

    -- Declare variables to store parsed values
    DECLARE @FilterType NVARCHAR(100), @ColumnName NVARCHAR(100), @lValue NVARCHAR(100), @hValue NVARCHAR(100);

    -- Parse JSON input
    SELECT 
        @FilterType = JSON_VALUE(@InputData, '$.FilterType'),
        @ColumnName = JSON_VALUE(@InputData, '$.ColumnName'),
        @lValue = JSON_VALUE(@InputData, '$.lValue'),
        @hValue = JSON_VALUE(@InputData, '$.hValue');

    -- Check for required fields
    IF @FilterType IS NULL OR @ColumnName IS NULL OR @lValue IS NULL OR @hValue IS NULL
    BEGIN
        PRINT 'JSON is missing required fields (FilterType, ColumnName, lValue, or hValue).'
        RETURN;
    END

    -- Construct the dynamic SQL query
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT * FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName) + 
               ' WHERE ' + QUOTENAME(@ColumnName) + ' BETWEEN @LowerValue AND @HigherValue';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @sql, N'@LowerValue NVARCHAR(100), @HigherValue NVARCHAR(100)', @LowerValue = @lValue, @HigherValue = @hValue;
END
