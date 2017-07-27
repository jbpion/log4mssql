IF OBJECT_ID('LoggerBase.Config_Appenders_Get') IS NOT NULL DROP FUNCTION LoggerBase.Config_Appenders_Get
GO

CREATE FUNCTION LoggerBase.Config_Appenders_Get(@Config XML)
RETURNS TABLE
AS

	RETURN

	SELECT 
	ROW_NUMBER() OVER (ORDER BY t.appender.value('./@name', 'VARCHAR(500)')) AS RowID
	,t.appender.value('./@name', 'VARCHAR(500)') AS AppenderName
	,t.appender.value('./@type', 'SYSNAME') as AppenderType
	,t.appender.query('.') AS AppenderConfig
	FROM @Config.nodes('/log4mssql/appender') as t(appender)


