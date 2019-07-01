CREATE TABLE [LoggerBase].[Core_Level] (
    [LogLevelName]  VARCHAR (500) NOT NULL CONSTRAINT [PK_LoggerBase_Core_Level] PRIMARY KEY CLUSTERED ([LogLevelName]),
    [LogLevelValue] INT           NOT NULL,
    [LogLevelDesc]  VARCHAR (MAX) NOT NULL
);


