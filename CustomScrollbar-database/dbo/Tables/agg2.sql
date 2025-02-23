CREATE TABLE [dbo].[agg2] (
    [id]              INT          NOT NULL,
    [parentId]        INT          NOT NULL,
    [name]            VARCHAR (50) NULL,
    [customSort]      BIGINT       NULL,
    [hasChildren]     INT          NOT NULL,
    [childCount]      INT          NULL,
    [revenue]         MONEY        NULL,
    [descendantCount] INT          NOT NULL,
    [TotalRevenue]    INT          NOT NULL,
    [TreeLevel]       INT          NULL
);

