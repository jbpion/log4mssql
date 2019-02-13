IF OBJECT_ID('LoggerBase.Layout_FormatMessage') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE LoggerBase.Layout_FormatMessage
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
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

ALTER PROCEDURE LoggerBase.Layout_FormatMessage
(
	  @LayoutTypeName   SYSNAME
    , @LoggerName       VARCHAR(500)
	, @LogLevelName     VARCHAR(500)
	, @CorrelationId    VARCHAR(50) = NULL
	, @Message          VARCHAR(MAX)
	, @LayoutConfig     XML
	, @Debug            BIT
	, @FormattedMessage VARCHAR(MAX) OUTPUT
)

AS

    SET NOCOUNT ON
	
	DECLARE @SQL NVARCHAR(MAX) = CONCAT(@LayoutTypeName, ' @LoggerName, @LogLevelName, @Message, @Config, @Debug, @CorrelationId, @FormattedMessage OUTPUT')

	IF (@Debug = 1) 
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@SQL:', @SQL)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@CorrelationId:', @CorrelationId)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LayoutConfig:', CONVERT(VARCHAR(MAX), @LayoutConfig))
	END

	EXECUTE sp_executesql @SQL, N'@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT, @CorrelationId VARCHAR(50), @FormattedMessage VARCHAR(MAX) OUTPUT'
	,@LoggerName       = @LoggerName
	,@LogLevelName     = @LogLevelName
	,@Message          = @Message
	,@Config           = @LayoutConfig
	,@Debug            = @Debug
	,@CorrelationId    = @CorrelationId
	,@FormattedMessage = @FormattedMessage OUTPUT

