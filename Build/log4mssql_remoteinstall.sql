:SETVAR LOGGINGDATABASE Log4MSSQLBuild
/*
NOTE:
***This script must be run in SQLCMD mode.
***Select Query->SQLCMD from the menu bar.

MIT License

Copyright (c) 2017 jbpion

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

SET NOCOUNT ON;

DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':Installation started'); RAISERROR(@Message,0,1);

DECLARE @V VARCHAR(50) = (SELECT [Version] FROM [$(LOGGINGDATABASE)].LoggerBase.VersionInfo())

SET @Message = CONCAT('| Logging database $(LOGGINGDATABASE) is at version ', @V, ' |')
PRINT CONCAT('+', REPLICATE('-', LEN(@Message)-2), '+')
PRINT @Message
PRINT CONCAT('+', REPLICATE('-', LEN(@Message)-2), '+')

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Logger')
BEGIN
	PRINT 'Creating schema Logger'
    EXEC('CREATE SCHEMA Logger')
END
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'LoggerBase')
BEGIN
	PRINT 'Creating schema LoggerBase'
	EXEC('CREATE SCHEMA LoggerBase')
END

IF OBJECT_ID('Logger.Tokens_List') IS NOT NULL DROP SYNONYM Logger.Tokens_List
BEGIN
	PRINT 'Creating synonym Logger.Tokens_List'
	CREATE SYNONYM Logger.Tokens_List FOR [$(LOGGINGDATABASE)].Logger.Tokens_List
END

IF OBJECT_ID('LoggerBase.Configuration_Get') IS NOT NULL DROP SYNONYM LoggerBase.Configuration_Get
BEGIN
	PRINT 'Creating synonym LoggerBase.Configuration_Get'
	CREATE SYNONYM LoggerBase.Configuration_Get FOR [$(LOGGINGDATABASE)].LoggerBase.Configuration_Get
END

IF OBJECT_ID('LoggerBase.Configuration_Set') IS NOT NULL DROP SYNONYM LoggerBase.Configuration_Set
BEGIN
	PRINT 'Creating synonym LoggerBase.Configuration_Set'
	CREATE SYNONYM LoggerBase.Configuration_Set FOR [$(LOGGINGDATABASE)].LoggerBase.Configuration_Set
END

IF OBJECT_ID('LoggerBase.CorrelationId_Helper') IS NOT NULL DROP SYNONYM LoggerBase.CorrelationId_Helper
BEGIN
	PRINT 'Creating synonym LoggerBase.CorrelationId_Helper'
	CREATE SYNONYM LoggerBase.CorrelationId_Helper FOR [$(LOGGINGDATABASE)].LoggerBase.CorrelationId_Helper
END

IF OBJECT_ID('LoggerBase.DefaultErrorMessage') IS NOT NULL DROP SYNONYM LoggerBase.DefaultErrorMessage
BEGIN
	PRINT 'Creating synonym LoggerBase.DefaultErrorMessage'
	CREATE SYNONYM LoggerBase.DefaultErrorMessage FOR [$(LOGGINGDATABASE)].LoggerBase.DefaultErrorMessage
END

IF OBJECT_ID('LoggerBase.Logger_Base') IS NOT NULL DROP SYNONYM LoggerBase.Logger_Base
BEGIN
	PRINT 'Creating synonym Logger.DefaultErrorMessage'
	CREATE SYNONYM LoggerBase.Logger_Base FOR [$(LOGGINGDATABASE)].LoggerBase.Logger_Base
END

IF OBJECT_ID('LoggerBase.Layout_Tokens_Pivot') IS NOT NULL DROP SYNONYM LoggerBase.Layout_Tokens_Pivot
BEGIN
	PRINT 'Creating synonym Logger.Layout_Tokens_Pivot'
	CREATE SYNONYM LoggerBase.Layout_Tokens_Pivot FOR [$(LOGGINGDATABASE)].LoggerBase.Layout_Tokens_Pivot
END

IF OBJECT_ID('LoggerBase.Util_Configuration_Properties') IS NOT NULL DROP SYNONYM LoggerBase.Util_Configuration_Properties
BEGIN
	PRINT 'Creating synonym Logger.Util_Configuration_Properties'
	CREATE SYNONYM LoggerBase.Util_Configuration_Properties FOR [$(LOGGINGDATABASE)].LoggerBase.Util_Configuration_Properties
END


GO
IF OBJECT_ID('dbo.LogConfiguration') IS NULL
CREATE TYPE [dbo].[LogConfiguration] FROM [nvarchar](max) NULL
GO


GO

CREATE TYPE LoggerBase.TokenValues AS TABLE 
(
	 ServerName    SYSNAME     NULL
	,DatabaseName  SYSNAME     NULL
	,SessionId     INT         NULL
    --,CorrelationId VARCHAR(20) NULL
	--,LoggerName    VARCHAR(500) NULL
)

GO
IF OBJECT_ID('Logger.CorrelationId') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.CorrelationId
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.CorrelationId

    Date:           03/08/2019
    Author:         Jerome Pion
    Description:    Gets a probably unique correlation Id

    --TEST

	DECLARE @CorrelationId VARCHAR(20)
	EXEC Logger.CorrelationId @CorrelationId OUTPUT
	SELECT @CorrelationId

**********************************************************************************************/

ALTER PROCEDURE Logger.CorrelationId
(
	 @CorrelationId VARCHAR(20) OUTPUT
)
AS 
BEGIN

	SET NOCOUNT ON

	BEGIN TRY
		SELECT TOP(1) @CorrelationId = CorrelationId FROM LoggerBase.CorrelationId_Helper
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ') Line: ', ERROR_LINE())
		PRINT @ErrorMessage
	END CATCH
END
GO
GO
IF OBJECT_ID('Logger.DefaultErrorMessage') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.DefaultErrorMessage
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.DefaultErrorMessage

    Date:           03/08/2019
    Author:         Jerome Pion
    Description:    Wraps the default error message function

    --TEST

	DECLARE @DefaultErrorMessage VARCHAR(20)
	EXEC Logger.DefaultErrorMessage @DefaultErrorMessage OUTPUT
	SELECT @DefaultErrorMessage

**********************************************************************************************/

ALTER PROCEDURE Logger.DefaultErrorMessage
(
	 @DefaultErrorMessage NVARCHAR(MAX) OUTPUT
)
AS 
BEGIN

	SET NOCOUNT ON

	BEGIN TRY
		SET @DefaultErrorMessage = LoggerBase.DefaultErrorMessage()
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ') Line: ', ERROR_LINE())
		PRINT @ErrorMessage
	END CATCH
END
GO
GO
IF OBJECT_ID('Logger.Configure') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Configure
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.Configure

    Date:           03/08/2019
    Author:         Jerome Pion
    Description:    Initialize a configuration.

    --TEST

	DECLARE @LogConfiguration LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @CallingProcedureId = @@PROCID

	SELECT @LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName'

	SELECT @LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName', @CallingProcedureId = @@PROCID

	SELECT @LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'InvalidPropertyName', @PropertyValue = 'AssignedLoggerName', @CallingProcedureId = @@PROCID

	SELECT @LogConfiguration

**********************************************************************************************/

ALTER PROCEDURE Logger.Configure
(
	 @CurrentConfiguration              LogConfiguration
	,@NewConfiguration                  LogConfiguration OUTPUT
	,@CallingProcedureId                INT = NULL
	,@PropertyName                      VARCHAR(5000) = NULL
	,@PropertyValue                     VARCHAR(5000) = NULL
	,@Debug                             BIT = 0
)
AS 
BEGIN

	SET NOCOUNT ON

	BEGIN TRY
	--If @PropertyName is null then set defaults
	SET @NewConfiguration = @CurrentConfiguration

	--Use sp_executesql so that we can catch the error if LoggerBase.Util_Configuration_Properties doesn't exist. 
	IF (@DEBUG = 1) PRINT CONCAT('Checking if @PropertyName ', COALESCE(@PropertyName, 'NULL'), ' is valid')
	DECLARE @PropertyExists BIT
	EXEC sp_executesql N'SELECT @PropertyExists = 1 FROM LoggerBase.Util_Configuration_Properties WHERE ConfigurationPropertyName = @PropertyName', N'@PropertyExists BIT OUTPUT, @PropertyName VARCHAR(5000)', @PropertyExists = @PropertyExists OUTPUT, @PropertyName = @PropertyName
	IF (COALESCE(@PropertyName,'') <> '' AND COALESCE(@PropertyExists, 0) <> 1)
	BEGIN
		PRINT CONCAT('[Logger.Configure]: ', @PropertyName, ' is not a valid configuration property')
		DECLARE @ConfigurationProperties TABLE
		(
			ConfigurationPropertyId INT
			,ConfigurationPropertyName VARCHAR(250)
		)

		INSERT INTO @ConfigurationProperties
		(
		    ConfigurationPropertyId,
		    ConfigurationPropertyName
		)
		EXEC sp_executesql N'SELECT ConfigurationPropertyId, ConfigurationPropertyName FROM LoggerBase.Util_Configuration_Properties'
		PRINT 'Valid propreties are:'
		DECLARE @Counter TINYINT, @Limit TINYINT, @Message VARCHAR(4000)
		SELECT @Counter = MIN(ConfigurationPropertyId), @Limit = MAX(ConfigurationPropertyId) 
		FROM @ConfigurationProperties

		WHILE (@Counter <= @Limit)
		BEGIN
			SELECT @Message = ConfigurationPropertyName
			FROM @ConfigurationProperties
			WHERE 1=1
			AND ConfigurationPropertyId = @Counter

			PRINT CONCAT('  ', @Message)
			SET @Counter += 1

		END --WHILE
	END
	ELSE 
	BEGIN
		DECLARE @CheckSQL NVARCHAR(MAX) = 'SELECT @PropertyExists = IIF(RTRIM(COALESCE(LoggerBase.Configuration_Get(@CurrentConfiguration, @PropertyName),'''')) = '''', 0, 1)'
		DECLARE @SetSQL NVARCHAR(MAX) = 'SELECT @NewConfiguration = LoggerBase.Configuration_Set(@CurrentConfiguration, @PropertyName, @PropertyValue)'
	
		IF (@PropertyName IS NULL)
		BEGIN
			IF (@DEBUG = 1) PRINT '@PropertyName is null. Setting defaults.'

			DECLARE @LoggerName VARCHAR(500) = CONCAT(OBJECT_SCHEMA_NAME(@CallingProcedureId), '.', OBJECT_NAME(@CallingProcedureId))
			IF (@CallingProcedureId IS NOT NULL AND OBJECT_NAME(@CallingProcedureId) IS NOT NULL)
			BEGIN	
				IF (@DEBUG =1) PRINT '@CallingProcedureId is valid. Checking if we should use it to set the logger name.'
				EXEC sp_executesql @CheckSQL, N'@CurrentConfiguration LogConfiguration, @PropertyExists BIT OUTPUT, @PropertyName VARCHAR(5000)', @CurrentConfiguration = @CurrentConfiguration, @PropertyExists = @PropertyExists OUTPUT, @PropertyName = 'LoggerName'
			
				IF (@PropertyExists = 0) 
				BEGIN
					IF (@Debug = 1) PRINT 'LoggerName property is not set. Attempting set using @CallingProcedureId'
					EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'LoggerName', @PropertyValue = @LoggerName
					SET @CurrentConfiguration = @NewConfiguration
				END
			END
			ELSE
			BEGIN
				EXEC sp_executesql @CheckSQL, N'@CurrentConfiguration LogConfiguration, @PropertyExists BIT OUTPUT, @PropertyName VARCHAR(5000)', @CurrentConfiguration = @CurrentConfiguration, @PropertyExists = @PropertyExists OUTPUT, @PropertyName = 'LoggerName'
			
				IF (@PropertyExists = 0) 
				BEGIN
					IF (@Debug = 1) PRINT 'LoggerName property is not set. Attempting set using default value.'
					EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'LoggerName', @PropertyValue = 'Undefined Logger'
					SET @CurrentConfiguration = @NewConfiguration
				END
			END
				--Set default LogLevel
				EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'LogLevel', @PropertyValue = 'INFO'
				SET @CurrentConfiguration = @NewConfiguration
				--Set default CorrelationId
				DECLARE @CorrelationId VARCHAR(20)
				EXEC Logger.CorrelationId @CorrelationId OUTPUT
				IF (@Debug = 1) PRINT CONCAT('Attempting to set @PropertyName: CorrelationId to default value ''', @CorrelationId, '''.')
				EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'CorrelationId', @PropertyValue = @CorrelationId
				SET @CurrentConfiguration = @NewConfiguration
				--Set default SavedConfigurationName
				EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'SavedConfigurationName', @PropertyValue = 'DEFAULT'
				SET @CurrentConfiguration = @NewConfiguration
		END
		ELSE
		BEGIN
			IF (@Debug = 1) PRINT CONCAT('Attempting to set @PropertyName: ', @PropertyName, ' to value ''', @PropertyValue, '''.')
			EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = @PropertyName, @PropertyValue = @PropertyValue
		END
	END --Valid Property Name Check
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ') Line: ', ERROR_LINE())
		PRINT @ErrorMessage
	END CATCH
END
GO
GO
IF OBJECT_ID('Logger.Debug') IS NOT NULL
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
	EXEC Logger.Debug @Message = 'A test INFO message', @LogConfiguration = @LogConfiguration

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

	BEGIN TRY
		DECLARE @TokenValues VARCHAR(MAX) = CONCAT(@@SERVERNAME, '|', DB_NAME(), '|', @@SPID)

		EXEC LoggerBase.Logger_Base 
		  @Message               = @Message
		, @LoggerName            = @LoggerName
		, @RequestedLogLevelName = 'DEBUG'
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
GO
IF OBJECT_ID('Logger.Fatal') IS NOT NULL
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
	EXEC Logger.Fatal @Message = 'A test INFO message', @LogConfiguration = @LogConfiguration

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

	BEGIN TRY
		DECLARE @TokenValues VARCHAR(MAX) = CONCAT(@@SERVERNAME, '|', DB_NAME(), '|', @@SPID)

		EXEC LoggerBase.Logger_Base 
		  @Message               = @Message
		, @LoggerName            = @LoggerName
		, @RequestedLogLevelName = 'FATAL'
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
	
	DECLARE @Config XML = '
	<log4mssql>
  <appender name="Test-Console" type="LoggerBase.Appender_ConsoleAppender">
    <layout type="LoggerBase.Layout_PatternLayout">
      <conversionPattern value="%timestamp %level %logger-%message" />
    </layout>
  </appender>
  <root>
    <level value="INFO" />
    <appender-ref ref="Test-Console" />
  </root>
</log4mssql>
	'
	DECLARE @LogConfiguration LogConfiguration
	SET @LogConfiguration = Logger.Configuration_Set(@LogConfiguration, 'ConfigurationXml', CONVERT(NVARCHAR(MAX), @Config))
	EXEC Logger.Info @Message = 'A test INFO message', @LogConfiguration = @LogConfiguration

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

	BEGIN TRY
		DECLARE @TokenValues VARCHAR(MAX) = CONCAT(@@SERVERNAME, '|', DB_NAME(), '|', @@SPID)

		EXEC LoggerBase.Logger_Base 
		  @Message               = @Message
		, @LoggerName            = @LoggerName
		, @RequestedLogLevelName = 'INFO'
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


GO
IF OBJECT_ID('Logger.Warn') IS NOT NULL
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
	EXEC Logger.Warn @Message = 'A test INFO message', @LogConfiguration = @LogConfiguration

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

	BEGIN TRY
		DECLARE @TokenValues VARCHAR(MAX) = CONCAT(@@SERVERNAME, '|', DB_NAME(), '|', @@SPID)

		EXEC LoggerBase.Logger_Base 
		  @Message               = @Message
		, @LoggerName            = @LoggerName
		, @RequestedLogLevelName = 'WARN'
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
RAISERROR('',0,1)WITH NOWAIT;
RAISERROR('+-----------------------------------------+',0,1)WITH NOWAIT;
RAISERROR('|                                         |',0,1)WITH NOWAIT;
RAISERROR('| log4mssql remote installation complete  |',0,1)WITH NOWAIT;
RAISERROR('|                                         |',0,1)WITH NOWAIT;
RAISERROR('+-----------------------------------------+',0,1)WITH NOWAIT;
GO
