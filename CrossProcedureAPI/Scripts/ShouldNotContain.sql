CREATE PROCEDURE [dbo].[ShouldNotContain]
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
    DECLARE @ColumnName NVARCHAR(100), @Values NVARCHAR(MAX);

    -- Parse JSON input
    SELECT 
        @ColumnName = JSON_VALUE(@InputData, '$.ColumnName'),
        @Values = JSON_QUERY(@InputData, '$.Value');

    -- Check for required fields
    IF @ColumnName IS NULL OR @Values IS NULL
    BEGIN
        PRINT 'JSON is missing required fields (ColumnName or Value).'
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

    DECLARE @notLikeClause NVARCHAR(MAX) = '';

    SELECT @notLikeClause = @notLikeClause + QUOTENAME(@ColumnName) + ' NOT LIKE ''%' + Value + '%'' AND '
    FROM @ValueList;

    -- Remove the trailing ' AND '
    IF LEN(@notLikeClause) > 0
        SET @notLikeClause = LEFT(@notLikeClause, LEN(@notLikeClause) - 4);

    -- Append the constructed NOT LIKE clauses to the SQL query
    SET @sql = @sql + @notLikeClause;

    -- Execute the dynamic SQL query
    EXEC sp_executesql @sql;
END
