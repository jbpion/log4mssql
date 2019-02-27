
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author:		Jerome Pion
Create date: 02/27/2019
Description:	Replaces tokens in pattern with values

SELECT LoggerBase.Layout_ReplaceTokens ('Hello, World', '%d %dbname [%message]', 'MyLogger', 'INFO', 'ABC-123', 'MyServer', 'MyDatabase', 1234, %date)
=============================================*/
CREATE FUNCTION LoggerBase.Layout_ReplaceTokens 
(
	 @Message VARCHAR(MAX)
	,@ConversionPattern VARCHAR(MAX)
	,@LoggerName   VARCHAR(500)
	,@LogLevelName VARCHAR(500)
	,@CorrelationId VARCHAR(20) = NULL
	,@ServerName SYSNAME
	,@DatabaseName SYSNAME
	,@SessionID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	--DECLARE @FormattedMessage VARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	SELECT @ConversionPattern = REPLACE(@ConversionPattern, Token, COALESCE(TokenCurrentValue,''))
	FROM LoggerBase.Layout_GetTokens(@LoggerName, @LogLevelName, @Message, @CorrelationId, @DatabaseName, @ServerName, @SessionId)

	-- Return the result of the function
	RETURN @ConversionPattern

END
GO

