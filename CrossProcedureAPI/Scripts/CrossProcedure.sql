CREATE PROCEDURE [dbo].[CrossProcedure]
	@Query NVARCHAR(MAX),
	@PageNumber INT = 1, -- Set your desired page number here
	@PageSize INT = 10 -- Set your desired page size here
AS
BEGIN
    SET NOCOUNT ON;

	IF ISJSON(@Query) = 0
	BEGIN
		PRINT 'Invalid JSON input.'
		RETURN;
	END

    -- Declare variables
    DECLARE @SchemaName NVARCHAR(100);
    DECLARE @ViewName NVARCHAR(200);

	DECLARE @SortColumn NVARCHAR(100);
	DECLARE @SortDirection NVARCHAR(10);

    DECLARE @QueryTable TABLE (
        FilterType NVARCHAR(100),
        JsonData NVARCHAR(MAX)
    );
	DECLARE @CountTable TABLE (
        [Type] NVARCHAR(100),
        JsonData NVARCHAR(MAX)
    );

    -- Parse JSON input
    SELECT 
        @SchemaName = JSON_VALUE(@Query, '$.Object.SchemaName'),
        @ViewName = JSON_VALUE(@Query, '$.Object.ViewName'),
		@SortColumn = JSON_VALUE(@Query, '$.Sort.ColumnName'),
		@SortDirection = JSON_VALUE(@Query, '$.Sort.SortDirection');

    -- Insert each Query item into @QueryTable along with its FilterType and full JSON
    INSERT INTO @QueryTable (FilterType, JsonData)
    SELECT 
        q.FilterType,
        JSON_QUERY(q.QueryItem) AS JsonData
    FROM OPENJSON(@Query, '$.Query') WITH (
        FilterType NVARCHAR(100) '$.FilterType',
        QueryItem NVARCHAR(MAX) '$' AS JSON
    ) AS q;

	INSERT INTO @CountTable ([Type], JsonData)
    SELECT 
        c.[Type],
        JSON_QUERY(c.CountItem) AS JsonData
    FROM OPENJSON(@Query, '$.Count') WITH (
        [Type] NVARCHAR(100) '$.Type',
        CountItem NVARCHAR(MAX) '$' AS JSON
    ) AS c;
	
	--Create a physical table to accumulate the result there.
	--Declaring Temporary dbo.CurrentResults table
	IF OBJECT_ID('dbo.CurrentResults') IS NOT NULL
		DROP TABLE dbo.CurrentResults
	DECLARE @SQL NVARCHAR(MAX);
	SET @SQL = '
		SELECT *
		INTO dbo.CurrentResults
		FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName) + '
		WHERE 1 = 0;';
	EXEC sp_executesql @SQL;

	--Declaring Temporary dbo.FinalResults table
	IF OBJECT_ID('dbo.FinalResults') IS NOT NULL
		DROP TABLE dbo.FinalResults
	SET @SQL = '
		SELECT *
		INTO dbo.FinalResults
		FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName) + '
		WHERE 1 = 0;';
	EXEC sp_executesql @SQL;
	--Declaring Temporary dbo.TempIntersection table
	IF OBJECT_ID('dbo.TempIntersection') IS NOT NULL
		DROP TABLE dbo.TempIntersection
	SET @SQL = '
		SELECT *
		INTO dbo.TempIntersection
		FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName) + '
		WHERE 1 = 0;';
	EXEC sp_executesql @SQL;

	SET @SQL = 'INSERT INTO dbo.FinalResults SELECT * FROM '+QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName)+';' ;
	EXEC sp_executesql @SQL;

	--Start the loop
	DECLARE @FilterType NVARCHAR(100), @JsonData NVARCHAR(MAX);

	-- Declare the cursor
	DECLARE filter_cursor CURSOR FOR
	SELECT FilterType, JsonData
	FROM @QueryTable;

	-- Open the cursor
	OPEN filter_cursor;

	-- Fetch the first row into variables
	FETCH NEXT FROM filter_cursor INTO @FilterType, @JsonData;

	-- Loop through the rows
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT 'FilterType: ' + @FilterType; --+ ', JsonData: ' + @JsonData;
		IF (@FilterType = 'ShouldContain')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[ShouldContain] @SchemaName, @ViewName, @JsonData;
			END
		IF (@FilterType = 'ShouldNotContain')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[ShouldNotContain] @SchemaName, @ViewName, @JsonData;
			END
		IF (@FilterType = 'Equals')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[Equals] @SchemaName, @ViewName, @JsonData;
			END
		IF (@FilterType = 'NotEqual')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[NotEqual] @SchemaName, @ViewName, @JsonData;
			END
		IF (@FilterType = 'GreaterThanOrEqualTo')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[GreaterThanOrEqualTo] @SchemaName, @ViewName, @JsonData;
			END
		IF (@FilterType = 'LessThanOrEqualTo')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[LessThanOrEqualTo] @SchemaName, @ViewName, @JsonData;
			END
		IF (@FilterType = 'Range')
			BEGIN
				INSERT INTO dbo.CurrentResults
				EXEC [dbo].[Range] @SchemaName, @ViewName, @JsonData;
			END

		--Once got the results now process that.
		IF EXISTS (SELECT 1 FROM dbo.CurrentResults)
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.FinalResults)
			BEGIN
				INSERT INTO dbo.TempIntersection
				SELECT * FROM dbo.FinalResults
				INTERSECT
				SELECT * FROM dbo.CurrentResults;
			END
			ELSE
			BEGIN
				INSERT INTO dbo.TempIntersection
				SELECT * FROM dbo.CurrentResults;
			END

			--Delete all from Final and Current

			DELETE FROM dbo.FinalResults;
			DELETE FROM dbo.CurrentResults;

			--Transfer from Intersection to Final

			INSERT INTO dbo.FinalResults
			SELECT * FROM dbo.TempIntersection;

			DELETE FROM dbo.TempIntersection;
		END


		FETCH NEXT FROM filter_cursor INTO @FilterType, @JsonData;
	END

	CLOSE filter_cursor;
	DEALLOCATE filter_cursor;
	
	--Count based on query
	DECLARE @CountType NVARCHAR(100), @CountJsonData NVARCHAR(MAX);

	-- Declare the cursor
	DECLARE count_cursor CURSOR FOR
	SELECT [Type], JsonData
	FROM @CountTable;

	DECLARE @Identifier NVARCHAR(100);
	DECLARE @Hits BIGINT;

	--Declaring a table that will contain the Counts.
	DECLARE @CountResults TABLE (
		[Identifier] NVARCHAR(200),
		[Hits] BIGINT
	);
	OPEN count_cursor;

	-- Fetch the first row into variables
	FETCH NEXT FROM count_cursor INTO @CountType, @CountJsonData;

	-- Loop through the rows
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@CountType = 'CountOf')
		BEGIN
			EXEC [dbo].[CountOf] @CountJsonData, @Identifier OUTPUT, @Hits OUTPUT;
			INSERT INTO @CountResults ([Identifier],[Hits])
			VALUES (@Identifier,@Hits);
		END
		IF (@CountType = 'CountOfRange')
		BEGIN
			EXEC [dbo].[CountOfRange] @CountJsonData, @Identifier OUTPUT, @Hits OUTPUT;
			INSERT INTO @CountResults ([Identifier],[Hits])
			VALUES (@Identifier,@Hits);
		END
		
		FETCH NEXT FROM count_cursor INTO @CountType, @CountJsonData;
	END
	CLOSE count_cursor;
	DEALLOCATE count_cursor;

	--Sort based on query
	DECLARE @OffsetRows INT = (@PageNumber - 1) * @PageSize;

	SET @SQL = 'SELECT * FROM dbo.FinalResults
            ORDER BY ' + QUOTENAME(@SortColumn) + ' ' + @SortDirection + '
            OFFSET ' + CAST(@OffsetRows AS NVARCHAR(10)) + ' ROWS 
            FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(10)) + ' ROWS ONLY 
            FOR JSON PATH, INCLUDE_NULL_VALUES;';
	--this gives main result.
	EXEC sp_executesql @SQL;

	--this gives count results.
	SELECT * FROM @CountResults FOR JSON PATH, INCLUDE_NULL_VALUES;

	--At the end Drop all the temp tables.
	DROP TABLE dbo.TempIntersection;
	DROP TABLE dbo.CurrentResults;
	DROP TABLE dbo.FinalResults;
END;

