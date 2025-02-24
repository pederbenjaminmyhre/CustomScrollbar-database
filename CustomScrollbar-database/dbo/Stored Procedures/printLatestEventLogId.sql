CREATE procedure printLatestEventLogId
as
declare @latestEventLogId INT = (select max(logId) from Log1);
exec PrintEventLogId @latestEventLogId