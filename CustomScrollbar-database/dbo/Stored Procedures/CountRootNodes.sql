CREATE PROCEDURE dbo.CountRootNodes
(
	@NumberOfRootNodes INT output
)
AS
BEGIN
	select @NumberOfRootNodes = max(CustomSort)
	from ActiveAnalyticalTable
	where parentId = 0
END