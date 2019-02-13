IF OBJECT_ID('LoggerBase.Configuration_Get_Properties') IS NOT NULL
DROP FUNCTION [LoggerBase].[Configuration_Get_Properties]
GO

CREATE FUNCTION [LoggerBase].[Configuration_Get_Properties](@Configuration NVARCHAR(MAX))
RETURNS TABLE
AS RETURN
(
	SELECT 
	 CP.ConfigurationPropertyId
	,CP.ConfigurationPropertyName
	,CP.ConfigurationPropertyDataType
	,O.Item AS ConfigurationPropertyValue
	FROM LoggerBase.Util_Configuration_Properties CP
	LEFT JOIN LoggerBase.Util_Split(@Configuration, CHAR(1)) O ON CP.ConfigurationPropertyId = O.PropertyId
)
GO


