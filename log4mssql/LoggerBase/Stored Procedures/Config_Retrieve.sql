IF OBJECT_ID('LoggerBase.Config_Retrieve') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE LoggerBase.Config_Retrieve
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Config_Retrieve

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    Returns the lowest-level config given the current state. 
					The order of preference is:
					*Passed in config XML
					*Saved config name
					*Session config
					*Saved default config
					*Hard-coded config

    --TEST

**********************************************************************************************/

ALTER PROCEDURE [LoggerBase].[Config_Retrieve]
(
	 @Override XML = NULL
	,@SavedConfigName VARCHAR(500) = NULL
    ,@Config XML OUTPUT
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	IF (@Override IS NOT NULL) 
	BEGIN
		SET @Config = @Override
		RETURN
	END

	IF (@Config IS NULL)
	BEGIN
		SELECT @Config = ConfigXML FROM LoggerBase.Config_Saved WHERE ConfigName = @SavedConfigName
	END

	--IF (@Override IS NULL)
	--BEGIN 
	--	IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']:@Override is null calling LoggerBase.Config_RetrieveFromSession')
	--	SELECT @Config = LoggerBase.Config_RetrieveFromSession()
	--END

	IF (@Config IS NULL)
	BEGIN
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']: @Config is null. Getting "DEFAULT" from saved configuration.')
		SELECT @Config = ConfigXML FROM LoggerBase.Config_Saved WHERE ConfigName = 'DEFAULT'
	END

	IF (@Config IS NULL)
	BEGIN
		IF (@Debug = 1) PRINT CONCAT('[', OBJECT_NAME(@@PROCID), ']: @Config is null. Assigning default string.')
		SELECT @Config = '<log4mssql>
		<appender name="Hard-Coded-Console" type="Logger.Appender_ConsoleAppender">
			<layout type="Logger.Layout_PatternLayout">
				<conversionPattern value="%timestamp %level %logger-%message" />
			</layout>
		</appender>
		   <root>
			<level value="DEBUG" />
			<appender-ref ref="Hard-Coded-Console" />
		</root>
	</log4mssql>'
	END

GO


