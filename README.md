# log4mssql
This is a logging framework for T-SQL (SQL Server) stored procedure that is designed to be similar to Apache's [log4net](https://logging.apache.org/log4net/).

# Overview
This framework is an attempt to mirror some of the capabilities found in the Apache Project's popular log4net framework in Microsoft SQL Server's T-SQL language. The framework uses a similar XML configuration to log4net which can be set as a default or defined ad hoc. A developer, primarily of stored procedures, can create logging statements and then change how messages are layed out and handled without changing any code.

# Installation
Run the log4mssql_install.sql file from the Build folder in the database context where you want to install the framework. You can also create a central database that holds the main logging functions for the instance and do a remote install. Execute the LoggerBase.InstallToRemote stored procedure. The "remote" install will create a few stored procedures and then synonyms that point back to your main logging database in the same instance.

# Usage
The logging stored procedures reflect log4net's log object methods of Debug, Info, Warn, Error, and Fatal. To define a logging statement you provide the message and the logger name. For example:
```
EXEC Logger.Debug 'A test debug message', 'Test Logger'
```
Will send the message "A test debug message" with a logger name of "Test Logger" to any appenders registered at the debug level if the current logging level is at debug.

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
Logging configuration is set using XML. Generally you will stored your configuration in the LoggerBase.Config_Saved table. This XML is similar to log4net.

## Initializing the framework
You will need to initialize the configuration for the framework. This configuration can be passed down to child loggers.

You create a log configuration by declaring a variable of type "LogConfiguration" and then setting its properties using the Logger.Configure stored procedure.

E.g.
DECLARE @LogConfiguration LogConfiguration

Passing in the @@PROCID will set the logger name to the name of the calling procedure:
EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @CallingProcedureId = @@PROCID

You can also set an explicit logger name:
EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName'

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

