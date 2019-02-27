IF OBJECT_ID('LoggerBase.Layout_PatternLayout') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE LoggerBase.Layout_PatternLayout
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Layout_PatternLayout

    Date:           07/18/2017
    Author:         Jerome Pion
    Description:    A simple implemention of a pattern layout that does simple token replacement.

    --TEST
	DECLARE @FormattedMessage VARCHAR(MAX)
	EXEC LoggerBase.Layout_PatternLayout 
	  @LoggerName   = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message      = 'A test message'
	, @Config       = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="[%timestamp] [%thread] %level - %logger - %message%newline"/></layout>'
	, @Debug        = 1
	, @FormattedMessage = @FormattedMessage OUTPUT
	SELECT @FormattedMessage

	DECLARE @FormattedMessage2 VARCHAR(MAX)
	EXEC LoggerBase.Layout_PatternLayout 
	  @LoggerName   = 'LoggerName'
	, @LogLevelName = 'DEBUG'
	, @Message      = 'A test message'
	, @Config       = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="[%timestamp] [%thread] [%dbname] %level - %logger - %message%newline"/></layout>'
	, @Debug        = 1
	, @TokenValues = 'AServer|ADbName|'
	, @FormattedMessage = @FormattedMessage2 OUTPUT

	SELECT @FormattedMessage2

**********************************************************************************************/

ALTER PROCEDURE LoggerBase.Layout_PatternLayout
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

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Message:', @Message)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@CorrelationId:', @CorrelationId)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:', CONVERT(VARCHAR(MAX), @Config))
	END
	
	DECLARE @ConversionPattern VARCHAR(MAX) = LoggerBase.Layout_GetConversionPatternFromConfig(@Config)

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@ConversionPattern:', @ConversionPattern)
	END

	--SET @FormattedMessage = @ConversionPattern

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@FormattedMessage (before replace):', @FormattedMessage)
	END

	DECLARE @ServerName SYSNAME, @DatabaseName SYSNAME, @SessionID INT
	SELECT @ServerName = ServerName, @DatabaseName = DatabaseName, @SessionID = SessionID
	FROM LoggerBase.Layout_Tokens_Pivot(@TokenValues)

	
	--SELECT @FormattedMessage = REPLACE(@FormattedMessage, Token, COALESCE(TokenCurrentValue,''))
	--FROM LoggerBase.Layout_GetTokens(@LoggerName, @LogLevelName, @Message, @CorrelationId, @DatabaseName, @ServerName, @SessionId)

	SELECT @FormattedMessage = LoggerBase.Layout_ReplaceTokens(@Message, @ConversionPattern, @LoggerName, @LogLevelName, @CorrelationId, @ServerName, @DatabaseName, @SessionID) 
--(
--	 @Message VARCHAR(MAX)
--	,@ConversionPattern VARCHAR(MAX)
--	,@LoggerName   VARCHAR(500)
--	,@LogLevelName VARCHAR(500)
--	,@CorrelationId VARCHAR(20) = NULL
--	,@ServerName SYSNAME
--	,@DatabaseName SYSNAME
--	,@SessionID INT
--)
	
	

