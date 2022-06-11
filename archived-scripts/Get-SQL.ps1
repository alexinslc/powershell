<#
This script allows you to query data from a Microsoft SQL server and returns the query as a System.Data.DataTable Object in PowerShell.

WARNING: This script allows SQL injection. You should NEVER expose this publically.

Usage: Get-SQL -SQLQuery "SELECT * FROM TABLENAME" -SQLServer "SQL SERVER" -Database "DATABASE NAME" -Username "SQL USERNAME" -Password "SQL PASSWORD"

#>

function Get-SQL()
{
    param(
        [Parameter(mandatory=$true)][string]$SQLQuery,
        [parameter(mandatory=$true)][string]$SQLServer,
        [parameter(mandatory=$true)][string]$Database,
        [parameter(mandatory=$true)][string]$UserName,
        [parameter(mandatory=$true)][string]$Password
    )
    try{
        $connectionString = “Server=$SQLServer;Database=$Database;User=$UserName;Password=$Password;Integrated Security=False;”
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = $connectionString


        
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = $SQLQuery
        $data = $command.ExecuteReader()
        $result = New-Object System.Data.DataTable
        $result.Load($data)
        
        if ($result.Rows.Count -eq 0){throw "Query:`n $query `n`nReturned no results."}
        
        $connection.Close()               
        return $result
    }
    catch
    {
        $connection.Close()
        Write-Warning $_
        return $null
    }
}