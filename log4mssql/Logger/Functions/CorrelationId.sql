-- =============================================
-- Author:		Jerome Pion
-- Create date: 02/13/2019
-- Description:	Gets a probably unique identifier to use as a correlation id for logging
-- =============================================
CREATE FUNCTION Logger.CorrelationId()
RETURNS VARCHAR(20)
AS
BEGIN
	RETURN (SELECT CorrelationId FROM LoggerBase.CorrelationId_Helper)
END
GO

