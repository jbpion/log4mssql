-- =============================================
-- Author:		Jerome Pion
-- Create date: 02/13/2019
-- Description:	Gets a probably unique identifier to use as a correlation id for logging
-- =============================================
CREATE VIEW LoggerBase.CorrelationId_Helper
AS
	SELECT CAST(SUBSTRING(CONVERT(VARCHAR(MAX), NEWID()), 1, 20) AS VARCHAR(20)) AS CorrelationId