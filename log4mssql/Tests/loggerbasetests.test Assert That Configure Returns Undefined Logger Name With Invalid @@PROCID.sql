CREATE PROCEDURE [loggerbasetests].[test Assert That Configure Returns Undefined Logger Name With Invalid @@PROCID]
AS
BEGIN

	SET NOCOUNT ON

  --Act
	DECLARE @LogConfiguration LogConfiguration
	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @CallingProcedureId = 0

	SET @LogConfiguration = REPLACE(@LogConfiguration, CHAR(1), '|')  
  --Assert

  EXEC tSQLt.AssertLike @ExpectedPattern = N'%Undefined Logger%',
                        @Actual = @LogConfiguration,
                        @Message = N''       
  
  
END;





