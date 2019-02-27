
CREATE TYPE LoggerBase.TokenValues AS TABLE 
(
	 ServerName    SYSNAME     NULL
	,DatabaseName  SYSNAME     NULL
	,SessionId     INT         NULL
    --,CorrelationId VARCHAR(20) NULL
	--,LoggerName    VARCHAR(500) NULL
)

