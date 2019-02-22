IF ServerProperty('EngineEdition') = 5
BEGIN
	DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':LoggerBase.Appender_File_Private_WriteTextFileWithMutex requires CLR with external access which is not supported in Azure. This appendeder will not be available.'); RAISERROR(@Message,0,1);
	SET NOEXEC ON
END
GO

IF (OBJECT_ID('LoggerBase.Appender_File_Private_WriteTextFileWithMutex') IS NOT NULL AND ServerProperty('EngineEdition') <> 5) 
SET NOEXEC ON
GO

CREATE PROCEDURE LoggerBase.Appender_File_Private_WriteTextFileWithMutex
	@text [NVARCHAR](4000),
	@path [NVARCHAR](4000),
	@append [BIT],
	@mutexname NVARCHAR(4000),
	@exitCode [INT] OUTPUT,
	@errorMessage [NVARCHAR](4000) OUTPUT
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME log4mssql.WriteFilesWithMutex.WriteTextFile
GO
GO

