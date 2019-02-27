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
  $buildDatabaseName = "Log4MSSQLBuildRemote"
  $buildDatabaseDataFilePath = "C:\MSSQL\Data"
  $buildDatabaseLogFilePath = "C:\MSSQL\Logs"
  $srcDirectory = "\\nisa.local\nisa\Users\jpion001\Projects\OpenSource\log4mssql"
  $buildDirectory = [System.IO.Path]::Combine($srcDirectory, "Build");
  $testsDirectory = "$buildDirectory\..\log4mssql\Tests";
  $installScriptName = "log4mssql_remoteinstall.sql"
  $OutputFile = [System.IO.Path]::Combine($buildDirectory, $installScriptName);
}

task default -depends Build

task Build  -depends CreateInstallScript, ApplyInstallScript{

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



  task CreateInstallScript -depends CreateDatabase {
      $sqlFiles = @(
        "..\Build\InstallScriptHeaderRemote.sql"
        ,"Types\LogConfiguration.sql"
        ,"Types\TokenValues.sql"
        ,"Logger\Stored Procedures\Debug.sql"
        ,"Logger\Stored Procedures\Error.sql"
        ,"Logger\Stored Procedures\Fatal.sql"
        ,"Logger\Stored Procedures\Info.sql"
        ,"Logger\Stored Procedures\Warn.sql"
        , "..\Build\InstallScriptFooterRemote.sql"
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

  