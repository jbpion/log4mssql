
/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ADOAppender
   
    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    Writes logging entries to database without enlisting in a transaction.

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_ADOAppender
(@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT=0)
AS
	SET NOCOUNT ON

	IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID),':@Message:', @Message)
	IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID),':@Config:', CONVERT(VARCHAR(MAX),@Config))

	--Get command text
	DECLARE @CommandText VARCHAR(MAX)
	DECLARE @ConnectionString VARCHAR(MAX)

	SELECT @CommandText = t.commandText.value('./@value', 'varchar(MAX)') 
	FROM @Config.nodes('/appender/commandText') as t(commandText)

	SELECT @ConnectionString = t.connectionString.value('./@value', 'varchar(MAX)') 
	FROM @Config.nodes('/appender/connectionString') as t(connectionString)
	--Loop through parameters. 

	SET @ConnectionString = CONCAT(@ConnectionString, ';Enlist=false;')

	SELECT 
	ROW_NUMBER() OVER (ORDER BY t.parameter.value('(parameterName/@value)[1]', 'varchar(MAX)')) AS RowID
	,t.parameter.value('(parameterName/@value)[1]', 'varchar(MAX)') AS ParameterName
	,t.parameter.value('(dbType/@value)[1]', 'varchar(MAX)') AS dbType
	,t.parameter.value('(layout/@type)[1]', 'varchar(MAX)') AS LayoutType
	,t.parameter.value('(layout/conversionPattern/@value)[1]', 'varchar(MAX)') AS ConversionPattern
	,t.parameter.query('./layout') AS ParameterXML
	,CAST('' AS VARCHAR(MAX)) AS ParameterValue
	INTO #Parameters
	FROM @Config.nodes('/appender/parameter') as t(parameter)
		--Get parameter name and datatype
			--Use layout to get value.

	IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID), ':@CommandText:', @CommandText)

	DECLARE @Counter INT
	DECLARE @Limit INT
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @LayoutTypeName SYSNAME
	DECLARE @LayoutConfig XML
	DECLARE @FormattedMessage VARCHAR(MAX)

	SELECT @Counter = MIN(RowID), @Limit = MAX(RowID)
	FROM #Parameters

	WHILE (@Counter <= @Limit)
	BEGIN
		SELECT @LayoutTypeName = LayoutType
		,@LayoutConfig = ParameterXML
		FROM #Parameters
		WHERE 1=1
		AND RowID = @Counter

	 	EXEC LoggerBase.Layout_FormatMessage 
		  @LayoutTypeName  = @LayoutTypeName
		, @LoggerName      = @LoggerName
		, @LogLevelName    = @LogLevelName
		, @Message         = @Message
		, @LayoutConfig    = @LayoutConfig
		, @Debug           = @Debug
		, @FormattedMessage = @FormattedMessage OUTPUT

	  UPDATE #Parameters SET ParameterValue = @FormattedMessage
	  WHERE 1=1
	  AND RowID = @Counter

		SET @Counter += 1

		IF (@Debug = 1)
		BEGIN
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LayoutTypeName:', @LayoutTypeName)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LoggerName:', @LoggerName)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LogLevelName:', @LogLevelName)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@Message:', @Message)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LayoutConfig:', CONVERT(VARCHAR(MAX), @LayoutConfig))
		END
	END

	--Take the parameters and construct the parameters definition and parameters/value list
	DECLARE @ParameterDefinition NVARCHAR(MAX)
	SELECT @ParameterDefinition = COALESCE(@ParameterDefinition+',' ,'') + CONCAT(ParameterName, ' ' , dbType, ' = ''', ParameterValue, '''')
	FROM #Parameters

SELECT @SQL = CONCAT('DECLARE ', @ParameterDefinition, '; ', @CommandText)
IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID), ':@SQL:', @SQL)
BEGIN
	EXEC LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
	 @connectionstring = @ConnectionString
	,@query = @SQL
END

GO
