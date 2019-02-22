/*
Assign a GUID to use at installation time to identify all logging by this database's process.
*/
DECLARE @MutexName NVARCHAR(4000) = NEWID()
DECLARE @SQL VARCHAR(8000) = CONCAT('
CREATE FUNCTION LoggerBase.Appender_MutexName()
RETURNS NVARCHAR(4000)
AS
BEGIN

    RETURN ''', @MutexName, ''' 
END')

EXEC (@SQL)

