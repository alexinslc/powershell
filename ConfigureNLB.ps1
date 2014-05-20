<#
 
 .SYNOPSIS
 Create and Configure Network Load Balancer 
 
 .DESCRIPTION
 This script creates and configures a Network Load Balancer.
 
 .PARAMETER ComputerName
 Required, String: The name of the computer to configure the NLB on. "YOURCOMPUTER"

 .PARAMETER ClusterName
 Required, String: The name of the NLB cluster.  "cluster01.contoso.com"

 .PARAMETER Interface
 Required, Interface Object: The interface object to setup the NLB on.

 .PARAMETER VirtualIP
 Required, The Virtual IP of the NLB to be configured. "192.168.0.50"

 .PARAMETER SubnetMask
 Required, The Subnetmask of the NLB to be configured. "255.255.255.0"

 .PARAMETER Port
 Required, Integer: The port number to run the NLB on. 8888

 .EXAMPLE
 ConfigureNLB -ComputerName "YOURCOMPUTER" -ClusterName "cluster01.contoso.com" -Interface $Interface -VirtualIP "192.168.0.50" -SubnetMask "255.255.255.0" -Port 8888
 
  .NOTES
 Author: Alex Lutz
 Date: 5/13/2014

 #>
function ConfigureNLB() {
    param(
        [Parameter(Mandatory=$false)][string]$ComputerName = $env:ComputerName,
        [Parameter(Mandatory=$true)][string]$ClusterName,
        [Parameter(Mandatory=$true)]$Interface,
        [Parameter(Mandatory=$true)][string]$VirtualIP,
        [Parameter(Mandatory=$true)][string]$SubnetMask,
        [Parameter(Mandatory=$true)][int]$Port
    )
    
    try {

    Import-Module NetworkLoadBalancingClusters

    # If the cluster hasn't been created yet then create it
    if (!(Get-NlbCluster -HostName $VirtualIP -ErrorAction SilentlyContinue))
    {
        # Create Cluster 
        New-NlbCluster -InterfaceName $Interface.Name -ClusterName $ClusterName -ClusterPrimaryIP $VirtualIP -SubnetMask $SubnetMask

        # Remove defaults
        Get-NlbClusterPortRule | Remove-NlbClusterPortRule -Force

        # Create port rules
        Get-NlbCluster | Add-NlbClusterPortRule -StartPort $Port -EndPort $Port -Protocol TCP -Affinity None | Out-Null

    }


    # if this node isn't already a member of a cluster then add it
    if(!(Get-NlbClusterNode -HostName $ComputerName))
    {
        # Add node to cluster
        Get-NlbCluster -HostName $VirtualIP | Add-NlbClusterNode -NewNodeName $ComputerName -NewNodeInterface $Interface.Name
    }    
    
    } catch {
      Write-Warning $_
    }
}
