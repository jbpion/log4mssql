
/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ConsoleAppender

    Date:           07/14/2017
    Author:         Jerome Pion
    Description:    Invokes the requested appender using the provided XML configuration.

    --TEST
	DECLARE @LoggerName   VARCHAR(500) = 'TestAppenderLoggerBase'
	DECLARE @LogLevelName VARCHAR(500) = 'DEBUG'
	DECLARE @Message      VARCHAR(MAX) = 'Appender test message!'
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
	, @Debug        = 1

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_ConsoleAppender (@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config LoggerBase.ConfigurationProperties READONLY, @Debug BIT=0)
AS
	
	SET NOCOUNT ON

	IF (@Debug = 1) PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Message:', @Message)

	DECLARE @FormattedMessage VARCHAR(MAX)
	DECLARE @LayoutType       SYSNAME
	DECLARE @LayoutConfig     LoggerBase.ConfigurationProperties
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
		, @Debug           = @Debug
		, @FormattedMessage = @FormattedMessage OUTPUT

	PRINT @FormattedMessage

GO
