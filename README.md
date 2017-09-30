# log4mssql
This is a logging framework for T-SQL (SQL Server) stored procedure that is designed to be similar to Apache's [log4net](https://logging.apache.org/log4net/).

# Overview
This framework is an attempt to mirror some of the capabilities found in the Apache Project's popular log4net framework in Microsoft SQL Server's T-SQL language. The framework uses a similar XML configuration to log4net which can be set as a default, defined for the scope of a session, or defined ad hoc. A developer, primarily of stored procedures, can create logging statements and then change how messages are layed out and handled without changing any code.

# Installation
Currently you install log4mssql using the dacpac file found in the build folder. This targets SQL Server 2014

# Usage
The logging stored procedures reflect log4net's log object methods of Debug, Info, Warn, Error, and Fatal. To define a logging statement you provide the message and the logger name. For example:
```
EXEC Logger.Debug 'A test debug message', 'Test Logger'
```
Will send the message "A test debug message" with a logger name of "Test Logger" to any appenders registered at the debug level if the current logging level is at debug.

If no session configuration is in scope the logger will use the stored default configuration which uses the console appender which to send a print event.

# Configuration
TODO

