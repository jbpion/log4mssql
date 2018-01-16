/*
DROP FUNCTION LoggerBase.Core_Level_ConvertNameToValue
*/
CREATE FUNCTION LoggerBase.Core_Level_ConvertNameToValue(@LogLevelName VARCHAR(500), @DefaultType CHAR(3))
RETURNS INT
AS
BEGIN

	DECLARE @Result INT

	

	SELECT @Result = MAX(LogLevelValue) --Use "MAX" to make sure we get back a null if no rows match. If it returns null return the min level for the table.
	FROM LoggerBase.Core_Level
	WHERE LogLevelName = @LogLevelName

	IF (@Result IS NULL)
	BEGIN
		IF (COALESCE(@DefaultType, 'MIN') = 'MIN') SELECT @Result = MIN(LogLevelValue) FROM LoggerBase.Core_Level
		IF (@DefaultType = 'MAX') SELECT @Result = MAX(LogLevelValue) FROM LoggerBase.Core_Level
	END

	RETURN @Result

END
	