IF OBJECT_ID('Logger.DefaultErrorMessage') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.DefaultErrorMessage
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.DefaultErrorMessage

    Date:           03/08/2019
    Author:         Jerome Pion
    Description:    Wraps the default error message function

    --TEST

	DECLARE @DefaultErrorMessage VARCHAR(20)
	EXEC Logger.DefaultErrorMessage @DefaultErrorMessage OUTPUT
	SELECT @DefaultErrorMessage

**********************************************************************************************/

ALTER PROCEDURE Logger.DefaultErrorMessage
(
	 @DefaultErrorMessage NVARCHAR(MAX) OUTPUT
)
AS 
BEGIN

	SET NOCOUNT ON

	BEGIN TRY
		SET @DefaultErrorMessage = LoggerBase.DefaultErrorMessage()
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ') Line: ', ERROR_LINE())
		PRINT @ErrorMessage
	END CATCH
END
GO
