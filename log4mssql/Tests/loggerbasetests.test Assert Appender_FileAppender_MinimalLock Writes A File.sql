CREATE PROCEDURE [loggerbasetests].[test Assert Appender_FileAppender_MinimalLock Writes A File]
AS
BEGIN
	DECLARE @LoggerName VARCHAR(500) = 'TestAppenderLogger'
	DECLARE @LogLevelName VARCHAR(500) = 'DEBUG'
	DECLARE @Message VARCHAR(500) = NEWID()
	DECLARE @XMLConfig XML = '<appender name="FileAppender" type="LoggerBase.Appender_FileAppender_MinimalLock">
		<file value="C:\Temp\log-file-test.txt" />
		<appendToFile value="false" />
		<layout type="LoggerBase.Layout_PatternLayout">
			<conversionPattern value="%message" />
		</layout>
</appender>'
  
  --Act
	EXEC LoggerBase.Appender_FileAppender_MinimalLock 
	  @LoggerName = @LoggerName
	, @LogLevelName = @LogLevelName 
	, @Message      = @Message
	, @Config       = @XMLConfig
	, @Debug        = 1
	, @CorrelationId = '1'
  
  --Assert
  IF OBJECT_ID('TempDB..#Actual') IS NOT NULL DROP TABLE #Actual
    CREATE TABLE #Actual
	(
		RowData NVARCHAR(MAX)
	)
	BULK INSERT #Actual
	FROM 'C:\Temp\log-file-test.txt'

	DECLARE @Actual NVARCHAR(500) = (SELECT * FROM #Actual)

	EXEC tSQLt.AssertEquals @Expected = @Message, -- sql_variant
	                        @Actual = @Actual,   -- sql_variant
	                        @Message = N''    -- nvarchar(max)
	
  
END;


