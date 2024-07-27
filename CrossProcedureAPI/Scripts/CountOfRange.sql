CREATE PROCEDURE [dbo].[CountOfRange]
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
    DECLARE @lValue NVARCHAR(100);
    DECLARE @hValue NVARCHAR(100);

    -- Parse JSON input
    SELECT 
        @Type = JSON_VALUE(@InputData, '$.Type'),
        @Identifier = JSON_VALUE(@InputData, '$.Identifier'),
        @ColumnName = JSON_VALUE(@InputData, '$.ColumnName'),
        @lValue = JSON_VALUE(@InputData, '$.lValue'),
        @hValue = JSON_VALUE(@InputData, '$.hValue');

    -- Validate parsed values
    IF @Type IS NULL OR @Identifier IS NULL OR @ColumnName IS NULL
    BEGIN
        PRINT 'JSON is missing required fields (Type, Identifier, ColumnName).'
        RETURN;
    END

    -- Construct the dynamic SQL query
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @Params NVARCHAR(MAX);

    IF @lValue IS NOT NULL AND @hValue IS NOT NULL
    BEGIN
        -- Both lower and upper limits are specified
        SET @sql = 'SELECT @Hits = COUNT(*)' + 
                   ' FROM dbo.FinalResults WHERE ' + QUOTENAME(@ColumnName) + ' >= @lValueParam AND ' + QUOTENAME(@ColumnName) + ' <= @hValueParam';

        SET @Params = '@lValueParam NVARCHAR(100), @hValueParam NVARCHAR(100), @Hits BIGINT OUTPUT';

        EXEC sp_executesql @sql, @Params, @lValueParam = @lValue, @hValueParam = @hValue, @Hits = @Hits OUTPUT;
    END
    ELSE IF @lValue IS NOT NULL
    BEGIN
        -- Only lower limit is specified
        SET @sql = 'SELECT @Hits = COUNT(*)' + 
                   ' FROM dbo.FinalResults WHERE ' + QUOTENAME(@ColumnName) + ' >= @lValueParam';

        SET @Params = '@lValueParam NVARCHAR(100), @Hits BIGINT OUTPUT';

        EXEC sp_executesql @sql, @Params, @lValueParam = @lValue, @Hits = @Hits OUTPUT;
    END
    ELSE IF @hValue IS NOT NULL
    BEGIN
        -- Only upper limit is specified
        SET @sql = 'SELECT @Hits = COUNT(*)' + 
                   ' FROM dbo.FinalResults WHERE ' + QUOTENAME(@ColumnName) + ' <= @hValueParam';

        SET @Params = '@hValueParam NVARCHAR(100), @Hits BIGINT OUTPUT';

        EXEC sp_executesql @sql, @Params, @hValueParam = @hValue, @Hits = @Hits OUTPUT;
    END
    ELSE
    BEGIN
        -- Neither lower nor upper limit is specified
        SET @sql = 'SELECT @Hits = COUNT(*)' + 
                   ' FROM dbo.FinalResults';

        SET @Params = '@Hits BIGINT OUTPUT';

        EXEC sp_executesql @sql, @Params, @Hits = @Hits OUTPUT;
    END
END
