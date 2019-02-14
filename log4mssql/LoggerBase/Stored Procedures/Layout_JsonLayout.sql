IF OBJECT_ID('LoggerBase.Layout_JSONLayout') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE LoggerBase.Layout_JSONLayout
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Layout_JSONLayout

    Date:           02/14/2019
    Author:         Jerome Pion
    Description:    A layout for converting a delimited token string to a JSON string.

    --TEST
	DECLARE @FormattedMessage VARCHAR(MAX)
	EXEC LoggerBase.Layout_JSONLayout 
	  @LoggerName   = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message      = 'A test message'
	, @Config       = '<layout type="LoggerBase.Layout_JSONLayout"><conversionPattern value="%timestamp|%thread|%level|%correlationid|%logger|%message" delimiter="|"/></layout>'
	, @Debug        = 0
	, @FormattedMessage = @FormattedMessage OUTPUT
	SELECT @FormattedMessage

**********************************************************************************************/

ALTER PROCEDURE LoggerBase.Layout_JSONLayout
(
	  @LoggerName   VARCHAR(500)
	, @LogLevelName VARCHAR(500)
	, @Message      VARCHAR(MAX)
	, @Config       XML
	, @Debug        BIT=0
	, @CorrelationId VARCHAR(20) = NULL
	, @FormattedMessage VARCHAR(MAX) OUTPUT
)
AS
	SET NOCOUNT ON

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@CorrelationId:', @CorrelationId)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:', CONVERT(VARCHAR(MAX), @Config))
	END
	
	DECLARE @ConversionPattern VARCHAR(MAX) = LoggerBase.Layout_GetConversionPatternFromConfig(@Config)
	DECLARE @Delimiter CHAR(1) = (SELECT t.conversionPattern.value('./@delimiter', 'char(1)')
	FROM @Config.nodes('./layout/conversionPattern') as t(conversionPattern))

	

	DECLARE @TokenReplacements TABLE
	(
		TokenElement VARCHAR(500)
		,JSONPropertyName VARCHAR(500)
		,TokenReplacement VARCHAR(MAX) 
	)

	INSERT INTO @TokenReplacements
	(TokenElement, JSONPropertyName, TokenReplacement)
	VALUES
	 ('%d', 'Date', CONVERT(CHAR(10), LoggerBase.Layout_GetDate(), 120))
	,('%date', 'Date', CONVERT(CHAR(10), LoggerBase.Layout_GetDate(), 120))
	,('%identity', 'Identity', LoggerBase.Layout_LoginUser())
	,('%level', 'Level', @LogLevelName)
	,('%logger', 'Logger', @LoggerName)
	,('%m', 'Message', @Message)
	,('%message', 'Message', @Message)
	,('%p', 'Level', @LogLevelName)
	,('%r', 'TimeStamp', CONCAT(SYSDATETIME(),''))
	,('%', 'SessionId', CONCAT(@@SPID, ''))
	,('%thread', 'SessionId', CONCAT(@@SPID, ''))
	,('%spid', 'SessionId', CONCAT(@@SPID, ''))
	,('%timestamp', 'TimeStamp', CONCAT(SYSDATETIME(),''))
	,('%u', 'UserName', LoggerBase.Layout_LoginUser())
	,('%username', 'UserName', LoggerBase.Layout_LoginUser())
	,('%utcdate', 'UTCDate', CONCAT(SYSUTCDATETIME(),''))
	,('%w', 'UserName', LoggerBase.Layout_LoginUser())
	,('%correlationid', 'CorrelationId',  @CorrelationId)


	--SELECT @FormattedMessage = COALESCE(@FormattedMessage + '"' + JSONPropertyName + '":"' + TokenReplacement + '"', ',', '')
	SELECT @FormattedMessage = COALESCE(@FormattedMessage + ',', '') + CONCAT('"', JSONPropertyName, '":"', TokenReplacement, '"')
	FROM LoggerBase.Util_Split(@ConversionPattern, '|') T
	LEFT JOIN @TokenReplacements R ON T.Item = R.TokenElement

	SET @FormattedMessage = CONCAT('{', @FormattedMessage, '}')

	SELECT *
	FROM LoggerBase.Util_Split(@ConversionPattern, '|') T
	LEFT JOIN @TokenReplacements R ON T.Item = R.TokenElement

	--SET @FormattedMessage = @ConversionPattern
	
	--SET @FormattedMessage = REPLACE(@FormattedMessage COLLATE Latin1_General_CS_AS, '%c ', @LoggerName)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%d ', LoggerBase.Layout_GetDate())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%date', LoggerBase.Layout_GetDate())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%identity', LoggerBase.Layout_LoginUser())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%level', @LogLevelName)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%logger', @LoggerName)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%m ', @Message)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%message', @Message)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%n ', CHAR(13))
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%newline', CHAR(13))
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%p ', @LogLevelName)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%r ', SYSDATETIME())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '% ', @@SPID)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%thread', @@SPID)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%spid', @@SPID)
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%timestamp', SYSDATETIME())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%u ', LoggerBase.Layout_LoginUser())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%username', LoggerBase.Layout_LoginUser())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%utcdate', SYSUTCDATETIME())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%w ', LoggerBase.Layout_LoginUser())
	--SET @FormattedMessage = REPLACE(@FormattedMessage, '%correlationid', @CorrelationId)
	

