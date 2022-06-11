<#
 
 TECHNICALLY, this is deprecated. If you're using PowerShell v4.0,
 Use Send-MailMessage instead: http://technet.microsoft.com/en-us/library/hh849925.aspx
 
 .SYNOPSIS
 Send an email via PowerShell.
 
 .DESCRIPTION
 Sends an email via PowerShell.
 
 .PARAMETER smtpServer
 Required, The SMTP relay server to use to send the email. 
 
 .PARAMETER ComputerName
 Optional, String: The name of the computer to include in the email. "YOURCOMPUTER"

 .PARAMETER from
 Optional, Who the email will be sent from. "no-reply@contoso.com"

 .PARAMETER to
 Optional, Who the email will be sent to. "jdoe@contoso.com"

 .PARAMETER subject
 Optional, The subject of the email message. "Test Mail Subject Line"

 .PARAMETER body
 Optional, The body of the email message. "Here is the body!"

 .EXAMPLE
 Send-Email -smtpServer "hub.contoso.com" -ComputerName $ComputerName -from "no-reply@contoso.com" -to "jdoe@contoso.com" -subject "Test Mail Subject" -body "Here is the body!"
 
  .NOTES
 Author: Alex Lutz
 Date: 5/13/2014

 #>
function Send-Email(){
    param(
        [Parameter(Mandatory=$true)][string]$smtpServer = "YOUREMAILSERVER.COM",
        [string]$ComputerName = $env:ComputerName,
        [string]$from = "from@yourdomain.com",
        [string]$to = "you@yourdomain.com",
        [string]$subject = "Default Send-Email Subject.",
        [string]$body = "Default Send-Email Body"
    )
    
    try {

        #Creating a Mail object
        $msg = new-object Net.Mail.MailMessage

        #Creating SMTP server object
        $smtp = new-object Net.Mail.SmtpClient($smtpServer)

        #Email structure 
        $msg.From = $from
        $msg.ReplyTo = "noreply@yourdomain.com"
        $msg.To.Add($to)
        $msg.subject = "Your Test Subject"
        $msg.body = "Your Test Body."

        #Sending email 
        $smtp.Send($msg)
  } catch {
        Write-Warning $_
  }
}
