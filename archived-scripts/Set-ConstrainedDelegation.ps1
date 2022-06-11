<#
 
 .SYNOPSIS
 Adds the necessary AD delegation rights to HyperV Hosts to allow SMB, Live Migration and Replication
 
 .DESCRIPTION
 This script takes an array of HyperV hostnames and SMB Server hostnames and adds the necessary AD constrained delegation rights to each HyperV Server object in AD to allow for SMB. Additional parameters add the Live Migration Delegation and the Hyper-V Replica Delegation rights.
 
 .PARAMETER adPath
 Required, String: The AD path for the domain: "DC=MyDomain,DC=local"

 .PARAMETER hvServersGroup
 Required, String: The AD Name for the Hyper-V Hosts Computer Security Group: "HyperV-Hosts"

 .PARAMETER hvServers
 Required, Array of Strings: The list of Hyper-V Servers to add the delegation rights to in AD: @("HVServer01","HVServer02","HVServer03")

 .PARAMETER smbServers
 Required, Array of Strings: The list of SMB Servers that will be allowed to have delegation rights in AD: @("SMBServer01","SMBServer02")

 .PARAMETER EnableLiveMigration
 Optional, Boolean, default = true. Whether or not to set the Live Migration Delegation

 .PARAMETER EnableReplication
 Optional, Boolean, default = true. Whether or not to set the Hyper-V Replication Delegation

 .EXAMPLE
 Set-ConstrainedDelegation -adPath "DC=MyDomain,DC=local" -hvServersGroup "HyperV-Hosts" -hvServers @("HVServer01","HVServer02","HVServer03") -smbServers @("SMBServer01","SMBServer02") -EnableReplication $false 
 
  .NOTES
 Author: Jordan Gillespie
 Date: 5/13/2014

 #>

function Set-ConstrainedDelegation() {
    param(
        [Parameter(mandatory=$true)][string]$adPath,
        [Parameter(mandatory=$true)][string]$hvServersGroup,
        [Parameter(mandatory=$true)]$hvServers,
        [Parameter(mandatory=$true)]$smbServers,
        [boolean]$EnableLiveMigration = $true,
        [boolean]$EnableReplication = $true
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
 
        Foreach ($server in $smbServers)
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
 
        # Find if HyperV Server group exists in AD.  If not, add it.
        $tmp1 = Get-AdGroup -Filter {Name -eq $hvServersGroup}
        If ($tmp1 -eq $null)
        {
           $error.Clear()
           New-ADGroup -Name $hvServersGroup -DisplayName $hvServersGroup -GroupScope Global -GroupCategory Security -Path "CN=Users,$adPath" -Description "Hyper-V Servers"
           Write-Host "$hvServersGroup did not exist in Active Directory; it was added"
           If ($error.length -ge 0) {Throw "Error adding AD group $hvServersGroup - aborting" }
        }
 
        # Add Hyper-V servers to group if not already in Hyper-V Server group
        $errTag = $false
        Foreach ($server in $hvServers)
        {
          $hvServersAD = @(Get-ADGroupMember -Identity $hvServersGroup)
           If ($hvServersAD.count -lt 1) { Add-ADGroupMember -Identity $hvServersGroup -Members (Get-ADComputer -Identity $server) }
           Else
           {
               For ($hvCnt = 0; $hvCnt -lt $hvServersAD.count; $hvCnt++)
               {
                   $error.Clear()
                   If (!($server -in $hvServersAD.Name))
                   {
                       Add-ADGroupMember -Identity $hvServersGroup -Members (Get-ADComputer -Identity $server)
                   }
                   If ($error.length -ge 1)
                   {
                       Write-Warning "Error adding $server to AD Group $hvServersGroup"
                       $errTag = $true
                   }
                }
            }
        }
 
        If ($errTag) { Throw "Errors detected adding members to group $hvServersGroup - aborting" }
 
        Foreach ($smbServer in $smbServers)
        {
            $smbServerAD = Get-ADComputer $smbServer
            $AllowedToDelegateToSMB = @(
                ("cifs/"+$smbServerAD.Name),
                ("cifs/"+$smbServerAD.DNSHostName))
 
            $hvServersAD = Get-ADGroupMember -Identity $hvServersGroup
            For ($srvCnt = 0; $srvCnt -lt $hvServersAD.count; $srvCnt++)
            {
                $AllowedToDelegateTo = $AllowedToDelegateToSMB
                If ($EnableLiveMigration)
                {
                    For ($delCNT = 0; $delCNT -lt $hvServersAD.count; $delCNT++)
                    {
                        If ($delCNT -ne $srvCnt)
                        {
                            $delegationServer = $HvServersAD[$delCNT] | Get-ADComputer
                            $AllowedToDelegateTo += @(
                                ("Microsoft Virtual System Migration Service/"+$delegationServer.Name),
                                ("Microsoft Virtual System Migration Service/"+$delegationServer.DNSHostName))      
                        }
                    }
                }
                If ($EnableReplication)
                {
                    For ($delCNT = 0; $delCNT -lt $hvServersAD.count; $delCNT++)
                    {
                        If ($delCNT -ne $srvCnt)
                        {
                            $delegationServer = $HvServersAD[$delCNT] | Get-ADComputer
                            $AllowedToDelegateTo += @(
                                ("Hyper-V Replica Service/"+$delegationServer.Name),
                                ("Hyper-V Replica Service/"+$delegationServer.DNSHostName))      
                        }
                    }        
                }
                ($hvServersAD[$srvCnt] | Get-ADComputer) | Set-ADObject -Add @{"msDS-AllowedToDelegateTo"=$AllowedToDelegateTo}
            }
        }
        Return $true
    }
    catch{
        Write-Host -ForegroundColor Red $_
        Return $null
    }
}