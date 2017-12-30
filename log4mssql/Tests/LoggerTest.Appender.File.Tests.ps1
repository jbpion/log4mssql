# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

param($buildDatabaseServer,$buildDatabaseName, $testsDirectory)

$outputTestFile = [System.IO.Path]::Combine($testsDirectory, "FileAppenderTest.txt")
function Write-FileUsingSql
{
    if (Test-Path $outputTestFile) {Remove-Item -Path $outputTestFile}
    function Write-FileUsingSql
    ($buildDatabaseServer, $buildDatabaseName, $outputTestFile)
    {
        if (Test-Path $outputTestFile) {Remove-Item -Path $outputTestFile}
    
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server=$buildDatabaseServer;Database=$buildDatabaseName;Integrated Security=True"
        $SqlCmd = $SqlConnection.CreateCommand();
        $SqlCmd.CommandText = "LoggerBase.Appender_File_Private_WriteTextFile"
        $SqlCmd.Connection = $SqlConnection
        $SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;
    
        $txtParameter = New-Object System.Data.SqlClient.SqlParameter;
        $txtParameter.ParameterName = "@text";
        $txtParameter.Direction = [System.Data.ParameterDirection]::Input;
        $txtParameter.DbType = [System.Data.DbType]::String
        $txtParameter.Size = 4000;
        $SqlCmd.Parameters.AddWithValue($txtParameter, "Test Message!")| Out-Null;
    
        $pthParameter = New-Object System.Data.SqlClient.SqlParameter;
        $pthParameter.ParameterName = "@path";
        $pthParameter.Direction = [System.Data.ParameterDirection]::Input;
        $pthParameter.DbType = [System.Data.DbType]::String
        $pthParameter.Size = 4000;
        $SqlCmd.Parameters.AddWithValue($pthParameter, $outputTestFile)#| Out-Null;
    
        $apdParameter = New-Object System.Data.SqlClient.SqlParameter;
        $apdParameter.ParameterName = "@append";
        $apdParameter.Direction = [System.Data.ParameterDirection]::Input;
        $apdParameter.DbType = [System.Data.DbType]::Boolean
        $SqlCmd.Parameters.AddWithValue($apdParameter,0)| Out-Null;
    
        $extParameter = New-Object System.Data.SqlClient.SqlParameter;
        $extParameter.ParameterName = "@exitCode";
        $extParameter.Direction = [System.Data.ParameterDirection]::Output;
        $extParameter.DbType = [System.Data.DbType]::Int32
        $SqlCmd.Parameters.Add($extParameter)| Out-Null;
    
        $ermParameter = New-Object System.Data.SqlClient.SqlParameter;
        $ermParameter.ParameterName = "@errorMessage";
        $ermParameter.Direction = [System.Data.ParameterDirection]::Output;
        $ermParameter.DbType = [System.Data.DbType]::String
        $ermParameter.Size = 4000;
        $SqlCmd.Parameters.Add($ermParameter)| Out-Null;
    
        $SqlConnection.Open();
    
        $result = $SqlCmd.ExecuteNonQuery();
        #$truth = $SqlCmd.Parameters["@answer"].Value;
        Write-Host $SqlCmd.Parameters["@errorMessage"].Value;
        Write-Host "@path: $($SqlCmd.Parameters["@path"])"
        $SqlConnection.Close();
    }

    # if ($Result -eq $null)
    # {
    #     Write-Host "Query returned null indicating an error. Please make sure that the SQL Server Instance user has read/write privileges to the '$testsDirectory'." -ForeGroundColor yellow
    # }

}

function Test-FileUsingSql
{
    # Write-Host "Running Appender_File_WriteTextFile"
    Write-FileUsingSql -buildDatabaseServer $buildDatabaseServer -buildDatabaseName $buildDatabaseName -outputTestFile $outputTestFile
     Write-Host "Checking for $outputTestFile"
    return Test-Path $outputTestFile
}

Describe "LoggerTest.Appender.File" {
    It "Writes a file to disk." {
        Test-FileUsingSql | Should Be $true
    }
}
