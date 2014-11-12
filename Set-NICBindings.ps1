<#

 .SYNOPSIS
 Sets the NIC Bindings for a Server 2012 Host (local or remote)

 .DESCRIPTION

 This script sets NIC's TCPIP Binding order according to the passed NetAdapter Objects in the order of the array.
 .PARAMETER ComputerName

 .EXAMPLE

 .\Set-NICBindings.ps1 -ComputerName "MyComputer" -NewBinding @($nic1,$nic2)

 #>

function Set-NICBindings() {
param(
   [string]$ComputerName = $env:ComputerName,
   [Parameter(mandatory=$true)]$NewBinding
)
    [array]$bindings = $null
    foreach ($bind in $NewBinding){

        $bindings += ("\Device\" + $bind.DeviceID)

    }
    $scriptblock = [scriptblock]::Create( 'Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage" -Name Bind -Value "' + $bindings + '"')
    Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptblock
}
