IF OBJECT_ID('LoggerBase.Appender_ConsoleAppender') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE LoggerBase.Appender_ConsoleAppender
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO
/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ConsoleAppender

    Date:           07/14/2017
    Author:         Jerome Pion
    Description:    Invokes the requested appender using the provided XML configuration.

    --TEST
	DECLARE @LoggerName   VARCHAR(500) = 'TestAppenderLoggerBase'
	DECLARE @LogLevelName VARCHAR(500) = 'DEBUG'
	DECLARE @Message      VARCHAR(MAX) = 'Appender test message!'
	DECLARE @TokenValues  LoggerBase.TokenValues
	DECLARE @CorrelationId VARCHAR(20) = '1234-F'
	INSERT INTO @TokenValues (ServerName, DatabaseName, SessionId) VALUES ('ADb', 'AServer', 20)
	DECLARE @Config       XML          = '<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>'

	EXEC LoggerBase.Appender_ConsoleAppender 
	  @LoggerName   = @LoggerName
	, @LogLevelName = @LogLevelName 
	, @Message      = @Message
	, @Config       = @Config
	, @TokenValues  = @TokenValues
	, @CorrelationId = @CorrelationId
	, @Debug        = 1

**********************************************************************************************/

ALTER PROCEDURE LoggerBase.Appender_ConsoleAppender (@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @CorrelationId VARCHAR(50), @Debug BIT=0, @TokenValues LoggerBase.TokenValues READONLY)
AS
	
	SET NOCOUNT ON

	IF (@Debug = 1) PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Message:', @Message)

	DECLARE @FormattedMessage VARCHAR(MAX)
	DECLARE @LayoutType       SYSNAME
	DECLARE @LayoutConfig     XML
	DECLARE @SQL              NVARCHAR(MAX)

	SELECT @LayoutType = LayoutType, @LayoutConfig = LayoutConfig FROM LoggerBase.Config_Layout(@Config)

	IF (@Debug = 1)
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:'    , CONVERT(VARCHAR(MAX), @Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LayoutType:', @LayoutType)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@SQL:'       , @SQL)
	END

	EXEC LoggerBase.Layout_FormatMessage 
		  @LayoutTypeName  = @LayoutType
		, @LoggerName      = @LoggerName
		, @LogLevelName    = @LogLevelName
		, @Message         = @Message
		, @LayoutConfig    = @LayoutConfig
		, @CorrelationId   = @CorrelationId
		, @Debug           = @Debug
		, @TokenValues     = @TokenValues
		, @FormattedMessage = @FormattedMessage OUTPUT

	PRINT @FormattedMessage

GO
