
/*********************************************************************************************

    PROCEDURE LoggerBase.Layout_FormatMessage

    Date:           07/14/2017
    Author:         Jerome Pion
    Description:    Execute the request layout and return the formatted message.

    --TEST
	DECLARE 
	  @LayoutTypeName   SYSNAME
    , @LoggerName       VARCHAR(500)
	, @LogLevelName     VARCHAR(500)
	, @Message          VARCHAR(MAX)
	, @LayoutConfig     XML
	, @Debug            BIT
    , @FormattedMessage VARCHAR(MAX)

	EXEC LoggerBase.Layout_FormatMessage 
		  @LayoutTypeName  = 'LoggerBase.Layout_PatternLayout'
		, @LoggerName      = 'LoggerName'
		, @LogLevelName    = 'DEBUG'
		, @Message         = 'A test message'
		, @LayoutConfig    = '<layout type="Logger.Layout_PatternLayout"><conversionPattern value="[%timestamp] [%thread] %level - %logger - %message%newline"/></layout>'
		, @Debug           = 1
		, @FormattedMessage = @FormattedMessage OUTPUT

	SELECT @FormattedMessage

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Layout_FormatMessage
(
	  @LayoutTypeName   SYSNAME
    , @LoggerName       VARCHAR(500)
	, @LogLevelName     VARCHAR(500)
	, @Message          VARCHAR(MAX)
	, @LayoutConfig     LoggerBase.ConfigurationProperties READONLY
	, @Debug            BIT
	, @FormattedMessage VARCHAR(MAX) OUTPUT
)

AS

    SET NOCOUNT ON
	
	DECLARE @SQL NVARCHAR(MAX) = CONCAT(@LayoutTypeName, ' @LoggerName, @LogLevelName, @Message, @Config, @Debug, @FormattedMessage OUTPUT')

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@SQL:', @SQL)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
	END

	EXECUTE sp_executesql @SQL, N'@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT, @FormattedMessage VARCHAR(MAX) OUTPUT'
	,@LoggerName       = @LoggerName
	,@LogLevelName     = @LogLevelName
	,@Message          = @Message
	,@Config           = @LayoutConfig
	,@Debug            = @Debug
	,@FormattedMessage = @FormattedMessage OUTPUT

