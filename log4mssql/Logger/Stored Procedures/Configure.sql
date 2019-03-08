IF OBJECT_ID('Logger.Configure') IS NOT NULL
SET NOEXEC ON
GO

CREATE PROCEDURE Logger.Configure
AS
	PRINT 'Stub only'
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    PROCEDURE Logger.Configure

    Date:           03/08/2019
    Author:         Jerome Pion
    Description:    Initialize a configuration.

    --TEST

	DECLARE @LogConfiguration LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @CallingProcedureId = @@PROCID

	SELECT @LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName'

	SELECT @LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'LoggerName', @PropertyValue = 'AssignedLoggerName', @CallingProcedureId = @@PROCID

	SELECT @LogConfiguration

	EXEC Logger.Configure @CurrentConfiguration = @LogConfiguration, @NewConfiguration = @LogConfiguration OUTPUT, @PropertyName = 'InvalidPropertyName', @PropertyValue = 'AssignedLoggerName', @CallingProcedureId = @@PROCID

	SELECT @LogConfiguration

**********************************************************************************************/

ALTER PROCEDURE Logger.Configure
(
	 @CurrentConfiguration              LogConfiguration
	,@NewConfiguration                  LogConfiguration OUTPUT
	,@CallingProcedureId                INT = NULL
	,@PropertyName                      VARCHAR(5000) = NULL
	,@PropertyValue                     VARCHAR(5000) = NULL
	,@Debug                             BIT = 0
)
AS 
BEGIN

	SET NOCOUNT ON

	BEGIN TRY
	--If @PropertyName is null then set defaults
	SET @NewConfiguration = @CurrentConfiguration

	--Use sp_executesql so that we can catch the error if LoggerBase.Util_Configuration_Properties doesn't exist. 
	IF (@DEBUG = 1) PRINT CONCAT('Checking if @PropertyName ', COALESCE(@PropertyName, 'NULL'), ' is valid')
	DECLARE @PropertyExists BIT
	EXEC sp_executesql N'SELECT @PropertyExists = 1 FROM LoggerBase.Util_Configuration_Properties WHERE ConfigurationPropertyName = @PropertyName', N'@PropertyExists BIT OUTPUT, @PropertyName VARCHAR(5000)', @PropertyExists = @PropertyExists OUTPUT, @PropertyName = @PropertyName
	IF (COALESCE(@PropertyName,'') <> '' AND COALESCE(@PropertyExists, 0) <> 1)
	BEGIN
		PRINT CONCAT('[Logger.Configure]: ', @PropertyName, ' is not a valid configuration property')
		DECLARE @ConfigurationProperties TABLE
		(
			ConfigurationPropertyId INT
			,ConfigurationPropertyName VARCHAR(250)
		)

		INSERT INTO @ConfigurationProperties
		(
		    ConfigurationPropertyId,
		    ConfigurationPropertyName
		)
		EXEC sp_executesql N'SELECT ConfigurationPropertyId, ConfigurationPropertyName FROM LoggerBase.Util_Configuration_Properties'
		PRINT 'Valid propreties are:'
		DECLARE @Counter TINYINT, @Limit TINYINT, @Message VARCHAR(4000)
		SELECT @Counter = MIN(ConfigurationPropertyId), @Limit = MAX(ConfigurationPropertyId) 
		FROM @ConfigurationProperties

		WHILE (@Counter <= @Limit)
		BEGIN
			SELECT @Message = ConfigurationPropertyName
			FROM @ConfigurationProperties
			WHERE 1=1
			AND ConfigurationPropertyId = @Counter

			PRINT CONCAT('  ', @Message)
			SET @Counter += 1

		END --WHILE
	END
	ELSE 
	BEGIN
		DECLARE @CheckSQL NVARCHAR(MAX) = 'SELECT @PropertyExists = IIF(RTRIM(COALESCE(LoggerBase.Configuration_Get(@CurrentConfiguration, @PropertyName),'''')) = '''', 0, 1)'
		DECLARE @SetSQL NVARCHAR(MAX) = 'SELECT @NewConfiguration = LoggerBase.Configuration_Set(@CurrentConfiguration, @PropertyName, @PropertyValue)'
	
		IF (@PropertyName IS NULL)
		BEGIN
			IF (@DEBUG = 1) PRINT '@PropertyName is null. Setting defaults.'

			DECLARE @LoggerName VARCHAR(500) = CONCAT(OBJECT_SCHEMA_NAME(@CallingProcedureId), '.', OBJECT_NAME(@CallingProcedureId))
			IF (@CallingProcedureId IS NOT NULL AND OBJECT_NAME(@CallingProcedureId) IS NOT NULL)
			BEGIN	
				IF (@DEBUG =1) PRINT '@CallingProcedureId is valid. Checking if we should use it to set the logger name.'
				EXEC sp_executesql @CheckSQL, N'@CurrentConfiguration LogConfiguration, @PropertyExists BIT OUTPUT, @PropertyName VARCHAR(5000)', @CurrentConfiguration = @CurrentConfiguration, @PropertyExists = @PropertyExists OUTPUT, @PropertyName = 'LoggerName'
			
				IF (@PropertyExists = 0) 
				BEGIN
					IF (@Debug = 1) PRINT 'LoggerName property is not set. Attempting set using @CallingProcedureId'
					EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'LoggerName', @PropertyValue = @LoggerName
					SET @CurrentConfiguration = @NewConfiguration
				END
			END
			ELSE
			BEGIN
				EXEC sp_executesql @CheckSQL, N'@CurrentConfiguration LogConfiguration, @PropertyExists BIT OUTPUT, @PropertyName VARCHAR(5000)', @CurrentConfiguration = @CurrentConfiguration, @PropertyExists = @PropertyExists OUTPUT, @PropertyName = 'LoggerName'
			
				IF (@PropertyExists = 0) 
				BEGIN
					IF (@Debug = 1) PRINT 'LoggerName property is not set. Attempting set using default value.'
					EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'LoggerName', @PropertyValue = 'Undefined Logger'
					SET @CurrentConfiguration = @NewConfiguration
				END
			END
				--Set default LogLevel
				EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'LogLevel', @PropertyValue = 'INFO'
				SET @CurrentConfiguration = @NewConfiguration
				--Set default CorrelationId
				DECLARE @CorrelationId VARCHAR(20)
				EXEC Logger.CorrelationId @CorrelationId OUTPUT
				IF (@Debug = 1) PRINT CONCAT('Attempting to set @PropertyName: CorrelationId to default value ''', @CorrelationId, '''.')
				EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'CorrelationId', @PropertyValue = @CorrelationId
				SET @CurrentConfiguration = @NewConfiguration
				--Set default SavedConfigurationName
				EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = 'SavedConfigurationName', @PropertyValue = 'DEFAULT'
				SET @CurrentConfiguration = @NewConfiguration
		END
		ELSE
		BEGIN
			IF (@Debug = 1) PRINT CONCAT('Attempting to set @PropertyName: ', @PropertyName, ' to value ''', @PropertyValue, '''.')
			EXEC sp_executesql @SetSQL, N'@NewConfiguration LogConfiguration OUTPUT, @CurrentConfiguration LogConfiguration, @PropertyName VARCHAR(5000), @PropertyValue VARCHAR(5000)',@NewConfiguration = @NewConfiguration OUTPUT, @CurrentConfiguration = @CurrentConfiguration, @PropertyName = @PropertyName, @PropertyValue = @PropertyValue
		END
	END --Valid Property Name Check
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(8000) = CONCAT('[',OBJECT_SCHEMA_NAME(@@PROCID),'].[',OBJECT_NAME(@@PROCID),'] An error occurred in the logging framework: ', ERROR_MESSAGE(), ' (', ERROR_NUMBER(), ') Line: ', ERROR_LINE())
		PRINT @ErrorMessage
	END CATCH
END
GO
