function Test-IsAwake() {
    param(
        [Parameter(Mandatory=$true)][ValidateSet("PowerShell","SMB")][string]$Type,
        [string]$ComputerName = $env:ComputerName,
        [int]$MaxTries = 30,
        [int]$RetryBuffer = 10,
        [int]$Buffer = 20
    )
    
    try {

        #initial wait while computer is maybe shutting down
        Start-Sleep -Seconds $Buffer
            
        $Count = 0
        Write-Host "Waiting for $Type on $ComputerName..."
        
        switch ($Type) {
            "PowerShell" {
                while ((Get-Service -Name lanmanserver -ComputerName $ComputerName -ErrorAction Ignore).Status -ne "Running" ) {
                    Start-Sleep -Seconds $RetryBuffer
                    $Count++
                    if ($Count -ge $MaxTries) {
                        throw "PowerShell on $ComputerName did not respond after $MaxTries attempts."
                    }
                }
            }
            "SMB" {
                while (!(Test-Path -Path "\\$ComputerName\C$" )) {
                    Start-Sleep -Seconds $RetryBuffer
                    $Count++
                    if ($Count -ge $MaxTries) {
                        throw "An active share on $ComputerName could not be found after $MaxTries attempts."
                    }
                }
            }
        }
        
        #Make sure things are really up (buffer)
        Start-Sleep -Seconds $Buffer
        Write-Host "$ComputerName should be up now..."
    }
    catch {
        Write-Warning $_
        return $null
    }
}