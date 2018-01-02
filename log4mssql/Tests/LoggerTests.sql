
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbasetests';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbasetests.[SetUp]
AS
BEGIN
	--PRINT 'Setup not implemented'
	--EXEC tSQLt.FakeTable 'dbo.Table'
	--INSERT INTO dbo.Table VALUES('');
	PRINT ''
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

CREATE PROCEDURE loggerbasetests.[Test Assert We Can Return The Configuration Pattern From A ConfigurationProperties Table]
AS
BEGIN
	
	DECLARE @ConfigurationProperties LoggerBase.ConfigurationProperties

	INSERT INTO @ConfigurationProperties
	(
	 ObjectID                     
	,ParentObjectID               
	,MaterializedPathByID         
	,MaterializedPathByElementName
	,ElementName                  
	,ElementValue
	)
	VALUES
	 (1, NULL, '1',       'layout',                              'layout',              ''                                                          )
	,(2, 1,    '1.2',     'layout.type',                         'type',                'LoggerBase.Layout_PatternLayout'                           )
	,(3, 2,    '1.2.3',   'layout.type.conversionPattern',       'conversionPattern',   ''                                                          )
	,(4, 3,    '1.2.3.4', 'layout.type.conversionPattern.value', 'value',               '%timestamp [%thread] %level %LoggerBase - %message%newline')
	
	DECLARE @Expected VARCHAR(1000) = '%timestamp [%thread] %level %LoggerBase - %message%newline'
	DECLARE @Actual   VARCHAR(1000)
	
	SELECT @Actual = LoggerBase.Layout_GetConversionPatternFromConfigProperties(@ConfigurationProperties)
	
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual
END;
GO

CREATE PROCEDURE loggerbasetests.[Test Assert We Get The Layout Pattern]
AS
BEGIN
	
	DECLARE @ConfigurationProperties LoggerBase.ConfigurationProperties

	INSERT INTO @ConfigurationProperties
	(
	 ObjectID                     
	,ParentObjectID               
	,MaterializedPathByID         
	,MaterializedPathByElementName
	,ElementName                  
	,ElementValue
	)
	VALUES
	 (1, NULL, '1',       'layout',                              'layout',              ''                                                          )
	,(2, 1,    '1.2',     'layout.type',                         'type',                'LoggerBase.Layout_PatternLayout'                           )
	,(3, 2,    '1.2.3',   'layout.type.conversionPattern',       'conversionPattern',   ''                                                          )
	,(4, 3,    '1.2.3.4', 'layout.type.conversionPattern.value', 'value',               '%level - %message'                     )

	DECLARE 
	  @LoggerName   VARCHAR(500) = 'TestLogger'
	, @LogLevelName VARCHAR(500) = 'DEBUG'
	, @Message      VARCHAR(MAX) = 'A test message'
	, @Debug        BIT=0
	, @FormattedMessage VARCHAR(MAX)
	
	DECLARE @Expected VARCHAR(1000) = 'DEBUG - A test message'
	DECLARE @Actual   VARCHAR(1000)
	
	EXEC LoggerBase.Layout_PatternLayout @LoggerName = @LoggerName
	,@LogLevelName = @LogLevelName
	,@Message = @Message
	,@Config = @ConfigurationProperties
	,@Debug = @Debug
	,@FormattedMessage = @FormattedMessage OUTPUT

	SET @Actual = @FormattedMessage
	
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual
END;
GO

--EXEC tSQLt.Run 'loggerbasetests'
EXEC tSQLt.Run 'loggerbasetests.[Test Assert We Get The Layout Pattern]'
GO

