IF OBJECT_ID('LoggerBase.Config_Saved_Set') IS NOT NULL
DROP PROCEDURE [LoggerBase].[Config_Saved_Set]
GO

/*********************************************************************************************

    PROCEDURE LoggerBase.Config_Saved_Set

    Date:           02/08/2019
    Author:         Jerome Pion
    Description:    Upsert the XML definition of a saved config in LoggerBase.Config_Saved.

    --TEST

**********************************************************************************************/

CREATE PROCEDURE [LoggerBase].[Config_Saved_Set]
(
	 @ConfigName VARCHAR(500)
    ,@Config XML OUTPUT
	,@Debug  BIT = 0
)

AS
BEGIN
    SET NOCOUNT ON

	IF (@ConfigName IS NULL OR RTRIM(@ConfigName) = '')
	BEGIN
		PRINT '[LoggerBase.Config_Saved_Set]: @ConfigName cannot be null or empty'
		RETURN -1
	END

	IF (@Config IS NULL)
	BEGIN
		PRINT '[LoggerBase.Config_Saved_Set]: @Config cannot be null'
		RETURN -2
	END

	IF NOT EXISTS (SELECT * FROM LoggerBase.Config_Saved WHERE ConfigName = @ConfigName)
	BEGIN
		INSERT INTO LoggerBase.Config_Saved
		(ConfigName, ConfigXML)
		VALUES (@ConfigName, @Config)
	END
	ELSE
	BEGIN
		UPDATE LoggerBase.Config_Saved
		SET ConfigXML = @Config
		WHERE 1=1
		AND ConfigName = @ConfigName
	END

	RETURN 0

END
GO


