IF OBJECT_ID('LoggerBase.Layout_GetTokens') IS NOT NULL
SET NOEXEC ON
GO

CREATE FUNCTION LoggerBase.Layout_GetTokens()
RETURNS TABLE
AS 
	RETURN SELECT NULL AS Token


GO

SET NOEXEC OFF
GO
/*********************************************************************************************

    FUNCTION Logger.Layout_GetTokens

    Date:           02/15/2019
    Author:         Jerome Pion
    Description:    Gets the list and values, if available, of layout tokens.

	--TEST:
	SELECT * FROM LoggerBase.Layout_GetTokens('TESTLOGGERNAME', 'DEBUG', 'Hello, world!', '1234', 'ADatabaseName', 'LocalServerName', 20)
	SELECT * FROM LoggerBase.Layout_GetTokens('TESTLOGGERNAME', 'DEBUG', 'Hello, world!', '1234', NULL, NULL, NULL)

**********************************************************************************************/
ALTER FUNCTION LoggerBase.Layout_GetTokens
(
      @LoggerName   VARCHAR(500)
	, @LogLevelName VARCHAR(500)
	, @Message      VARCHAR(MAX)
	, @CorrelationId VARCHAR(20)
	, @DatabaseName SYSNAME
	, @ServerName   SYSNAME
	, @SessionId    INT
)
RETURNS TABLE
AS RETURN
(
	SELECT '%d ' AS Token, 'Date' AS TokenProperty, '' AS TokenDescription, CONCAT(CONVERT(CHAR(10), LoggerBase.Layout_GetDate(), 120), ' ') 
	AS TokenCurrentValue
	UNION ALL SELECT '%date', 'Date', '', CONCAT(CONVERT(CHAR(10), LoggerBase.Layout_GetDate(), 120), '') 
	UNION ALL SELECT '%logger',        'Logger',          '', @LoggerName
	UNION ALL SELECT '%identity',      'Identity',        '', LoggerBase.Layout_LoginUser()
	UNION ALL SELECT '%m ',             'Message',         '', CONCAT(@Message, ' ')
	UNION ALL SELECT '%message',       'Message',         '', @Message
	UNION ALL SELECT '%n ', 'NewLine', '', CHAR(13)
	UNION ALL SELECT '%newline', 'NewLine', '', CHAR(13)
	UNION ALL SELECT '%Level',             'Level',           '', @LogLevelName
	UNION ALL SELECT '%p ',             'Level',           '', CONCAT(@LogLevelName,' ')
	UNION ALL SELECT '%r ',             'TimeStamp',       '', CONCAT(SYSDATETIME(),' ')
	UNION ALL SELECT '% ',              'SessionId',       '', CONCAT(COALESCE(@SessionId, @@SPID), ' ')
	UNION ALL SELECT '%thread',        'SessionId',       '', CONCAT(COALESCE(@SessionId, @@SPID), '')
	UNION ALL SELECT '%spid',          'SessionId',       '', CONCAT(COALESCE(@SessionId, @@SPID), '')
	UNION ALL SELECT '%timestamp',     'TimeStamp',       '', CONCAT(SYSDATETIME(),'')
	UNION ALL SELECT '%u ',             'UserName',        '',CONCAT( LoggerBase.Layout_LoginUser(),' ')
	UNION ALL SELECT '%utcdate',       'UTCDate',         '', CONCAT(SYSUTCDATETIME(),'')
	UNION ALL SELECT '%w ',             'UserName',        '', CONCAT(LoggerBase.Layout_LoginUser(),' ')
	UNION ALL SELECT '%correlationid', 'CorrelationId',   '', @CorrelationId
	UNION ALL SELECT '%appname',       'ApplicationName', '', LoggerBase.Layout_ApplicationName()
	UNION ALL SELECT '%ouser',         'OriginalUser',    '', LoggerBase.Layout_OriginalUser()
	UNION ALL SELECT '%originaluser',  'OriginalUser',    '', LoggerBase.Layout_OriginalUser()
	UNION ALL SELECT '%server',        'ServerName',      '', CONCAT(COALESCE(@ServerName, @@SERVERNAME), '')
	UNION ALL SELECT '%dbname',        'DatabaseName',    '', CONCAT(COALESCE(@DatabaseName, DB_NAME()), '')
	
	-- ('%d', 'Date', CONVERT(CHAR(10), LoggerBase.Layout_GetDate(), 120))
	--,('%date', 'Date', CONVERT(CHAR(10), LoggerBase.Layout_GetDate(), 120))
	--,('%identity', 'Identity', LoggerBase.Layout_LoginUser())
	--,('%level', 'Level', @LogLevelName)
	--,('%logger', 'Logger', @LoggerName)
	--,('%m', 'Message', @Message)
	--,('%message', 'Message', @Message)
	--,('%p', 'Level', @LogLevelName)
	--,('%r', 'TimeStamp', CONCAT(SYSDATETIME(),''))
	--,('%', 'SessionId', CONCAT(@@SPID, ''))
	--,('%thread', 'SessionId', CONCAT(@@SPID, ''))
	--,('%spid', 'SessionId', CONCAT(@@SPID, ''))
	--,('%timestamp', 'TimeStamp', CONCAT(SYSDATETIME(),''))
	--,('%u', 'UserName', LoggerBase.Layout_LoginUser())
	--,('%username', 'UserName', LoggerBase.Layout_LoginUser())
	--,('%utcdate', 'UTCDate', CONCAT(SYSUTCDATETIME(),''))
	--,('%w', 'UserName', LoggerBase.Layout_LoginUser())
	--,('%correlationid', 'CorrelationId',  @CorrelationId)
)
GO
