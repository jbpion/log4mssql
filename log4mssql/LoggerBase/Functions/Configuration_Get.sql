-- =============================================
-- Author:		Jerome Pion
-- Create date: 02/12/2019
-- Description:	Gets a value from the configuration "object"
-- =============================================
CREATE FUNCTION LoggerBase.Configuration_Get
(
	-- Add the parameters for the function here
	 @Configuration NVARCHAR(MAX)
	,@PropertyName  VARCHAR(500)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result NVARCHAR(MAX)
	DECLARE @Delimiter CHAR(1) = CHAR(1)-- '-'
	
	SELECT @Result = COALESCE(O.Item,'')
	FROM LoggerBase.Util_Configuration_Properties CP
	LEFT JOIN LoggerBase.Util_Split(@Configuration, @Delimiter) O ON CP.ConfigurationPropertyId = O.PropertyId
	WHERE 1=1
	AND CP.ConfigurationPropertyName = @PropertyName
	-- Return the result of the function
	
	RETURN @Result

END
GO


