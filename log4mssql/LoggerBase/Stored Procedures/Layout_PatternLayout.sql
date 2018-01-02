
/*********************************************************************************************

    PROCEDURE LoggerBase.Layout_PatternLayout

    Date:           07/18/2017
    Author:         Jerome Pion
    Description:    A simple implemention of a pattern layout that does simple token replacement.

    --TEST


**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Layout_PatternLayout
(
	  @LoggerName   VARCHAR(500)
	, @LogLevelName VARCHAR(500)
	, @Message      VARCHAR(MAX)
	, @Config       LoggerBase.ConfigurationProperties READONLY
	, @Debug        BIT=0
	, @FormattedMessage VARCHAR(MAX) OUTPUT
)
AS
	SET NOCOUNT ON
	
	DECLARE @ConversionPattern VARCHAR(MAX) = LoggerBase.Layout_GetConversionPatternFromConfigProperties(@Config)

	IF (@Debug = 1)
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@ConversionPattern:', CONVERT(VARCHAR(5000), @ConversionPattern))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LoggerName:',        CONVERT(VARCHAR(5000), @LoggerName))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LogLevelName:',      CONVERT(VARCHAR(5000), @LogLevelName))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@Message:',           CONVERT(VARCHAR(5000), @Message))
	END

	SET @FormattedMessage = @ConversionPattern	
	IF (@Debug = 1)PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@FormattedMessage:', CONVERT(VARCHAR(5000), @FormattedMessage))
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
	IF (@Debug = 1)PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@FormattedMessage:', CONVERT(VARCHAR(5000), @FormattedMessage))

