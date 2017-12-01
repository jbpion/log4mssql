IF NOT EXISTS (SELECT * FROM LoggerBase.Core_Level)
INSERT INTO LoggerBase.Core_Level VALUES
 ('OFF',2147483647,'Level designates a higher level than all the rest.'),
 ('EMERGENCY',120000,'Level designates very severe error events;System unusable, emergencies.'),
 ('FATAL',110000,'Level designates very severe error events that will presumably lead the application to abort.'),
 ('ALERT',100000,'Level designates very severe error events. Take immediate action, alerts.'),
 ('CRITCAL',90000,'Level designates very severe error events. Critical condition, critical.'),
 ('SEVERE',80000,'Level designates very severe error events.'),
 ('ERROR',70000,'Level designates error events that might still allow the application to continue running.'),
 ('WARN',60000,'Level designates potentially harmful situations.'),
 ('NOTICE',50000,'Level designates informational messages that highlight the progress of the application at coarse-grained level.'),
 ('INFO',40000,'Level designates informational messages that highlight the progress of the application at coarse-grained level.'),
 ('DEBUG',30000,'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('FINE',30000,'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('TRACE',20000,'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('FINER',20000,'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('VERBOSE',10000,'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('FINEST',10000,'Level designates fine-grained informational events that are most useful to debug an application.'),
 ('ALL',-2147483647,'Level designates the lowest level possible.');
GO


