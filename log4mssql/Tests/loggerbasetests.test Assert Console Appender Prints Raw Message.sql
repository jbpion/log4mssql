CREATE PROCEDURE [loggerbasetests].[test Assert Console Appender Prints Raw Message]
AS
BEGIN

	DECLARE @SQLToTest VARCHAR(2000) = '
	DECLARE @LoggerName   VARCHAR(500) = ''TestAppenderLoggerBase''
	DECLARE @LogLevelName VARCHAR(500) = ''DEBUG''
	DECLARE @Message      VARCHAR(MAX) = ''Appender test message!''
	DECLARE @Config       XML          = ''
	<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
		<layout type="LoggerBase.Layout_PatternLayout">
			<conversionPattern value="%message"/>
		</layout>
	</appender>''
	DECLARE @CorrelationId VARCHAR(20) = ''1234-ABC''
	DECLARE @TokenValues VARCHAR(MAX) = ''AServer|ADatabase|1234''

	EXEC LoggerBase.Appender_ConsoleAppender 
	  @LoggerName   = @LoggerName
	, @LogLevelName = @LogLevelName 
	, @Message      = @Message
	, @Config       = @Config
	, @Debug        = 0
	, @CorrelationId = @CorrelationId
	, @TokenValues  = @TokenValues
	'

	EXEC tSQLt.CaptureOutput @command = @SQLToTest

	DECLARE @Expected VARCHAR(1000) = 'Appender test message!
'
	DECLARE @Actual   VARCHAR(1000) = (SELECT TOP(1) OutputText FROM tSQLt.CaptureOutputLog)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO
