/*
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
GO

IF ServerProperty('EngineEdition') <> 5
BEGIN
	DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':Enabling the CLR for the current database'); RAISERROR(@Message,0,1);
	EXEC sp_configure 'clr enabled', 1;

	SELECT @Message = 'Running the reconfigure command'; RAISERROR(@Message,0,1);
	RECONFIGURE;
END
ELSE
BEGIN
	SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':Install is running in Azure. Skipping CLR configuration.'); RAISERROR(@Message,0,1);
END
GO

IF ServerProperty('EngineEdition') <> 5
BEGIN     
	DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':Setting TRUSTWORTHY on for current database to run CLR stored procedures and functions.'); RAISERROR(@Message,0,1); 
	ALTER DATABASE CURRENT SET TRUSTWORTHY ON
END
GO
