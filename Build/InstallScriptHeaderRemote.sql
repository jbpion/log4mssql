:SETVAR LOGGINGDATABASE Log4MSSQLBuild
/*
NOTE:
***This script must be run in SQLCMD mode.
***Select Query->SQLCMD from the menu bar.

MIT License

Copyright (c) 2017 jbpion

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

SET NOCOUNT ON;

DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':Installation started'); RAISERROR(@Message,0,1);

DECLARE @V VARCHAR(50) = (SELECT [Version] FROM [$(LOGGINGDATABASE)].LoggerBase.VersionInfo())

SET @Message = CONCAT('| Logging database $(LOGGINGDATABASE) is at version ', @V, ' |')
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

IF OBJECT_ID('Logger.Tokens_List') IS NOT NULL DROP SYNONYM Logger.Tokens_List
BEGIN
	PRINT 'Creating synonym Logger.Tokens_List'
	CREATE SYNONYM Logger.Tokens_List FOR [$(LOGGINGDATABASE)].Logger.Tokens_List
END

IF OBJECT_ID('LoggerBase.Configuration_Get') IS NOT NULL DROP SYNONYM LoggerBase.Configuration_Get
BEGIN
	PRINT 'Creating synonym LoggerBase.Configuration_Get'
	CREATE SYNONYM LoggerBase.Configuration_Get FOR [$(LOGGINGDATABASE)].LoggerBase.Configuration_Get
END

IF OBJECT_ID('LoggerBase.Configuration_Set') IS NOT NULL DROP SYNONYM LoggerBase.Configuration_Set
BEGIN
	PRINT 'Creating synonym LoggerBase.Configuration_Set'
	CREATE SYNONYM LoggerBase.Configuration_Set FOR [$(LOGGINGDATABASE)].LoggerBase.Configuration_Set
END

IF OBJECT_ID('LoggerBase.CorrelationId_Helper') IS NOT NULL DROP SYNONYM LoggerBase.CorrelationId_Helper
BEGIN
	PRINT 'Creating synonym LoggerBase.CorrelationId_Helper'
	CREATE SYNONYM LoggerBase.CorrelationId_Helper FOR [$(LOGGINGDATABASE)].LoggerBase.CorrelationId_Helper
END

IF OBJECT_ID('LoggerBase.DefaultErrorMessage') IS NOT NULL DROP SYNONYM LoggerBase.DefaultErrorMessage
BEGIN
	PRINT 'Creating synonym LoggerBase.DefaultErrorMessage'
	CREATE SYNONYM LoggerBase.DefaultErrorMessage FOR [$(LOGGINGDATABASE)].LoggerBase.DefaultErrorMessage
END

IF OBJECT_ID('LoggerBase.Logger_Base') IS NOT NULL DROP SYNONYM LoggerBase.Logger_Base
BEGIN
	PRINT 'Creating synonym Logger.DefaultErrorMessage'
	CREATE SYNONYM LoggerBase.Logger_Base FOR [$(LOGGINGDATABASE)].LoggerBase.Logger_Base
END

IF OBJECT_ID('LoggerBase.Layout_Tokens_Pivot') IS NOT NULL DROP SYNONYM LoggerBase.Layout_Tokens_Pivot
BEGIN
	PRINT 'Creating synonym Logger.Layout_Tokens_Pivot'
	CREATE SYNONYM LoggerBase.Layout_Tokens_Pivot FOR [$(LOGGINGDATABASE)].LoggerBase.Layout_Tokens_Pivot
END

IF OBJECT_ID('LoggerBase.Util_Configuration_Properties') IS NOT NULL DROP SYNONYM LoggerBase.Util_Configuration_Properties
BEGIN
	PRINT 'Creating synonym Logger.Util_Configuration_Properties'
	CREATE SYNONYM LoggerBase.Util_Configuration_Properties FOR [$(LOGGINGDATABASE)].LoggerBase.Util_Configuration_Properties
END


