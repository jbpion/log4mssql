IF OBJECT_ID('Logger.CorrelationId') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.CorrelationId
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.CorrelationId

    Date:           03/08/2019
    Author:         Jerome Pion
    Description:    Gets a probably unique correlation Id

    --TEST

	DECLARE @CorrelationId VARCHAR(20)
	EXEC Logger.CorrelationId @CorrelationId OUTPUT
	SELECT @CorrelationId

**********************************************************************************************/

ALTER PROCEDURE Logger.CorrelationId
(
	 @CorrelationId VARCHAR(20) OUTPUT
)
AS 
BEGIN

	SET NOCOUNT ON

	BEGIN TRY
		SELECT TOP(1) @CorrelationId = CorrelationId FROM LoggerBase.CorrelationId_Helper
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ') Line: ', ERROR_LINE())
		PRINT @ErrorMessage
	END CATCH
END
GO
