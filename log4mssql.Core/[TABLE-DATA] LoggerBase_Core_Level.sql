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


