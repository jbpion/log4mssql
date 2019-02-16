IF OBJECT_ID('LoggerBase.Layout_ApplicationName') IS NOT NULL
SET NOEXEC ON
GO

CREATE FUNCTION LoggerBase.Layout_ApplicationName()
RETURNS NVARCHAR(256)
AS 
BEGIN
	RETURN NULL
END

GO

SET NOEXEC OFF
GO
/*********************************************************************************************

    FUNCTION LoggerBase.Layout_ApplicationName

    Date:           02/15/2019
    Author:         Jerome Pion
    Description:    Gets the name application name of the connecting context.

**********************************************************************************************/
ALTER FUNCTION LoggerBase.Layout_ApplicationName()
RETURNS NVARCHAR(256)
AS
BEGIN

    RETURN APP_NAME()

END