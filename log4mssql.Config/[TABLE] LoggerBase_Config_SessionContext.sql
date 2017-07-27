IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LoggerBase.Config_SessionContext') AND type in (N'U'))
DROP TABLE LoggerBase.Config_SessionContext
GO

CREATE TABLE LoggerBase.Config_SessionContext
(
	  SessionContextID      UNIQUEIDENTIFIER
	, Config                XML
	, OverrideLogLevelName  VARCHAR(500)
	, ExpirationDatetimeUTC DATETIME2
)