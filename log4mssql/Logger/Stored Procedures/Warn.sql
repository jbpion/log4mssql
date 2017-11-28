
/*********************************************************************************************

    PROCEDURE Logger.WARN

    Date:           11/28/2017
    Author:         Jerome Pion
    Description:    Log a WARN level message.

    --TEST
	EXEC Logger.WARN 'A test WARN message', 'Test Logger'
	EXEC Logger.WARN @Message = 'A test WARN message', @LoggerName = 'Test Logger', @DEBUG = 1

	EXEC LoggerBase.Session_Level_Set 'WARN', @WARN = 1
	SELECT LoggerBase.Session_ContextID_Get()
	SELECT LoggerBase.Session_Level_Get()
	
	EXEC Logger.WARN 'A test WARN message', 'Test Logger'
	EXEC Logger.WARN @Message = 'A test WARN message', @LoggerName = 'Test Logger', @DEBUG = 1

**********************************************************************************************/

CREATE PROCEDURE Logger.WARN
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500)
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @DEBUG                 BIT          = 0
)

AS

    SET NOCOUNT ON

	EXEC LoggerBase.Logger_Base 
	  @Message               = @Message
	, @LoggerName            = @LoggerName
	, @RequestedLogLevelName = 'WARN'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @DEBUG                 = @DEBUG

