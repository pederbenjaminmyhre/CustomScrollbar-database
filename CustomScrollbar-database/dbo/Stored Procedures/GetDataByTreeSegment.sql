CREATE PROCEDURE [dbo].[GetDataByTreeSegment]
    @TreeSegment TreeSegmentType READONLY,  -- Use the table type
    @firstColumnNumber INT,
    @lastColumnNumber INT,
	@logId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

	-- declare variables
    DECLARE @frozenColumnList NVARCHAR(MAX) = 'ID, ParentID, Name, CustomSort, HasChildren, ChildCount';
    DECLARE @scrollableColumnList NVARCHAR(MAX) = '';
    DECLARE @combinedColumnList NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX) = '';
    DECLARE @currentColumnNumber INT;

	-- enforce min and max boundaries for column names to prevent errors due to non-existant columns
	if @firstColumnNumber < 1
		set @firstColumnNumber = 1
	if @lastColumnNumber > 300
		set @lastColumnNumber = 300;

    -- Build the scrollableColumnList dynamically
    SET @currentColumnNumber = @firstColumnNumber;
    WHILE @currentColumnNumber <= @lastColumnNumber
    BEGIN
        SET @scrollableColumnList = @scrollableColumnList + 
            CASE WHEN @scrollableColumnList = '' THEN '' ELSE ', ' END + 
            'Col' + CAST(@currentColumnNumber AS NVARCHAR(10));
        SET @currentColumnNumber = @currentColumnNumber + 1;
    END

    -- Combine frozen column list and scrollable column list into a combined column list
    SET @combinedColumnList = @frozenColumnList + 
        CASE WHEN @scrollableColumnList <> '' THEN ',' + CHAR(13) + CHAR(10) + CHAR(9) + @scrollableColumnList ELSE '' END;

    -- Get query requests
    DECLARE @parentId INT, @firstRecordNumber INT, @lastRecordNumber INT, @treeLevel INT;
    DECLARE TreeSegmentCursor CURSOR FOR 
    SELECT parentId, firstRecordNumber, lastRecordNumber, treeLevel FROM @TreeSegment;

	-- For each query request, add a SELECT ... FROM separated by UNION ALL
    OPEN TreeSegmentCursor;
    FETCH NEXT FROM TreeSegmentCursor INTO @parentId, @firstRecordNumber, @lastRecordNumber, @treeLevel;

	-- start looping
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Append UNION ALL if this is not the first query
        IF @sql <> '' SET @sql = @sql + CHAR(13) + CHAR(10) + '	UNION ALL	' + CHAR(13) + CHAR(10);

        -- Build the select statement
        SET @sql = @sql + 
            'SELECT ' + CAST(@treeLevel AS NVARCHAR(10)) + ' AS TreeLevel, ' + @combinedColumnList + CHAR(13) + CHAR(10) + 'FROM ActiveAnalyticalTable ' + CHAR(13) + CHAR(10) +
            'WHERE ActiveAnalyticalTable.parentId = ' + CAST(@parentId AS NVARCHAR(10)) + 
            ' AND ActiveAnalyticalTable.CustomSort BETWEEN ' + CAST(@firstRecordNumber AS NVARCHAR(10)) + 
            ' AND ' + CAST(@lastRecordNumber AS NVARCHAR(10));

        FETCH NEXT FROM TreeSegmentCursor INTO @parentId, @firstRecordNumber, @lastRecordNumber, @treeLevel;
    END

    CLOSE TreeSegmentCursor;
    DEALLOCATE TreeSegmentCursor;
	-- Done looping now

    -- Execute the dynamic SQL
    EXEC sp_executesql @sql;

	-- If logging is activated, populate log tables
	IF @logId <> 0
	BEGIN
		INSERT INTO QueryRequests (logId, parentId, firstRecordNumber, lastRecordNumber, treeLevel)
		SELECT @logId, parentId, firstRecordNumber, lastRecordNumber, treeLevel
		FROM @TreeSegment

		INSERT INTO LogSql (logId, dynamic_sql)
		SELECT @logId, @sql
	END
END;