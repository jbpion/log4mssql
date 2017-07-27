PRINT 'PROCEDURE LoggerBase.Session_ContextID_Set CREATED 07/12/2017'
GO

IF OBJECT_ID('LoggerBase.Session_ContextID_Set') IS NOT NULL
BEGIN
    PRINT '   DROP PROCEDURE LoggerBase.Session_ContextID_Set'
    DROP PROCEDURE LoggerBase.Session_ContextID_Set
END
GO

PRINT '   CREATE PROCEDURE LoggerBase.Session_ContextID_Set'
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Session_ContextID_Set

    Date:           07/24/2017
    Author:         Jerome Pion
    Description:    

    --TEST

**********************************************************************************************/

CREATE PROCEDURE LoggerBase.Session_ContextID_Set
(
     @ContextID UNIQUEIDENTIFIER
	,@Debug  BIT = 0
)

AS

    SET NOCOUNT ON

	SET CONTEXT_INFO @ContextID

GO

IF @@ERROR = 0
BEGIN
    PRINT '   PROCEDURE LoggerBase.Session_ContextID_Set CREATED SUCCESSFULLY'
END
ELSE
BEGIN
    PRINT '   CREATE PROCEDURE LoggerBase.Session_ContextID_Set FAILED!'
END
GO
