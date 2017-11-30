properties {
    $testMessage = 'Executed Test!'
    $compileMessage = 'Executed Compile!'
    $cleanMessage = 'Executed Clean!'
    $buildDatabaseServer = "localhost"
    $buildDatabaseName = "Log4MSSQLBuild"
    $buildDatabaseDataFilePath = "C:\MSSQL\Data"
    $buildDatabaseLogFilePath = "C:\MSSQL\Logs"
    $srcDirectory = "C:\Users\jpion\Documents\GitHub\log4mssql"
    $buildDirectory = [System.IO.Path]::Combine($srcDirectory, "Build");
    $installScriptName = "log4mssql_install.sql"
    $OutputFile = [System.IO.Path]::Combine($buildDirectory, $installScriptName);
  }

  task default

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

      $createDatabaseQuery = [string]::Format("CREATE DATABASE [Log4MSSQLBuild]
      CONTAINMENT = NONE
      ON  PRIMARY 
     ( NAME = N'Log4MSSQLBuild', FILENAME = N'C:\MSSQL\Data\Log4MSSQLBuild\Log4MSSQLBuild.mdf' , SIZE = 4096KB , FILEGROWTH = 1024KB )
      LOG ON 
     ( NAME = N'Log4MSSQLBuild_log', FILENAME = N'C:\MSSQL\Logs\Log4MSSQLBuild\Log4MSSQLBuild_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
     GO
     ALTER DATABASE [Log4MSSQLBuild] SET COMPATIBILITY_LEVEL = 120
     GO
     ALTER DATABASE [Log4MSSQLBuild] SET RECOVERY SIMPLE 
     GO"
      )

      Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database master -Query $createDatabaseQuery
    
  }

  task CompileCLRAssembly {
    "C:\Users\jpion\Documents\GitHub\log4mssql\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.cs"
    c:\Windows\microsoft.net\Framework\v3.5\csc.exe /target:library /out:"C:\Users\jpion\Documents\GitHub\log4mssql\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.dll" "C:\Users\jpion\Documents\GitHub\log4mssql\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.cs"
  }

  task RegisterAssemblyWithDatabase -depends CompileCLRAssembly, CreateDatabase {
      $assemblyRegistrationQuery = "
      USE $buildDatabaseName
      GO
      ALTER DATABASE $buildDatabaseName SET TRUSTWORTHY ON
      GO
      
      CREATE ASSEMBLY log4mssql
      FROM 'C:\Users\jpion\Documents\GitHub\log4mssql\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.dll'
      WITH PERMISSION_SET = EXTERNAL_ACCESS
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
      IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'log4mssql' and is_user_defined = 1)
      DROP ASSEMBLY [log4mssql]
      GO
      
      CREATE ASSEMBLY [log4mssql]
      FROM $fileByteString
      WITH PERMISSION_SET = EXTERNAL_ACCESS
      GO
      "

      $assemblyScript | Set-Content C:\Users\jpion\Documents\GitHub\log4mssql\log4mssql\LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.sql

  }

  task CreateInstallScript -depends ScriptAssemblyFromDatabase {
      $sqlFiles = @(
        "..\Build\InstallScriptHeader.sql"
        ,"Security\Logger.sql"
        ,"Security\LoggerBase.sql"
        ,"LoggerBase\Assemblies\LoggerBase_Exec_Non_Transacted_Query.sql"
        ,"LoggerBase\Tables\Config_Saved.sql"
        ,"LoggerBase\Tables\Config_SessionContext.sql"
        ,"LoggerBase\Tables\Core_Level.sql"
        ,"LoggerBase\TableData\Populate Table LoggerBase_Config_Saved.sql"
        ,"LoggerBase\Functions\Config_Appenders_Get.sql"
        ,"LoggerBase\Functions\Core_Level_RetrieveFromSession.sql"
        ,"LoggerBase\Functions\Layout_GetConversionPatternFromConfig.sql"
        ,"LoggerBase\Functions\Layout_GetDate.sql"
        ,"LoggerBase\Functions\Layout_LoginUser.sql"
        ,"LoggerBase\Functions\Session_ContextID_Get.sql"
        ,"LoggerBase\Functions\Session_Level_Get.sql"
        ,"LoggerBase\Functions\Config_Layout.sql"
        ,"LoggerBase\Functions\Config_RetrieveFromSession.sql"
        ,"LoggerBase\Functions\Config_Root_Get.sql"
        ,"LoggerBase\Stored Procedures\Session_ContextID_Set.sql"
        ,"LoggerBase\Stored Procedures\Session_Level_Set.sql"
        ,"LoggerBase\Stored Procedures\Session_Clear.sql"
        ,"LoggerBase\Stored Procedures\Session_Config_Set.sql"
        ,"LoggerBase\Stored Procedures\Layout_PatternLayout.sql"
        ,"LoggerBase\Stored Procedures\Config_Appenders_FilteredByLevel.sql"
        ,"LoggerBase\Stored Procedures\Config_Retrieve.sql"
        ,"LoggerBase\Stored Procedures\Layout_FormatMessage.sql"
        ,"LoggerBase\Stored Procedures\Appender_MSSQLSQLDatabaseAppender_ExecNonTransactedQuery.sql"
        ,"LoggerBase\Stored Procedures\Appender_ConsoleAppender.sql"
        ,"LoggerBase\Stored Procedures\Appender_MSSQLDatabaseAppender.sql"
        ,"LoggerBase\Stored Procedures\Logger_Base.sql"
        ,"Logger\Stored Procedures\Debug.sql"
        ,"Logger\Stored Procedures\Error.sql"
        ,"Logger\Stored Procedures\Fatal.sql"
        ,"Logger\Stored Procedures\Info.sql"
        ,"Logger\Stored Procedures\Warn.sql"
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