CREATE PROCEDURE [loggerbasetests].[test Assert We Can Get The Date From The Layout_GetDate Function]
AS
BEGIN

	DECLARE @Expected DATE = CAST(GETDATE() AS DATE)
	DECLARE @Actual   DATE = LoggerBase.Layout_GetDate()

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

END;
GO
