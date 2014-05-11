<#

.SYNOPSIS
This script will set the logon account for the specified service.

.DESCRIPTION
Using this script, an administrator can set the logon account for the specified service.

.PARAMETER ComputerName
This parameter is used to define the name of the Computer to run set-servicecreds on.

.PARAMETER Account
The account you will be setting the service to use. EX: Domain\User

.PARAMETER Password
The password for the account.

.PARAMETER Servicename
The service to set the credentials for.

.NOTES
Author:  Alex Lutz
Email:   alexinslc@gmail.com
Date:    04/25/2014
Version: 1.0

# Command and Parameters:
.\Set-ServiceCreds.ps1 -ComputerName "YOURCOMPUTER" -Account "DOMAIN\USER" -Password "YOURPASSWORD" -Servicename "VSS"


#>

function Set-ServiceCreds() {
  param(
      [string]$ComputerName = $env:ComputerName,
      [Parameter(Mandatory=$true)][string]$Account="domain\user",
      [Parameter(Mandatory=$true)][string]$Password="passsword",
      [Parameter(Mandatory=$true)][string]$Servicename = "servicename"
  )
 
 try { 
      # 
      $scriptblock = {
        if ( Get-Service $Servicename | Where Status -eq 'Running' ) 
        {
          Write-Warning "$Servicename is currently running, stopping service."
          $service="name='$Servicename'"
          $svc=gwmi win32_service -filter $service
          Stop-Service $Servicename
          $svc.change($null,$null,$null,$null,$null,$null,$Account,$Password,$null,$null,$null)
          Write-Warning "$Servicename has been set to use $Account to logon."
          Start-Service $Servicename
          Write-Warning "$Servicename starting..."
          if (Get-Service $Servicename | Where Status -eq 'Running')
          {
            Write-Warning "$Servicename started."
          } 
        } 
        else {
          $service="name='$Servicename'"
          $svc=gwmi win32_service -filter $service
          $svc.change($null,$null,$null,$null,$null,$null,$Account,$Password,$null,$null,$null)
          Write-Warning "$Servicename has been set to use $Account to logon."
        }
      }
      Invoke-Command -ComputerName $ComputerName  -ScriptBlock $scriptblock
  }   
  catch {
    Write-Warning "Error Occured on set-servicecreds.ps1"
    Write-Host "$_"
  }
}