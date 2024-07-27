CREATE PROCEDURE [dbo].[CountOf]
    @InputData NVARCHAR(MAX),
    @Identifier NVARCHAR(100) OUTPUT,
    @Hits BIGINT OUTPUT
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
    DECLARE @Type NVARCHAR(100);
    DECLARE @ColumnName NVARCHAR(100);
    DECLARE @Value NVARCHAR(100);

    -- Parse JSON input
    SELECT 
        @Type = JSON_VALUE(@InputData, '$.Type'),
        @Identifier = JSON_VALUE(@InputData, '$.Identifier'),
        @ColumnName = JSON_VALUE(@InputData, '$.ColumnName'),
        @Value = JSON_VALUE(@InputData, '$.Value');

    -- Validate parsed values
    IF @Type IS NULL OR @Identifier IS NULL OR @ColumnName IS NULL OR @Value IS NULL
    BEGIN
        PRINT 'JSON is missing required fields (Type, Identifier, ColumnName, or Value).'
        RETURN;
    END

    -- Construct the dynamic SQL query
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT @Hits = COUNT(*)' + 
               ' FROM dbo.FinalResults WHERE ' + QUOTENAME(@ColumnName) + ' = @ValueParam';

    -- Execute the dynamic SQL query with parameter
    DECLARE @Params NVARCHAR(MAX);
    SET @Params = '@ValueParam NVARCHAR(100), @Hits BIGINT OUTPUT';

    EXEC sp_executesql @sql, @Params, @ValueParam = @Value, @Hits = @Hits OUTPUT;
END
