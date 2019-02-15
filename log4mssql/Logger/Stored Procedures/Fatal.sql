﻿IF OBJECT_ID('Logger.Fatal') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Fatal
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.Fatal

    Date:           11/28/2017
    Author:         Jerome Pion
    Description:    Log a Fatal level message.

    --TEST
	EXEC Logger.Fatal 'A test Fatal message', 'Test Logger'
	EXEC Logger.Fatal @Message = 'A test Fatal message', @LoggerName = 'Test Logger', @DEBUG = 1

	EXEC LoggerBase.Session_Level_Set 'Fatal', @Fatal = 1
	SELECT LoggerBase.Session_ContextID_Get()
	SELECT LoggerBase.Session_Level_Get()
	
	EXEC Logger.Fatal 'A test Fatal message', 'Test Logger'
	EXEC Logger.Fatal @Message = 'A test Fatal message', @LoggerName = 'Test Logger', @DEBUG = 1

**********************************************************************************************/

ALTER PROCEDURE Logger.Fatal
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
	, @RequestedLogLevelName = 'FATAL'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @LogConfiguration      = LogConfiguration
	, @DEBUG                 = @DEBUG

