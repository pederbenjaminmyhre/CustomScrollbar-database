create PROCEDURE print_treeSegments2
(
    @logId INT
)
AS
BEGIN
    DECLARE @ColumnHeaders NVARCHAR(MAX);
    DECLARE @ColumnValues NVARCHAR(MAX);

    -- Define column headers explicitly in the correct order
    SET @ColumnHeaders = 'logId' + CHAR(9) + 
                         'SegmentID' + CHAR(9) + 
                         'ParentSegmentID' + CHAR(9) + 
                         'SegmentPosition' + CHAR(9) + 
                         'ParentID' + CHAR(9) + 
                         'TreeLevel' + CHAR(9) + 
                         'RecordCount' + CHAR(9) + 
                         'FirstTreeRow' + CHAR(9) + 
                         'LastTreeRow' + CHAR(9) + 
                         'FirstCustomSortID' + CHAR(9) + 
                         'LastCustomSortID';

    PRINT @ColumnHeaders;

    -- Declare variables for each column
    DECLARE 
        @logId1 INT, 
        @SegmentID INT, 
        @ParentSegmentID INT, 
        @SegmentPosition INT, 
        @ParentID INT, 
        @TreeLevel INT, 
        @RecordCount INT, 
        @FirstTreeRow INT, 
        @LastTreeRow INT, 
        @FirstCustomSortID INT, 
        @LastCustomSortID INT;

    -- Declare a cursor
    DECLARE cursor_query CURSOR FOR
    SELECT 
        [logId], [SegmentID], [ParentSegmentID], [SegmentPosition], 
        [ParentID], [TreeLevel], [RecordCount], [FirstTreeRow], 
        [LastTreeRow], [FirstCustomSortID], [LastCustomSortID]
    FROM [DataGridWithVirtualScrolling].[dbo].[LogTreeSegmentTable]
    WHERE logId = @logId;

    OPEN cursor_query;
    FETCH NEXT FROM cursor_query INTO 
        @logId1, @SegmentID, @ParentSegmentID, @SegmentPosition, 
        @ParentID, @TreeLevel, @RecordCount, @FirstTreeRow, 
        @LastTreeRow, @FirstCustomSortID, @LastCustomSortID;

    -- Loop through each record
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Concatenate column values separated by tabs
        SET @ColumnValues = 
            CAST(@logId1 AS NVARCHAR) + CHAR(9) +
            CAST(@SegmentID AS NVARCHAR) + CHAR(9) +
            CAST(@ParentSegmentID AS NVARCHAR) + CHAR(9) +
            CAST(@SegmentPosition AS NVARCHAR) + CHAR(9) +
            CAST(@ParentID AS NVARCHAR) + CHAR(9) +
            CAST(@TreeLevel AS NVARCHAR) + CHAR(9) +
            CAST(@RecordCount AS NVARCHAR) + CHAR(9) +
            CAST(@FirstTreeRow AS NVARCHAR) + CHAR(9) +
            CAST(@LastTreeRow AS NVARCHAR) + CHAR(9) +
            CAST(@FirstCustomSortID AS NVARCHAR) + CHAR(9) +
            CAST(@LastCustomSortID AS NVARCHAR);

        PRINT @ColumnValues;

        FETCH NEXT FROM cursor_query INTO 
            @logId1, @SegmentID, @ParentSegmentID, @SegmentPosition, 
            @ParentID, @TreeLevel, @RecordCount, @FirstTreeRow, 
            @LastTreeRow, @FirstCustomSortID, @LastCustomSortID;
    END

    CLOSE cursor_query;
    DEALLOCATE cursor_query;
END;