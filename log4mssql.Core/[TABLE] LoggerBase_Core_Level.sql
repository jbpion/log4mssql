SET NOCOUNT ON
SET ANSI_PADDING ON

PRINT 'TABLE LoggerBase.Core_Level CREATED ' + CONVERT(VARCHAR(10), GETDATE(), 101)
GO

IF OBJECT_ID('LoggerBase.Core_Level') IS NOT NULL
BEGIN
    PRINT '   DROP TABLE LoggerBase.Core_Level'
    DROP TABLE LoggerBase.Core_Level
END
GO

PRINT '   CREATE TABLE LoggerBase.Core_Level'
GO

CREATE TABLE LoggerBase.Core_Level
(
	 LogLevelName  VARCHAR(500) NOT NULL
	,LogLevelValue INT          NOT NULL
	,LogLevelDesc  VARCHAR(MAX) NOT NULL
)

EXEC('CREATE UNIQUE NONCLUSTERED INDEX UX_LoggerBase_Core_Level_LogLevelName ON LoggerBase.Core_Level(LogLevelName)')

GO

IF @@ERROR = 0
BEGIN
    PRINT '   TABLE LoggerBase.Core_Level CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE TABLE LoggerBase.Core_Level FAILED'
END
GO

