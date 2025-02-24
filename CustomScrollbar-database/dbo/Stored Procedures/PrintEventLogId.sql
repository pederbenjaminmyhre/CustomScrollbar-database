CREATE procedure PrintEventLogId
(
	@logId int
)
as
begin

declare @eventName as varchar(100);
declare @ts_log as varchar(max);

-- get event name and typescript log
SELECT  
      @eventName = [eventName]
      ,@ts_log = [ts_log]
from [dbo].[Log1]

PRINT '
TypeScript for logID: ' + cast(@logId as varchar(20)) + '; Event: "' + @eventName + '"'
PRINT @ts_log

PRINT '
TreeSegments for logID: ' + cast(@logId as varchar(20)) + '; Event: "' + @eventName + '"'
exec print_treeSegments2 @logId

PRINT '
QueryRequests for logID: ' + cast(@logId as varchar(20)) + '; Event: "' + @eventName + '"'
exec print_queryRequests2 @logId

PRINT '
SQL for logID: ' + cast(@logId as varchar(20)) + '; Event: "' + @eventName + '"'
declare @dynamic_sql varchar(max)
select @dynamic_sql = dynamic_sql 
from logsql
where logid = @logid
print @dynamic_sql

end