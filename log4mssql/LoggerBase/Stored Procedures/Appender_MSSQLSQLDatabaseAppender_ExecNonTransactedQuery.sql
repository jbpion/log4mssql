IF ServerProperty('EngineEdition') = 5
BEGIN
	DECLARE @Message NVARCHAR(MAX);SELECT @Message = CONCAT(CONVERT(NVARCHAR,GETDATE(),121),':LoggerBase.Appender_MSSQLSQLDatabaseAppender_ExecNonTransactedQuery requires CLR with external access which is not supported in Azure. This appendeder will not be available.'); RAISERROR(@Message,0,1);
END
ELSE
BEGIN
EXEC('
CREATE PROCEDURE [LoggerBase].[Appender_MSSQLSQLDatabaseAppender_ExecNonTransactedQuery]
(
	@ConnectionString NVARCHAR(4000),
	@Query NVARCHAR(4000),
	@Parameters XML,
	@CommandTimeout INT = 5,
	@Debug BIT = 0
)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [log4mssql].[StoredProcedures].[LoggerBase_Exec_Non_Transacted_Query]
')
END