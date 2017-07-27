
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbase_layout_formatmessage';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbase_layout_formatmessage.[SetUp]
AS
BEGIN
	EXEC tSQLt.SpyProcedure 'LoggerBase.Layout_PatternLayout'
END;
GO

--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbase_layout_formatmessage.[Test Assert Something]
AS
BEGIN
	DECLARE @FormattedMessage VARCHAR(MAX)

	SELECT  LoggerName      = 'LoggerName'
		   ,LogLevelName    = 'DEBUG'
		   ,[Message]       = 'A test message'
		   ,Config          = '<layout type="Logger.Layout_PatternLayout"><conversionPattern value="[%timestamp] [%thread] %level - %logger - %message%newline"/></layout>'
		   ,Debug           = 1
	INTO #Expected		   

	EXEC LoggerBase.Layout_FormatMessage 
		  @LayoutTypeName  = 'LoggerBase.Layout_PatternLayout'
		, @LoggerName      = 'LoggerName'
		, @LogLevelName    = 'DEBUG'
		, @Message         = 'A test message'
		, @LayoutConfig    = '<layout type="Logger.Layout_PatternLayout"><conversionPattern value="[%timestamp] [%thread] %level - %logger - %message%newline"/></layout>'
		, @Debug           = 1
		, @FormattedMessage = @FormattedMessage OUTPUT

	SELECT 
	 LoggerName
	,LogLevelName
	,[Message]
	,CONVERT(VARCHAR(5000), Config) AS Config
	,Debug
	INTO #Actual
	FROM LoggerBase.Layout_PatternLayout_SpyProcedureLog;

	EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual'
END;
GO

EXEC tSQLt.Run 'loggerbase_layout_formatmessage'
GO

