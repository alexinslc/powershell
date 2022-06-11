function Test-IsAwake() {
    param(
        [Parameter(Mandatory=$true)][ValidateSet("PowerShell","SMB","SSH")][string]$Type,
        [string]$ComputerName = $env:ComputerName,
        [int]$MaxTries = 30,
        [int]$RetryBuffer = 10,
        [int]$Buffer = 10,
        [string]$username,
        [string]$password
    )
    
    try {
        . .\Invoke-SSHCommand.ps1
        #inital wait while computer is maybe shutting down
        Start-Sleep -Seconds $Buffer
            
        $Count = 0
        Write-Host "Waiting for $Type on $ComputerName..."
        
        switch ($Type) 
        {
            "PowerShell" {
                $Service = (Get-Service -Name lanmanserver -ComputerName $ComputerName -ErrorAction Ignore)
                while (!($Service)) 
                {
                    Start-Sleep -Seconds $RetryBuffer
                    Clear-DnsClientCache
                    $Service = (Get-Service -Name lanmanserver -ComputerName $ComputerName -ErrorAction Ignore)
                    $Count++
                    if ($Count -ge $MaxTries) { throw "PowerShell on $ComputerName did not respond after $MaxTries attempts." }
                }
            }
            "SMB" {
                while (!(Test-Path -Path "\\$ComputerName\C$" )) 
                {
                    Start-Sleep -Seconds $RetryBuffer
                    Clear-DnsClientCache
                    $Count++
                    if ($Count -ge $MaxTries) { throw "An active share on $ComputerName could not be found after $MaxTries attempts." }
                }
            }
            "SSH" {
                #check to make sure putty is installed, thow an error if its not
                if (!(Test-Path -Path ".\PuttyFiles\plink.exe")) { throw "Putty is not installed on the server, Invoke-SSHCommand will not work." }
                #check to make sure a username and password are supplied
                if (!$username -or !$password) { throw "An SSH Test-IsAwake requires a username and password." }
                #use Invoke-SSHCommand to see if the server is online
                while (!(Invoke-SSHCommand -HostName $ComputerName -SSHCommand "df" -Username $username -Password $password -AcceptHostKey -ErrorAction SilentlyContinue))
                {
                    Start-Sleep -Seconds $RetryBuffer
                    $Count ++
                    if ($Count -ge $MaxTries) { throw "Could not SSH to $ComputerName after $MaxTries attempts." }
                }
            }
            default { throw "$Type is not a valid type of test." }
        }
        
        #Make sure things are really up (buffer)
        Start-Sleep -Seconds $Buffer
        Write-Host "...$Type is up on $ComputerName"
        return $true
    }
    catch {
        Write-Warning $_
        return $null
    }
}
