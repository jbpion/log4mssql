IF NOT EXISTS (SELECT * FROM LoggerBase.Config_Saved WHERE ConfigName = 'DEFAULT')
INSERT INTO LoggerBase.Config_Saved
(
	 ConfigName
	,ConfigXML
)
VALUES
(
	 'DEFAULT'
	,'<log4mssql>
	<appender name="Saved-Default-Console" type="LoggerBase.Appender_ConsoleAppender">
	<layout type="LoggerBase.Layout_PatternLayout">
	<conversionPattern value="%timestamp %level %logger-%message" />
	</layout>
	</appender>
	<root>
	<level value="INFO" />
	<appender-ref ref="Saved-Default-Console" />
	</root>
	</log4mssql>'
)
GO


