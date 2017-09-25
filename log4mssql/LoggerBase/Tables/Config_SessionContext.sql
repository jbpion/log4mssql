CREATE TABLE [LoggerBase].[Config_SessionContext] (
    [SessionContextID]      UNIQUEIDENTIFIER NULL,
    [Config]                XML              NULL,
    [OverrideLogLevelName]  VARCHAR (500)    NULL,
    [ExpirationDatetimeUTC] DATETIME2 (7)    NULL
);

