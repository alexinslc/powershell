# .\Send-Email -to "you@yourdomain.com" -from "from@yourdomain.com" -subject "Default Send-Email Subject" -body "Default Send-Email Body"

function Send-Email(){
    param(
        [Parameter(Mandatory=$true)][string]$smtp = "YOUREMAILSERVER.COM",
        [string]$ComputerName = $env:ComputerName,
        [string]$from = "from@yourdomain.com",
        [string]$to = "you@yourdomain.com",
        [string]$subject = "Default Send-Email Subject.",
        [string]$body = "Default Send-Email Body"
    )
    
    try {
        #SMTP server name
        $smtpServer = "YOUREMAILSERVER.COM"

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