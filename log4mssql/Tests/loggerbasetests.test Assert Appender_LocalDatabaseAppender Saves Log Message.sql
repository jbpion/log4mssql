CREATE PROCEDURE [loggerbasetests].[test Assert Appender_LocalDatabaseAppender Saves Log Message]
AS
BEGIN
	DECLARE @Config XML = 
'<appender name="MSSQLAppender" type="LoggerBase.Appender_LocalDatabaseAppender">
    <commandText value="INSERT INTO loggerbasetests.TestLog ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
    <parameter>
        <parameterName value="@log_date" />
        <dbType value="DateTime" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%date" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@thread" />
        <dbType value="VarChar" />
	   <size value="255" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%thread" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@log_level" />
        <dbType value="VarChar" />
	   <size value="50" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%level" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@logger" />
        <dbType value="VarChar" />
	   <size value="255" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%logger" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@message" />
        <dbType value="VarChar" />
	   <size value="4000" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%message" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@exception" />
        <dbType value="VarChar" />
	   <size value="2000" />
        <layout type="LoggerBase.Layout_PatternLayout" />
    </parameter>
</appender>'

CREATE TABLE loggerbasetests.TestLog
(
	[Date] DATE
	,[Thread] INT
	,[Level] VARCHAR(500)
	,[Logger] VARCHAR(500)
	,[Message] VARCHAR(MAX)
	,[Exception] VARCHAR(MAX)
)

EXEC LoggerBase.Appender_LocalDatabaseAppender @LoggerName = 'TestLogger', @LogLevelName = 'DEBUG', @Message = 'This is a test.', @Config = @Config, @CorrelationId = '1234'
, @Debug = 0

SELECT CAST('DEBUG' AS VARCHAR(500)) AS [Level]
,CAST('TestLogger' AS VARCHAR(500)) AS [Logger]
,CAST('This is a test.' AS VARCHAR(MAX)) AS [Message]
INTO #Expected

SELECT 
[Level]
,Logger
,[Message]
INTO #Actual
FROM loggerbasetests.TestLog

EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual'

END;
GO
