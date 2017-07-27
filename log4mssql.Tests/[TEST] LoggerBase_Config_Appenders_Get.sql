
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbase_config_appenders';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbase_config_appenders.[SetUp]
AS
BEGIN
	PRINT 'Setup not implemented'
	--EXEC tSQLt.FakeTable 'dbo.Table'
	--INSERT INTO dbo.Table VALUES('');
END;
GO

--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbase_config_appenders.[Test Assert We Get Back The Name, Type, And Config]
AS
BEGIN
	
	DECLARE @Config XML = '<log4mssql>
	<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>
	<root>
        <level value="DEBUG" />
        <appender-ref ref="A1" />
    </root>
</log4mssql>'

	DECLARE @ExpectedAppenderName   VARCHAR(500) = 'A1'
	DECLARE @ActualAppenderName     VARCHAR(500)
	DECLARE @ExpectedAppenderType   SYSNAME       = 'LoggerBase.Appender_ConsoleAppender'
	DECLARE @ActualAppenderType     SYSNAME
	DECLARE @ExpectedAppenderConfig XML           = '<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>'
	DECLARE @ActualAppenderConfig   XML           

	SELECT 
	 @ActualAppenderName   = AppenderName
	,@ActualAppenderType   = AppenderType
	,@ActualAppenderConfig = AppenderConfig
	FROM LoggerBase.Config_Appenders_Get(@Config)

	DECLARE @ExpectedAppenderConfigConverted VARCHAR(5000) = CAST(@ExpectedAppenderConfig AS VARCHAR(5000))
	DECLARE @ActualAppenderConfigConverted   VARCHAR(5000) = CAST(@ActualAppenderConfig AS VARCHAR(5000))

	--EXEC tSQLt.AssertEquals @Expected, @Actual
	EXEC tSQLt.AssertEquals @ExpectedAppenderName,            @ActualAppenderName
	EXEC tSQLt.AssertEquals @ExpectedAppenderType,            @ActualAppenderType
	EXEC tSQLt.AssertEquals @ExpectedAppenderConfigConverted, @ActualAppenderConfigConverted
END;
GO

EXEC tSQLt.Run 'loggerbase_config_appenders'
GO

