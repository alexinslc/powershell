function ConfigureNLB() {
    param(
        [Parameter(Mandatory=$true)][string]$ComputerName = $env:ComputerName,
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

    }
}