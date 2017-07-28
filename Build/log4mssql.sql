IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Logger')
EXEC sys.sp_executesql N'CREATE SCHEMA Logger'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'LoggerBase')
EXEC sys.sp_executesql N'CREATE SCHEMA LoggerBase'
GO
IF OBJECT_ID('LoggerBase.Layout_GetDate') IS NOT NULL DROP FUNCTION LoggerBase.Layout_GetDate
GO

CREATE FUNCTION LoggerBase.Layout_GetDate()
RETURNS DATE
AS
BEGIN

    RETURN CAST(GETDATE() AS DATE)

END
GO
IF OBJECT_ID('LoggerBase.Layout_LoginUser') IS NOT NULL DROP FUNCTION LoggerBase.Layout_LoginUser
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
IF OBJECT_ID('LoggerBase.Config_Layout') IS NOT NULL DROP FUNCTION LoggerBase.Config_Layout
GO

/*********************************************************************************************

    FUNCTION LoggerBase.Config_Layout

    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    A simple implemention of a pattern layout that does simple token replacement.

    --TEST
	SELECT * FROM LoggerBase.Config_Layout('   <appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
 
        <!-- A1 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%-4timestamp [%thread] %-5level %logger %ndc - %message%newline" />
        </layout>
    </appender>')

**********************************************************************************************/

CREATE FUNCTION LoggerBase.Config_Layout(@Config XML)
RETURNS TABLE
AS
	RETURN
	SELECT 
	 t.layout.value('./@type', 'varchar(500)') AS LayoutType
	,t.layout.query('.')                       AS LayoutConfig
	FROM @Config.nodes('./appender/layout') AS t(layout)


GO
IF OBJECT_ID('LoggerBase.Core_Level_RetrieveFromSession') IS NOT NULL DROP FUNCTION LoggerBase.Core_Level_RetrieveFromSession
GO

CREATE FUNCTION LoggerBase.Core_Level_RetrieveFromSession()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @Level VARCHAR(500) =
	(
		SELECT OverrideLogLevelName
		FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)

	RETURN @Level
END
GO
SET NOCOUNT ON
SET ANSI_PADDING ON

PRINT 'TABLE LoggerBase.Core_Level CREATED ' + CONVERT(VARCHAR(10), GETDATE(), 101)
GO

IF OBJECT_ID('LoggerBase.Core_Level') IS NOT NULL
BEGIN
    PRINT '   DROP TABLE LoggerBase.Core_Level'
    DROP TABLE LoggerBase.Core_Level
END
GO

PRINT '   CREATE TABLE LoggerBase.Core_Level'
GO

CREATE TABLE LoggerBase.Core_Level
(
	 LogLevelName  VARCHAR(500) NOT NULL
	,LogLevelValue INT          NOT NULL
	,LogLevelDesc  VARCHAR(MAX) NOT NULL
)

EXEC('CREATE UNIQUE NONCLUSTERED INDEX UX_LoggerBase_Core_Level_LogLevelName ON LoggerBase.Core_Level(LogLevelName)')

GO

IF @@ERROR = 0
BEGIN
    PRINT '   TABLE LoggerBase.Core_Level CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE TABLE LoggerBase.Core_Level FAILED'
END
GO

GO
IF OBJECT_ID('TempDB..#LoggerBaseCore_Level') IS NOT NULL DROP TABLE #LoggerBaseCore_Level
CREATE TABLE #LoggerBaseCore_Level
(
     LogLevelName  VARCHAR(500) NOT NULL
    ,LogLevelValue INT          NOT NULL
    ,LogLevelDesc  VARCHAR(MAX) NOT NULL
);


INSERT INTO #LoggerBaseCore_Level VALUES
 ('OFF'      ,2147483647,'Level designates a higher level than all the rest.'),
 ('EMERGENCY',120000,    'Level designates very severe error events;System unusable, emergencies.'),
 ('FATAL'    ,110000,    'Level designates very severe error events that will presumably lead the application to abort.'),
 ('ALERT'    ,100000,    'Level designates very severe error events. Take immediate action, alerts.'),
 ('CRITCAL'  ,90000,     'Level designates very severe error events. Critical condition, critical.'),
 ('SEVERE'   ,80000,     'Level designates very severe error events.'),
 ('ERROR'    ,70000,     'Level designates error events that might still allow the application to continue running.'),
 ('WARN'     ,60000,     'Level designates potentially harmful situations.'),
 ('NOTICE'   ,50000,     'Level designates informational messages that highlight the progress of the application at coarse-grained level.'),
 ('INFO'     ,40000,     'Level designates informational messages that highlight the progress of the application at coarse-grained level.'),
 ('DEBUG'    ,30000,     'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('FINE'     ,30000,     'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('TRACE'    ,20000,     'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('FINER'    ,20000,     'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('VERBOSE'  ,10000,     'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('FINEST'   ,10000,     'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('ALL'      ,-2147483647,'Level designates the lowest level possible.');

UPDATE S
SET 
 S.LogLevelValue = V.LogLevelValue
,S.LogLevelDesc  = V.LogLevelDesc
FROM LoggerBase.Core_Level S
INNER JOIN #LoggerBaseCore_Level V ON S.LogLevelName = V.LogLevelName

INSERT LoggerBase.Core_Level
(LogLevelName, LogLevelValue, LogLevelDesc)
SELECT LogLevelName, LogLevelValue, LogLevelDesc
FROM #LoggerBaseCore_Level V
WHERE NOT EXISTS (SELECT LogLevelName FROM LoggerBase.Core_Level)


GO
IF OBJECT_ID('LoggerBase.Session_ContextID_Get') IS NOT NULL DROP FUNCTION LoggerBase.Session_ContextID_Get
GO

CREATE FUNCTION LoggerBase.Session_ContextID_Get()
RETURNS VARBINARY(128)
AS
BEGIN
	RETURN  CONTEXT_INFO()
END
GO
IF OBJECT_ID('LoggerBase.Session_Level_Get') IS NOT NULL DROP FUNCTION LoggerBase.Session_Level_Get
GO

CREATE FUNCTION LoggerBase.Session_Level_Get()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @Level VARCHAR(500) =
	(
		SELECT OverrideLogLevelName
		FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)

	RETURN @Level
END
GO
PRINT 'PROCEDURE LoggerBase.Session_Clear CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Session_Clear') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Session_Clear'
    DROP PROCEDURE LoggerBase.Session_Clear
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Session_Clear'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Session_Clear

    Date:           07/17/2017
    Author:         Jerome Pion
    Description:    

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_Clear
(
     @Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	DELETE LoggerBase.Config_SessionContext
	WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	
GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Session_Clear CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Session_Clear FAILED!'
END
GO
GO
PRINT 'PROCEDURE LoggerBase.Session_Config_Set CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Session_Config_Set') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Session_Config_Set'
    DROP PROCEDURE LoggerBase.Session_Config_Set
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Session_Config_Set'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Session_Config_Set

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    Returns the lowest-level config given the current state. 
					The order of preference is:
					*Passed in config XML
					*Saved config name
					*Session config
					*Saved default config
					*Hard-coded config

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_Config_Set
(
	 @Override XML = NULL
    ,@Config XML OUTPUT
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	IF EXISTS (SELECT * FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)
	BEGIN
		UPDATE LoggerBase.Config_SessionContext
		SET Config = @Config
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	END
	ELSE
	BEGIN
		DECLARE @SessionID UNIQUEIDENTIFIER = NEWID()
		INSERT INTO LoggerBase.Config_SessionContext
		(SessionContextID, Config, OverrideLogLevelName, ExpirationDatetimeUTC)
		VALUES (@SessionID, @Config, NULL, DATEADD(DAY, 1, GETUTCDATE()))
		
		EXEC LoggerBase.Session_Config_Set @SessionID

	END

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Session_Config_Set CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Session_Config_Set FAILED!'
END
GO
GO
PRINT 'PROCEDURE LoggerBase.Session_ContextID_Set CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Session_ContextID_Set') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Session_ContextID_Set'
    DROP PROCEDURE LoggerBase.Session_ContextID_Set
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Session_ContextID_Set'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Session_ContextID_Set

    Date:           07/24/2017
    Author:         Jerome Pion
    Description:    

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_ContextID_Set
(
     @ContextID UNIQUEIDENTIFIER
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	SET CONTEXT_INFO @ContextID

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Session_ContextID_Set CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Session_ContextID_Set FAILED!'
END
GO
GO
PRINT 'PROCEDURE LoggerBase.Session_Level_Set CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Session_Level_Set') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Session_Level_Set'
    DROP PROCEDURE LoggerBase.Session_Level_Set
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Session_Level_Set'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Session_Level_Set

    Date:           07/17/2017
    Author:         Jerome Pion
    Description:    

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_Level_Set
(
     @LogLevelName VARCHAR(500)
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	IF EXISTS (SELECT * FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)
	BEGIN
		IF (@Debug = 1)
		BEGIN
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:Updating existing session:')
		END
		UPDATE LoggerBase.Config_SessionContext
		SET OverrideLogLevelName = @LogLevelName
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	END
	ELSE
	BEGIN

		DECLARE @SessionID UNIQUEIDENTIFIER = NEWID()
				
		IF (@Debug = 1)
		BEGIN
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:Creating new session:', @SessionID)
		END

		INSERT INTO LoggerBase.Config_SessionContext
		(SessionContextID, Config, OverrideLogLevelName, ExpirationDatetimeUTC)
		VALUES (@SessionID, NULL, @LogLevelName, DATEADD(DAY, 1, GETUTCDATE()))

		EXEC LoggerBase.Session_ContextID_Set @SessionID

	END

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Session_Level_Set CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Session_Level_Set FAILED!'
END
GO
GO
IF OBJECT_ID('LoggerBase.Config_Appenders_Get') IS NOT NULL DROP FUNCTION LoggerBase.Config_Appenders_Get
GO

CREATE FUNCTION LoggerBase.Config_Appenders_Get(@Config XML)
RETURNS TABLE
AS

	RETURN

	SELECT 
	ROW_NUMBER() OVER (ORDER BY t.appender.value('./@name', 'VARCHAR(500)')) AS RowID
	,t.appender.value('./@name', 'VARCHAR(500)') AS AppenderName
	,t.appender.value('./@type', 'SYSNAME') as AppenderType
	,t.appender.query('.') AS AppenderConfig
	FROM @Config.nodes('/log4mssql/appender') as t(appender)


GO
PRINT 'PROCEDURE LoggerBase.Config_Retrieve CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Config_Retrieve') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Config_Retrieve'
    DROP PROCEDURE LoggerBase.Config_Retrieve
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Config_Retrieve'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Config_Retrieve

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    Returns the lowest-level config given the current state. 
					The order of preference is:
					*Passed in config XML
					*Saved config name
					*Session config
					*Saved default config
					*Hard-coded config

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Config_Retrieve
(
	 @Override XML = NULL
    ,@Config XML OUTPUT
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	IF (@Override IS NOT NULL) 
	BEGIN
		SET @Config = @Override
		RETURN
	END

	IF (@Override IS NULL)
	SELECT @Config = LoggerBase.Config_RetrieveFromSession()

	IF (@Config IS NULL)
	SELECT @Config = ConfigXML FROM LoggerBase.Config_Saved WHERE ConfigName = 'DEFAULT'

	IF (@Config IS NULL)
	SELECT @Config = '<log4mssql>
    <appender name="Hard-Coded-Console" type="Logger.Appender_ConsoleAppender">
        <layout type="Logger.Layout_PatternLayout">
            <conversionPattern value="%timestamp %level %logger-%message" />
        </layout>
    </appender>
	   <root>
        <level value="DEBUG" />
        <appender-ref ref="Hard-Coded-Console" />
    </root>
</log4mssql>'

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Config_Retrieve CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Config_Retrieve FAILED!'
END
GO
GO
IF OBJECT_ID('LoggerBase.Config_RetrieveFromSession') IS NOT NULL DROP FUNCTION LoggerBase.Config_RetrieveFromSession
GO

CREATE FUNCTION LoggerBase.Config_RetrieveFromSession()
RETURNS XML
AS
BEGIN
	DECLARE @Config XML =
	(
		SELECT Config
		FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)

	RETURN @Config
END
GO
IF OBJECT_ID('LoggerBase.Config_Root_Get') IS NOT NULL DROP FUNCTION LoggerBase.Config_Root_Get
GO

CREATE FUNCTION LoggerBase.Config_Root_Get(@Config XML)
RETURNS @Root TABLE
(
	 RowID      INT
	,LevelValue VARCHAR(500)
	,AppenderRef VARCHAR(500)
)
AS
BEGIN
	INSERT INTO @Root
	SELECT 
	ROW_NUMBER() OVER (ORDER BY AR.AppenderRef) AS RowID
	,LV.LevelValue
	,AR.AppenderRef
	FROM
	(
		SELECT @Config.value('(/log4mssql/root/level/@value)[1]', 'varchar(500)') AS LevelValue
	) AS LV
	CROSS JOIN
	(
		SELECT 
		t.rootnode.value('@ref', 'varchar(500)') AS AppenderRef
		FROM @Config.nodes('/log4mssql/root/appender-ref') as t(rootnode)
	) AS AR

	RETURN

END

GO
PRINT 'PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Config_Appenders_FilteredByLevel') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel'
    DROP PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    Returns the appender configurations that still fire for the requested level.

    --TEST
	DECLARE @InfoConfig XML = '<log4mssql><appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message"/></layout></appender><root><level value="INFO"/><appender-ref ref="Saved-Default-Console"/></root></log4mssql>'
	DECLARE @RequestedLogLevelName VARCHAR(500) = 'DEBUG'

	EXEC LoggerBase.Config_Appenders_FilteredByLevel @Config = @InfoConfig, @RequestedLogLevelName = @RequestedLogLevelName, @Debug = 1

	DECLARE @DebugConfig XML = '<log4mssql><appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message"/></layout></appender><root><level value="DEBUG"/><appender-ref ref="Saved-Default-Console"/></root></log4mssql>'

	EXEC LoggerBase.Config_Appenders_FilteredByLevel @Config = @DebugConfig, @RequestedLogLevelName = @RequestedLogLevelName, @Debug = 1

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel
(
	 @Config                XML
	,@RequestedLogLevelName VARCHAR(500)
	,@Debug                 BIT = 0               
)

AS

    SET NOCOUNT ON

	IF (@Debug = 1)
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@Config:', CONVERT(VARCHAR(5000), @Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@RequestedLogLevelName:', @RequestedLogLevelName)
		DECLARE @RowCount INT = (SELECT COUNT(*) FROM LoggerBase.Config_Root(@Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:LoggerBase.Config_Root returned rowcount:', @RowCount)
		SET @RowCount = (SELECT COUNT(*) FROM LoggerBase.Config_Appenders_Get(@Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:LoggerBase.Config_Appenders_Get returned rowcount:', @RowCount)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:OverrideLogLevel:', LoggerBase.Session_Level_Get()) 
	END

	SELECT 
	ROW_NUMBER() OVER (ORDER BY A.AppenderName) AS RowID
	,A.AppenderType
	,A.AppenderConfig
	FROM       LoggerBase.Config_Root     (@Config) R
	INNER JOIN LoggerBase.Config_Appenders_Get(@Config) A ON R.AppenderRef = A.AppenderName
	--Check if we have an override in the session that changes the root-appender defined logging level.
	INNER JOIN LoggerBase.Core_Level                    LL ON COALESCE(LoggerBase.Session_Level_Get(),  R.LevelValue)  = LL.LogLevelName
	AND LL.LogLevelValue <= (SELECT LogLevelValue FROM LoggerBase.Core_Level WHERE LogLevelName = @RequestedLogLevelName)
	
GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Config_Appenders_FilteredByLevel FAILED!'
END
GO

GO
SET NOCOUNT ON
SET ANSI_PADDING ON

PRINT 'TABLE LoggerBase.Config_Saved CREATED ' + CONVERT(VARCHAR(10), GETDATE(), 101)
GO

IF OBJECT_ID('LoggerBase.Config_Saved') IS NOT NULL
BEGIN
    PRINT '   DROP TABLE LoggerBase.Config_Saved'
    DROP TABLE LoggerBase.Config_Saved
END
GO

PRINT '   CREATE TABLE LoggerBase.Config_Saved'
GO

CREATE TABLE LoggerBase.Config_Saved 
(
    ConfigName     VARCHAR(500) NOT NULL
   ,ConfigXML      XML          NOT NULL
   ,CreateDateTime DATETIME2    NOT NULL CONSTRAINT DF_Config_Saved_CreateDateTime DEFAULT (GETUTCDATE()),
    CONSTRAINT PK_Config_Saved PRIMARY KEY CLUSTERED (ConfigName)
)
GO

IF @@ERROR = 0
BEGIN
    PRINT '   TABLE LoggerBase.Config_Saved CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE TABLE LoggerBase.Config_Saved FAILED'
END
GO

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LoggerBase.Config_SessionContext') AND type in (N'U'))
DROP TABLE LoggerBase.Config_SessionContext
GO

CREATE TABLE LoggerBase.Config_SessionContext
(
	  SessionContextID      UNIQUEIDENTIFIER
	, Config                XML
	, OverrideLogLevelName  VARCHAR(500)
	, ExpirationDatetimeUTC DATETIME2
)
GO
SET NOCOUNT ON

IF OBJECT_ID('TempDB..#LoggerBaseConfig_Saved') IS NOT NULL DROP TABLE #LoggerBaseConfig_Saved
CREATE TABLE #LoggerBaseConfig_Saved(
    ConfigName varchar(500) NOT NULL,
    ConfigXML xml NOT NULL
);

INSERT INTO #LoggerBaseConfig_Saved VALUES
 ('DEFAULT',N'<log4mssql><appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message" /></layout></appender><root><level value="INFO" /><appender-ref ref="Saved-Default-Console" /></root></log4mssql>')
 ,('DEBUG',N'<log4mssql><appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message" /></layout></appender><root><level value="DEBUG" /><appender-ref ref="Saved-Default-Console" /></root></log4mssql>')
UPDATE S
SET S.ConfigXML = V.ConfigXML
FROM LoggerBase.Config_Saved S
INNER JOIN #LoggerBaseConfig_Saved V ON S.ConfigName = V.ConfigName

PRINT CONCAT('Updated ', @@ROWCOUNT, ' rows.')

INSERT LoggerBase.Config_Saved
(ConfigName, ConfigXML)
SELECT ConfigName, ConfigXML
FROM #LoggerBaseConfig_Saved V
WHERE NOT EXISTS (SELECT ConfigName FROM LoggerBase.Config_Saved)

PRINT CONCAT('Inserted ', @@ROWCOUNT, ' rows.')


GO
IF EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery' and is_user_defined = 1)
DROP ASSEMBLY [LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery]
GO

CREATE ASSEMBLY [LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery]
FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C0103002C0879590000000000000000E00002210B010800000800000006000000000000FE250000002000000040000000004000002000000002000004000000000000000400000000000000008000000002000000000000030040850000100000100000000010000010000000000000100000000000000000000000A425000057000000004000006003000000000000000000000000000000000000006000000C00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E7465787400000004060000002000000008000000020000000000000000000000000000200000602E72737263000000600300000040000000040000000A0000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000000E00000000000000000000000000004000004200000000000000000000000000000000E0250000000000004800000002000500D8200000CC04000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001B300200630000000100001100730400000A0A0F01280500000A0B0F00280500000A0C08730600000A0D00096F0700000A0006176F0800000A0006076F0900000A0006096F0A00000A00066F0B00000A26096F0C00000A0000DE120914FE01130411042D07096F0D00000A00DC002A000110000002001E00314F0012000000001E02280E00000A2A42534A4201000100000000000C00000076322E302E35303732370000000005006C00000078010000237E0000E40100006402000023537472696E67730000000048040000080000002355530050040000100000002347554944000000600400006C00000023426C6F620000000000000002000001471502000900000000FA013300160000010000000B0000000200000002000000020000000E0000000300000001000000010000000200000000000A000100000000000600670060000A008F007A000600F000D00006001001D0000A00810166010A00AD0197010A00C20197010A00E301D0010A00F501D0010A00FF016E0006005002600000000000010000000000010001000100100046000000050001000100502000000000960099000A000100D020000000008618B3001200030000000100B90000000200CA001900B30016002100B30012002900B30012003100B30012001100B80120003900B30024004100F001120049000B02290049001B02240031002B022F0049003A02350041004A02120059005C0212000900B300120020001B001B002E000B0043002E0013004C0039000480000000000000000000000000000000002E010000020000000000000000000000010057000000000002000000000000000000000001006E00000000000000003C4D6F64756C653E004C6F67676572426173655F417070656E6465725F41444F417070656E6465725F457865635F4E6F6E7472616E61637465645F51756572792E646C6C0053746F72656450726F63656475726573006D73636F726C69620053797374656D004F626A6563740053797374656D2E446174610053797374656D2E446174612E53716C54797065730053716C537472696E6700657865635F6E6F6E5F7472616E7361637465645F7175657279002E63746F7200436F6E6E656374696F6E537472696E670051756572790053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C697479417474726962757465004C6F67676572426173655F417070656E6465725F41444F417070656E6465725F457865635F4E6F6E7472616E61637465645F5175657279004D6963726F736F66742E53716C5365727665722E5365727665720053716C50726F6365647572654174747269627574650053797374656D2E446174612E53716C436C69656E740053716C436F6D6D616E64006765745F56616C75650053716C436F6E6E656374696F6E0053797374656D2E446174612E436F6D6D6F6E004462436F6E6E656374696F6E004F70656E004462436F6D6D616E6400436F6D6D616E6454797065007365745F436F6D6D616E6454797065007365745F436F6D6D616E6454657874007365745F436F6E6E656374696F6E00457865637574654E6F6E517565727900436C6F73650049446973706F7361626C6500446973706F736500000320000000000000EE14536952F543A3926C30678F44250008B77A5C561934E089070002011109110903200001042001010804010000000320000E042001010E05200101112905200101121D0320000809070512190E0E121D020801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F77730100CC2500000000000000000000EE250000002000000000000000000000000000000000000000000000E02500000000000000000000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF25002040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058400000040300000000000000000000040334000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B00464020000010053007400720069006E006700460069006C00650049006E0066006F0000004002000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000098003C00010049006E007400650072006E0061006C004E0061006D00650000004C006F00670067006500720042006100730065005F0041007000700065006E006400650072005F00410044004F0041007000700065006E006400650072005F0045007800650063005F004E006F006E007400720061006E00610063007400650064005F00510075006500720079002E0064006C006C0000002800020001004C006500670061006C0043006F007000790072006900670068007400000020000000A0003C0001004F0072006900670069006E0061006C00460069006C0065006E0061006D00650000004C006F00670067006500720042006100730065005F0041007000700065006E006400650072005F00410044004F0041007000700065006E006400650072005F0045007800650063005F004E006F006E007400720061006E00610063007400650064005F00510075006500720079002E0064006C006C000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000C000000003600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
WITH PERMISSION_SET = EXTERNAL_ACCESS
GO


GO
PRINT 'PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery CREATED 07/07/2017'
GO

IF OBJECT_ID('LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery'
    DROP PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
   
    Date:           07/28/2017
    Author:         Jerome Pion
    Description:    Executes a query against a database without enlisting in a a transaction.

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
 @connectionstring nvarchar(4000)
,@query [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery].[StoredProcedures].[exec_non_transacted_query]

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Appender_ADOAppender CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Appender_ADOAppender FAILED!'
END
GO
GO
PRINT 'PROCEDURE LoggerBase.Appender_ADOAppender CREATED 07/07/2017'
GO

IF OBJECT_ID('LoggerBase.Appender_ADOAppender') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Appender_ADOAppender'
    DROP PROCEDURE LoggerBase.Appender_ADOAppender
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Appender_ADOAppender'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ADOAppender
   
    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    Writes logging entries to database without enlisting in a transaction.

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_ADOAppender
(@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT=0)
AS
	SET NOCOUNT ON

	IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID),':@Message:', @Message)
	IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID),':@Config:', CONVERT(VARCHAR(MAX),@Config))

	--Get command text
	DECLARE @CommandText VARCHAR(MAX)
	DECLARE @ConnectionString VARCHAR(MAX)

	SELECT @CommandText = t.commandText.value('./@value', 'varchar(MAX)') 
	FROM @Config.nodes('/appender/commandText') as t(commandText)

	SELECT @ConnectionString = t.connectionString.value('./@value', 'varchar(MAX)') 
	FROM @Config.nodes('/appender/connectionString') as t(connectionString)
	--Loop through parameters. 

	SET @ConnectionString = CONCAT(@ConnectionString, ';Enlist=false;')

	SELECT 
	ROW_NUMBER() OVER (ORDER BY t.parameter.value('(parameterName/@value)[1]', 'varchar(MAX)')) AS RowID
	,t.parameter.value('(parameterName/@value)[1]', 'varchar(MAX)') AS ParameterName
	,t.parameter.value('(dbType/@value)[1]', 'varchar(MAX)') AS dbType
	,t.parameter.value('(layout/@type)[1]', 'varchar(MAX)') AS LayoutType
	,t.parameter.value('(layout/conversionPattern/@value)[1]', 'varchar(MAX)') AS ConversionPattern
	,t.parameter.query('./layout') AS ParameterXML
	,CAST('' AS VARCHAR(MAX)) AS ParameterValue
	INTO #Parameters
	FROM @Config.nodes('/appender/parameter') as t(parameter)
		--Get parameter name and datatype
			--Use layout to get value.

	IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID), ':@CommandText:', @CommandText)

	DECLARE @Counter INT
	DECLARE @Limit INT
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @LayoutTypeName SYSNAME
	DECLARE @LayoutConfig XML
	DECLARE @FormattedMessage VARCHAR(MAX)

	SELECT @Counter = MIN(RowID), @Limit = MAX(RowID)
	FROM #Parameters

	WHILE (@Counter <= @Limit)
	BEGIN
		SELECT @LayoutTypeName = LayoutType
		,@LayoutConfig = ParameterXML
		FROM #Parameters
		WHERE 1=1
		AND RowID = @Counter

	 	EXEC LoggerBase.Layout_FormatMessage 
		  @LayoutTypeName  = @LayoutTypeName
		, @LoggerName      = @LoggerName
		, @LogLevelName    = @LogLevelName
		, @Message         = @Message
		, @LayoutConfig    = @LayoutConfig
		, @Debug           = @Debug
		, @FormattedMessage = @FormattedMessage OUTPUT

	  UPDATE #Parameters SET ParameterValue = @FormattedMessage
	  WHERE 1=1
	  AND RowID = @Counter

		SET @Counter += 1

		IF (@Debug = 1)
		BEGIN
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LayoutTypeName:', @LayoutTypeName)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LoggerName:', @LoggerName)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LogLevelName:', @LogLevelName)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@Message:', @Message)
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:@LayoutConfig:', CONVERT(VARCHAR(MAX), @LayoutConfig))
		END
	END

	--SELECT * FROM #Parameters

	--Take the parameters and construct the parameters definition and parameters/value list
	DECLARE @ParameterDefinition NVARCHAR(MAX)
	SELECT @ParameterDefinition = COALESCE(@ParameterDefinition+',' ,'') + CONCAT(ParameterName, ' ' , dbType, ' = ''', ParameterValue, '''')
	FROM #Parameters

SELECT @SQL = CONCAT('DECLARE ', @ParameterDefinition, '; ', @CommandText)
IF (@Debug = 1) PRINT CONCAT(OBJECT_NAME(@@PROCID), ':@SQL:', @SQL)
BEGIN
--EXEC (@SQL)
	EXEC LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
	 @connectionstring = @ConnectionString
	,@query = @SQL
END

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Appender_ADOAppender CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Appender_ADOAppender FAILED!'
END
GO
GO
PRINT 'PROCEDURE LoggerBase.Appender_ConsoleAppender CREATED 07/07/2017'
GO

IF OBJECT_ID('LoggerBase.Appender_ConsoleAppender') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Appender_ConsoleAppender'
    DROP PROCEDURE LoggerBase.Appender_ConsoleAppender
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Appender_ConsoleAppender'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ConsoleAppender

    Date:           07/14/2017
    Author:         Jerome Pion
    Description:    Invokes the requested appender using the provided XML configuration.

    --TEST
	DECLARE @LoggerName   VARCHAR(500) = 'TestAppenderLoggerBase'
	DECLARE @LogLevelName VARCHAR(500) = 'DEBUG'
	DECLARE @Message      VARCHAR(MAX) = 'Appender test message!'
	DECLARE @Config       XML          = '<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>'

	EXEC LoggerBase.Appender_ConsoleAppender 
	  @LoggerName   = @LoggerName
	, @LogLevelName = @LogLevelName 
	, @Message      = @Message
	, @Config       = @Config
	, @Debug        = 1

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_ConsoleAppender (@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT=0)
AS
	
	SET NOCOUNT ON

	IF (@Debug = 1) PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Message:', @Message)

	DECLARE @FormattedMessage VARCHAR(MAX)
	DECLARE @LayoutType       SYSNAME
	DECLARE @LayoutConfig     XML
	DECLARE @SQL              NVARCHAR(MAX)

	SELECT @LayoutType = LayoutType, @LayoutConfig = LayoutConfig FROM LoggerBase.Config_Layout(@Config)

	IF (@Debug = 1)
	BEGIN
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@Config:'    , CONVERT(VARCHAR(MAX), @Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LoggerName:', @LoggerName)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID),']:@LayoutType:', @LayoutType)
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

	PRINT @FormattedMessage

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Appender_ConsoleAppender CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Appender_ConsoleAppender FAILED!'
END
GO
GO
PRINT 'PROCEDURE LoggerBase.Logger_Base CREATED 07/07/2017'
GO

IF OBJECT_ID('LoggerBase.Logger_Base') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Logger_Base'
    DROP PROCEDURE LoggerBase.Logger_Base
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Logger_Base'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Logger_Base

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    A base logging SP that other level-specific loggers will use, e.g. Logger.Debug

    --TEST
	DECLARE @Config XML = 
'<log4mssql>
    <!-- A1 is set to be a ConsoleAppender -->
    <appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
 
        <!-- A1 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="****TEST RESULT****%timestamp [%thread] %level %logger - %message" />
        </layout>
    </appender>
    
	<appender name="A2" type="LoggerBase.Appender_ConsoleAppender">
 
        <!-- A2 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="****TEST RESULT****%timestamp [%thread] %level %logger - %message" />
        </layout>
    </appender>

<appender name="MSSQLAppender" type="LoggerBase.Appender_MSSQLAppender">
    <commandText value="INSERT INTO LoggerBase.TestLog ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
    <parameter>
        <parameterName value="@log_date" />
        <dbType value="DateTime" />
        <layout type="LoggerBase.Layout_RawTimeStampLayout" />
    </parameter>
    <parameter>
        <parameterName value="@thread" />
        <dbType value="varchar(255)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%thread" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@log_level" />
        <dbType value="varchar(50)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%level" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@logger" />
        <dbType value="varchar(255)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%logger" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@message" />
        <dbType value="varchar(4000)" />
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%message" />
        </layout>
    </parameter>
    <parameter>
        <parameterName value="@exception" />
        <dbType value="varchar(2000)" />
        <layout type="LoggerBase.Layout_PatternLayout" />
    </parameter>
</appender>

    <!-- Set root logger level to DEBUG and its only appenders to A1, A2, MSSQLAppender -->
    <root>
        <level value="DEBUG" />
        <appender-ref ref="A1" />
		<appender-ref ref="A2" />
    </root>

	<!--For the "TestProcedure" logger set the level of its "A2" appender to INFO -->
	<logger name="TestProcedure">
		<level value="INFO" />
		<appender-ref ref="A2" />
	</logger>
	<logger name="TestProcedure2">
		<level value="INFO" />
		<appender-ref ref="A2" />
	</logger>
</log4mssql>'

DECLARE @RequestedLogLevelName VARCHAR(100) = 'DEBUG'
DECLARE @LoggerName VARCHAR(500) = 'JustATestLogger'

EXEC LoggerBase.Logger_Base 
  @Message               = 'Some message.'
, @LoggerName            = @LoggerName
, @Config                = @Config
, @RequestedLogLevelName = 'DEBUG'
, @Debug                 = 1

EXEC LoggerBase.Logger_Base 
  @Message               = 'Some message.'
, @LoggerName            = 'DefaultConfigLogger'
, @RequestedLogLevelName = 'DEBUG'
, @Debug                 = 1

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Logger_Base 
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500)
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @RequestedLogLevelName VARCHAR(100)
	, @Debug                 BIT = 0
)

AS

    SET NOCOUNT ON
	DECLARE @PrivateConfig XML
	EXEC LoggerBase.Config_Retrieve @Override = @Config, @Config = @PrivateConfig OUTPUT, @Debug = @Debug

	IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@Config:', CONVERT(VARCHAR(MAX), @Config))

	DECLARE @Appenders TABLE
	(
		RowID INT
		,AppenderType SYSNAME
		,AppenderConfig XML
	)
	INSERT INTO @Appenders
	EXEC LoggerBase.Config_Appenders_FilteredByLevel
		 @Config                = @PrivateConfig           
		,@RequestedLogLevelName = @RequestedLogLevelName
		,@Debug                 = @Debug

	DECLARE @Counter INT
	DECLARE @Limit   INT
	DECLARE @SQL     NVARCHAR(MAX)
	DECLARE @AppenderConfig XML

	SELECT @Counter = MIN(RowID), @Limit = MAX(RowID)
	FROM @Appenders

	WHILE (@Counter <= @Limit)
	BEGIN
		SELECT @SQL = CONCAT(A.AppenderType, ' @LoggerName, @LogLevelName, @Message, @Config, @Debug')
		,@AppenderConfig = AppenderConfig
		FROM @Appenders A
		WHERE 1=1
		AND RowID = @Counter

		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@SQL:', @SQL)
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@Message:', @Message)
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@AppenderConfig:', CONVERT(VARCHAR(MAX), @AppenderConfig))

		EXECUTE sp_executesql @SQL, N'@LoggerName VARCHAR(500), @LogLevelName VARCHAR(500), @Message VARCHAR(MAX), @Config XML, @Debug BIT'
		, @LoggerName   = @LoggerName
		, @LogLevelName = @RequestedLogLevelName
		, @Message      = @Message
		, @Config       = @AppenderConfig
		, @Debug        = @Debug

		SET @Counter += 1

	END

 GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Logger_Base CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Logger_Base FAILED!'
END
GO
GO
PRINT 'PROCEDURE Logger.Debug CREATED 07/07/2017'
GO

IF OBJECT_ID('Logger.Debug') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE Logger.Debug'
    DROP PROCEDURE Logger.Debug
END
GO

PRINT '   CREATE PROCEDURE Logger.Debug'
GO

/*********************************************************************************************

    PROCEDURE Logger.Debug

    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    Log a DEBUG level message.

    --TEST
	EXEC Logger.Debug 'A test debug message', 'Test Logger'
	EXEC Logger.Debug @Message = 'A test debug message', @LoggerName = 'Test Logger', @Debug = 1

	EXEC LoggerBase.Session_Level_Set 'DEBUG', @Debug = 1
	SELECT LoggerBase.Session_ContextID_Get()
	SELECT LoggerBase.Session_Level_Get()
	
	EXEC Logger.Debug 'A test debug message', 'Test Logger'
	EXEC Logger.Debug @Message = 'A test debug message', @LoggerName = 'Test Logger', @Debug = 1

**********************************************************************************************/

CREATE PROCEDURE Logger.Debug
(
	  @Message               VARCHAR(MAX)
	, @LoggerName            VARCHAR(500)
	, @Config                XML          = NULL
	, @StoredConfigName      VARCHAR(500) = NULL
	, @Debug                 BIT          = 0
)

AS

    SET NOCOUNT ON

	EXEC LoggerBase.Logger_Base 
	  @Message               = @Message
	, @LoggerName            = @LoggerName
	, @RequestedLogLevelName = 'DEBUG'
	, @Config                = @Config
	, @StoredConfigName      = @StoredConfigName
	, @Debug                 = @Debug

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE Logger.Debug CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE Logger.Debug FAILED!'
END
GO
GO
