CREATE PROCEDURE [dbo].[GreaterThanOrEqualTo]
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
    DECLARE @FilterType NVARCHAR(100), @ColumnName NVARCHAR(100), @Value NVARCHAR(100);

    -- Parse JSON input
    SELECT 
        @FilterType = JSON_VALUE(@InputData, '$.FilterType'),
        @ColumnName = JSON_VALUE(@InputData, '$.ColumnName'),
        @Value = JSON_VALUE(@InputData, '$.Value');

    -- Check for required fields
    IF @FilterType IS NULL OR @ColumnName IS NULL OR @Value IS NULL
    BEGIN
        PRINT 'JSON is missing required fields (FilterType, ColumnName, or Value).'
        RETURN;
    END

    -- Construct the dynamic SQL query
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT * FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName) + 
               ' WHERE ' + QUOTENAME(@ColumnName) + ' >= @ComparisonValue';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @sql, N'@ComparisonValue NVARCHAR(100)', @ComparisonValue = @Value;
END
