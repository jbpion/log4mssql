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

	Change Log: 
	Jpion - 03/08/2019 - Make @Message optional and populate with default error message if null.

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
	  @Message               VARCHAR(MAX) = NULL
	, @LoggerName            VARCHAR(500) = NULL
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @LogConfiguration      LogConfiguration = NULL
	, @DEBUG                 BIT          = 0
)

AS

    SET NOCOUNT ON

	BEGIN TRY
		DECLARE @TokenValues VARCHAR(MAX) = CONCAT(@@SERVERNAME, '|', DB_NAME(), '|', @@SPID)

		IF @Message IS NULL EXEC Logger.DefaultErrorMessage @Message OUTPUT

		EXEC LoggerBase.Logger_Base 
		  @Message               = @Message
		, @LoggerName            = @LoggerName
		, @RequestedLogLevelName = 'ERROR'
		, @Config                = @Config
		, @StoredConfigName      = @StoredConfigName
		, @LogConfiguration      = @LogConfiguration
		, @TokenValues           = @TokenValues
		, @DEBUG                 = @DEBUG
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ')')
		PRINT @ErrorMessage
	END CATCH

GO
