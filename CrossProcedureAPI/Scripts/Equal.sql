CREATE PROCEDURE [dbo].[Equal]
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
    DECLARE @FilterType NVARCHAR(100), @ColumnName NVARCHAR(100), @Values NVARCHAR(MAX);

    -- Parse JSON input
    SELECT 
        @FilterType = JSON_VALUE(@InputData, '$.FilterType'),
        @ColumnName = JSON_VALUE(@InputData, '$.ColumnName'),
        @Values = JSON_QUERY(@InputData, '$.Value');

    -- Check for required fields
    IF @FilterType IS NULL OR @ColumnName IS NULL OR @Values IS NULL
    BEGIN
        PRINT 'JSON is missing required fields (FilterType, ColumnName, or Value).'
        RETURN;
    END

    -- Validate that @Values is a JSON array
    IF ISJSON(@Values) = 0
    BEGIN
        PRINT 'Value field is not a valid JSON array.'
        RETURN;
    END

    -- Declare table variable to store values
    DECLARE @ValueList TABLE (Value NVARCHAR(100));

    -- Insert values from JSON array into table variable
    INSERT INTO @ValueList (Value)
    SELECT value
    FROM OPENJSON(@Values);

    -- Construct the dynamic SQL query
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT * FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName) + ' WHERE ';

    DECLARE @equalsClause NVARCHAR(MAX) = '';

    SELECT @equalsClause = @equalsClause + QUOTENAME(@ColumnName) + ' = ''' + Value + ''' OR '
    FROM @ValueList;

    -- Remove the trailing ' OR '
    IF LEN(@equalsClause) > 0
        SET @equalsClause = LEFT(@equalsClause, LEN(@equalsClause) - 3);

    -- Append the constructed equals clauses to the SQL query
    SET @sql = @sql + @equalsClause;

    -- Execute the dynamic SQL query
    EXEC sp_executesql @sql;
END
