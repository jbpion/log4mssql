!!c:\Windows\microsoft.net\Framework\v3.5\csc.exe /target:library /out:"C:\Working\Projects\log4mssql\LoggerBase_Appender_ADOAppender_Exec_Nontranacted_Query.dll" "C:\Working\Projects\log4mssql\log4mssql.Appender\[PROCEDURE-CLR] LoggerBase_Appender_ADOAppender_Exec_Nontranacted_Query.cs"

USE master
GO
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

USE LoggerTest
GO
ALTER DATABASE LoggerTest SET TRUSTWORTHY ON
GO

CREATE ASSEMBLY LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery
FROM 'C:\Working\Projects\log4mssql\LoggerBase_Appender_ADOAppender_Exec_Nontranacted_Query.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS
GO

CREATE PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
 @connectionstring nvarchar(4000)
,@query [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery].[StoredProcedures].[exec_non_transacted_query]

