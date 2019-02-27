/*********************************************************************************************

    FUNCTION LoggerBase.Layout_Tokens_Pivot

    Date:           02/27/2019
    Author:         Jerome Pion
    Description:    A function for pivoting the functions split string.

    --TEST
	DECLARE @TokenValues VARCHAR(MAX) = 'MyServerName|MyDatabaseName|1234'
	
	SELECT * FROM LoggerBase.Layout_Tokens_Pivot(@TokenValues)

	SELECT @TokenValues = 'MyServerName||1234'
	SELECT * FROM LoggerBase.Layout_Tokens_Pivot(@TokenValues)

**********************************************************************************************/

IF OBJECT_ID (N'LoggerBase.Layout_Tokens_Pivot') IS NOT NULL
   DROP FUNCTION LoggerBase.Layout_Tokens_Pivot
GO

CREATE FUNCTION LoggerBase.Layout_Tokens_Pivot(@TokenValues VARCHAR(MAX))
RETURNS @Values TABLE 
(
     ServerName  SYSNAME
	,DatabaseName SYSNAME
    ,SessionId INT
)
AS
-- body of the function
BEGIN
	DECLARE @Pivot TABLE
	(
		PropertyId INT
		,ServerName BIT
		,DatabaseName BIT
		,SessionId BIT
	)

	INSERT INTO @Pivot
	(
		PropertyId,
		ServerName,
		DatabaseName,
		SessionId
	)
	VALUES
	 (1, 1, 0, 0)
	,(2, 0, 1, 0)
	,(3, 0, 0, 1)

	INSERT INTO @Values
	SELECT 
	 MAX(IIF(ServerName =1, V.Item, NULL)) AS ServerName
	,MAX(IIF(P.DatabaseName =1, V.Item, NULL)) AS DatabaseName
	,MAX(IIF(P.SessionId =1, V.Item, NULL)) AS SessionId
	FROM LoggerBase.Util_Split(@TokenValues, '|') V
	INNER JOIN @Pivot P ON V.PropertyId = P.PropertyId

	RETURN
   
END
GO


