
/*********************************************************************************************

    PROCEDURE LoggerBase.Session_Level_Set

    Date:           07/17/2017
    Author:         Jerome Pion
    Description:    

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_Level_Set
(
     @LogLevelName VARCHAR(500)
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	IF EXISTS (SELECT * FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)
	BEGIN
		IF (@Debug = 1)
		BEGIN
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:Updating existing session:')
		END
		UPDATE LoggerBase.Config_SessionContext
		SET OverrideLogLevelName = @LogLevelName
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	END
	ELSE
	BEGIN

		DECLARE @SessionID UNIQUEIDENTIFIER = NEWID()
				
		IF (@Debug = 1)
		BEGIN
			PRINT CONCAT('[',OBJECT_NAME(@@PROCID), ']:Creating new session:', @SessionID)
		END

		INSERT INTO LoggerBase.Config_SessionContext
		(SessionContextID, Config, OverrideLogLevelName, ExpirationDatetimeUTC)
		VALUES (@SessionID, NULL, @LogLevelName, DATEADD(DAY, 1, GETUTCDATE()))

		EXEC LoggerBase.Session_ContextID_Set @SessionID

	END

