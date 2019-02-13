IF ServerProperty('EngineEdition') = 5
BEGIN
	DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':LoggerBase.Appender_File_Private_WriteTextFile requires CLR with external access which is not supported in Azure. This appendeder will not be available.'); RAISERROR(@Message,0,1);
	SET NOEXEC ON
END
GO

IF (OBJECT_ID('LoggerBase.Appender_File_Private_WriteTextFile') IS NOT NULL AND ServerProperty('EngineEdition') <> 5) 
SET NOEXEC ON
GO

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
GO

IF ServerProperty('EngineEdition') <> 5 SET NOEXEC OFF
GO

ALTER PROCEDURE LoggerBase.Appender_File_Private_WriteTextFile
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
