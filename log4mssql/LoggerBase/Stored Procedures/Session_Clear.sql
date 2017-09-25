
/*********************************************************************************************

    PROCEDURE LoggerBase.Session_Clear

    Date:           07/17/2017
    Author:         Jerome Pion
    Description:    

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_Clear
(
     @Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	DELETE LoggerBase.Config_SessionContext
	WHERE SessionContextID = LoggerBase.Session_ContextID_Get()
	
