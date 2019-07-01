
IF OBJECT_ID('') IS NOT NULL 
DROP TABLE [LoggerBase].[Util_Configuration_Properties]
GO

CREATE TABLE [LoggerBase].[Util_Configuration_Properties](
	[ConfigurationPropertyId] [int] NOT NULL CONSTRAINT [PK_LoggerBase_Util_Configuration_Properties] PRIMARY KEY CLUSTERED ([ConfigurationPropertyId]),
	[ConfigurationPropertyName] [varchar](250) NULL,
	[ConfigurationPropertyDataType] [varchar](500) NULL
)
ON [PRIMARY]
GO

INSERT INTO LoggerBase.Util_Configuration_Properties
([ConfigurationPropertyId], [ConfigurationPropertyName], [ConfigurationPropertyDataType])
VALUES
 (1, 'ConfigurationXml', 'XML')
,(2, 'LoggerName', 'VARCHAR(500)')
,(3, 'LogLevel', 'VARCHAR(500)')
,(4, 'CorrelationId', 'UNIQUEIDENTIFIER')
,(5, 'SavedConfigurationName', 'VARCHAR(500)')



