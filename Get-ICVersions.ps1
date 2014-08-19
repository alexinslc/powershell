# This script will provide a list to compare your Hyper-V Integration Component Versions (VM vs Host)
# NOTE: This script only works with Hyper-V 2012 R2 and PowerShell v4

$Servers = @( "SERVER01", "SERVER02", "SERVER03") # Add your server names here!
$VMs = Get-VM –ComputerName $Servers # Set the VMs Variable
$Results = @() # Define an empty array to dump your completed object to.
foreach ($vm in $VMs) {
    $filter = ("ElementName=" + "'" + $vm.Name + "'")
    $VMWMI = gwmi -ComputerName $vm.ComputerName -namespace root\virtualization\v2 Msvm_ComputerSystem -filter $filter
    # Get the associated KVP Exchange Component
    $query = ("Associators of {$VMWMI} where ResultClass=Msvm_KvpExchangeComponent")
    $kvp = gwmi -ComputerName $vm.ComputerName -namespace root\virtualization\v2 -query $query

    # Pull the Guest Intrinsic Exchange Items from XML into a hash
    $kvpHash = @{}
    if($kvp.GuestIntrinsicExchangeItems){
        $xmlContents = ([xml]("<xml>"+$kvp.GuestIntrinsicExchangeItems+"</xml>"))
        foreach($instance in $xmlContents.xml.INSTANCE)
        { 
            $name = $instance.PROPERTY | where {$_.NAME -eq "Name"}
            $data = $instance.PROPERTY | where {$_.NAME -eq "Data"}
            $kvphash.add($name.Value,$data.Value)
        }
    }
    # Save the VM's version
    $icVersionGuest = $kvpHash.IntegrationServicesVersion
    # Save the Hosts's version
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $vm.ComputerName)
    $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Virtualization\\GuestInstaller\\Version")
    $icVersionHost = $RegKey.GetValue("Microsoft-Hyper-V-Guest-Installer-Win6x-Package")
    # Build Object for Viewing and add it to empty array.
    $ResultObject = New-Object System.Object
    $ResultObject | Add-Member -MemberType NoteProperty -Name VM -Value $vm.Name
    $ResultObject | Add-Member -MemberType NoteProperty -Name Host -Value $vm.ComputerName
    $ResultObject | Add-Member -MemberType NoteProperty -Name VM-Version -Value $icVersionGuest
    $ResultObject | Add-Member -MemberType NoteProperty -Name Host-Version -Value $icVersionHost
    $Results += $ResultObject
}
$Results | Out-GridView -Title "Integration Component Versions"
