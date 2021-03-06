CREATE PROCEDURE [loggerbasetests].[test Assert Procedure Appender_Filter_LevelRange_FilterAppenders Filters By Config]
AS
BEGIN

	--DECLARE @ExpectedMinLogLevelValue INT = 30000
	--DECLARE @ExpectedMaxLogLevelValue INT = 60000

	--DECLARE @ActualMinLogLevelValue INT 
	--DECLARE @ActualMaxLogLevelValue INT 
	DECLARE @Config XML = '
<log4mssql>
<appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender">
	<layout type="LoggerBase.Layout_PatternLayout">
		<conversionPattern value="%timestamp %level %logger-%message"/>
	</layout>
	<filter type="LoggerBase.Filter_LevelRangeFilter">
		<levelMin value="INFO" />
		<levelMax value="FATAL" />
	</filter>
</appender>
	<root>
		<level value="INFO"/>
		<appender-ref ref="Saved-Default-Console"/>
	</root>
</log4mssql>
'
	DECLARE @CurrentLoggingLevel VARCHAR(50) = 'DEBUG'

	DECLARE @Expected VARCHAR(500) = NULL
	DECLARE @Actual   VARCHAR(500)

	SELECT @Actual = AppenderName
	FROM LoggerBase.Appender_Filter_RangeFile_Apply(@Config, @CurrentLoggingLevel)

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @CurrentLoggingLevel = 'INFO'
	SET @Expected = 'Saved-Default-Console'

	SELECT @Actual = AppenderName
	FROM LoggerBase.Appender_Filter_RangeFile_Apply(@Config, @CurrentLoggingLevel)

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	--EXEC tSQLt.AssertEquals @Expected = @ExpectedMinLogLevelValue, @Actual = @ActualMinLogLevelValue
	--EXEC tSQLt.AssertEquals @Expected = @ExpectedMaxLogLevelValue, @Actual = @ActualMaxLogLevelValue

END;
GO
