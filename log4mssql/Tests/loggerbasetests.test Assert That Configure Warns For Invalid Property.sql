CREATE PROCEDURE [loggerbasetests].[test Assert That Configure Warns For Invalid Property]
AS
BEGIN

	SET NOCOUNT ON

  --Act
  	DECLARE @SQLToTest VARCHAR(2000) = '
	DECLARE @LogConfiguration LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = ''InvalidProperty'', @PropertyValue = ''Some Value''
	'

	EXEC tSQLt.CaptureOutput @command = @SQLToTest
 	
	DECLARE @Actual   VARCHAR(1000) = (SELECT TOP(1) OutputText FROM tSQLt.CaptureOutputLog)

  --Assert
	EXEC tSQLt.AssertLike @ExpectedPattern = '%InvalidProperty is not a valid configuration property%'
	,@Actual = @Actual
		 
END;




