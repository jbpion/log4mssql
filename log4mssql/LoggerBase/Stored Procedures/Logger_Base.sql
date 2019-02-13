IF OBJECT_ID('LoggerBase.Logger_Base') IS NOT NULL
DROP PROCEDURE [LoggerBase].[Logger_Base]
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Logger_Base

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    A base logging SP that other level-specific loggers will use, e.g. Logger.Debug

    --TEST
	DECLARE @Config XML = 
'<log4mssql>
    <!-- A1 is set to be a ConsoleAppender -->
    <appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
 
        <!-- A1 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="****TEST RESULT****%timestamp [%thread] %level %logger - %message" />
        </layout>
    </appender>
    
	<appender name="A2" type="LoggerBase.Appender_ConsoleAppender">
 
        <!-- A2 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="****TEST RESULT****%timestamp [%thread] %level %logger - %message" />
        </layout>
    </appender>

<appender name="MSSQLAppender" type="LoggerBase.Appender_MSSQLAppender">
    <commandText value="INSERT INTO LoggerBase.TestLog ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
    <parameter>
        <parameterName value="@log_date" />
        <dbType value="DateTime" />
        <layout type="LoggerBase.Layout_RawTimeStampLayout" />
    </parameter>
    <parameter>
        <parameterName value="@thread" />
        <dbType value="varchar(255)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%thread" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@log_level" />
        <dbType value="varchar(50)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%level" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@logger" />
        <dbType value="varchar(255)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%logger" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@message" />
        <dbType value="varchar(4000)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%message" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@exception" />
        <dbType value="varchar(2000)" />
        <layout type="LoggerBase.Layout_PatternLayout" />
    </parameter>
</appender>

    <!-- Set root logger level to DEBUG and its only appenders to A1, A2, MSSQLAppender -->
    <root>
        <level value="DEBUG" />
        <appender-ref ref="A1" />
		<appender-ref ref="A2" />
    </root>

	<!--For the "TestProcedure" logger set the level of its "A2" appender to INFO -->
	<logger name="TestProcedure">
		<level value="INFO" />
		<appender-ref ref="A2" />
	</logger>
	<logger name="TestProcedure2">
		<level value="INFO" />
		<appender-ref ref="A2" />
	</logger>
</log4mssql>'

DECLARE @RequestedLogLevelName VARCHAR(100) = 'DEBUG'
DECLARE @LoggerName VARCHAR(500) = 'JustATestLogger'

EXEC LoggerBase.Logger_Base 
  @Message               = 'Some message.'
, @LoggerName            = @LoggerName
, @Config                = @Config
, @RequestedLogLevelName = 'DEBUG'
, @Debug                 = 1

EXEC LoggerBase.Logger_Base 
  @Message               = 'Some message.'
, @LoggerName            = 'DefaultConfigLogger'
, @RequestedLogLevelName = 'DEBUG'
, @Debug                 = 1

**********************************************************************************************/

CREATE PROCEDURE [LoggerBase].[Logger_Base] 
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500)
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @RequestedLogLevelName VARCHAR(100)
	, @LogConfiguration      LogConfiguration = NULL
	, @Debug                 BIT = 0
)

AS

    SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @PrivateConfig XML

	select * FROM LoggerBase.Configuration_Get_Properties(@LogConfiguration) C

	SELECT 
	 @LoggerName       = COALESCE(@LoggerName, C.ConfigurationPropertyValue)
	FROM LoggerBase.Configuration_Get_Properties(@LogConfiguration) C
	WHERE 1=1
	AND C.ConfigurationPropertyName = 'LoggerName'

	SELECT 
	 @StoredConfigName = COALESCE(@StoredConfigName, C.ConfigurationPropertyValue)
	FROM LoggerBase.Configuration_Get_Properties(@LogConfiguration) C
	WHERE 1=1
	AND C.ConfigurationPropertyName = 'SavedConfigurationName'

	SELECT 
	 @Config           = COALESCE(@Config, IIF(RTRIM(C.ConfigurationPropertyValue) = '', NULL, C.ConfigurationPropertyValue))
	FROM LoggerBase.Configuration_Get_Properties(@LogConfiguration) C
	WHERE 1=1
	AND C.ConfigurationPropertyName = 'ConfigurationXml'


	--TODO: Normalize out get by config name
	IF (@Config IS NULL) 
	BEGIN
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:Retrieving StoredConfig, ', @StoredConfigName, ' from LoggerBase.Config_Saved.')
		SELECT @Config = (SELECT ConfigXML FROM LoggerBase.Config_Saved WHERE ConfigName = @StoredConfigName)
	END
	EXEC LoggerBase.Config_Retrieve @Override = @Config, @Config = @PrivateConfig OUTPUT, @Debug = @Debug

	IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@Config:', CONVERT(VARCHAR(MAX), @Config))
	IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@StoredConfigName:', CONVERT(VARCHAR(MAX), @StoredConfigName))
	IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@RequestedLogLevelName:', CONVERT(VARCHAR(MAX), @RequestedLogLevelName))

	DECLARE @Appenders TABLE
	(
		RowID INT
		,AppenderType SYSNAME
		,AppenderConfig XML
	)
	INSERT INTO @Appenders
	EXEC LoggerBase.Config_Appenders_FilteredByLevel
		 @Config                = @PrivateConfig           
		,@RequestedLogLevelName = @RequestedLogLevelName
		,@Debug                 = @Debug

	DECLARE @Counter INT
	DECLARE @Limit   INT
	DECLARE @SQL     NVARCHAR(MAX)
	DECLARE @AppenderConfig XML

	SELECT @Counter = MIN(RowID), @Limit = MAX(RowID)
	FROM @Appenders

	WHILE (@Counter <= @Limit)
	BEGIN
		SELECT @SQL = CONCAT(A.AppenderType, ' @LoggerName, @LogLevelName, @Message, @Config, @Debug')
		,@AppenderConfig = AppenderConfig
		FROM @Appenders A
		WHERE 1=1
		AND RowID = @Counter

		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@SQL:', @SQL)
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@Message:', @Message)
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@AppenderConfig:', CONVERT(VARCHAR(MAX), @AppenderConfig))

		EXECUTE sp_executesql @SQL, N'@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT'
		, @LoggerName   = @LoggerName
		, @LogLevelName = @RequestedLogLevelName
		, @Message      = @Message
		, @Config       = @AppenderConfig
		, @Debug        = @Debug

		SET @Counter += 1

	END

GO


