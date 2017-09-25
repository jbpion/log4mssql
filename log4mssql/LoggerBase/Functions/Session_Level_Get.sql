﻿
CREATE FUNCTION LoggerBase.Session_Level_Get()
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
