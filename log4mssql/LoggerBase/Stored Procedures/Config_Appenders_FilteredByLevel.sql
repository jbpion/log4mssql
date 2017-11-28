﻿
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
		DECLARE @RowCount INT = (SELECT COUNT(*) FROM LoggerBase.Config_Root_Get(@Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:LoggerBase.Config_Root returned rowcount:', @RowCount)
		SET @RowCount = (SELECT COUNT(*) FROM LoggerBase.Config_Appenders_Get(@Config))
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:LoggerBase.Config_Appenders_Get returned rowcount:', @RowCount)
		PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:OverrideLogLevel:', LoggerBase.Session_Level_Get()) 
	END

	SELECT 
	ROW_NUMBER() OVER (ORDER BY A.AppenderName) AS RowID
	,A.AppenderType
	,A.AppenderConfig
	FROM       LoggerBase.Config_Root_Get     (@Config) R
	INNER JOIN LoggerBase.Config_Appenders_Get(@Config) A ON R.AppenderRef = A.AppenderName
	--Check if we have an override in the session that changes the root-appender defined logging level.
	INNER JOIN LoggerBase.Core_Level                    LL ON COALESCE(LoggerBase.Session_Level_Get(),  R.LevelValue)  = LL.LogLevelName
	AND LL.LogLevelValue <= (SELECT LogLevelValue FROM LoggerBase.Core_Level WHERE LogLevelName = @RequestedLogLevelName)
	
