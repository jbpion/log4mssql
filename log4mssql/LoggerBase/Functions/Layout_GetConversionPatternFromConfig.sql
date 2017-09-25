
CREATE FUNCTION LoggerBase.Layout_GetConversionPatternFromConfig(@Config XML)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @ConversionPattern VARCHAR(MAX)
    SELECT @ConversionPattern = t.conversionPattern.value('./@value', 'varchar(max)')
	FROM @Config.nodes('./layout/conversionPattern') as t(conversionPattern)

	RETURN @ConversionPattern

END
