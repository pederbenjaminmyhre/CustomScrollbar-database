create PROCEDURE print_queryRequests2
(
    @logId INT
)
AS
BEGIN
    DECLARE @ColumnHeaders NVARCHAR(MAX);
    DECLARE @ColumnValues NVARCHAR(MAX);

    -- Define column headers explicitly in the correct order
    SET @ColumnHeaders = 'logId' + CHAR(9) + 
                         'parentId' + CHAR(9) + 
                         'firstRecordNumber' + CHAR(9) + 
                         'lastRecordNumber' + CHAR(9) + 
                         'treeLevel';

    PRINT @ColumnHeaders;

    -- Loop through each record and print values separated by tabs
    DECLARE @logId1 INT, @parentId INT, @firstRecordNumber INT, @lastRecordNumber INT, @treeLevel INT;
    DECLARE cursor_query CURSOR FOR
    SELECT [logId], [parentId], [firstRecordNumber], [lastRecordNumber], [treeLevel]
    FROM [dbo].[QueryRequests]
    WHERE logId = @logId;

    OPEN cursor_query;
    FETCH NEXT FROM cursor_query INTO @logId1, @parentId, @firstRecordNumber, @lastRecordNumber, @treeLevel;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ColumnValues = 
            CAST(@logId1 AS NVARCHAR) + CHAR(9) +
            CAST(@parentId AS NVARCHAR) + CHAR(9) +
            CAST(@firstRecordNumber AS NVARCHAR) + CHAR(9) +
            CAST(@lastRecordNumber AS NVARCHAR) + CHAR(9) +
            CAST(@treeLevel AS NVARCHAR);

        PRINT @ColumnValues;

        FETCH NEXT FROM cursor_query INTO @logId1, @parentId, @firstRecordNumber, @lastRecordNumber, @treeLevel;
    END

    CLOSE cursor_query;
    DEALLOCATE cursor_query;
END;