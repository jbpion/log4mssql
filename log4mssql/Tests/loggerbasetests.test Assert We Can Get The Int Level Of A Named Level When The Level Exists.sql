CREATE PROCEDURE [loggerbasetests].[test Assert We Can Get The Int Level Of A Named Level When The Level Exists]
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
