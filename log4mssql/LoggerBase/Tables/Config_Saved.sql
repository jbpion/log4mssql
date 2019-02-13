IF OBJECT_ID('LoggerBase.Config_Saved') IS NULL
CREATE TABLE [LoggerBase].[Config_Saved] (
    [ConfigName]     VARCHAR (500) NOT NULL,
    [ConfigXML]      XML           NOT NULL,
    [CreateDateTime] DATETIME2 (7) CONSTRAINT [DF_Config_Saved_CreateDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Config_Saved] PRIMARY KEY CLUSTERED ([ConfigName] ASC)
);

