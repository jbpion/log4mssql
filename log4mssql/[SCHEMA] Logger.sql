IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Logger')
EXEC sys.sp_executesql N'CREATE SCHEMA Logger'