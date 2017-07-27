PRINT 'PROCEDURE LoggerBase.Config_Retrieve CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Config_Retrieve') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Config_Retrieve'
    DROP PROCEDURE LoggerBase.Config_Retrieve
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Config_Retrieve'
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

CREATE PROCEDURE LoggerBase.Config_Retrieve
(
	 @Override XML = NULL
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

	IF (@Override IS NULL)
	SELECT @Config = LoggerBase.Config_RetrieveFromSession()

	IF (@Config IS NULL)
	SELECT @Config = ConfigXML FROM LoggerBase.Config_Saved WHERE ConfigName = 'DEFAULT'

	IF (@Config IS NULL)
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

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Config_Retrieve CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Config_Retrieve FAILED!'
END
GO
