
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbase_config_appenders_filteredbylevel';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbase_config_appenders_filteredbylevel.[SetUp]
AS
BEGIN
	
	EXEC tSQLt.FakeTable 'LoggerBase.Core_Level'
	INSERT INTO LoggerBase.Core_Level(LogLevelName, LogLevelValue)  VALUES('DEBUG', 1), ('INFO', 2)
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Config_Root ', @FakeFunctionName = 'loggerbase_config_appenders_filteredbylevel.Config_Root'
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Config_Appenders ', @FakeFunctionName = 'loggerbase_config_appenders_filteredbylevel.Config_Appenders'
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Core_Level_RetrieveFromSession', @FakeFunctionName = 'loggerbase_config_appenders_filteredbylevel.Core_Level_RetrieveFromSession'
END;
GO

CREATE FUNCTION loggerbase_config_appenders_filteredbylevel.Config_Root(@Config XML)
RETURNS @Root TABLE
(
	 RowID      INT
	,LevelValue VARCHAR(500)
	,AppenderRef VARCHAR(500)
)
AS
BEGIN
	INSERT INTO @Root
	SELECT 
	1 AS RowID
	,'DEBUG'
	,'A1'
	
	RETURN

END;
GO

CREATE FUNCTION loggerbase_config_appenders_filteredbylevel.Config_Appenders(@Config XML)
RETURNS TABLE
AS

	RETURN

	SELECT 
	1 AS RowID
	,'A1' AS AppenderName
	,'LoggerBase.Appender_ConsoleAppender' as AppenderType
	,'<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>' AS AppenderConfig
	FROM @Config.nodes('/log4mssql/appender') as t(appender)

GO

CREATE FUNCTION loggerbase_config_appenders_filteredbylevel.Core_Level_RetrieveFromSession()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @Level VARCHAR(500) = NULL

	RETURN @Level
END;
GO

--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbase_config_appenders_filteredbylevel.[Test Assert We Only Return Loggers At Or Above Logging Level]
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

	CREATE TABLE #Results
	(
		RowID INT
		,AppenderType VARCHAR(500)
		,AppenderConfig XML
	)

	SELECT TOP(0) * INTO #Expected FROM #Results
	SELECT TOP(0) * INTO #Actual   FROM #Results

	INSERT INTO #Expected
	SELECT RowID = 1
	,AppenderType = 'LoggerBase.Appender_ConsoleAppender'
	,AppenderConfig = '<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>'

	INSERT INTO #Actual
	EXEC LoggerBase.Config_Appenders_FilteredByLevel @Config = @Config, @RequestedLogLevelName = 'DEBUG'
	select * from #Actual
	SELECT RowID, AppenderType, CONVERT(VARCHAR(5000), AppenderConfig) AS AppenderConfig
	INTO #ExpectedConverted
	FROM #Expected

	SELECT RowID, AppenderType, CONVERT(VARCHAR(5000), AppenderConfig) AS AppenderConfig
	INTO #ActualConverted
	FROM #Actual

	EXEC tSQLt.AssertEqualsTable @Expected='#ExpectedConverted', @Actual='#ActualConverted'

END;
GO

EXEC tSQLt.Run 'loggerbase_config_appenders_filteredbylevel'
GO

