CREATE TYPE [dbo].[TreeSegmentType] AS TABLE (
    [parentId]          INT NULL,
    [firstRecordNumber] INT NULL,
    [lastRecordNumber]  INT NULL,
    [treeLevel]         INT NULL);

