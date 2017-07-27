
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbase_config_retrievefromsession';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbase_config_retrievefromsession.[SetUp]
AS
BEGIN
	PRINT 'Setup not implemented'
	EXEC tSQLt.FakeTable 'LoggerBase.Config_SessionContext'
	INSERT INTO LoggerBase.Config_SessionContext(SessionContextID, Config) 
		VALUES(CAST(5 AS VARBINARY(1)), '<log4mssql/>')
		,(CAST(6 AS VARBINARY(1)), '<log4mssql6/>');
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Core_Session_Get', @FakeFunctionName = 'loggerbase_config_retrievefromsession.Core_Session_Get'
END;
GO

CREATE FUNCTION loggerbase_config_retrievefromsession.Core_Session_Get()
RETURNS VARBINARY(1)
AS
BEGIN
	RETURN  CAST(5 AS VARBINARY(1))
END;
GO

--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbase_config_retrievefromsession.[Test Assert We Get The Config From The Session Context Table]
AS
BEGIN
	PRINT 'Test not implemented.';
	DECLARE @Expected XML = '<log4mssql/>'
	DECLARE @Actual   XML = LoggerBase.Config_RetrieveFromSession()

	DECLARE @ExpectedConverted VARCHAR(50) = CAST(@Expected AS VARCHAR(50))
	DECLARE @ActualConverted   VARCHAR(50) = CAST(@Actual   AS VARCHAR(50))

	EXEC tSQLt.AssertEquals @ExpectedConverted, @ActualConverted
END;
GO

EXEC tSQLt.Run 'loggerbase_config_retrievefromsession'
GO

