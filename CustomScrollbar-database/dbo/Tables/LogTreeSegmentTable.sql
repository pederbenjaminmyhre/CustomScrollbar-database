CREATE TABLE [dbo].[LogTreeSegmentTable] (
    [logId]             INT NULL,
    [SegmentID]         INT NULL,
    [ParentSegmentID]   INT NULL,
    [SegmentPosition]   INT NOT NULL,
    [ParentID]          INT NOT NULL,
    [TreeLevel]         INT NOT NULL,
    [RecordCount]       INT NOT NULL,
    [FirstTreeRow]      INT NOT NULL,
    [LastTreeRow]       INT NOT NULL,
    [FirstCustomSortID] INT NOT NULL,
    [LastCustomSortID]  INT NOT NULL
);

