IF OBJECT_ID('LoggerBase.Config_Root_Get') IS NOT NULL DROP FUNCTION LoggerBase.Config_Root_Get
GO

CREATE FUNCTION LoggerBase.Config_Root_Get(@Config XML)
RETURNS @Root TABLE
(
	 RowID      INT
	,LevelValue VARCHAR(500)
	,AppenderRef VARCHAR(500)
)
AS
BEGIN
	INSERT INTO @Root
	SELECT 
	ROW_NUMBER() OVER (ORDER BY AR.AppenderRef) AS RowID
	,LV.LevelValue
	,AR.AppenderRef
	FROM
	(
		SELECT @Config.value('(/log4mssql/root/level/@value)[1]', 'varchar(500)') AS LevelValue
	) AS LV
	CROSS JOIN
	(
		SELECT 
		t.rootnode.value('@ref', 'varchar(500)') AS AppenderRef
		FROM @Config.nodes('/log4mssql/root/appender-ref') as t(rootnode)
	) AS AR

	RETURN

END

