CREATE PROCEDURE dbo.truncateLogTables
as
    TRUNCATE TABLE [dbo].[Log1];
	TRUNCATE TABLE [dbo].[Log2];
    TRUNCATE TABLE [dbo].[LogTreeSegmentTable];
    TRUNCATE TABLE [dbo].[QueryRequests];
    TRUNCATE TABLE [dbo].[logsql];