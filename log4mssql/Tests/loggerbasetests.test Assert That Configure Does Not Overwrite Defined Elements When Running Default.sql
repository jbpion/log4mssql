
CREATE PROCEDURE [loggerbasetests].[test Assert That Configure Does Not Overwrite Defined Elements When Running Default]
AS
BEGIN

SET NOCOUNT ON

DECLARE @LogConfiguration LogConfiguration
EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName'

  EXEC tSQLt.AssertLike @ExpectedPattern = '%AssignedLoggerName%'
	,@Actual = @LogConfiguration

EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT

  EXEC tSQLt.AssertLike @ExpectedPattern = '%AssignedLoggerName%'
	,@Actual = @LogConfiguration, @Message = N'The second call to the logger overwrote the assigned logger name with a default.'
  
END;




