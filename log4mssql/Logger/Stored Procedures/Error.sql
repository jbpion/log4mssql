
/*********************************************************************************************

    PROCEDURE Logger.ERROR

    Date:           11/28/2017
    Author:         Jerome Pion
    Description:    Log a ERROR level message.

    --TEST
	EXEC Logger.ERROR 'A test ERROR message', 'Test Logger'
	EXEC Logger.ERROR @Message = 'A test ERROR message', @LoggerName = 'Test Logger', @DEBUG = 1

	EXEC LoggerBase.Session_Level_Set 'ERROR', @ERROR = 1
	SELECT LoggerBase.Session_ContextID_Get()
	SELECT LoggerBase.Session_Level_Get()
	
	EXEC Logger.ERROR 'A test ERROR message', 'Test Logger'
	EXEC Logger.ERROR @Message = 'A test ERROR message', @LoggerName = 'Test Logger', @DEBUG = 1

**********************************************************************************************/

CREATE PROCEDURE Logger.Error
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
	, @RequestedLogLevelName = 'ERROR'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @DEBUG                 = @DEBUG

