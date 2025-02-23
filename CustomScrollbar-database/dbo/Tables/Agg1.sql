CREATE TABLE [dbo].[Agg1] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [parentId]    INT          NOT NULL,
    [name]        VARCHAR (50) NULL,
    [customSort]  BIGINT       NULL,
    [hasChildren] INT          NOT NULL,
    [childCount]  INT          NULL,
    [revenue]     MONEY        NULL
);

