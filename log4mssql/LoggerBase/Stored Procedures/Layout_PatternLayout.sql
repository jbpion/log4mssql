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

**********************************************************************************************/

ALTER PROCEDURE LoggerBase.Layout_PatternLayout
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
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Message:', @Message)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@CorrelationId:', @CorrelationId)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:', CONVERT(VARCHAR(MAX), @Config))
	END
	
	DECLARE @ConversionPattern VARCHAR(MAX) = LoggerBase.Layout_GetConversionPatternFromConfig(@Config)

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@ConversionPattern:', @ConversionPattern)
	END

	SET @FormattedMessage = @ConversionPattern

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@FormattedMessage (before replace):', @FormattedMessage)
	END

	--SELECT @FormattedMessage = REPLACE(@FormattedMessage, Token, TokenCurrentValue)
	--FROM LoggerBase.Layout_GetTokens(@LoggerName, @LogLevelName, @Message, @CorrelationId)

	SELECT @FormattedMessage = REPLACE(@FormattedMessage, Token, COALESCE(TokenCurrentValue,''))
	FROM LoggerBase.Layout_GetTokens(@LoggerName, @LogLevelName, @Message, @CorrelationId)
	
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
	

