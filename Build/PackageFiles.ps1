$StartingFolder = "C:\Working\Projects\log4mssql"
$Files = @(
    "``[SCHEMA``] Logger.sql",
    "``[SCHEMA``] LoggerBase.sql",
    "``[FUNCTION``] LoggerBase_Layout_GetDate.sql",
    "``[FUNCTION``] LoggerBase_Layout_LoginUser.sql",
    "``[PROCEDURE``] LoggerBase_Layout_PatternLayout.sql",
    "``[PROCEDURE``] LoggerBase_Layout_FormatMessage.sql"
)
#(dir $StartingFolder -Recurse -Include "*SCHEMA*")[0].FullName
$OutputFile = "C:\Working\Projects\log4mssql\Build\log4mssql.sql"

$null | Set-Content $OutputFile

foreach ($File in $Files)
{
    #Write-Host $file
    #$FileToFind = "$StartingFolder\*\$File";
    #$FileInfo = dir -Path $FileToFind -Recurse
    #$File = $File.Replace(" ", "*")
    
    $File
    $FileInfo = Get-ChildItem $StartingFolder -Recurse -Include "$File"
    #$FileInfo.Equals($null)
    if ($FileInfo -eq $null) {Write-Host "Unable to find file $File." -ForegroundColor Red; Break;}
    $File = $($FileInfo.FullName).Replace("[", "````[")
    $File = $File.Replace("]", "````]")
    Get-Content $File | Add-Content $OutputFile;
    "GO" | Add-Content $OutputFile
}

#Get-Content "C:\Working\Projects\log4mssql\log4mssql\/[SCHEMA/] Logger.sql"


