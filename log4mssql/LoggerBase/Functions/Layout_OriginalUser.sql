IF OBJECT_ID('LoggerBase.Layout_OriginalUser') IS NOT NULL
SET NOEXEC ON
GO

CREATE FUNCTION LoggerBase.Layout_OriginalUser()
RETURNS NVARCHAR(256)
AS 
BEGIN
	RETURN NULL
END

GO

SET NOEXEC OFF
GO
/*********************************************************************************************

    FUNCTION LoggerBase.Layout_OriginalUser

    Date:           02/15/2019
    Author:         Jerome Pion
    Description:    Gets the name of the original login user even in case of impersonation.

**********************************************************************************************/
ALTER FUNCTION [LoggerBase].[Layout_OriginalUser]()
RETURNS NVARCHAR(256)
AS
BEGIN

    RETURN ORIGINAL_LOGIN()

END