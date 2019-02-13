IF OBJECT_ID('Logger.Info') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Info
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.Info

    Date:           11/28/2017
    Author:         Jerome Pion
    Description:    Log a INFO level message.

    --TEST
	EXEC Logger.INFO 'A test INFO message', 'Test Logger'
	EXEC Logger.INFO @Message = 'A test INFO message', @LoggerName = 'Test Logger', @DEBUG = 1

	EXEC LoggerBase.Session_Level_Set 'INFO', @INFO = 1
	SELECT LoggerBase.Session_ContextID_Get()
	SELECT LoggerBase.Session_Level_Get()
	
	EXEC Logger.INFO 'A test INFO message', 'Test Logger'
	EXEC Logger.INFO @Message = 'A test INFO message', @LoggerName = 'Test Logger', @DEBUG = 1

**********************************************************************************************/

ALTER PROCEDURE [Logger].[Info]
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500) = NULL
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @LogConfiguration      LogConfiguration	
	, @DEBUG                 BIT          = 0
)

AS

    SET NOCOUNT ON

	EXEC LoggerBase.Logger_Base 
	  @Message               = @Message
	, @LoggerName            = @LoggerName
	, @RequestedLogLevelName = 'INFO'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @LogConfiguration      = @LogConfiguration
	, @DEBUG                 = @DEBUG

GO


