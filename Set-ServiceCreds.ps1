<#

.SYNOPSIS
This script will set the logon account for the specified service.

.DESCRIPTION
Using this script, an administrator can set the logon account for the specified service.

.PARAMETER ComputerName
This parameter is used to define the name of the Computer to run Set-ServiceCreds on.

.PARAMETER Account
The account you will be setting the service to use. EX: Domain\User

.PARAMETER Password
The password for the account.

.PARAMETER Servicename
The service to set the credentials for. EX: Spooler, etc.

.NOTES
Author:  Alex Lutz
Email:   alexinslc@gmail.com

# Command and Parameters:
.\Set-ServiceCreds.ps1 -ComputerName "YOURCOMPUTER" -Account "DOMAIN\USER" -Password "YOURPASSWORD" -Servicename "YOURSERVICE"


#>

function Set-ServiceCreds() {
  param(
      [string]$ComputerName = $env:ComputerName,
      [Parameter(Mandatory=$true)][string]$Account,
      [Parameter(Mandatory=$true)][string]$Password,
      [Parameter(Mandatory=$true)][string]$ServiceName
  )
 
 try { 
      # 
      $scriptblock = {
        param(
                $ComputerName, $Account, $Password, $ServiceName
             )
        if ( Get-Service $ServiceName | Where Status -eq 'Running' ) 
        {
          Write-Warning "$ServiceName is currently running, stopping service."
          $service="name='$ServiceName'"
          $svc=gwmi win32_service -filter $service
          Stop-Service $ServiceName
          $svc.change($null,$null,$null,$null,$null,$null,$Account,$Password,$null,$null,$null)
          Write-Warning "$ServiceName has been set to use $Account to logon."
          Start-Service $ServiceName
          Write-Warning "$ServiceName starting..."
          if (Get-Service $ServiceName | Where Status -eq 'Running')
          {
            Write-Warning "$ServiceName started."
          } 
        } 
        else {
          $service="name='$ServiceName'"
          $svc=gwmi win32_service -filter $service
          $svc.change($null,$null,$null,$null,$null,$null,$Account,$Password,$null,$null,$null)
          Write-Warning "$ServiceName has been set to use $Account to logon."
        }
      }
      Invoke-Command -ComputerName $ComputerName  -ScriptBlock $scriptblock -ArgumentList @($ComputerName, $Account, $Password, $ServiceName)
  }    
  catch {
    Write-Warning "Error Occured on set-servicecreds.ps1"
    Write-Host "$_"
  }
}