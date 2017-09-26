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