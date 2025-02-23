CREATE PROCEDURE sp_GetVirtualScrollingData
    @StartRow INT,         -- The starting row based on vertical scroll
    @PageSize INT,         -- Number of rows to retrieve
    @StartColumn INT,      -- The first visible column (based on horizontal scroll)
    @EndColumn INT         -- The last visible column (based on horizontal scroll)
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a dynamic SQL query to select only the columns that are visible
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Dynamically generate the SELECT statement based on the visible columns
    SET @SQL = 'SELECT ID,';

    -- Generate the column names dynamically based on @StartColumn and @EndColumn
    DECLARE @ColumnIndex INT = @StartColumn;

    WHILE @ColumnIndex <= @EndColumn
    BEGIN
        -- Append the column name to the SELECT statement (e.g., Col1, Col2, Col3, etc.)
        SET @SQL = @SQL + 'Col' + CAST(@ColumnIndex AS NVARCHAR(10)) + ', ';
        SET @ColumnIndex = @ColumnIndex + 1;
    END

    -- Remove the trailing comma and space
    SET @SQL = LEFT(@SQL, LEN(@SQL) - 1);

    -- Add the FROM clause and pagination using OFFSET and FETCH
    SET @SQL = @SQL + ' FROM VirtualScrolling ' +
               'ORDER BY ID ' + 
               'OFFSET ' + CAST((@StartRow-1) AS NVARCHAR(10)) + ' ROWS ' +
               'FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(10)) + ' ROWS ONLY;';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @SQL;
END;
