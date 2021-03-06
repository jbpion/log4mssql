CREATE PROCEDURE [loggerbasetests].[test Assert Function Config_Appenders_Get Returns A Table Of Appenders, Types, and Configs]
AS
BEGIN

	DECLARE @Config XML = 
	'<log4mssql>
		<appender name="LocalDBAppender" type="LoggerBase.Appender_LocalDatabaseAppender">
			<commandText value="INSERT SQL HERE" />
			<parameter>
				<parameterName value="@log_date" />
				<dbType value="DateTime" />
				<layout type="LoggerBase.Layout_PatternLayout">
					<conversionPattern value="%date" />
				</layout>
			</parameter>
		</appender>
		<appender name="ConsoleAppender" type="LoggerBase.Appender_ConsoleAppender">
			<layout type="LoggerBase.Layout_PatternLayout">
				<conversionPattern value="message" />
			</layout>
        </appender>
		<root>
			<level value="INFO" />
			<appender-ref ref="LocalDBAppender" />
			<appender-ref ref="ConsoleAppender" />
		</root>
	</log4mssql>'
	
	SELECT RowID = 1,AppenderName = 'ConsoleAppender', AppenderType = 'LoggerBase.Appender_ConsoleAppender', AppenderConfig = '<appender name="ConsoleAppender" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="message"/></layout></appender>'
		INTO #Expected
		UNION ALL
	SELECT RowID = 2,AppenderName = 'LocalDBAppender', AppenderType = 'LoggerBase.Appender_LocalDatabaseAppender', AppenderConfig = '<appender name="LocalDBAppender" type="LoggerBase.Appender_LocalDatabaseAppender"><commandText value="INSERT SQL HERE"/><parameter><parameterName value="@log_date"/><dbType value="DateTime"/><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%date"/></layout></parameter></appender>'

	SELECT 
	RowID
	,AppenderName
	,AppenderType
	,CAST(AppenderConfig AS VARCHAR(8000)) AS AppenderConfig
	INTO #Actual
	FROM LoggerBase.Config_Appenders_Get(@Config)

	--SELECT * FROM #Expected
	--SELECT * FROM #Actual

	EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual'

	--EXEC tSQLt.AssertEquals @Expected = @ExpectedMinLogLevelValue, @Actual = @ActualMinLogLevelValue
	--EXEC tSQLt.AssertEquals @Expected = @ExpectedMaxLogLevelValue, @Actual = @ActualMaxLogLevelValue

END;
GO
