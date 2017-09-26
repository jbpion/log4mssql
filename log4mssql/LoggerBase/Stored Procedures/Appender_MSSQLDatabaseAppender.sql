/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_MSSQLDatabaseAppender
   
    Property of Clearent, LLC
    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    Writes logging entries to database without enlisting in a transaction.

	/*jpion: 2017-07-29: Changed name to reflect that tacking "Enlist=false" to the connection string may only work for MSSQL Server*/
    --TEST

	DECLARE @Config XML = 
'<appender name="MSSQLAppender" type="LoggerBase.Appender_MSSQLDatabaseAppender">
	<connectionString value="data source=localhost;initial catalog=LoggerTest;integrated security=true;" />
    <commandText value="INSERT INTO LoggerBase.TestLog ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
    <parameter>
        <parameterName value="@log_date" />
        <dbType value="DateTime" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%date" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@thread" />
        <dbType value="VarChar" />
	   <size value="255" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%thread" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@log_level" />
        <dbType value="VarChar" />
	   <size value="50" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%level" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@logger" />
        <dbType value="VarChar" />
	   <size value="255" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%logger" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@message" />
        <dbType value="VarChar" />
	   <size value="4000" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%message" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@exception" />
        <dbType value="VarChar" />
	   <size value="2000" />
        <layout type="LoggerBase.Layout_PatternLayout" />
    </parameter>
</appender>'

IF OBJECT_ID('LoggerBase.TestLog') IS NOT NULL DROP TABLE LoggerBase.TestLog
CREATE TABLE LoggerBase.TestLog
(
	[Date] DATE
	,[Thread] INT
	,[Level] VARCHAR(500)
	,[Logger] VARCHAR(500)
	,[Message] VARCHAR(MAX)
	,[Exception] VARCHAR(MAX)
)

EXEC LoggerBase.Appender_MSSQLDatabaseAppender @LoggerName = 'TestLogger', @LogLevelName = 'DEBUG', @Message = 'This is a test.', @Config = @Config
, @Debug = 1
SELECT * FROM LoggerBase.TestLog

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_MSSQLDatabaseAppender
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
	,t.parameter.value('(size/@value)[1]', 'varchar(MAX)') AS size
	,t.parameter.value('(layout/@type)[1]', 'varchar(MAX)') AS LayoutType
	,t.parameter.value('(layout/conversionPattern/@value)[1]', 'varchar(MAX)') AS ConversionPattern
	,t.parameter.query('./layout') AS ParameterXML
	,CAST('' AS VARCHAR(MAX)) AS ParameterValue
	INTO #Parameters
	FROM @Config.nodes('/appender/parameter') as t(parameter)
		--Get parameter name and datatype
			--Use layout to get value.
			select * from #Parameters
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

	--SELECT * FROM #Parameters

	--Take the parameters and construct the parameters definition and parameters/value list
	DECLARE @ParameterDefinition NVARCHAR(MAX)
	SELECT @ParameterDefinition = COALESCE(@ParameterDefinition+',' ,'') + CONCAT(ParameterName, ' ' , dbType, ' = ''', ParameterValue, '''')
	FROM #Parameters

--SELECT @SQL = CONCAT('DECLARE ', @ParameterDefinition, '; ', @CommandText)
IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID), ':@SQL:', @CommandText)
--BEGIN
----EXEC (@SQL)
--	--EXEC LoggerBase.Appender_MSSQLDatabaseAppender_ExecNonTransactedQuery
--	-- @connectionstring = @ConnectionString
--	--,@query = @SQL
--END
--SELECT 1 AS Tag
--,NULL AS Parent
--,NULL AS [Parameters!1!ParameterName]
--,NULL AS [Parameter!2!DBType]
--,NULL AS [Parameter!2!!CData]
--UNION ALL
--select 2 AS Tag
--,1 AS Parent
--,ParameterName  
--,DBType         
--,ParameterValue
-- FROM #Parameters 
-- FOR XML EXPLICIT;

DECLARE @ParametersXML xml

SET @ParametersXML = (
	SELECT *
	FROM
	(
	SELECT 1        AS Tag
	,NULL           AS Parent
	,NULL           AS [Parameters!1!ParameterName]
	,NULL		 AS [Parameter!2!ParameterName]
	,NULL           AS [Parameter!2!DBType]
	,NULL           AS [Parameter!2!Size]
	,NULL           AS [Parameter!2!!CData]
	UNION ALL
    SELECT 
     2              AS Tag
    ,1              AS Parent
    ,ParameterName  AS [Parameter!2!ParameterName]
    ,ParameterName  AS [Parameter!2!ParameterName]
    ,DBType         AS [Parameter!2!DBType]
    ,Size           AS [Parameter!2!Size]
    ,ParameterValue AS [Parameter!2!!CData]
    FROM #Parameters
	) AS N
    FOR XML EXPLICIT
	--FOR XML PATH('Parameter'), ROOT('Parameters')
 )

 --print CONCAT('@ParametersXML ', CONVERT(VARCHAR(8000), @ParametersXML))
 IF (@Debug = 1) PRINT CONCAT('@ParametersXML ', CONVERT(VARCHAR(8000), @ParametersXML))
 ----EXEC (@SQL)
EXEC [LoggerBase].[Appender_MSSQLSQLDatabaseAppender_ExecNonTransactedQuery]
	 @ConnectionString = @ConnectionString
	,@Query            = @CommandText
	,@Parameters       = @ParametersXML
	,@CommandTimeout   = 5
	,@Debug            = @Debug 