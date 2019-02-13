
/*
DROP FUNCTION LoggerBase.Core_Level_ConvertNameToValue
*/
CREATE FUNCTION [LoggerBase].[Core_Level_ConvertNameToValue](@LogLevelName VARCHAR(500), @DefaultType CHAR(3))
RETURNS INT
AS
BEGIN
	DECLARE @Default INT = NULL
	DECLARE @Result INT
	IF (COALESCE(@DefaultType, 'MIN') = 'MIN') SELECT @Default = MIN(LogLevelValue) FROM LoggerBase.Core_Level
	IF (@DefaultType = 'MAX') SELECT @Default = MAX(LogLevelValue) FROM LoggerBase.Core_Level 

	SELECT @Result = COALESCE(MAX(LogLevelValue), @Default) --Use "MAX" to make sure we get back a null if no rows match. If it returns null return the min level for the table.
	FROM LoggerBase.Core_Level
	WHERE LogLevelName = @LogLevelName

	RETURN @Result

END
	
GO


