IF OBJECT_ID('Logger.Error') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Error
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.ERROR

    Date:           11/28/2017
    Author:         Jerome Pion
    Description:    Log a ERROR level message.

    --TEST
DECLARE @Config XML = '
	<log4mssql>
  <appender name="Test-Console" type="LoggerBase.Appender_ConsoleAppender">
    <layout type="LoggerBase.Layout_PatternLayout">
      <conversionPattern value="%timestamp %level %server %dbname %thread %logger-%message" />
    </layout>
  </appender>
  <root>
    <level value="DEBUG" />
    <appender-ref ref="Test-Console" />
  </root>
</log4mssql>
	'
	DECLARE @LogConfiguration LogConfiguration
	SET @LogConfiguration = Logger.Configuration_Set(@LogConfiguration, 'ConfigurationXml', CONVERT(NVARCHAR(MAX), @Config))
	EXEC Logger.Error @Message = 'A test INFO message', @LogConfiguration = @LogConfiguration

**********************************************************************************************/

ALTER PROCEDURE [Logger].[Error]
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500) = NULL
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @LogConfiguration      LogConfiguration = NULL
	, @DEBUG                 BIT          = 0
)

AS

    SET NOCOUNT ON

	DECLARE @TokenValues VARCHAR(MAX) = CONCAT(@@SERVERNAME, '|', DB_NAME(), '|', @@SPID)

	EXEC LoggerBase.Logger_Base 
	  @Message               = @Message
	, @LoggerName            = @LoggerName
	, @RequestedLogLevelName = 'ERROR'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @LogConfiguration      = @LogConfiguration
	, @TokenValues           = @TokenValues
	, @DEBUG                 = @DEBUG

GO


