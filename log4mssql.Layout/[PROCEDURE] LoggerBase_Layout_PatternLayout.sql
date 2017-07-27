IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LoggerBase.Layout_PatternLayout') AND type in (N'P', N'PC'))
DROP PROCEDURE LoggerBase.Layout_PatternLayout
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
	, @Debug        = 0
	, @FormattedMessage = @FormattedMessage OUTPUT
	SELECT @FormattedMessage

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Layout_PatternLayout
(
	  @LoggerName   VARCHAR(500)
	, @LogLevelName VARCHAR(500)
	, @Message      VARCHAR(MAX)
	, @Config       XML
	, @Debug        BIT=0
	, @FormattedMessage VARCHAR(MAX) OUTPUT
)
AS
	SET NOCOUNT ON
	
	DECLARE @ConversionPattern VARCHAR(MAX) = LoggerBase.Layout_GetConversionPatternFromConfig(@Config)

	SET @FormattedMessage = @ConversionPattern
	
	SET @FormattedMessage = REPLACE(@FormattedMessage COLLATE Latin1_General_CS_AS, '%c ', @LoggerName)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%d ', LoggerBase.Layout_GetDate())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%date', LoggerBase.Layout_GetDate())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%identity', LoggerBase.Layout_LoginUser())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%level', @LogLevelName)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%logger', @LoggerName)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%m ', @Message)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%message', @Message)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%n ', CHAR(13))
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%newline', CHAR(13))
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%p ', @LogLevelName)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%r ', SYSDATETIME())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '% ', @@SPID)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%thread', @@SPID)
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%timestamp', SYSDATETIME())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%u ', LoggerBase.Layout_LoginUser())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%username', LoggerBase.Layout_LoginUser())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%utcdate', SYSUTCDATETIME())
	SET @FormattedMessage = REPLACE(@FormattedMessage, '%w ', LoggerBase.Layout_LoginUser())

GO

