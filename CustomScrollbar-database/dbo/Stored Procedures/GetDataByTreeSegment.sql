CREATE PROCEDURE [dbo].[GetDataByTreeSegment]
    @TreeSegment TreeSegmentType READONLY,  -- Use the table type
    @firstColumnNumber INT,
    @lastColumnNumber INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @frozenColumnList NVARCHAR(MAX) = 'ID, ParentID, Name, CustomSort, HasChildren, ChildCount';
    DECLARE @scrollableColumnList NVARCHAR(MAX) = '';
    DECLARE @combinedColumnList NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX) = '';
    DECLARE @currentColumnNumber INT;

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

    -- Combine frozen and scrollable columns
    SET @combinedColumnList = @frozenColumnList + 
        CASE WHEN @scrollableColumnList <> '' THEN ', ' + @scrollableColumnList ELSE '' END;

    -- Generate dynamic SQL
    DECLARE @parentId INT, @firstRecordNumber INT, @lastRecordNumber INT, @treeLevel INT;
    DECLARE TreeSegmentCursor CURSOR FOR 
    SELECT parentId, firstRecordNumber, lastRecordNumber, treeLevel FROM @TreeSegment;

    OPEN TreeSegmentCursor;
    FETCH NEXT FROM TreeSegmentCursor INTO @parentId, @firstRecordNumber, @lastRecordNumber, @treeLevel;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Append UNION ALL if this is not the first query
        IF @sql <> '' SET @sql = @sql + ' UNION ALL ';

        -- Build the select statement
        SET @sql = @sql + 
            'SELECT ' + CAST(@treeLevel AS NVARCHAR(10)) + ' AS TreeLevel, ' + @combinedColumnList + ' FROM ActiveAnalyticalTable ' +
            'WHERE ActiveAnalyticalTable.parentId = ' + CAST(@parentId AS NVARCHAR(10)) + 
            ' AND ActiveAnalyticalTable.CustomSort BETWEEN ' + CAST(@firstRecordNumber AS NVARCHAR(10)) + 
            ' AND ' + CAST(@lastRecordNumber AS NVARCHAR(10));

        FETCH NEXT FROM TreeSegmentCursor INTO @parentId, @firstRecordNumber, @lastRecordNumber, @treeLevel;
    END

    CLOSE TreeSegmentCursor;
    DEALLOCATE TreeSegmentCursor;

    -- Execute the dynamic SQL
    EXEC sp_executesql @sql;
END;
