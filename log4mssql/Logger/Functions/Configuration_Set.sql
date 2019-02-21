IF OBJECT_ID('Logger.Configuration_Set') IS NOT NULL 
DROP FUNCTION [Logger].[Configuration_Set]
GO

-- =============================================
-- Author:		Jerome Pion
-- Create date: 02/12/2019
-- Description:	Sets values on the configuration "object"
-- =============================================
CREATE FUNCTION [Logger].[Configuration_Set] 
(
	-- Add the parameters for the function here
	 @Configuration NVARCHAR(MAX)
	,@PropertyName  VARCHAR(500)
	,@PropertyValue NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	--DECLARE @Result NVARCHAR(MAX)
	DECLARE @Delimiter CHAR(1) = CHAR(1)-- '-'
	DECLARE @NewConfiguration NVARCHAR(MAX) --= @Delimiter
	DECLARE @ConfigurationTable TABLE
	(
		 ConfigurationPropertyId       INT
		,ConfigurationPropertyName     VARCHAR(500)
		,ConfigurationPropertyDataType VARCHAR(500)
		,ConfigurationPropertyValue    NVARCHAR(MAX)
	)

	--EXEC (CONCAT('SELECT TRY_CAST('', @

	INSERT INTO @ConfigurationTable
	SELECT 
	 CP.ConfigurationPropertyId
	,CP.ConfigurationPropertyName
	,CP.ConfigurationPropertyDataType
	,O.Item AS ConfigurationPropertyValue
	FROM LoggerBase.Util_Configuration_Properties CP
	LEFT JOIN LoggerBase.Util_Split(@Configuration, @Delimiter) O ON CP.ConfigurationPropertyId = O.PropertyId
	-- Return the result of the function
	
	UPDATE @ConfigurationTable SET ConfigurationPropertyValue = @PropertyValue WHERE ConfigurationPropertyName = @PropertyName

	IF (@@ROWCOUNT = 0)
	BEGIN
		--PRINT CONCAT('ERROR: Unable to find property with name "', @PropertyName, '". Set failed.')
		SET @NewConfiguration = @Configuration
	END
	ELSE
	BEGIN

		SELECT @NewConfiguration = COALESCE(@NewConfiguration + @Delimiter, '') + COALESCE(ConfigurationPropertyValue,'')
		FROM @ConfigurationTable
	END

	RETURN @NewConfiguration

END
GO


