<#
 
 .SYNOPSIS
 Retrieves the NetAdapters in binding order for a Server 2012 + Host (local or remote)
 
 .DESCRIPTION

 This script outputs an array of NetAdapter Objects in the order they are bound.
 .PARAMETER ComputerName

 .EXAMPLE
 
 .\Get-NICBindings.ps1 -ComputerName "TESTBOX.contoso.local"   
 
 #>

function Get-NICBindings() {
 param(
    [string]$ComputerName = $env:ComputerName
 )
 
 
 
 $bindings = Invoke-Command -ComputerName $ComputerName -ScriptBlock { (get-itemproperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage").bind }
 $returnobj = new-object PSobject
 [array]$bindingorder = $null
 foreach ($bind in $bindings)
 {
  $deviceid = $bind.split("\")[2]
  $adapter = (get-netadapter -CimSession $ComputerName |where {$_.DeviceID -eq $deviceid})
  $bindingorder += $adapter
 }

  return $bindingorder
}