$StartingFolder = "$([environment]::getfolderpath("mydocuments"))\GitHub\log4mssql"
$Files = @(
    "log4mssql\[SCHEMA] Logger.sql",
    "log4mssql\[SCHEMA] LoggerBase.sql",
    "log4mssql.Layout\[FUNCTION] LoggerBase_Layout_GetConversionPatternFromConfig.sql",
    "log4mssql.Layout\[FUNCTION] LoggerBase_Layout_GetDate.sql",
    "log4mssql.Layout\[FUNCTION] LoggerBase_Layout_LoginUser.sql",
    "log4mssql.Layout\[PROCEDURE] LoggerBase_Layout_PatternLayout.sql",
    "log4mssql.Layout\[PROCEDURE] LoggerBase_Layout_FormatMessage.sql",
    "log4mssql.Core\[FUNCTION] LoggerBase_Config_Layout.sql",
    "log4mssql.Core\[FUNCTION] LoggerBase_Core_Level_RetrieveFromSession.sql",
    "log4mssql.Core\[TABLE] LoggerBase_Core_Level.sql",
    "log4mssql.Core\[TABLE-DATA] LoggerBase_Core_Level.sql",
    "log4mssql.Session\[FUNCTION] LoggerBase_Session_ContextID_Get.sql",
    "log4mssql.Session\[FUNCTION] LoggerBase_Session_Level_Get.sql",
    "log4mssql.Session\[PROCEDURE] LoggerBase_Session_Clear.sql",
    "log4mssql.Session\[PROCEDURE] LoggerBase_Session_Config_Set.sql",
    "log4mssql.Session\[PROCEDURE] LoggerBase_Session_ContextID_Set.sql",
    "log4mssql.Session\[PROCEDURE] LoggerBase_Session_Level_Set.sql",
    "log4mssql.Config\[FUNCTION] LoggerBase_Config_Appenders_Get.sql",
    "log4mssql.Config\[FUNCTION] LoggerBase_Config_Retrieve.sql",
    "log4mssql.Config\[FUNCTION] LoggerBase_Config_RetrieveFromSession.sql",
    "log4mssql.Config\[FUNCTION] LoggerBase_Config_Root_Get.sql",
    "log4mssql.Config\[PROCEDURE ] LoggerBase_Config_Appenders_FilteredByLevel.sql",
    "log4mssql.Config\[TABLE] LoggerBase_Config_Saved.sql",
    "log4mssql.Config\[TABLE] LoggerBase_Config_SessionContext.sql",
    "log4mssql.Config\[TABLE-DATA] LoggerBase_Config_Saved.sql",
    "log4mssql.Appender\[ASSEMBLY] LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery.sql",
    "log4mssql.Appender\[PROCEDURE] LoggerBase_Appender_ADOAppender_ExecNonTransactedQuery.sql"
    "log4mssql.Appender\[PROCEDURE] LoggerBase_Appender_ADOAppender.sql",
    "log4mssql.Appender\[PROCEDURE] LoggerBase_Appender_ConsoleAppender.sql",
    "log4mssql.Logger\[PROCEDURE] LoggerBase_Logger_Base.sql",
    "log4mssql.Logger\[PROCEDURE] Logger_Debug.sql"
    
)
#(dir $StartingFolder -Recurse -Include "*SCHEMA*")[0].FullName
$OutputFile = "$([environment]::getfolderpath("mydocuments"))\GitHub\log4mssql\Build\log4mssql.sql"

$null | Set-Content $OutputFile

foreach ($File in $Files)
{
   
    $File = $File.Replace("[", "``[")
    $File = $File.Replace("]", "``]")
    $FullFilePath = "$StartingFolder\$File"
    # $FileInfo = Get-Item $FullFilePath 
    # if ($FileInfo -eq $null) {Write-Host "Unable to find file $FullFilePath." -ForegroundColor Red; Break;}
    
    Write-Host "Adding $FullFilePath to $OutputFile"
    Get-Content $FullFilePath | Add-Content $OutputFile;
    "GO" | Add-Content $OutputFile
}

#Get-Content "C:\Working\Projects\log4mssql\log4mssql\/[SCHEMA/] Logger.sql"


