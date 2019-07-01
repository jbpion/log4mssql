/*********************************************************************************************

    PROCEDURE LoggerBase.InstallToRemote

    Date:           03/14/2019
    Author:         Jerome Pion
    Description:    Installs the framework on another database in the instance pointing back to the main logging database.

    --TEST
	--CREATE DATABASE LogInstallTest
	EXEC LoggerBase.InstallToRemote 'LogInstallTest'

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.InstallToRemote
(
	 @DatabaseName SYSNAME
	,@Debug BIT = 0
)
AS

SET NOCOUNT ON;

DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR(50),GETDATE(),121),':Installation started'); RAISERROR(@Message,0,1);

DECLARE @V VARCHAR(50) = (SELECT [Version] FROM LoggerBase.VersionInfo())

DECLARE @SQL NVARCHAR(MAX)
DECLARE @ObjectName VARCHAR(MAX)

SET @Message = CONCAT('| Logging database ', DB_NAME(), ' is at version ', @V, ' |')
PRINT CONCAT('+', REPLICATE('-', LEN(@Message)-2), '+')
PRINT @Message
PRINT CONCAT('+', REPLICATE('-', LEN(@Message)-2), '+')

--Schema
SET @ObjectName = 'Logger'
PRINT CONCAT('***Checking for schema ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = ''', @ObjectName, ''') BEGIN PRINT ''Create schema ''''', @ObjectName, ''''''' EXEC(''CREATE SCHEMA ', @ObjectName, ''') END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase'
PRINT CONCAT('***Checking for schema ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = ''', @ObjectName, ''') BEGIN PRINT ''Create schema ''''', @ObjectName, ''''''' EXEC(''CREATE SCHEMA ', @ObjectName, ''') END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

----Synonym
SET @ObjectName = 'Logger.Tokens_List'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.Configuration_Get'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.Configuration_Set'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.CorrelationId_Helper'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.DefaultErrorMessage'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.Logger_Base'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.Layout_Tokens_Pivot'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

SET @ObjectName = 'LoggerBase.Util_Configuration_Properties'
PRINT CONCAT('***Checking for synonym ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create synonym ', @ObjectName, ''' CREATE SYNONYM ', @ObjectName, ' FOR [', DB_NAME(), '].', @ObjectName, ' END')
IF (@Debug = 1) PRINT @SQL
EXEC sp_executesql @SQL

----User Defined Types
PRINT '***Checking for user-defined type dbo.LogConfiguration***'
SELECT @SQL = CONCAT('USE ', @DatabaseName, '; IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N''LogConfiguration'' AND ss.name = N''dbo'') BEGIN PRINT ''Create type LogConfiguration'' CREATE TYPE [dbo].[LogConfiguration] FROM [nvarchar](max) NULL END')
EXEC sp_executesql @SQL

----Stored Procedures
SET @ObjectName = 'Logger.CorrelationId'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.DefaultErrorMessage'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.Configure'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.Debug'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.Error'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.Fatal'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.Info'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

SET @ObjectName = 'Logger.Warn'
PRINT CONCAT('***Checking for stored procedure ', @ObjectName, '***')
SELECT @SQL = CONCAT('USE ', @DatabaseName, ';IF OBJECT_ID(''', @ObjectName, ''') IS NULL BEGIN PRINT ''Create procedure ', @ObjectName, ''' EXEC(''', REPLACE(OBJECT_DEFINITION(OBJECT_ID(@ObjectName)), '''', ''''''), ''') END')
EXEC sp_executesql @SQL

RAISERROR('',0,1)WITH NOWAIT;
RAISERROR('+-----------------------------------------+',0,1)WITH NOWAIT;
RAISERROR('|                                         |',0,1)WITH NOWAIT;
RAISERROR('| log4mssql remote installation complete  |',0,1)WITH NOWAIT;
RAISERROR('|                                         |',0,1)WITH NOWAIT;
RAISERROR('+-----------------------------------------+',0,1)WITH NOWAIT;
GO
