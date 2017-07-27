IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Logger')
EXEC sys.sp_executesql N'CREATE SCHEMA Logger'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'LoggerBase')
EXEC sys.sp_executesql N'CREATE SCHEMA LoggerBase'
GO

CREATE FUNCTION [LoggerBase].Layout_GetDate()
RETURNS DATE
AS
BEGIN

    RETURN CAST(GETDATE() AS DATE)

END
GO

CREATE FUNCTION LoggerBase.Layout_LoginUser()
RETURNS NVARCHAR(256)
AS
BEGIN

    RETURN SUSER_NAME()

END
GO
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

GO
	PRINT 'PROCEDURE LoggerBase.Layout_FormatMessage CREATED 07/14/2017'
GO

IF OBJECT_ID('LoggerBase.Layout_FormatMessage') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Layout_FormatMessage'
    DROP PROCEDURE LoggerBase.Layout_FormatMessage
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Layout_FormatMessage'
GO

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
	, @LayoutConfig     XML
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

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Layout_FormatMessage CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Layout_FormatMessage FAILED!'
END
GO


GO
