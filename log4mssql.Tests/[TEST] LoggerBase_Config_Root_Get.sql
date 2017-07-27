
SET NOCOUNT ON

EXEC tSQLt.NewTestClass 'loggerbase_config_root_get';
GO

--Assemble - Define and populate fake tables. Create result tracking tables.
CREATE PROCEDURE loggerbase_config_root_get.[SetUp]
AS
BEGIN
	PRINT 'Setup not implemented'
	--EXEC tSQLt.FakeTable 'dbo.Table'
	--INSERT INTO dbo.Table VALUES('');
END;
GO

--Act: Define the query/code under test.


--Assert: Create tests to compare the expected and actual results of the object under test.
CREATE PROCEDURE loggerbase_config_root_get.[Test Assert Something]
AS
BEGIN
	DECLARE @Config XML = '<log4mssql>
	<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
	<!-- A1 uses PatternLayout -->
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp [%thread] %level %LoggerBase - %message%newline"/>
	</layout>
	</appender>
	<root>
        <level value="DEBUG" />
        <appender-ref ref="A1" />
    </root>
</log4mssql>'

	SELECT RowID = 1, LevelValue = CAST('DEBUG' AS VARCHAR(500)), AppenderRef = CAST('A1' AS VARCHAR(500))
	INTO #Expected

	SELECT *
	INTO #Actual
	FROM LoggerBase.Config_Root_Get(@Config)

	EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual'

END;
GO

EXEC tSQLt.Run 'loggerbase_config_root_get'
GO

