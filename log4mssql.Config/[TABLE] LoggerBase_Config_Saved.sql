SET NOCOUNT ON
SET ANSI_PADDING ON

PRINT 'TABLE LoggerBase.Config_Saved CREATED ' + CONVERT(VARCHAR(10), GETDATE(), 101)
GO

IF OBJECT_ID('LoggerBase.Config_Saved') IS NOT NULL
BEGIN
    PRINT '   DROP TABLE LoggerBase.Config_Saved'
    DROP TABLE LoggerBase.Config_Saved
END
GO

PRINT '   CREATE TABLE LoggerBase.Config_Saved'
GO

CREATE TABLE LoggerBase.Config_Saved 
(
    ConfigName     VARCHAR(500) NOT NULL
   ,ConfigXML      XML          NOT NULL
   ,CreateDateTime DATETIME2    NOT NULL CONSTRAINT DF_Config_Saved_CreateDateTime DEFAULT (GETUTCDATE()),
    CONSTRAINT PK_Config_Saved PRIMARY KEY CLUSTERED (ConfigName)
)
GO

IF @@ERROR = 0
BEGIN
    PRINT '   TABLE LoggerBase.Config_Saved CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE TABLE LoggerBase.Config_Saved FAILED'
END
GO

