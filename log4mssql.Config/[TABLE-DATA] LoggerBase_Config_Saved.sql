SET NOCOUNT ON

IF OBJECT_ID('TempDB..#Values') IS NOT NULL DROP TABLE #Values
CREATE TABLE #Values(
    ConfigName varchar(500) NOT NULL,
    ConfigXML xml NOT NULL
);

INSERT INTO #Values VALUES
 ('DEFAULT',N'<log4mssql><appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message" /></layout></appender><root><level value="INFO" /><appender-ref ref="Saved-Default-Console" /></root></log4mssql>')
 ,('DEBUG',N'<log4mssql><appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender"><layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%timestamp %level %logger-%message" /></layout></appender><root><level value="DEBUG" /><appender-ref ref="Saved-Default-Console" /></root></log4mssql>')
UPDATE S
SET S.ConfigXML = V.ConfigXML
FROM LoggerBase.Config_Saved S
INNER JOIN #Values V ON S.ConfigName = V.ConfigName

PRINT CONCAT('Updated ', @@ROWCOUNT, ' rows.')

INSERT LoggerBase.Config_Saved
(ConfigName, ConfigXML)
SELECT ConfigName, ConfigXML
FROM #Values V
WHERE NOT EXISTS (SELECT ConfigName FROM LoggerBase.Config_Saved)

PRINT CONCAT('Inserted ', @@ROWCOUNT, ' rows.')


