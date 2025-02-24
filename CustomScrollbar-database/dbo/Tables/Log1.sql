CREATE TABLE [dbo].[Log1] (
    [logId]     INT           IDENTITY (1, 1) NOT NULL,
    [eventName] VARCHAR (100) NULL,
    [ts_log]    VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([logId] ASC)
);

