CREATE PROCEDURE [loggerbasetests].[test Assert Config_Appenders_FilteredByLevel Returns Appenders When Request Level Is At Appender Level]
AS
BEGIN

	--Set the level to "INFO" and above.
	DECLARE @InfoConfig XML = '
	<log4mssql>
		<appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender">
			<layout type="LoggerBase.Layout_PatternLayout">
				<conversionPattern value="%timestamp %level %logger-%message"/>
			</layout>
		</appender>
		<root>
			<level value="INFO"/>
			<appender-ref ref="Saved-Default-Console"/>
		</root>
	</log4mssql>'

	DECLARE @RequestedLogLevelName VARCHAR(500) = 'INFO'

	CREATE TABLE #Result
	(
		 RowID INT
		,AppenderType VARCHAR(500)
		,AppenderConfig XML
	)

	IF OBJECT_ID('TempDB..#Expected') IS NOT NULL DROP TABLE #Expected
	SELECT 
	 1 AS RowID
	,'LoggerBase.Appender_ConsoleAppender' AS AppenderType
	,'<appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message"/></layout></appender>' AS AppenderConfig
	INTO #Expected

	--Request a debug output. The appender should not fire.
	INSERT INTO #Result
	EXEC LoggerBase.Config_Appenders_FilteredByLevel @Config = @InfoConfig, @RequestedLogLevelName = @RequestedLogLevelName, @Debug = 0

	SELECT 
	 RowID
	,AppenderType
	,CONVERT(VARCHAR(1000), AppenderConfig) AS AppenderConfig
	INTO #Actual
	FROM #Result

	EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual'

END;

--EXEC tSQLt.Run '[loggerbasetests].[Test Assert Config_Appenders_FilteredByLevel Returns Appenders When Request Level Is At Appender Level]'

GO
