CREATE PROCEDURE [loggerbasetests].[test Assert That Configure Sets The LoggerName]
AS
BEGIN

    SET NOCOUNT ON

  --Act
DECLARE @LogConfiguration LogConfiguration
EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName'
  
  --Assert
  EXEC tSQLt.AssertLike @ExpectedPattern = '%AssignedLoggerName%'
	,@Actual = @LogConfiguration
  
END;




