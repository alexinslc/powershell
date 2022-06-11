<#
 
 .SYNOPSIS
 Adds the necessary SMB Shares on HyperV Hosts to allow VMs to live on UNC Shares
 
 .DESCRIPTION
 This script takes an array of HyperV hostnames and adds the necessary SMB share to each HyperV Server and allows all other HyperV servers to access all the Shares
 
 .PARAMETER domainName
 Required, String: The domain name: "MyDomain.local"

 .PARAMETER hvServers
 Required, Array of Strings: The list of Hyper-V Servers to add the SMB shares to: @("HVServer01","HVServer02","HVServer03")

 .PARAMETER hvAdmin
 Required, String: Name of the Domain account that should have full rights to the shares.

 .EXAMPLE
 Set-SMBShares -domainName "MyDomain.local" -hvServers @("HVServer01","HVServer02","HVServer03") -hvAdmin "HVAdmin" 
 
  .NOTES
 Author: Jordan Gillespie
 Date: 5/14/2014

 #>

function Set-SMBShares() {
    param(
        [Parameter(mandatory=$true)][string]$domainName,
        [Parameter(mandatory=$true)]$hvServers,
        [Parameter(mandatory=$true)][string]$hvAdmin
    )

    try{ 
        #Validate that all servers are in Active Directory
        $errTag = $false
        Foreach ($server in $hvServers)
        {
           $error.Clear()
           $trash = Get-ADComputer $server
           If ($error.length -ge 1)
           {
              Write-Warning "Server $server is not found in Active Directory"
              $errTag = $true
           }
        }
  
        If ($errTag) {Throw "Errors detected. Run aborted."}
  
        $accessList = $domainName + "\" + $hvAdmin
        Foreach ($hvServer in $hvServers)
        {
            $accessList += ', ' + $domainName + '\' + $hvServer + '$'
        }

        Foreach ($hvServer in $hvServers)
        {
            $error.Clear()
            $path = '\\' + $hvServer + '\e$\HyperV\'
            if (!(Test-Path -Path $path)) { New-Item $path -ItemType Directory }
            Invoke-Command -ComputerName $hvServer -ScriptBlock ([scriptblock]::Create("New-SMBShare -Name HyperV -Path E:\HyperV -FullAccess $accessList"))
            Invoke-Command -ComputerName $hvServer -ScriptBlock { 'Set-SmbPathAcl -Name HyperV' }
            If ($error.length -ge 1)
            {
               Write-Warning "Failed to create share or set permissions on share on $server"
               $errTag = $true
            }
        }

        If ($errTag) {Throw "Errors detected. Run aborted."}

        Return $true
    }
    catch{
        Write-Host -ForegroundColor Red $_
        Return $null
    }
}