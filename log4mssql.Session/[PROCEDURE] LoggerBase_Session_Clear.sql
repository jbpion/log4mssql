PRINT 'PROCEDURE LoggerBase.Session_Clear CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Session_Clear') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Session_Clear'
    DROP PROCEDURE LoggerBase.Session_Clear
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Session_Clear'
GO

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
	
GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Session_Clear CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Session_Clear FAILED!'
END
GO
