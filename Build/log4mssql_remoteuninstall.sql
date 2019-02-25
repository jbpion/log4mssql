IF OBJECT_ID('Logger.Debug') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Debug'
	DROP SYNONYM Logger.Debug
END

IF OBJECT_ID('Logger.Error') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Error'
	DROP SYNONYM Logger.Error
END

IF OBJECT_ID('Logger.Fatal') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Fatal'
	DROP SYNONYM Logger.Fatal
END

IF OBJECT_ID('Logger.Info') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Info'
	DROP SYNONYM Logger.Info
END

IF OBJECT_ID('Logger.Warn') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Warn'
	DROP SYNONYM Logger.Warn
END

IF OBJECT_ID('Logger.Tokens_List') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Tokens_List'
	DROP SYNONYM Logger.Tokens_List
END

IF OBJECT_ID('Logger.Configuration_Get') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Configuration_Get'
	DROP SYNONYM Logger.Configuration_Get
END

IF OBJECT_ID('Logger.Configuration_Set') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.Configuration_Set'
	DROP SYNONYM Logger.Configuration_Set
END

IF OBJECT_ID('Logger.CorrelationId') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.CorrelationId'
	DROP SYNONYM Logger.CorrelationId
END

IF OBJECT_ID('Logger.DefaultErrorMessage') IS NOT NULL 
BEGIN
	PRINT 'Removing synonym Logger.DefaultErrorMessage'
	DROP SYNONYM Logger.DefaultErrorMessage
END

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Logger')
BEGIN
	PRINT 'Removing schema Logger'
    EXEC('DROP SCHEMA Logger')
END
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'LoggerBase')
BEGIN
	PRINT 'Removing schema LoggerBase'
	EXEC('DROP SCHEMA LoggerBase')
END