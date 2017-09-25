
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

