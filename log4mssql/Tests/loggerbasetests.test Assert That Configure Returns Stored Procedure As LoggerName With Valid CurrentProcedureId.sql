CREATE PROCEDURE [loggerbasetests].[test Assert That Configure Returns Stored Procedure As LoggerName With Valid @CurrentProcedureId]
AS
BEGIN

	SET NOCOUNT ON


  --Assemble

  --Act
 	DECLARE @LogConfiguration LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @CallingProcedureId = @@PROCID

	SET @LogConfiguration = REPLACE(@LogConfiguration, CHAR(1), '|')  
  --Assert
  DECLARE @ExpectedPattern NVARCHAR(MAX) = CONCAT('%',OBJECT_SCHEMA_NAME(@@PROCID), '.', OBJECT_NAME(@@PROCID), '%')
  EXEC tSQLt.AssertLike @ExpectedPattern = @ExpectedPattern,
                        @Actual = @LogConfiguration,        
                        @Message = N''          
  
END;




