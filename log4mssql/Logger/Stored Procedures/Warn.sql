﻿IF OBJECT_ID('Logger.Warn') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Warn
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO
/*********************************************************************************************

    PROCEDURE Logger.Warn

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

ALTER PROCEDURE Logger.Warn
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

	DECLARE @TokenValues LoggerBase.TokenValues
	INSERT INTO @TokenValues(ServerName, DatabaseName, SessionId) VALUES (@@SERVERNAME, DB_NAME(), @@SPID)

	EXEC LoggerBase.Logger_Base 
	  @Message               = @Message
	, @LoggerName            = @LoggerName
	, @RequestedLogLevelName = 'WARN'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @LogConfiguration      = @LogConfiguration
	, @TokenValues           = @TokenValues
	, @DEBUG                 = @DEBUG

