
CREATE PROCEDURE [loggerbasetests].[test Assert We Can Get The Max Int Level Of A Named Level When The Level Does Not Exist And Max Is Requested]
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
