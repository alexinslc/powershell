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

# Get a list of all installed programs both x32/x64 and their versions.
Get-InstalledPrograms -ComputerName "MyComputer" 

# Get the specified x32 program's version.
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram"

# Get the specified x64 program's version. 
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram" -Checkx64

#>

function Get-InstalledPrograms() {
    param(
         [Parameter(mandatory=$true)][string]$ComputerName,
         [Parameter(mandatory=$false)][ValidateSet("x64","x32","All")]$Arch,
         [Parameter(mandatory=$false)][string]$ProgramName
    )
    try {
        # Set some variables
        $Reg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $Reg64 = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        # Only check for the specified Installed Program.
        if ($ProgramName) {
            $Scriptblock = {
                param($ProgramName,$Reg,$Reg64,$Arch)
                # Check for x64 Installed Program.
                switch ($Arch) {
                    "x32" { Get-ItemProperty $Reg | Where-Object -Property DisplayName -EQ $ProgramName | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize }
                    "x64" { Get-ItemProperty $Reg64 | Where-Object -Property DisplayName -EQ $ProgramName | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize }
                    "All" {
                        Write-Host "--------x32--------"
                        Get-ItemProperty $Reg | Where-Object -Property DisplayName -EQ $ProgramName | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                        Write-Host "--------x64--------" 
                        Get-ItemProperty $Reg64 | Where-Object -Property DisplayName -EQ $ProgramName | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                    }
                }
            }
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $Scriptblock -ArgumentList @($ProgramName,$Reg,$Reg64,$Arch)
        }
        # Check for ALL Installed Programs.
        else {
            $Scriptblock = {
                param($Reg,$Reg64,$Arch)
               # Switch on Application Architecture.
                switch ($Arch) {
                    "x32" { Get-ItemProperty $Reg | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize }
                    "x64" { Get-ItemProperty $Reg64 | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize }
                    "All" {
                        Write-Host "--------x32--------"
                        Write-Host " "
                        Get-ItemProperty $Reg | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                        Write-Host "--------x64--------"
                        Write-Host " "
                        Get-ItemProperty $Reg64 | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                    }
                }
            }
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $Scriptblock -ArgumentList @($Reg,$Reg64,$Arch)
        }
    }
    catch {
        Write-Warning $_
    }
}