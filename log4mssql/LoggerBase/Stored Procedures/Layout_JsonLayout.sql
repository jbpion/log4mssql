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
	DECLARE @TokenValues VARCHAR(MAX) = 'LocalServerName|ADbName|20'
	
	EXEC LoggerBase.Layout_JSONLayout 
	  @LoggerName   = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message      = 'A test message'
	, @Config       = '<layout type="LoggerBase.Layout_JSONLayout"><conversionPattern value="%timestamp|%server|%dbname|%thread|%level|%correlationid|%logger|%message" delimiter="|"/></layout>'
	, @Debug        = 0
	, @TokenValues  = @TokenValues
	, @FormattedMessage = @FormattedMessage OUTPUT
	SELECT @FormattedMessage

	EXEC LoggerBase.Layout_JSONLayout 
	  @LoggerName   = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message      = '{"Submessage":"A test JSON object as the message"}'
	, @Config       = '<layout type="LoggerBase.Layout_JSONLayout"><conversionPattern value="%timestamp|%server|%dbname|%thread|%level|%correlationid|%logger|%message" delimiter="|"/></layout>'
	, @Debug        = 0
	, @TokenValues  = @TokenValues
	, @FormattedMessage = @FormattedMessage OUTPUT
	SELECT @FormattedMessage

**********************************************************************************************/

ALTER PROCEDURE LoggerBase.Layout_JsonLayout
(
	  @LoggerName   VARCHAR(500)
	, @LogLevelName VARCHAR(500)
	, @Message      VARCHAR(MAX)
	, @Config       XML
	, @Debug        BIT=0
	, @CorrelationId VARCHAR(20) = NULL
	, @TokenValues   VARCHAR(MAX)
	, @FormattedMessage VARCHAR(MAX) OUTPUT
)
AS
	SET NOCOUNT ON

	SET @FormattedMessage = NULL --Make sure to clear out the return variable.

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@CorrelationId:', @CorrelationId)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:', CONVERT(VARCHAR(MAX), @Config))
	END
	
	DECLARE @ConversionPattern VARCHAR(MAX) = LoggerBase.Layout_GetConversionPatternFromConfig(@Config)
	DECLARE @Delimiter CHAR(1) = (SELECT t.conversionPattern.value('./@delimiter', 'char(1)')
	FROM @Config.nodes('./layout/conversionPattern') as t(conversionPattern))

	DECLARE @ServerName SYSNAME, @DatabaseName SYSNAME, @SessionID INT
	SELECT @ServerName = ServerName, @DatabaseName = DatabaseName, @SessionID = SessionID
	FROM LoggerBase.Layout_Tokens_Pivot(@TokenValues)

	
	SELECT @FormattedMessage = COALESCE(@FormattedMessage + ',', '') + 
	IIF(SUBSTRING(LTRIM(TokenCurrentValue),1,1) = '{' AND TokenProperty = 'Message', --Assume the user is deliberately supplying a JSON object with a leading {.
		CONCAT('"', TokenProperty, '":', TokenCurrentValue), --If it's a JSON object do not surround in double quotes.
		CONCAT('"', TokenProperty, '":"', LoggerBase.Layout_JsonEscape(TokenCurrentValue), '"')
	)
	FROM LoggerBase.Util_Split(@ConversionPattern, '|') T
	--LEFT JOIN @TokenReplacements R ON T.Item = R.TokenElement
	LEFT JOIN LoggerBase.Layout_GetTokens(@LoggerName, @LogLevelName, @Message, @CorrelationId, @DatabaseName, @ServerName, @SessionId) R ON T.Item = R.Token

	SET @FormattedMessage = CONCAT('{', @FormattedMessage, '}')
	

