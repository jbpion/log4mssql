PRINT 'PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery CREATED 07/07/2017'
GO

IF OBJECT_ID('LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery'
    DROP PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
   
    Date:           07/28/2017
    Author:         Jerome Pion
    Description:    Executes a query against a database without enlisting in a a transaction.

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Appender_ADOAppender_ExecNonTransactedQuery
 @connectionstring nvarchar(4000)
,@query [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery].[StoredProcedures].[exec_non_transacted_query]

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Appender_ADOAppender CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Appender_ADOAppender FAILED!'
END
GO
