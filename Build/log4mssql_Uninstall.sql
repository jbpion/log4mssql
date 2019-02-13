SET NOCOUNT ON
DECLARE @SQL VARCHAR(MAX)
DECLARE @ObjectType SYSNAME
DECLARE @ObjectSchema SYSNAME
DECLARE @ObjectName SYSNAME

PRINT 'Uninstalling procedures'
IF OBJECT_ID('TempDb..#R') IS NOT NULL DROP TABLE #R
SELECT 
 ROW_NUMBER() OVER (ORDER BY ROUTINE_SCHEMA) AS RowId
,ROUTINE_SCHEMA
,ROUTINE_NAME
,ROUTINE_TYPE
INTO #R
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA IN  ('Logger', 'LoggerBase', 'loggerbasetests')

DECLARE @Counter INT = 1
WHILE EXISTS (SELECT * FROM #R)
BEGIN
	SELECT @ObjectName = ROUTINE_NAME
	,@ObjectSchema = ROUTINE_SCHEMA
	,@ObjectType = ROUTINE_TYPE
	FROM #R
	WHERE 1=1
	AND RowID = @Counter

	SELECT @SQL = CONCAT('DROP ', @ObjectType, ' [', @ObjectSchema, '].[', @ObjectName, ']')
	DELETE FROM #R WHERE RowID = @Counter
	PRINT @SQL
	BEGIN TRY
		EXEC(@SQL)
	END TRY
	BEGIN CATCH
		INSERT INTO #T
		SELECT MAX(RowId) + 1
		,@ObjectSchema
		,@ObjectName
		,@ObjectType
		FROM #R
	END CATCH
	
	SELECT @Counter = MIN(RowId) FROM #R

END

PRINT 'Uninstalling tables. LoggerBase.Config_Saved will remain. You will need to remove it manually if desired.'
IF OBJECT_ID('TempDb..#T') IS NOT NULL DROP TABLE #T
SELECT 
 ROW_NUMBER() OVER (ORDER BY TABLE_SCHEMA) AS RowId
 ,TABLE_SCHEMA
 ,TABLE_NAME
 ,IIF(TABLE_TYPE = 'BASE TABLE', 'TABLE', TABLE_TYPE) AS TABLE_TYPE
INTO #T
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('Logger', 'LoggerBase')
AND TABLE_NAME <> 'Config_Saved'

SET @Counter = 1

WHILE EXISTS (SELECT * FROM #T)
BEGIN
	SELECT @ObjectName = TABLE_NAME
	,@ObjectSchema     = TABLE_SCHEMA
	,@ObjectType       = TABLE_TYPE
	FROM #T
	WHERE 1=1
	AND RowID = @Counter

	SELECT @SQL = CONCAT('DROP ', @ObjectType, ' [', @ObjectSchema, '].[', @ObjectName, ']')
	DELETE FROM #T WHERE RowID = @Counter
	PRINT @SQL
	BEGIN TRY
		EXEC(@SQL)
	END TRY
	BEGIN CATCH
		INSERT INTO #T
		SELECT MAX(RowId) + 1
		,@ObjectSchema
		,@ObjectName
		,@ObjectType
		FROM #T
	END CATCH
	
	SELECT @Counter = MIN(RowId) FROM #T

END

PRINT 'Uninstalling CLR assemblies'
IF EXISTS (SELECT * FROM sys.assemblies WHERE 1=1 AND name = 'log4mssql') DROP ASSEMBLY [log4mssql]

PRINT 'Uninstalling User-Defined types'
IF EXISTS (SELECT * FROM sys.types WHERE name = 'LogConfiguration') DROP TYPE LogConfiguration

PRINT 'Uninstalling Logger schema. LoggerBase is required by LoggerBase.Config_Saved. You will need to remove it manually if desired.'
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Logger') DROP SCHEMA Logger
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'loggerbasetests') DROP SCHEMA loggerbasetests
