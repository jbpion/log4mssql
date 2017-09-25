
CREATE FUNCTION LoggerBase.Config_RetrieveFromSession()
RETURNS XML
AS
BEGIN
	DECLARE @Config XML =
	(
		SELECT Config
		FROM LoggerBase.Config_SessionContext
		WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	)

	RETURN @Config
END
