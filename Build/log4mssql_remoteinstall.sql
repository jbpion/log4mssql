/*
This script must be run in SQLCMD mode.
Select Query->SQLCMD from the menu bar.
*/

--LOGGINGDATABASE: This is the name of the database, on the local instance, having the full install of the 
--log4mssql framework.
:SETVAR LOGGINGDATABASE Log4MSSQLBuild

DECLARE @V VARCHAR(50) = (SELECT [Version] FROM [$(LOGGINGDATABASE)].LoggerBase.VersionInfo())

DECLARE @Message VARCHAR(1000) = CONCAT('| Logging database $(LOGGINGDATABASE) is at version ', @V, ' |')
PRINT CONCAT('+', REPLICATE('-', LEN(@Message)-2), '+')
PRINT @Message
PRINT CONCAT('+', REPLICATE('-', LEN(@Message)-2), '+')

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Logger')
BEGIN
	PRINT 'Creating schema Logger'
    EXEC('CREATE SCHEMA Logger')
END
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'LoggerBase')
BEGIN
	PRINT 'Creating schema LoggerBase'
	EXEC('CREATE SCHEMA LoggerBase')
END

IF OBJECT_ID('Logger.Debug') IS NOT NULL DROP SYNONYM Logger.Debug
BEGIN
	PRINT 'Creating synonym Logger.Debug'
	CREATE SYNONYM Logger.Debug FOR [$(LOGGINGDATABASE)].Logger.Debug
END

IF OBJECT_ID('Logger.Error') IS NOT NULL DROP SYNONYM Logger.Error
BEGIN
	PRINT 'Creating synonym Logger.Error'
	CREATE SYNONYM Logger.Error FOR [$(LOGGINGDATABASE)].Logger.Error
END

IF OBJECT_ID('Logger.Fatal') IS NOT NULL DROP SYNONYM Logger.Fatal
BEGIN
	PRINT 'Creating synonym Logger.Fatal'
	CREATE SYNONYM Logger.Fatal FOR [$(LOGGINGDATABASE)].Logger.Fatal
END

IF OBJECT_ID('Logger.Info') IS NOT NULL DROP SYNONYM Logger.Info
BEGIN
	PRINT 'Creating synonym Logger.Info'
	CREATE SYNONYM Logger.Info FOR [$(LOGGINGDATABASE)].Logger.Info
END

IF OBJECT_ID('Logger.Warn') IS NOT NULL DROP SYNONYM Logger.Warn
BEGIN
	PRINT 'Creating synonym Logger.Warn'
	CREATE SYNONYM Logger.Warn FOR [$(LOGGINGDATABASE)].Logger.Warn
END

IF OBJECT_ID('Logger.Tokens_List') IS NOT NULL DROP SYNONYM Logger.Tokens_List
BEGIN
	PRINT 'Creating synonym Logger.Tokens_List'
	CREATE SYNONYM Logger.Tokens_List FOR [$(LOGGINGDATABASE)].Logger.Tokens_List
END

IF OBJECT_ID('Logger.Configuration_Get') IS NOT NULL DROP SYNONYM Logger.Configuration_Get
BEGIN
	PRINT 'Creating synonym Logger.Configuration_Get'
	CREATE SYNONYM Logger.Configuration_Get FOR [$(LOGGINGDATABASE)].Logger.Configuration_Get
END

IF OBJECT_ID('Logger.Configuration_Set') IS NOT NULL DROP SYNONYM Logger.Configuration_Set
BEGIN
	PRINT 'Creating synonym Logger.Configuration_Set'
	CREATE SYNONYM Logger.Configuration_Set FOR [$(LOGGINGDATABASE)].Logger.Configuration_Set
END

IF OBJECT_ID('Logger.CorrelationId') IS NOT NULL DROP SYNONYM Logger.CorrelationId
BEGIN
	PRINT 'Creating synonym Logger.CorrelationId'
	CREATE SYNONYM Logger.CorrelationId FOR [$(LOGGINGDATABASE)].Logger.CorrelationId
END

IF OBJECT_ID('Logger.DefaultErrorMessage') IS NOT NULL DROP SYNONYM Logger.DefaultErrorMessage
BEGIN
	PRINT 'Creating synonym Logger.DefaultErrorMessage'
	CREATE SYNONYM Logger.DefaultErrorMessage FOR [$(LOGGINGDATABASE)].Logger.DefaultErrorMessage
END

RAISERROR('',0,1)WITH NOWAIT;
RAISERROR('+-----------------------------------------+',0,1)WITH NOWAIT;
RAISERROR('|                                         |',0,1)WITH NOWAIT;
RAISERROR('| log4mssql remote installation complete  |',0,1)WITH NOWAIT;
RAISERROR('|                                         |',0,1)WITH NOWAIT;
RAISERROR('+-----------------------------------------+',0,1)WITH NOWAIT;