
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbase_core_level_retrievefromsession';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbase_core_level_retrievefromsession.[SetUp]
AS
BEGIN
	PRINT 'Setup not implemented'
	EXEC tSQLt.FakeTable 'LoggerBase.Config_SessionContext'
	INSERT INTO LoggerBase.Config_SessionContext(SessionContextID, OverrideLogLevelName) 
		VALUES(CAST(5 AS VARBINARY(1)), 'OVERRIDDEN-LEVEL-5')
		,(CAST(6 AS VARBINARY(1)), 'OVERRIDDEN-LEVEL-6');
	EXEC tSQLt.FakeFunction @FunctionName = 'LoggerBase.Core_Session_Get', @FakeFunctionName = 'loggerbase_core_level_retrievefromsession.Core_Session_Get'
END;
GO

CREATE FUNCTION loggerbase_core_level_retrievefromsession.Core_Session_Get()
RETURNS VARBINARY(1)
AS
BEGIN
	RETURN  CAST(5 AS VARBINARY(1))
END;
GO

--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbase_core_level_retrievefromsession.[Test Assert We Get The Overriding Level From The Session Context Table]
AS
BEGIN
	PRINT 'Test not implemented.';
	DECLARE @Expected XML = 'OVERRIDDEN-LEVEL-5'
	DECLARE @Actual   XML = LoggerBase.Core_Level_RetrieveFromSession()

	DECLARE @ExpectedConverted VARCHAR(500) = CAST(@Expected AS VARCHAR(500))
	DECLARE @ActualConverted   VARCHAR(500) = CAST(@Actual   AS VARCHAR(500))

	EXEC tSQLt.AssertEquals @ExpectedConverted, @ActualConverted
END;
GO

EXEC tSQLt.Run 'loggerbase_core_level_retrievefromsession'
GO

