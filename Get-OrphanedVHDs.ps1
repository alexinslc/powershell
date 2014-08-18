# This script is used to find orphaned vhd and vhdx files.
# Set variables. NOTE: I'm currently using CSVs, I'll probably re-write this to just use variables.

$ActiveVHDs = "C:\Active_VHDs.csv" # Your first CSV Export
$AllVHDs = "C:\All_VHDs.csv" # Your second CSV Export
$DiffVHDs = "C:\Diff_VHDs.csv" # Your final CSV Export with Orphaned Disk Information
$Servers = @( "SERVER01", "SERVER02", "SERVER03" , "SERVER04") # An array of your hyper-v host servers.


# Get a list of all ACTIVE VHDS on the servers.
$ActiveVHDs = Get-VM –ComputerName $Servers | Get-VMHardDiskDrive | Select-Object -Property ComputerName, Path | Sort-Object -Property ComputerName | Export-Csv $ActiveVHDs -NoTypeInformation

# Get a list of all .vhd and .vhdx files on the servers.
$Result = @('"ComputerName", "Path"')
foreach ($server in $Servers) {
    # Get the vhd + vhdx files and Ignore Replicas Directory
    $HyperVFileLocation = ("\\" + $server + "\C$\HyperV") # Change this to match the location of where your VMs are stored.
    $Dir = Get-ChildItem $HyperVFileLocation -Recurse | Where {$_.FullName -notmatch "\\Replica\\?" } 
    $Paths = ($List1 = $Dir | Where { $_.Extension -eq ".vhd" }).FullName + ($List2 = $Dir | Where { $_.Extension -eq ".vhdx" }).FullName
    # You may have to edit this string manipulation for your specific file locations.
    foreach ($path in $Paths) {
        $Split = $path.split("$")
        $NewPath = $Split[0].substring(($Split[0].length)-1,1) + ":" + $Split[1]
        $Result += '"' + $server + '","' + $NewPath + '"'
    }
}
$Result | Out-File $AllVHDs

# Compare the files. Anything on the => side *should* be an Orphaned VHD(x) File.
(Compare-Object (Get-Content $ActiveVHDs) (Get-Content $AllVHDs)) | Export-CSV $DiffVHDs -NoTypeInformation
