﻿IF OBJECT_ID('Logger.Debug') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Debug
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.Debug

    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    Log a DEBUG level message.

    --TEST
	EXEC Logger.Debug 'A test debug message', 'Test Logger'
	EXEC Logger.Debug @Message = 'A test debug message', @LoggerName = 'Test Logger', @Debug = 1

	EXEC LoggerBase.Session_Level_Set 'DEBUG', @Debug = 1
	SELECT LoggerBase.Session_ContextID_Get()
	SELECT LoggerBase.Session_Level_Get()
	
	EXEC Logger.Debug 'A test debug message', 'Test Logger'
	EXEC Logger.Debug @Message = 'A test debug message', @LoggerName = 'Test Logger', @Debug = 1

**********************************************************************************************/

ALTER PROCEDURE Logger.Debug
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500) = NULL
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @LogConfiguration      LogConfiguration	
	, @Debug                 BIT          = 0
)

AS

    SET NOCOUNT ON

	DECLARE @TokenValues LoggerBase.TokenValues
	INSERT INTO @TokenValues(ServerName, DatabaseName, SessionId) VALUES (@@SERVERNAME, DB_NAME(), @@SPID)

	EXEC LoggerBase.Logger_Base 
	  @Message               = @Message
	, @LoggerName            = @LoggerName
	, @RequestedLogLevelName = 'DEBUG'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @LogConfiguration      = @LogConfiguration
	, @TokenValues           = @TokenValues
	, @DEBUG                 = @DEBUG

