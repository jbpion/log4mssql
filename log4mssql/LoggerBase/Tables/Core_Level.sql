CREATE TABLE [LoggerBase].[Core_Level] (
    [LogLevelName]  VARCHAR (500) NOT NULL,
    [LogLevelValue] INT           NOT NULL,
    [LogLevelDesc]  VARCHAR (MAX) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_LoggerBase_Core_Level_LogLevelName]
    ON [LoggerBase].[Core_Level]([LogLevelName] ASC);

