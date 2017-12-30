IF ServerProperty('EngineEdition') = 5
BEGIN
	DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':LoggerBase.Appender_File_Private_WriteTextFile requires CLR with external access which is not supported in Azure. This appendeder will not be available.'); RAISERROR(@Message,0,1);
END
ELSE
BEGIN
EXEC('
CREATE PROCEDURE LoggerBase.Appender_File_Private_WriteTextFile
(
	 @text   NVARCHAR(4000)
	,@path   NVARCHAR(4000) 
	,@append BIT
	,@exitCode INT OUTPUT
	,@errorMessage NVARCHAR(4000) OUTPUT
)
WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME log4mssql.ReadWriteFiles.WriteTextFile
')
END