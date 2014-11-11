<# 

This script does the following: 
1. Finds Installed Programs 
2. Finds Installed Programs Versions.
3. Find a specific program's version that is Installed.
4. Find for x32/x64 Installed Programs.

.EXAMPLE
# Get a list of all x32 installed programs and their versions.
Get-InstalledPrograms -ComputerName "MyComputer"

# Get a list of all x64 installed programs and their versions.
Get-InstalledPrograms -ComputerName "MyComputer" -Checkx64

# Get the specified x32 program's version.
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram"

# Get the specified x64 program's version. 
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram" -Checkx64

#>

function Get-InstalledPrograms() {
    param(
         [Parameter(mandatory=$true)][string]$ComputerName,
         [Parameter(mandatory=$false)][bool]$Checkx64 = $false,
         [Parameter(mandatory=$false)][string]$ProgramName
    )
    try {
        # Set some variables
        $Reg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $Regx64 = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        # Only check for the specified Installed Program.
        if ($ProgramName) {
            $Scriptblock = {
                param($ProgramName,$Reg,$Regx64,$Checkx64)
                # Check for x64 Installed Program.
                if ($Checkx64) {
                    Get-ItemProperty $Regx64 | Where-Object -Property DisplayName -EQ $ProgramName | Sort-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                }
                # Check for x32 Installed Program.
                else {
                    Get-ItemProperty $Reg | Where-Object -Property DisplayName -EQ $ProgramName | Sort-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                }
            }
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $Scriptblock -ArgumentList @($ProgramName,$Reg,$Regx64,$Checkx64)
        }
        # Check for ALL Installed Programs.
        else {
            $Scriptblock = {
                param($Reg,$Regx64,$Checkx64)
                # Check for x64 Installed Programs.
                if ($Checkx64) {
                    Get-ItemProperty $Regx64 | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                }
                # Check for x32 Installed Programs.
                else {
                    Get-ItemProperty $Reg | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                }
            }
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $Scriptblock -ArgumentList @($Reg,$Regx64,$Checkx64)
        }
    }
    catch {
        Write-Warning $_
    }
}