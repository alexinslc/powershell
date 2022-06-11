# powershell.scripts
PowerShell scripts [@alexinslc](https://twitter.com/alexinslc)(me) and other coworkers have created for various [#sysadmin](https://twitter.com/search?q=%23sysadmin) and [#devops](https://twitter.com/search?q=%23devops) tasks.  


* [script.descriptions](https://github.com/alexinslc/powershell#scriptdescriptions)
* [older.script.descriptions](https://github.com/alexinslc/powershell#olderscriptdescriptions)
* [script.todos](https://github.com/alexinslc/powershell#scripttodos)


## script.descriptions
**Please NOTE**: Most of these scripts are verified using MacOS Big Sur, Windows 11, and PowerShell v7.2.1
| Script                          | Description                                                                    |
|---------------------------------|--------------------------------------------------------------------------------|
| [Invoke-DevSetup.ps1]      | Quick setup script for a laptop supports Win/Mac and many package managers |


## older.script.descriptions
**Please NOTE**: These older scripts are verified using Windows 8 / 2012 R2 and PowerShell v4+ and I should probably test / refactor them.
| Script                          | Description                                                          |
|---------------------------------|----------------------------------------------------------------------|
| [Get-InstalledPrograms.ps1]     | Get a list of installed programs, versions, (x32, x64, or both.)     |
| [Posh-MissyWix.ps1]             | Create .msi files using the [WiX Toolset] and PowerShell.            |
| [Get-OrphanedVHDs.ps1]          | Find orphaned VHD(x) Files.                                          |
| [Invoke-SSHCommand.ps1]         | Run SSH Commands via PowerShell to Linux boxes.                      |
| [ConfigureNLB.ps1]              | Create and Configure MS Network Load Balancer.                       |
| [Test-IsAwake.ps1]              | Test if a computer is awake via PowerShell, SMB Share, or SSH.       |
| [Get-NICBindings.ps1]           | Get an array of Network Adapters (objects) in Binding order.         |
| [Set-NICBindings.ps1]           | Set the binding order of Network Adapters.                           |
| [Send-Email.ps1]                | Send an e-mail. (For PowerShell v2)                                  |
| [Set-ServiceCreds.ps1]          | Set the credentials on a Windows Service.                            |
| [Set-ConstrainedDelegation.ps1] | Enable Hyper-V Host SMB, Live Migration, and Replication rights.     |
| [Set-SMBShares.ps1]             | Add SMB Shares on Hyper-V Hosts to allow VMs to live on UNC shares.  |
| [Get-SQL.ps1]                   | Query a MS SQL Server with PowerShell.                               |
| [ConvertTo-MacAddress.ps1]      | Add a delimiter to raw MacAddress.                                   |
| [Get-ICVersions.ps1]            | Get list of Integration Component Versions on Hyper-V 2012 +         |

<!-- Links for the table -->
[Get-InstalledPrograms.ps1]: https://github.com/alexinslc/powershell/blob/master/Get-InstalledPrograms.ps1
[Posh-MissyWix.ps1]: https://github.com/alexinslc/powershell/blob/master/Posh-MissyWix.ps1
[Get-OrphanedVHDs.ps1]: https://github.com/alexinslc/powershell/blob/master/Get-OrphanedVHDs.ps1
[Invoke-SSHCommand.ps1]: https://github.com/alexinslc/powershell/blob/master/Invoke-SSHCommand.ps1
[ConfigureNLB.ps1]: https://github.com/alexinslc/powershell/blob/master/ConfigureNLB.ps1
[Test-IsAwake.ps1]: https://github.com/alexinslc/powershell/blob/master/Test-IsAwake.ps1
[Get-NICBindings.ps1]: https://github.com/alexinslc/powershell/blob/master/Get-NICBindings.ps1
[Set-NICBindings.ps1]: https://github.com/alexinslc/powershell/blob/master/Set-NICBindings.ps1
[Send-Email.ps1]: https://github.com/alexinslc/powershell/blob/master/Send-Email.ps1
[Set-ServiceCreds.ps1]: https://github.com/alexinslc/powershell/blob/master/Set-ServiceCreds.ps1
[Set-ConstrainedDelegation.ps1]: https://github.com/alexinslc/powershell/blob/master/Set-ConstrainedDelegation.ps1
[Set-SMBShares.ps1]: https://github.com/alexinslc/powershell/blob/master/Set-SMBShares.ps1
[Get-SQL.ps1]: https://github.com/alexinslc/powershell/blob/master/Get-SQL.ps1
[ConvertTo-MacAddress.ps1]: https://github.com/alexinslc/powershell/blob/master/ConvertTo-MacAddress.ps1
[Get-ICVersions.ps1]: https://github.com/alexinslc/powershell/blob/master/Get-ICVersions.ps1
[Invoke-DevSetup.ps1]: https://github.com/alexinslc/powershell/blob/master/Invoke-DevSetup.ps1
