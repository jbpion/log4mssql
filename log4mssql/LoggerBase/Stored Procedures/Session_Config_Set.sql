
/*********************************************************************************************

    PROCEDURE LoggerBase.Session_Config_Set

    Date:           07/12/2017
    Author:         Jerome Pion
    Description:    Sets the config for the current session.

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_Config_Set
(
	 @Config XML
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	IF EXISTS (SELECT * FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)
	BEGIN
		UPDATE LoggerBase.Config_SessionContext
		SET Config = @Config
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	END
	ELSE
	BEGIN
		DECLARE @SessionID UNIQUEIDENTIFIER = NEWID()
		INSERT INTO LoggerBase.Config_SessionContext
		(SessionContextID, Config, OverrideLogLevelName, ExpirationDatetimeUTC)
		VALUES (@SessionID, @Config, NULL, DATEADD(DAY, 1, GETUTCDATE()))
		
		EXEC LoggerBase.Session_ContextID_Set @SessionID

	END

