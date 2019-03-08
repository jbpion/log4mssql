
-- =============================================
-- Author:		Jerome Pion
-- Create date: 02/21/2019
-- Description:	Format an error message
-- =============================================
CREATE FUNCTION LoggerBase.DefaultErrorMessage 
(
	
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN CONCAT('Procedure ', ERROR_PROCEDURE(), ', Line ', ERROR_LINE(), ', Error(', ERROR_NUMBER(),') ', ERROR_MESSAGE())
END
GO

