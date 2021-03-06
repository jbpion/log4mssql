CREATE PROCEDURE [loggerbasetests].[test Assert Function Config_Layout Returns The Layout Type And XML Config]
AS
BEGIN

	DECLARE @TestConfig XML = '
	<appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%-4timestamp [%thread] %-5level %logger %ndc - %message%newline"/>
        </layout>
    </appender>'
	DECLARE @ExpectedLayoutType   VARCHAR(500)  = 'LoggerBase.Layout_PatternLayout'
	DECLARE @ExpectedLayoutConfig VARCHAR(4000) = '<layout type="LoggerBase.Layout_PatternLayout"><conversionPattern value="%-4timestamp [%thread] %-5level %logger %ndc - %message%newline"/></layout>'

	DECLARE @ActualLayoutType   VARCHAR(500) 
	DECLARE @ActualLayoutConfig VARCHAR(4000)

	SELECT @ActualLayoutType = LayoutType, @ActualLayoutConfig = CONVERT(VARCHAR(4000), LayoutConfig)
	FROM LoggerBase.Config_Layout(@TestConfig)

	EXEC tSQLt.AssertEquals @Expected = @ExpectedLayoutType, @Actual = @ActualLayoutType
	EXEC tSQLt.AssertEquals @Expected = @ExpectedLayoutConfig, @Actual = @ActualLayoutConfig

END;
GO
