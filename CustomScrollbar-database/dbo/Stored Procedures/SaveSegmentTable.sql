CREATE PROCEDURE SaveSegmentTable
    @SegmentTableSegment SegmentTableType READONLY,
	@logId Int output,
	@log1 varchar(max),
	@eventName varchar(100)
AS
BEGIN
	INSERT INTO Log1(eventName, ts_log)
	select @eventName, @log1

	SET @logId = SCOPE_IDENTITY();

    INSERT INTO LogTreeSegmentTable (logId, SegmentID, ParentSegmentID, SegmentPosition, ParentID, TreeLevel, RecordCount, FirstTreeRow, LastTreeRow, FirstCustomSortID, LastCustomSortID)
    SELECT @logId, SegmentID, ParentSegmentID, SegmentPosition, ParentID, TreeLevel, RecordCount, FirstTreeRow, LastTreeRow, FirstCustomSortID, LastCustomSortID
    FROM @SegmentTableSegment;
	
END;