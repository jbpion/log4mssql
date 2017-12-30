
/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_FileAppender

    Date:           12/29/2017
    Author:         Jerome Pion
    Description:    Writes to a text file.

    --TEST
	DECLARE @LoggerName VARCHAR(500) = 'TestAppenderLogger'
	DECLARE @LogLevelName VARCHAR(500) = 'DEBUG'
	DECLARE @Message VARCHAR(MAX) = 'Appender test message!'
	DECLARE @XMLConfig XML = '<appender name="FileAppender" type="LoggerBase.Appender_FileAppender">
		<file value="C:\TEMP\log-file.txt" />
		<appendToFile value="true" />
		<layout type="LoggerBase.Layout_PatternLayout">
			<conversionPattern value="%date [%thread] %level %logger - %message%newline" />
		</layout>
</appender>'

	EXEC LoggerBase.Appender_FileAppender 
	  @LoggerName = @LoggerName
	, @LogLevelName = @LogLevelName 
	, @Message      = @Message
	, @Config       = @XMLConfig
	, @Debug        = 1

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_FileAppender (@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT=0)
AS
	
	SET NOCOUNT ON

	IF (@Debug = 1) PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Message:', @Message)

	DECLARE @FormattedMessage VARCHAR(MAX)
	DECLARE @LayoutType       SYSNAME
	DECLARE @LayoutConfig     XML
	DECLARE @SQL              NVARCHAR(MAX)
	DECLARE @FileName         NVARCHAR(4000)
	DECLARE @AppendToFile     BIT

	SELECT @LayoutType = LayoutType, @LayoutConfig = LayoutConfig FROM LoggerBase.Config_Layout(@Config)

	SELECT @FileName = t.appender.value('(./file/@value)[1]', 'nvarchar(4000)')
	,@AppendToFile = t.appender.value('(./appendToFile/@value)[1]', 'bit')
	FROM @Config.nodes('./appender') as t(appender)

	IF (@Debug = 1)
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:'    , CONVERT(VARCHAR(MAX), @Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LayoutType:', @LayoutType)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@FileName:',     @FileName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@AppendToFile:', @AppendToFile)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@SQL:'       , @SQL)
	END

	EXEC LoggerBase.Layout_FormatMessage 
		  @LayoutTypeName  = @LayoutType
		, @LoggerName      = @LoggerName
		, @LogLevelName    = @LogLevelName
		, @Message         = @Message
		, @LayoutConfig    = @LayoutConfig
		, @Debug           = @Debug
		, @FormattedMessage = @FormattedMessage OUTPUT

		DECLARE 	 
	 @text   NVARCHAR(4000) = @FormattedMessage
	,@path   NVARCHAR(4000) = @FileName
	,@append BIT = @AppendToFile
	,@exitCode INT 
	,@errorMessage NVARCHAR(4000) 

	EXEC LoggerBase.Appender_File_Private_WriteTextFile 
	@text = @text
	,@path = @path
	,@append = @append
	,@exitCode = @exitCode OUTPUT
	,@errorMessage = @errorMessage OUTPUT

GO
