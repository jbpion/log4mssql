CREATE PROCEDURE [loggerbasetests].[test Assert Config_Retrieve Returns Override When Passed In]
AS
BEGIN

	
	DECLARE @ExpectedConfig VARCHAR(1000) = '<log4mssql>OVERRIDE</log4mssql>'

	DECLARE @Config XML

	EXEC LoggerBase.Config_Retrieve @Override = @ExpectedConfig, @Config = @Config OUTPUT

	DECLARE @Actual VARCHAR(1000) = CONVERT(VARCHAR(1000), @Config)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedConfig, @Actual = @Actual

END;
GO
