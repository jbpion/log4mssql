﻿
CREATE FUNCTION LoggerBase.Session_ContextID_Get()
RETURNS VARBINARY(128)
AS
BEGIN
	RETURN  CONTEXT_INFO()
END
