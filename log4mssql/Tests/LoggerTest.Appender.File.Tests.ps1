# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

param($buildDatabaseServer,$buildDatabaseName, $testsDirectory)

$outputTestFile = [System.IO.Path]::Combine($testsDirectory, "FileAppenderTest.txt")
function Write-FileUsingSql
{
    if (Test-Path $outputTestFile) {Remove-Item -Path $outputTestFile}
    $Query = "SELECT [LoggerBase].[Appender_File_WriteTextFile]('Just a test message', '$outputTestFile', 0)"
    # Write-Host "Executing query: $Query"
    $Result = Invoke-Sqlcmd -ServerInstance $buildDatabaseServer -Database $buildDatabaseName -Query $Query -IncludeSqlUserErrors -ErrorAction Continue

    if ($Result -eq $null)
    {
        Write-Host "Query returned null indicating an error. Please make sure that the SQL Server Instance user has read/write privileges to the '$testsDirectory'." -ForeGroundColor yellow
    }

}

function Test-FileUsingSql
{
    # Write-Host "Running Appender_File_WriteTextFile"
    Write-FileUsingSql
    # Write-Host "Checking for $outputTestFile"
    return Test-Path $outputTestFile
}

Describe "LoggerTest.Appender.File" {
    It "Writes a file to disk." {
        Test-FileUsingSql | Should Be $true
    }
}
