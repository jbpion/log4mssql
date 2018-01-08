# log4mssql
This is a logging framework for T-SQL (SQL Server) stored procedure that is designed to be similar to Apache's [log4net](https://logging.apache.org/log4net/).

# Overview
This framework is an attempt to mirror some of the capabilities found in the Apache Project's popular log4net framework in Microsoft SQL Server's T-SQL language. The framework uses a similar XML configuration to log4net which can be set as a default, defined for the scope of a session, or defined ad hoc. A developer, primarily of stored procedures, can create logging statements and then change how messages are layed out and handled without changing any code.

# Installation
Run the log4mssql_install.sql file from the Build folder in the database context where you want to install the framework.

# Usage
The logging stored procedures reflect log4net's log object methods of Debug, Info, Warn, Error, and Fatal. To define a logging statement you provide the message and the logger name. For example:
```
EXEC Logger.Debug 'A test debug message', 'Test Logger'
```
Will send the message "A test debug message" with a logger name of "Test Logger" to any appenders registered at the debug level if the current logging level is at debug.

If no session configuration is in scope the logger will use the stored default configuration which uses the console appender which to send a print event.

# Getting Started
log4mssql comes with a default configuration in the LoggerBase.Config_SavedTable. This sets the level at INFO.

To test you can run the following:
```
EXEC Logger.Debug @Message = 'Hello, World!', @LoggerName = 'DefaultTest' --This will not return because the minimum level is INFO.
EXEC Logger.Info @Message = 'Hello, World!', @LoggerName = 'DefaultTest'
EXEC Logger.Warn @Message = 'Hello, World!', @LoggerName = 'DefaultTest'
EXEC Logger.Error @Message = 'Hello, World!', @LoggerName = 'DefaultTest'
EXEC Logger.Fatal @Message = 'Hello, World!', @LoggerName = 'DefaultTest'
```

You will get results like the following:
```
2017-11-28 12:56:36.9197193 INFO DefaultTest-Hello, World!
2017-11-28 12:56:36.9577457 WARN DefaultTest-Hello, World!
2017-11-28 12:56:36.9617485 ERROR DefaultTest-Hello, World!
2017-11-28 12:56:36.9637499 FATAL DefaultTest-Hello, World!
```
# Configuration
Logging configuration is set at a session level using XML. This XML is similar to log4net.
## Changing The Logging Level
One of the most basic configuration changes you can make is to change the logging level. For example, you may have put debug logging in your stored procedure. Normally you don't want to record those statements. If you need to set the level to debug you would change the level in the session.

First you run a debug logging call using the default (saved) config:
```
EXEC Logger.Debug @Message = 'Hello, World!', @LoggerName = 'DefaultTest'
```
Your output should be only:
```
Commands completed successfully.
```
If you then set the session-scope level to "debug" the framework will send the message to the configured appender. In this case it is the default "console" appender.
```
EXEC LoggerBase.Session_Level_Set @LogLevelName = 'DEBUG'
EXEC Logger.Debug @Message = 'Hello, World!', @LoggerName = 'DefaultTest'
```
You should now get a message like:
```
2017-11-28 13:09:17.1093443 DEBUG DefaultTest-Hello, World!
```
# Appenders
An appender defines a destination for logging messages.

## Console Appender
This appender simply "prints" out the message formatted with replacement tokens. If uses the T-SQL "print" statement which writes to the Info Message event stream.

1. To use this appender we define the type as "LoggerBase.Appender_ConsoleAppender".
2. We need to supply a layout type. There is only one currently called "LoggerBase.Layout_PatternLayout".
3. We then supply a format for our log message. This is the conversion pattern.

For example:
````
/*
Define the configuration as a console appender that will write 
the a string "****TEST RESULT****", timestamp, SPID, logging level, name of the logger, a dash, and the message we sent in.
We will only emit messages when at the "info" level or above.
*/
DECLARE @Config XML = '<log4mssql>
    <!-- A1 is set to be a ConsoleAppender -->
    <appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
        <!-- A1 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="****TEST RESULT****%timestamp [%thread] %level %logger - %message" />
        </layout>
    </appender>
    
	    <!-- Set root logger level to DEBUG and its only appenders to A1, A2, MSSQLAppender -->
    <root>
        <level value="INFO" />
        <appender-ref ref="A1" />
    </root>

</log4mssql>'

/*Store the configuration in the current session context*/
EXEC LoggerBase.Session_Config_Set @Config = @Config

/*Call the "info method" and print out our message as defined in the configuration*/
EXEC Logger.Info @LoggerName = 'ConsoleLogger', @Message = 'Console appender test'
````
You should get output that looks similar to:
````
****TEST RESULT****2018-01-08 15:36:10.6304547 [51] INFO ConsoleLogger - Console appender test
````




