
CREATE FUNCTION [LoggerBase].[Appender_Filter_RangeFile_Apply](@Config XML, @CurrentLogLevelName VARCHAR(500))
RETURNS TABLE
AS 
RETURN
SELECT 
	ROW_NUMBER() OVER (ORDER BY t.appender.value('./@name', 'VARCHAR(500)')) AS RowID
	,t.appender.value('./@name', 'VARCHAR(500)') AS AppenderName
	,t.appender.value('./@type', 'SYSNAME') as AppenderType
	,t.appender.query('.') AS AppenderConfig
	FROM @Config.nodes('/log4mssql/appender') as t(appender)
	WHERE LoggerBase.Core_Level_ConvertNameToValue(@CurrentLogLevelName, 'MIN')
	BETWEEN 
	LoggerBase.Core_Level_ConvertNameToValue(t.appender.value('(./filter/levelMin/@value)[1]', 'VARCHAR(500)'), 'MIN') AND
	LoggerBase.Core_Level_ConvertNameToValue(t.appender.value('(./filter/levelMax/@value)[1]', 'VARCHAR(500)'), 'MAX') 
GO


