<#To run build:
1) Download psake from https://github.com/psake/psake
2) Set-Location <psake download location>
3) Import-Module psake.psm1 
4) Download tSQLt from http://tsqlt.org/downloads/ to \log4mssql\log4mssql\Tests and extract the zip file.
5) Set-Location .\log4mssql\Build
6) Invoke-psake .\Build.ps1
7) To run a specific target add the target name. E.g. To run tests: Invoke-psake .\Build.ps1 RunTests
8) Modify the prop
#>

properties {
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
  $buildDatabaseServer = "localhost"
  $buildDatabaseName = "Log4MSSQLBuild"
  $buildDatabaseDataFilePath = "C:\MSSQL\Data"
  $buildDatabaseLogFilePath = "C:\MSSQL\Logs"
  $srcDirectory = "\\nisa.local\nisa\Users\jpion001\Projects\OpenSource\log4mssql"
  $buildDirectory = [System.IO.Path]::Combine($srcDirectory, "Build");
  $testsDirectory = "$buildDirectory\..\log4mssql\Tests";
  $installScriptName = "log4mssql_install.sql"
  $OutputFile = [System.IO.Path]::Combine($buildDirectory, $installScriptName);
}

task default -depends Build

task Build  -depends CreateInstallScript, ApplyInstallScript, RunTests {

}

task DropDatabase {
  $dropDatabaseQuery = [string]::Format("IF EXISTS (SELECT * FROM master.sys.databases WHERE name = '{0}')
  BEGIN
  EXEC('ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE')
  EXEC('USE [master];DROP DATABASE [{0}]')
  END
  ", $buildDatabaseName)
  Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database master -Query $dropDatabaseQuery
}

task CreateDatabase -depends DropDatabase{
    $DataFileDirectory = [System.IO.Path]::Combine($buildDatabaseDataFilePath,$buildDatabaseName)
    $LogFileDirectory = [System.IO.Path]::Combine($buildDatabaseLogFilePath,$buildDatabaseName)
    if (! (Test-Path $DataFileDirectory)) {New-Item -Name $buildDatabaseName -Path $buildDatabaseDataFilePath -ItemType Directory}
    if (! (Test-Path $LogFileDirectory)) {New-Item -Name $buildDatabaseName -Path $buildDatabaseLogFilePath -ItemType Directory}

    $createDatabaseQuery = [string]::Format("CREATE DATABASE [{0}]
    CONTAINMENT = NONE
    ON  PRIMARY 
   ( NAME = N'{0}', FILENAME = N'C:\MSSQL\Data\{0}\{0}.mdf' , SIZE = 4096KB , FILEGROWTH = 1024KB )
    LOG ON 
   ( NAME = N'{0}_log', FILENAME = N'C:\MSSQL\Logs\{0}\{0}_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
   GO
   ALTER DATABASE [{0}] SET RECOVERY SIMPLE 
   GO
   ALTER AUTHORIZATION ON DATABASE::[{0}] TO [sa]"
    ,$buildDatabaseName)

    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database master -Query $createDatabaseQuery
  
}

task CompileCLRAssembly {
  "$srcDirectory\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.cs"
  EXEC {c:\Windows\microsoft.net\Framework\v3.5\csc.exe /target:library /out:"$srcDirectory\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.dll" "$srcDirectory\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.cs"}
}

task RegisterAssemblyWithDatabase -depends CompileCLRAssembly, CreateDatabase {
    $assemblyRegistrationQuery = "
    USE $buildDatabaseName
    GO
    ALTER DATABASE $buildDatabaseName SET TRUSTWORTHY ON
    GO
    
    CREATE ASSEMBLY log4mssql
    FROM '$srcDirectory\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.dll'
    WITH PERMISSION_SET = UNSAFE --Required for mutex
    GO"

    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database master -Query $assemblyRegistrationQuery
}

task ScriptAssemblyFromDatabase -depends RegisterAssemblyWithDatabase{
    $fileBytesQuery = "
    SELECT
    afiles.content AS [FileBytes]
    FROM
    sys.assemblies AS asmbl
    INNER JOIN sys.assembly_files AS afiles ON afiles.assembly_id=asmbl.assembly_id
    WHERE asmbl.name = 'log4mssql'
    "
    $fileByteDataRow = Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -Query $fileBytesQuery -MaxBinaryLength 8192 #715827882
    [System.Byte[]] $fileByteData = $fileByteDataRow.FileBytes
    $fileByteString = "0x$([System.BitConverter]::ToString($fileByteData))" -replace "-", "" #Encoding.Default.GetString(
    $assemblyScript = "
    /*NOTE: This file is automatically generated by the build process. Modifications will be lost.*/
    IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'log4mssql' and is_user_defined = 1)
    DROP ASSEMBLY [log4mssql]
    GO
    
    CREATE ASSEMBLY [log4mssql]
    FROM $fileByteString
    WITH PERMISSION_SET = UNSAFE
    GO
    "

    $assemblyScript | Set-Content "$srcDirectory\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.sql"

}

  task CreateInstallScript -depends ScriptAssemblyFromDatabase {
      $sqlFiles = @(
        "..\Build\InstallScriptHeader.sql"
        ,"Security\Logger.sql"
        ,"Security\LoggerBase.sql"
        ,"Types\LogConfiguration.sql"
        ,"LoggerBase\Functions\Util_Split.sql"
        ,"LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.sql"
        ,"LoggerBase\Tables\Config_Saved.sql"
        #,"LoggerBase\Tables\Config_SessionContext.sql"
        ,"LoggerBase\Tables\Core_Level.sql"
        ,"LoggerBase\Tables\Util_Configuration_Properties.sql"
        ,"LoggerBase\TableData\Populate Table LoggerBase_Config_Saved.sql"
        ,"LoggerBase\TableData\Populate Table LoggerBase_Core_Level.sql"
        ,"LoggerBase\Views\CorrelatedId_Helper.sql"
        ,"LoggerBase\Functions\Core_Level_ConvertNameToValue.sql"
        ,"LoggerBase\Functions\Appender_Filter_RangeFile_Apply.sql"
        ,"LoggerBase\Functions\Config_Appenders_Get.sql"
        #,"LoggerBase\Functions\Core_Level_RetrieveFromSession.sql"
        ,"LoggerBase\Functions\Layout_GetConversionPatternFromConfig.sql"
        ,"LoggerBase\Functions\Layout_ApplicationName.sql"
        ,"LoggerBase\Functions\Layout_GetDate.sql"
        ,"LoggerBase\Functions\Layout_LoginUser.sql"
        ,"LoggerBase\Functions\Layout_JsonEscape.sql"
        ,"LoggerBase\Functions\Layout_OriginalUser.sql"
        ,"LoggerBase\Functions\Layout_ReplaceTokens.sql"
        ,"LoggerBase\Functions\Layout_Tokens_Pivot.sql"
        ,"LoggerBase\Functions\Layout_GetTokens.sql"
        ,"LoggerBase\Functions\Appender_MutexName.sql"
        #,"LoggerBase\Functions\Session_ContextID_Get.sql"
        #,"LoggerBase\Functions\Session_Level_Get.sql"
        ,"LoggerBase\Functions\Config_Layout.sql"
        #,"LoggerBase\Functions\Config_RetrieveFromSession.sql"
        ,"LoggerBase\Functions\Config_Root_Get.sql"
        ,"LoggerBase\Functions\Util_Split.sql"
        ,"LoggerBase\Functions\Configuration_Get_Properties.sql"
        ,"LoggerBase\Functions\VersionInfo.sql"
        ,"LoggerBase\Functions\Configuration_Set.sql"
        ,"LoggerBase\Functions\Configuration_Get.sql"
        # ,"LoggerBase\Functions\CorrelationId.sql"
        ,"Logger\Functions\Tokens_List.sql"
        ,"LoggerBase\Functions\DefaultErrorMessage.sql"
        
    ,"LoggerBase\Stored Procedures\Appender_File_Private_WriteTextFile.sql"
    ,"LoggerBase\Stored Procedures\Appender_File_Private_WriteTextFileWithMutex.sql"
        #,"LoggerBase\Stored Procedures\Session_ContextID_Set.sql"
        #,"LoggerBase\Stored Procedures\Session_Level_Set.sql"
        #,"LoggerBase\Stored Procedures\Session_Clear.sql"
        #,"LoggerBase\Stored Procedures\Session_Config_Set.sql"
        ,"LoggerBase\Stored Procedures\Layout_PatternLayout.sql"
        ,"LoggerBase\Stored Procedures\Layout_JSONLayout.sql"
        ,"LoggerBase\Stored Procedures\Config_Appenders_FilteredByLevel.sql"
        ,"LoggerBase\Stored Procedures\Config_Retrieve.sql"
        ,"LoggerBase\Stored Procedures\Config_Saved_Set.sql"
        ,"LoggerBase\Stored Procedures\Layout_FormatMessage.sql"
        ,"LoggerBase\Stored Procedures\Appender_MSSQLSQLDatabaseAppender_ExecNonTransactedQuery.sql"
        ,"LoggerBase\Stored Procedures\Appender_ConsoleAppender.sql"
        ,"LoggerBase\Stored Procedures\Appender_FileAppender.sql"
        ,"LoggerBase\Stored Procedures\Appender_FileAppender_MinimalLock.sql"
        ,"LoggerBase\Stored Procedures\Appender_MSSQLDatabaseAppender.sql"
        ,"LoggerBase\Stored Procedures\Appender_LocalDatabaseAppender.sql"
        ,"LoggerBase\Stored Procedures\Logger_Base.sql"
        ,"Logger\Stored Procedures\Debug.sql"
        ,"Logger\Stored Procedures\Error.sql"
        ,"Logger\Stored Procedures\Fatal.sql"
        ,"Logger\Stored Procedures\Info.sql"
        ,"Logger\Stored Procedures\Warn.sql"
        ,"Logger\Stored Procedures\Configure.sql"
        ,"Logger\Stored Procedures\CorrelationId.sql"
        ,"Logger\Stored Procedures\DefaultErrorMessage.sql"
        , "..\Build\InstallScriptFooter.sql"
      )

      $null | Set-Content $OutputFile

      foreach ($sqlFile in $sqlFiles)
      {
        Write-Host "Checking for file $sqlFile"
          if ($sqlFile -ilike "#*") {continue};
      
        $srcFile = $([System.IO.Path]::Combine($srcDirectory, "log4mssql\$sqlFile")) 
        if (! (Test-Path $srcFile)) {throw "$srcFile not found."}
          $Content = Get-Content $srcFile
          if ($Content -ne $null)
          {
              
              Write-Host "Writing to $OutputFile"
              $Content| Add-Content $OutputFile
              "GO" | Add-Content $OutputFile
          }
      }
  }

  task ApplyInstallScript -depends CreateDatabase{
    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -InputFile $OutputFile
  }

  task InstalltSQLt {
    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -InputFile $([System.IO.Path]::Combine($srcDirectory, "log4mssql\Tests\tSQLt\SetClrEnabled.sql"))
    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -InputFile $([System.IO.Path]::Combine($srcDirectory, "log4mssql\Tests\tSQLt\tSQLt.class.sql"))
  }

  task RunTests -depends InstalltSQLt{
    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -Query "EXEC tSQLt.NewTestClass 'loggerbasetests'" -Verbose -ErrorAction Stop
    foreach ($file in ((Get-ChildItem -Path ([System.IO.Path]::Combine($srcDirectory, "log4mssql\Tests\")) -Filter "loggerbasetests.*.sql")))
    {
      #Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -InputFile $([System.IO.Path]::Combine($srcDirectory, "log4mssql\Tests\LoggerTests.sql")) -Verbose -ErrorAction Stop
      Write-Host "[RunTests]: Applying file $($file.FullName)"
      Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -InputFile $file.FullName -Verbose -ErrorAction Stop
    }
    Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -Query "EXEC tSQLt.Run 'loggerbasetests'" -Verbose -ErrorAction Stop
    Import-Module Pester
    Invoke-Pester -Script @{Path ="$testsDirectory\LoggerTest.Appender.File.Tests.ps1"; Parameters = @{ buildDatabaseServer = $buildDatabaseServer; buildDatabaseName = $buildDatabaseName; testsDirectory = $testsDirectory }}
  } 