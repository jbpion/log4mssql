
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbasetests';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
--CREATE PROCEDURE loggerbasetests.[SetUp]
--AS
--BEGIN
--	PRINT 'Setup not implemented'
--	--EXEC tSQLt.FakeTable 'dbo.Table'
--	--INSERT INTO dbo.Table VALUES('');

--	IF OBJECT_ID('LoggerBase.TestLog') IS NOT NULL DROP TABLE LoggerBase.TestLog
--	CREATE TABLE LoggerBase.TestLog
--	(
--		[Date] DATE
--		,[Thread] INT
--		,[Level] VARCHAR(500)
--		,[Logger] VARCHAR(500)
--		,[Message] VARCHAR(MAX)
--		,[Exception] VARCHAR(MAX)
--	)
--END;
--GO

CREATE FUNCTION loggerbasetests.Session_ContextID_Get()
RETURNS VARBINARY(128)
AS
BEGIN
	RETURN CAST('AC' AS VARBINARY(128))
END;
GO

CREATE FUNCTION loggerbasetests.Config_RetrieveFromSession_Return_Config()
RETURNS XML
AS
BEGIN
	RETURN '<log4mssql>SESSION</log4mssql>'
END;
GO

CREATE FUNCTION loggerbasetests.Config_RetrieveFromSession_Return_Null()
RETURNS XML
AS
BEGIN
	RETURN '<log4mssql>
    <appender name="Hard-Coded-Console" type="Logger.Appender_ConsoleAppender">
        <layout type="Logger.Layout_PatternLayout">
            <conversionPattern value="%timestamp %level %logger-%message" />
        </layout>
    </appender>
	   <root>
        <level value="DEBUG" />
        <appender-ref ref="Hard-Coded-Console" />
    </root>
</log4mssql>'
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

CREATE PROCEDURE loggerbasetests.[Test Assert Function Config_Layout Returns The Layout Type And XML Config]
AS
BEGIN

	DECLARE @TestConfig XML = '
	<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%-4timestamp [%thread] %-5level %logger %ndc - %message%newline"/>
        </layout>
    </appender>'
	DECLARE @ExpectedLayoutType   VARCHAR(500)  = 'LoggerBase.Layout_PatternLayout'
	DECLARE @ExpectedLayoutConfig VARCHAR(4000) = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%-4timestamp [%thread] %-5level %logger %ndc - %message%newline"/></layout>'

	DECLARE @ActualLayoutType   VARCHAR(500) 
	DECLARE @ActualLayoutConfig VARCHAR(4000)

	SELECT @ActualLayoutType = LayoutType, @ActualLayoutConfig = CONVERT(VARCHAR(4000), LayoutConfig)
	FROM LoggerBase.Config_Layout(@TestConfig)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedLayoutType, @Actual = @ActualLayoutType
	EXEC tSQLt.AssertEquals @Expected = @ExpectedLayoutConfig, @Actual = @ActualLayoutConfig

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Current Session (ContextID) Config XML]
AS
BEGIN

	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Config_SessionContext'
	INSERT INTO LoggerBase.Config_SessionContext(SessionContextID, Config)
	VALUES 
	 (CAST('AB' AS VARBINARY(128)), '<log4mssql>TEST-AB</log4mssql>')
	,(CAST('AC' AS VARBINARY(128)), '<log4mssql>TEST-AC</log4mssql>')

	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Session_ContextID_Get', @FakeFunctionName = 'loggerbasetests.Session_ContextID_Get'

	DECLARE @Expected VARCHAR(1000) = '<log4mssql>TEST-AC</log4mssql>'
	DECLARE @Actual   VARCHAR(1000) = (SELECT CONVERT(VARCHAR(1000), LoggerBase.Config_RetrieveFromSession()))
	
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Root Config XML]
AS
BEGIN

	DECLARE @Config XML = '<log4mssql>
    <root>
        <level value="INFO" />
        <appender-ref ref="Appender1" />
		<appender-ref ref="Appender2" />
    </root>
</log4mssql>'

	SELECT RowID = 1, LevelValue = 'INFO', AppenderRef = 'Appender1'
	INTO #Expected
	UNION ALL
	SELECT RowID = 2, LevelValue = 'INFO', AppenderRef = 'Appender2'

	SELECT RowID, LevelValue, AppenderRef 
	INTO #Actual
	FROM LoggerBase.Config_Root_Get(@Config)

	EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual'

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Int Level Of A Named Level When The Level Exists]
AS
BEGIN

	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Core_Level'
	INSERT INTO LoggerBase.Core_Level
	(LogLevelName, LogLevelValue)
	VALUES
	 ('VERBOSE', 1)
	,('DEBUG',   2)
	,('ERROR',   3)

	DECLARE @Expected INT = 2
	DECLARE @Actual INT

	SELECT @Actual = LoggerBase.Core_Level_ConvertNameToValue('DEBUG', 'MIN')

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SELECT @Actual = LoggerBase.Core_Level_ConvertNameToValue('DEBUG', NULL)

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Min Int Level Of A Named Level When The Level Does Not Exist And Min Is Requested]
AS
BEGIN

	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Core_Level'
	INSERT INTO LoggerBase.Core_Level
	(LogLevelName, LogLevelValue)
	VALUES
	 ('VERBOSE', 1)
	,('DEBUG',   2)
	,('ERROR',   3)

	DECLARE @Expected INT = 1
	DECLARE @Actual INT

	SELECT @Actual = LoggerBase.Core_Level_ConvertNameToValue('NOTALEVEL', 'MIN')

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Max Int Level Of A Named Level When The Level Does Not Exist And Max Is Requested]
AS
BEGIN

	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Core_Level'
	INSERT INTO LoggerBase.Core_Level
	(LogLevelName, LogLevelValue)
	VALUES
	 ('VERBOSE', 1)
	,('DEBUG',   2)
	,('ERROR',   3)

	DECLARE @Expected INT = 3
	DECLARE @Actual INT

	SELECT @Actual = LoggerBase.Core_Level_ConvertNameToValue('NOTALEVEL', 'MAX')

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SELECT @Actual = LoggerBase.Core_Level_ConvertNameToValue(NULL, 'MAX')

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Min Int Level Of A When Nulls Passed In]
AS
BEGIN

	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Core_Level'
	INSERT INTO LoggerBase.Core_Level
	(LogLevelName, LogLevelValue)
	VALUES
	 ('VERBOSE', 1)
	,('DEBUG',   2)
	,('ERROR',   3)

	DECLARE @Expected INT = 1
	DECLARE @Actual INT

	SELECT @Actual = LoggerBase.Core_Level_ConvertNameToValue(NULL, NULL)

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get Current Session Context Level]
AS
BEGIN

	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Session_ContextID_Get', @FakeFunctionName = 'loggerbasetests.Session_ContextID_Get'
	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Config_SessionContext'
	INSERT INTO LoggerBase.Config_SessionContext
	VALUES(CAST('AC' AS VARBINARY(128)), NULL, 'TEST', '2070-01-01')

	DECLARE @Expected VARCHAR(500) = 'TEST'
	DECLARE @Actual   VARCHAR(500) = (SELECT LoggerBase.Core_Level_RetrieveFromSession())

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The ConversionPattern From The Layout Configuration]
AS
BEGIN

	DECLARE @Config XML = '<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="ConversionPatternToReturn"/>
	</layout>'

	DECLARE @Expected VARCHAR(1000) = 'ConversionPatternToReturn'
	DECLARE @Actual   VARCHAR(1000) = (SELECT LoggerBase.Layout_GetConversionPatternFromConfig(@Config))

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Date From The Layout_GetDate Function]
AS
BEGIN

	DECLARE @Expected DATE = CAST(GETDATE() AS DATE)
	DECLARE @Actual   DATE = LoggerBase.Layout_GetDate()

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Get The Current Session (ContextID) Override Level]
AS
BEGIN

	EXEC tSQLt.FakeTable @TableName = 'LoggerBase.Config_SessionContext'
	INSERT INTO LoggerBase.Config_SessionContext(SessionContextID, OverrideLogLevelName)
	VALUES 
	 (CAST('AB' AS VARBINARY(128)), 'TESTLEVEL-AB')
	,(CAST('AC' AS VARBINARY(128)), 'TESTLEVEL-AC')

	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Session_ContextID_Get', @FakeFunctionName = 'loggerbasetests.Session_ContextID_Get'

	DECLARE @Expected VARCHAR(500) = 'TESTLEVEL-AC'
	DECLARE @Actual   VARCHAR(500) = (SELECT LoggerBase.Session_Level_Get())
	
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Console Appender Prints Raw Message]
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

	EXEC LoggerBase.Appender_ConsoleAppender 
	  @LoggerName   = @LoggerName
	, @LogLevelName = @LogLevelName 
	, @Message      = @Message
	, @Config       = @Config
	, @Debug        = 0
	'

	EXEC tSQLt.CaptureOutput @command = @SQLToTest

	DECLARE @Expected VARCHAR(1000) = 'Appender test message!
'
	DECLARE @Actual   VARCHAR(1000) = (SELECT TOP(1) OutputText FROM tSQLt.CaptureOutputLog)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Config_Appenders_FilteredByLevel Returns No Appenders When Request Level Is Below Appender Level]
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

	DECLARE @RequestedLogLevelName VARCHAR(500) = 'DEBUG'

	CREATE TABLE #Result
	(
		 RowID INT
		,AppenderType VARCHAR(500)
		,AppenderConfig XML
	)

	IF OBJECT_ID('TempDB..#Expected') IS NOT NULL DROP TABLE #Expected
	SELECT 
	 RowID
	,AppenderType
	,CONVERT(VARCHAR(1000), AppenderConfig) AS AppenderConfig
	INTO #Expected
	FROM #Result

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

	--IF OBJECT_ID('TempDB..#Expected') IS NOT NULL DROP TABLE #Expected

	--SELECT 1 AS RowID
	--,'LoggerBase.Appender_ConsoleAppender' AS AppenderType
	--,'<appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender">
	--		<layout type="LoggerBase.Layout_PatternLayout">
	--			<conversionPattern value="%timestamp %level %logger-%message"/>
	--		</layout>
	--	</appender>' AS AppenderConfig
	--INTO #Expected

	--SET @RequestedLogLevelName = 'INFO'

	--EXEC LoggerBase.Config_Appenders_FilteredByLevel @Config = @InfoConfig, @RequestedLogLevelName = @RequestedLogLevelName, @Debug = 0

	----EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Config_Appenders_FilteredByLevel Returns Appenders When Request Level Is At Appender Level]
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
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Config_Retrieve Returns Override When Passed In]
AS
BEGIN

	
	DECLARE @ExpectedConfig VARCHAR(1000) = '<log4mssql>OVERRIDE</log4mssql>'

	DECLARE @Config XML

	EXEC LoggerBase.Config_Retrieve @Override = @ExpectedConfig, @Config = @Config OUTPUT

	DECLARE @Actual VARCHAR(1000) = CONVERT(VARCHAR(1000), @Config)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedConfig, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Config_Retrieve Returns Session Config When No Override And Session Config Not Null]
AS
BEGIN

	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Config_RetrieveFromSession', @FakeFunctionName = 'loggerbasetests.Config_RetrieveFromSession_Return_Config'

	DECLARE @ExpectedConfig VARCHAR(1000) = '<log4mssql>SESSION</log4mssql>'

	DECLARE @Config XML

	EXEC LoggerBase.Config_Retrieve @Override = @ExpectedConfig, @Config = @Config OUTPUT

	DECLARE @Actual VARCHAR(1000) = CONVERT(VARCHAR(1000), @Config)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedConfig, @Actual = @Actual

END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert Config_Retrieve Returns Session Config When No Override And Is Null Return Hard-Coded Default]
AS
BEGIN

	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Config_RetrieveFromSession', @FakeFunctionName = 'loggerbasetests.Config_RetrieveFromSession_Return_Null'

	DECLARE @ExpectedConfig VARCHAR(1000) = '<log4mssql><appender name="Hard-Coded-Console" type="Logger.Appender_ConsoleAppender"><layout type="Logger.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message"/></layout></appender><root><level value="DEBUG"/><appender-ref ref="Hard-Coded-Console"/></root></log4mssql>'

	DECLARE @Config XML

	EXEC LoggerBase.Config_Retrieve @Override = @ExpectedConfig, @Config = @Config OUTPUT

	DECLARE @Actual VARCHAR(1000) = CONVERT(VARCHAR(1000), @Config)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedConfig, @Actual = @Actual

END;
GO

--Setting this aside for now. The tSQLt transaction locks us out.
--CREATE PROCEDURE loggerbasetests.[Test Assert Console MSSQL Appender Saves To Table]
--AS
--BEGIN

--DECLARE @Config XML = 
--'<appender name="MSSQLAppender" type="LoggerBase.Appender_MSSQLDatabaseAppender">
--	<connectionString value="data source=localhost;initial catalog=Log4MSSQLBuild;integrated security=true;" />
--    <commandText value="INSERT INTO LoggerBase.TestLog ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
--    <parameter>
--        <parameterName value="@log_date" />
--        <dbType value="DateTime" />
--        <layout type="LoggerBase.Layout_PatternLayout">
--            <conversionPattern value="%date" />
--        </layout>
--    </parameter>
--    <parameter>
--        <parameterName value="@thread" />
--        <dbType value="VarChar" />
--	   <size value="255" />
--        <layout type="LoggerBase.Layout_PatternLayout">
--            <conversionPattern value="%thread" />
--        </layout>
--    </parameter>
--    <parameter>
--        <parameterName value="@log_level" />
--        <dbType value="VarChar" />
--	   <size value="50" />
--        <layout type="LoggerBase.Layout_PatternLayout">
--            <conversionPattern value="%level" />
--        </layout>
--    </parameter>
--    <parameter>
--        <parameterName value="@logger" />
--        <dbType value="VarChar" />
--	   <size value="255" />
--        <layout type="LoggerBase.Layout_PatternLayout">
--            <conversionPattern value="%logger" />
--        </layout>
--    </parameter>
--    <parameter>
--        <parameterName value="@message" />
--        <dbType value="VarChar" />
--	   <size value="4000" />
--        <layout type="LoggerBase.Layout_PatternLayout">
--            <conversionPattern value="%message" />
--        </layout>
--    </parameter>
--    <parameter>
--        <parameterName value="@exception" />
--        <dbType value="VarChar" />
--	   <size value="2000" />
--        <layout type="LoggerBase.Layout_PatternLayout" />
--    </parameter>
--</appender>'



--EXEC LoggerBase.Appender_MSSQLDatabaseAppender @LoggerName = 'TestLogger', @LogLevelName = 'DEBUG', @Message = 'This is a test.', @Config = @Config
--, @Debug = 0

--SELECT * FROM LoggerBase.TestLog

--END;
--GO

EXEC tSQLt.Run 'loggerbasetests'

--EXEC tSQLt.Run 'loggerbasetests.[Test Assert Config_Retrieve Returns Session Config When No Override And Is Null Return Hard-Coded Default]'
GO

