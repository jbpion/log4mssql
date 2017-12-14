CREATE FUNCTION LoggerBase.Appender_File_WriteTextFile
(
	 @text   NVARCHAR(4000)
	,@path   NVARCHAR(4000) 
	,@append BIT
)
RETURNS BIT WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME log4mssql.ReadWriteFiles.WriteTextFile
GO