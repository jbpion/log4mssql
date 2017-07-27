
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'log4mssql_Tests_Layout_PatternLayout';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE log4mssql_Tests_Layout_PatternLayout.[SetUp]
AS
BEGIN
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Layout_GetDate',   @FakeFunctionName = 'log4mssql_Tests_Layout_PatternLayout.Layout_GetDate'
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Layout_LoginUser', @FakeFunctionName = 'log4mssql_Tests_Layout_PatternLayout.Layout_LoginUser'
END;
GO

CREATE FUNCTION log4mssql_Tests_Layout_PatternLayout.Layout_GetDate()
RETURNS DATE
AS
BEGIN

    RETURN CAST('2017-01-01' AS DATE)

END;
GO
CREATE FUNCTION log4mssql_Tests_Layout_PatternLayout.Layout_LoginUser()
RETURNS NVARCHAR(256)
AS
BEGIN

    RETURN CAST('TEST\testuser' AS NVARCHAR(256))

END;
GO


--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE log4mssql_Tests_Layout_PatternLayout.[Test Assert LoggerName Returns for %c - case sensitive]
AS
BEGIN
	DECLARE @Expected VARCHAR(MAX) = 'test logger name';
	DECLARE @Actual   VARCHAR(MAX);
	DECLARE @ExpectedConverted VARCHAR(500) = CAST(@Expected AS VARCHAR(500))

	EXEC LoggerBase.Layout_PatternLayout @LoggerName = @Expected
	, @LogLevelName = 'DEBUG'
	, @Message = 'A test message'
	, @Config = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%c "/></layout>'
	, @Debug = 0
	, @FormattedMessage = @Actual OUTPUT

	DECLARE @ActualConverted VARCHAR(500)   = CAST(@Actual AS VARCHAR(500))

	EXEC tSQLt.AssertEquals @ExpectedConverted, @ActualConverted
END;
GO

CREATE PROCEDURE log4mssql_Tests_Layout_PatternLayout.[Test Assert Date Returns for %d - case insensitive]
AS
BEGIN
	DECLARE @Expected VARCHAR(MAX) = '2017-01-01';
	DECLARE @Actual   VARCHAR(MAX);
	DECLARE @ExpectedConverted VARCHAR(500) = CAST(@Expected AS VARCHAR(500))

	EXEC LoggerBase.Layout_PatternLayout @LoggerName = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message = 'A test message'
	, @Config = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%d "/></layout>'
	, @Debug = 0
	, @FormattedMessage = @Actual OUTPUT

	DECLARE @ActualConverted VARCHAR(500)   = CAST(@Actual AS VARCHAR(500))

	EXEC tSQLt.AssertEquals @ExpectedConverted, @ActualConverted
END;
GO

CREATE PROCEDURE log4mssql_Tests_Layout_PatternLayout.[Test Assert Date Returns for %date - case insensitive]
AS
BEGIN
	DECLARE @Expected VARCHAR(MAX) = '2017-01-01';
	DECLARE @Actual   VARCHAR(MAX);
	DECLARE @ExpectedConverted VARCHAR(500) = CAST(@Expected AS VARCHAR(500))

	EXEC LoggerBase.Layout_PatternLayout @LoggerName = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message = 'A test message'
	, @Config = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%date"/></layout>'
	, @Debug = 0
	, @FormattedMessage = @Actual OUTPUT

	DECLARE @ActualConverted VARCHAR(500)   = CAST(@Actual AS VARCHAR(500))

	EXEC tSQLt.AssertEquals @ExpectedConverted, @ActualConverted
END;
GO

CREATE PROCEDURE log4mssql_Tests_Layout_PatternLayout.[Test Assert Date Returns for %identity - case insensitive]
AS
BEGIN
	DECLARE @Expected VARCHAR(MAX) = 'TEST\testuser';
	DECLARE @Actual   VARCHAR(MAX);
	DECLARE @ExpectedConverted VARCHAR(500) = CAST(@Expected AS VARCHAR(500))

	EXEC LoggerBase.Layout_PatternLayout @LoggerName = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message = 'A test message'
	, @Config = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%identity"/></layout>'
	, @Debug = 0
	, @FormattedMessage = @Actual OUTPUT

	DECLARE @ActualConverted VARCHAR(500)   = CAST(@Actual AS VARCHAR(500))

	EXEC tSQLt.AssertEquals @ExpectedConverted, @ActualConverted
END;
GO

EXEC tSQLt.Run 'log4mssql_Tests_Layout_PatternLayout'
GO

