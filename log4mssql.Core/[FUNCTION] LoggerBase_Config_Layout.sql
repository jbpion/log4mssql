IF OBJECT_ID('') IS NOT NULL DROP FUNCTION LoggerBase.Config_Layout
GO

DROP FUNCTION LoggerBase.Config_Layout

GO
/*********************************************************************************************

    FUNCTION LoggerBase.Config_Layout

    Date:           07/07/2017
    Author:         Jerome Pion
    Description:    A simple implemention of a pattern layout that does simple token replacement.

    --TEST
	SELECT * FROM LoggerBase.Config_Layout('   <appender name="A1" type="LoggerBase.Appender_ConsoleAppender">
 
        <!-- A1 uses PatternLayout -->
        <layout type="LoggerBase.Layout_PatternLayout">
            <conversionPattern value="%-4timestamp [%thread] %-5level %logger %ndc - %message%newline" />
        </layout>
    </appender>')

**********************************************************************************************/

CREATE FUNCTION LoggerBase.Config_Layout(@Config XML)
RETURNS TABLE
AS
	RETURN
	SELECT 
	 t.layout.value('./@type', 'varchar(500)') AS LayoutType
	,t.layout.query('.')                       AS LayoutConfig
	FROM @Config.nodes('./appender/layout') AS t(layout)


