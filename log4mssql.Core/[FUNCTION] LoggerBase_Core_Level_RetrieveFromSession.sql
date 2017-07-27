IF OBJECT_ID('LoggerBase.Core_Level_RetrieveFromSession') IS NOT NULL DROP FUNCTION LoggerBase.Core_Level_RetrieveFromSession
GO

CREATE FUNCTION LoggerBase.Core_Level_RetrieveFromSession()
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @Level VARCHAR(500) =
	(
		SELECT OverrideLogLevelName
		FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)

	RETURN @Level
END