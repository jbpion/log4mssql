IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'LoggerBase')
EXEC sys.sp_executesql N'CREATE SCHEMA LoggerBase'