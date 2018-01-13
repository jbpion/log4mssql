/*
DROP FUNCTION LoggerBase.Appender_Filter_LevelRange
*/
CREATE FUNCTION LoggerBase.Appender_Filter_LevelRange(@MinLogLevelName VARCHAR(500), @MaxLogLevelName VARCHAR(500))
RETURNS @Results TABLE
(
	  MinLogLevelValue INT
	 ,MaxLogLevelValue INT
)
AS
BEGIN
	INSERT INTO @Results
	SELECT
	(
		SELECT COALESCE(MAX(LogLevelValue), (SELECT MIN(LogLevelValue) FROM LoggerBase.Core_Level)) --Use "MAX" to make sure we get back a null if no rows match. If it returns null return the min level for the table.
		FROM LoggerBase.Core_Level
		WHERE LogLevelName = @MinLogLevelName
	) AS MinLogLevelValue
	,
	(
		SELECT COALESCE(MAX(LogLevelValue), (SELECT MAX(LogLevelValue) FROM LoggerBase.Core_Level)) --Use "MAX" to make sure we get back a null if no rows match. If it returns null return the min level for the table.
		FROM LoggerBase.Core_Level
		WHERE LogLevelName = @MaxLogLevelName
	) AS MaxLogLevelValue

	RETURN
END

