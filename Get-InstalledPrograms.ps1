<# 
TODO: 
  1. Return results as objects instead of text. 

This script does the following: 
1. Finds Installed Programs 
2. Finds Installed Programs Versions.
3. Find a specific program's version that is Installed.
4. Find for x32/x64 Installed Programs.

.EXAMPLE
# Get a list of all x32 installed programs and their versions.
Get-InstalledPrograms -ComputerName "MyComputer" -Arch 32

# Get a list of all x64 installed programs and their versions.
Get-InstalledPrograms -ComputerName "MyComputer" -Arch x64

# Get a list of all installed programs on both architectures and their versions.
Get-InstalledPrograms -ComputerName "MyComputer" -Arch All

# Get the specified x32 program's version.
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram" -Arch x32

# Get the specified x64 program's version. 
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram" -Arch x64

# Get the specified program's version on both architectures.
Get-InstalledPrograms -ComputerName "MyComputer" -ProgramName "MyProgram" -Arch All

#>

function Get-InstalledPrograms() {
    param(
         [Parameter(mandatory=$true)][string]$ComputerName,
         [Parameter(mandatory=$true)][ValidateSet("x64","x32","All")]$Arch,
         [Parameter(mandatory=$false)][string]$ProgramName
    )
    try {
        # Set some variables
        $Reg = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $Reg64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        # Only check for the specified Installed Program.
        if ($ProgramName) {
            $Scriptblock = {
                param($ProgramName,$Reg,$Reg64,$Arch)
                $cmd = Get-ItemProperty $Reg | Where-Object -Property DisplayName -EQ $ProgramName | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                $cmd64 = Get-ItemProperty $Reg64 | Where-Object -Property DisplayName -EQ $ProgramName | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                switch ($Arch) {
                    "x32" { 
                        if ($cmd) { $cmd } else { Write-Warning ($ProgramName + " was not found with " + $Arch + " architecture.") } 
                    }
                    "x64" {
                        if ($cmd64) { $cmd64 } else { Write-Warning ($ProgramName + " was not found with " + $Arch + " architecture.") }
                    }
                    "All" {
                        Write-Host " "
                        Write-Host "---------------------x32 Apps---------------------"
                        if ($cmd) { $cmd } else { Write-Warning ($ProgramName + " was not found with " + $Arch + " architecture.") }
                        Write-Host "---------------------x64 Apps---------------------"
                        Write-Host " "
                        if ($cmd64) { $cmd64 } else { Write-Warning ($ProgramName + " was not found with " + $Arch + " architecture.") }
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
               $cmd = Get-ItemProperty $Reg | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
               $cmd64 = Get-ItemProperty $Reg64 | Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize
                switch ($Arch) {
                    "x32" { $cmd }
                    "x64" { $cmd64 }
                    "All" {
                        Write-Host " "
                        Write-Host "---------------------x32 Apps---------------------"
                        $cmd
                        Write-Host "---------------------x64 Apps---------------------"
                        Write-Host " "
                        $cmd64
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
