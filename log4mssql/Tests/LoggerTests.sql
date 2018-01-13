
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbasetests';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbasetests.[SetUp]
AS
BEGIN
	--PRINT 'Setup not implemented'
	PRINT ''
	--EXEC tSQLt.FakeTable 'dbo.Table'
	--INSERT INTO dbo.Table VALUES('');
END;
GO

--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbasetests.[Test Assert Appender_LocalDatabaseAppender Saves Log Message]
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

EXEC LoggerBase.Appender_LocalDatabaseAppender @LoggerName = 'TestLogger', @LogLevelName = 'DEBUG', @Message = 'This is a test.', @Config = @Config
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

--CREATE PROCEDURE loggerbasetests.[Test Assert Function Appender_File_WriteTextFile Writes A New File]
--AS
--BEGIN
--	SELECT [LoggerBase].[Appender_File_WriteTextFile]('Just a test message', 'C:\Temp\FileAppenderTest.txt', 0)
--END;
--GO

CREATE PROCEDURE loggerbasetests.[Test Assert Procedure Appender_File_Private_WriteTextFile Writes A New File]
AS
BEGIN
	--SELECT [LoggerBase].[Appender_File_WriteTextFile]('Just a test message', 'C:\Temp\FileAppenderTest.txt', 0)
	DECLARE 	 
	 @text   NVARCHAR(4000) = N'Just a test message'
	,@path   NVARCHAR(4000) = N'C:\Temp\FileAppenderTest.txt'
	,@append BIT = 0
	,@exitCode INT 
	,@errorMessage NVARCHAR(4000) 

	EXEC LoggerBase.Appender_File_Private_WriteTextFile 
	@text = @text
	,@path = @path
	,@append = @append
	,@exitCode = @exitCode OUTPUT
	,@errorMessage = @errorMessage OUTPUT
END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Procedure Appender_Filter_LevelRange Returns Defaults When Null Passed In]
AS
BEGIN

	DECLARE @ExpectedMinLogLevelValue INT = -2147483647
	DECLARE @ExpectedMaxLogLevelValue INT = 2147483647

	DECLARE @ActualMinLogLevelValue INT 
	DECLARE @ActualMaxLogLevelValue INT 

	SELECT @ActualMinLogLevelValue = MinLogLevelValue, @ActualMaxLogLevelValue = MaxLogLevelValue
	FROM LoggerBase.Appender_Filter_LevelRange(NULL, NULL)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedMinLogLevelValue, @Actual = @ActualMinLogLevelValue
	EXEC tSQLt.AssertEquals @Expected = @ExpectedMaxLogLevelValue, @Actual = @ActualMaxLogLevelValue

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Procedure Appender_Filter_LevelRange Returns Correct Lookups]
AS
BEGIN

	DECLARE @ExpectedMinLogLevelValue INT = 30000
	DECLARE @ExpectedMaxLogLevelValue INT = 60000

	DECLARE @ActualMinLogLevelValue INT 
	DECLARE @ActualMaxLogLevelValue INT 

	SELECT @ActualMinLogLevelValue = MinLogLevelValue, @ActualMaxLogLevelValue = MaxLogLevelValue
	FROM LoggerBase.Appender_Filter_LevelRange('DEBUG', 'WARN')

	EXEC tSQLt.AssertEquals @Expected = @ExpectedMinLogLevelValue, @Actual = @ActualMinLogLevelValue
	EXEC tSQLt.AssertEquals @Expected = @ExpectedMaxLogLevelValue, @Actual = @ActualMaxLogLevelValue

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Procedure Appender_Filter_LevelRange_FilterAppenders Filters By Config]
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

CREATE PROCEDURE loggerbasetests.[Test Assert Function Config_Appenders_Get Returns A Table Of Appenders, Types, and Configs]
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


EXEC tSQLt.Run 'loggerbasetests'
GO

