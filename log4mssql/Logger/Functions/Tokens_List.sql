/*********************************************************************************************

    FUNCTION Logger.Tokens_List

    Date:           02/15/2019
    Author:         Jerome Pion
    Description:    Gets the list and values, if available, of layout tokens.

	--TEST:
	SELECT * FROM Logger.Tokens_List()

**********************************************************************************************/
CREATE FUNCTION Logger.Tokens_List()
RETURNS TABLE
AS RETURN
(
	SELECT * 
	FROM LoggerBase.Layout_GetTokens(NULL, NULL, NULL, NULL, NULL, NULL, NULL)
)
GO