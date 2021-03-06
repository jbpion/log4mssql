CREATE PROCEDURE [loggerbasetests].[test Assert We Can Get The ConversionPattern From The Layout Configuration]
AS
BEGIN

	DECLARE @Config XML = '<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="ConversionPatternToReturn"/>
	</layout>'

	DECLARE @Expected VARCHAR(1000) = 'ConversionPatternToReturn'
	DECLARE @Actual   VARCHAR(1000) = (SELECT LoggerBase.Layout_GetConversionPatternFromConfig(@Config))

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO
